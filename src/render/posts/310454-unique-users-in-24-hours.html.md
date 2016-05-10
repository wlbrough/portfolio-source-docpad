---
layout: "post"
date: 2016-04-22
hasCode: false
title: "310,454 Unique Users in 24 Hours"
---

tl;dr — Frustration with selecting a programming language turned into a goofy ass website. That goofy ass website got a ton of traffic and is (totally unexpectedly) bringing in paying work.

## The Origins
I’d been endlessly drifting and unable to find direction on what programming language to learn next. Reading documentation, wikipedia pages, and blogger rants wasn’t getting me anywhere. The selection of a programming language is as much of a subjective decision as it was objective. With the information gathered growing equivalently to my frustration, I decided to throw together a tongue-in-cheek decision tree for others facing the same problem.

I built [“What f#&king programming language should I use?”](http://www.wfplsiu.com) in an attempt to answer that question for myself. I work with JavaScript (client-side and node) and Python and I was looking to branch out and try something new. For the record, I still haven’t made up my mind because I got sidetracked working on this goofy ass project.

It took 4 hours to put together the site. Most of that time was spent writing the content and not code, which you can see pretty clearly if you take a look at the [app.js](http://www.wfplsiu.com/app.js) file. I worked on it over one weekend in the mornings while my kids were still asleep and there was a little time to do some focused work.

The final product was mildly humorous so I shared it with a few friends and got a surprisingly positive response. Honestly, I thought some of the writing was shit, but then again they’re my friends so no one was going to tear me apart. Based on the response from those friends I thought some other people in the dev community would get a kick out of it so I decided to put it up on reddit.

I posted the link on [/r/InternetIsBeautiful](https://redd.it/4bs5jq) figuring that was probably the best audience for the site. The link was posted around noon (EST) and went back to work not expecting much to come of it. I looked at Google Analytics an hour later and there were around 3,500 active users on the site!!! My first thought was “Holy shit, this is awesome!” followed quickly by “Holy shit, hopefully the site doesn’t crash!” Fortunately, the site never crashed. A big thanks goes out to [CloudFlare](https://www.cloudflare.com) (not an affiliate link) for keeping things running.

## The Results

The post hit the front page at 5:50PM EST. At that point there were around 6,000 active users on the site and traffic held steady at over 5,000 active users until just before 8:00 pm when a mod took down the post claiming “Not unique” content. I tried a soft appeal, but it didn’t go anywhere. Even after they took it down, the site was still seeing around 3,000 active users based on shares on Facebook, Twitter, and elsewhere. All told, the original post got 4069 upvotes and had 1187 comments. I tried to reply to as many comments as possible, but I got totally overwhelmed by the volume.

![reddit not unique message - sad panda](/assets/img/not-unique.png)

I only posted the one link on r/InternetIsBeautiful, but the site got a ton of social shares. It was cross posted in r/programmerhumor, r/programmingcirclejerk, r/hackernews, and r/momsbox. The post in r/programmerhumor has 2,234 upvotes and 291 comments. The site also got 1,083 shares on Facebook, 55 +1s on Google+, 103 shares on LinkedIn, and 1 lonely share on Pinterest (thank you sharedcount.com!). The exact number of Twitter shares isn’t available because of their API changes, but I counted over 300.

On the day of the post, the site had 324,074 sessions and 310,454 unique visitors. Average session duration was 0:35 and 95.8% were new sessions. Around half the traffic came from reddit and the rest came from social shares and direct links. The cryptic email form that you filled out got 364 submissions, of which around 220 were valid emails. Most of the rest were some variation of ‘fuck@you.com’. It was shocking to see any emails come in based on the anti-value proposition on the capture site. It was even more shocking to see emails from people at some serious businesses.

![analytics image - lots of users](/assets/img/analytics.png)

In the days following, some updates were made to the site based on user requests. By far the most popular request was a “Back” button to go back one step so they weren’t required to start from the beginning every time. That was the first update. Permalinks and social sharing were added later.

The site has received another 50,000+ visitors since the day of the original post, which feels more impressive than the initial burst. It’s still averaging around 500 users a day.

## The Aftermath

I didn’t have a portfolio page or anything set up to take advantage of the traffic. I was just out to make a couple of people laugh and it totally blew up. Within a week, my portfolio site was up but I had missed most of the traffic by that point. Despite my complete lack of preparation or motive to profit from making the site, some cool stuff has come directly as a result of the project.

* Met someone that knew of me through the site, no financial benefit, but a totally surreal experience
* Introduction to Chris Stoikos of [Dollar Beard Club](http://www.dollarbeardclub.com) fame, currently talking about a project
* Contacted by a company building a SaaS project with some potential project work
* Contacted by a local company about a full-time job

All of that from a dumb idea that was unnecessarily over-executed.

## Tech specs for the nerds
* [KnockoutJS](http://knockoutjs.com)
* [Twitter Bootstrap](http://getbootstrap.com) (CSS only)
* Data is stored as a simple JSON object in app.js
* Site hosted on [Nginx](http://www.nginx.com) running on a small gear on [OpenShift by RedHat](https://www.openshift.com)
* [CloudFlare CDN](https://www.cloudflare.com) (thank you baby Jesus)
* [Mautic](http://www.mautic.com) for email collection
* [Google Analytics](https://analytics.google.com/analytics/)

This article, plus some additional commentary, is also posted on [Ghost Influence](http://ghostinfluence.com/4-hours-profane-coding-attracted-310454-unique-users-24-hours/).
