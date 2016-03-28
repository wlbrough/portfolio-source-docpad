---
layout: "post"
date: 2015-10-04
hasCode: true
title: "Testing with authenticated routes in Express"
---

I recently had a problem. I’m working on an Express API project and writing
tests with Mocha/Should/Supertest. Everything was going great and all of my
tests were passing and then I added authentication (using Passport) to my
routes.

As expected, my tests were now failing. Not as expected was the difficulty in
getting the tests back to passing. I (eventually) found a [Github
Gist](https://gist.github.com/joaoneto/5152248) that got me most of the way
there, but I couldn’t get it to work. As it turns out, it was just a small tweak
that allowed me to get back to passing tests.

With great appreciation to [joaoneto](https://gist.github.com/joaoneto), here’s
how to get passing tests with authenticated routes in Express.

To set the stage I’ll present an arbitrary test that I will base the remainder
of the code on.

```javascript
'use strict';
var should = require('should');
var app = require('../../app');
var request = require('supertest')(app);
describe('useless api endpoint', function() {
  it('posts an object', function(done) {
    request.post('/api/useless')
      .send({ property: value })
      .expect(201)
      .end(function(err, res) {
        should(err).equal(null);
        done()
      });
  });
});
```

My first attempt, before finding the Gist, was to simply use supertest to post
to the login endpoint and go about my business assuming the session data would
carry.

```javascript
before(function(done) {
  request.post(‘/auth/local’)
    .send({
      email: ‘test@user.com’,
      password: ‘password’
    })
    .end(function(err, res) {
      if (err) throw err;
      done();
    });
});
```

Unfortunately, the cookie data didn’t persist and the call to the authenticated
route returned an error. Using the Gist, I added a `token` variable that would
carry the token returned from logging in. But adding the token to req.cookies
wasn’t getting the desired result. The Gist is from three years ago, so I’m
assuming my struggle was the result of a change to supertest’s codebase. I
eventually figured out that I could pass the token with supertest’s query
method.

```javascript
'use strict';
var should = require('should');
var app = require('../../app');
var request = require('supertest')(app);
describe('useless api endpoint', function() {
  var token;
  before(function(done) {
    request.post(‘/auth/local’)
      .send({
        email: ‘test@user.com’,
        password: ‘password’
      })
      .end(function(err, res) {
        if (err) throw err;
        token = { access_token: res.body.token }
        done();
      });
  });

  it('posts an object', function(done) {
    request.post('/api/useless')
      .send({ property: value })
      .query(token)
      .expect(201)
      .end(function(err, res) {
        should(err).equal(null);
        done()
      });
  });
});
```

FWIW, I tried a lot of other solutions including supertest-session and some
really hack-y stuff before I landed on this. Hopefully I can save at least one
other person from going down the rabbit hole for 4–5 hours like I did.
