---
layout: "default"
date: 2015-10-01
hasCode: true
---

## Setting up mockgoose with angular-fullstack

I’m using the Yeoman angular-fullstack generator for a MEAN project that I’m
working on and I wanted to be able to mock the database connection for quicker
testing. I found [mockgoose](https://github.com/mccormicka/Mockgoose), but I
wasn’t clear on how to implement it in this environment. Without further ado,
here are the steps.

First, install mockgoose with npm:

```bash
npm install mockgoose --save-dev
```

Open the file {project-base}/server/app.js and find the block starting with **//
Connect to database**:

```javascript
mongoose.connect(config.mongo.uri, config.mongo.options);
mongoose.connection.on(‘error’, function(err) {
  console.error(‘MongoDB connection error: ‘ + err);
  process.exit(-1);
  }
);
```

Edit this block to the following:

```javascript
if (process.env.NODE_ENV == ‘test’) {
  var mockgoose = require(‘mockgoose’)(mongoose);
  mongoose.connect(config.mongo.uri);
} else {
  mongoose.connect(config.mongo.uri, config.mongo.options);
  mongoose.connection.on(‘error’, function(err) {
    console.error(‘MongoDB connection error: ‘ + err);
    process.exit(-1);
    }
  );
}
```

That’s it! I’m working on a micro cloud instance, so changing to mockgoose took
my test run time from 88 seconds to 2.3 seconds.
