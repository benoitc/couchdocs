I got an email today explaining an approach to stats logging that quite suprised me in terms of its complete obviousness (that I had failed to see) and its complete awesomeness.

The basic idea: pre-reduce. The use case as described below is for stats reporting and the idea is that after we've figured out to use _bulk_docs and buffer some number or time period of log data before inserting, we can go one step further and pre-reduce that data down into a single doc for insertion. I can already see people implementing support via their favorite language binding support to even use the same map/reduce functions from CouchDB as a pre-processor for creating summary docs on input.

Anyway, I thought this would make a good candidate for the How-to series of wiki pages so here it is. Forgive the Mysql on CouchDB wiki, but I didn't want to edit the original until after it'd been read and discussed a bit. Then we can delete the reference and pretend it never happened.

This is via apokalyptik on #couchdb:

A common thing people think of when they read how CouchDB works is "STATS CRUNCHING, THAT'LL WORK PERFECTLY!"  I know that thats the first thing I thought.  And it will work, but you're probably already thinking about doing it the hard way (read: in a way that won't.)  You're thinking that you'll dump a couple hundred or thousand docs a second into Couch and let map/reduce magically make your cares all disappear (and ponies... map/reduce should make ponies!)  
But a few hundred thousand documents into the process and it's going to fall over in a big way leaving you pretty jaded and upset at CouchDB.  Well, since CouchDB is all about approaching problems from a different angle, lets try looking at the problem from a different angle.  
First lets drop some assumptions that you're already likely to be working off of.

#1 this is a collect and report model and not a realtime view

#2 this kind of data almost NEVER EVER actually really has to be accessible in absolute realtime

#3 you do not need one document for every (whatever) you're recording

For assumption #1 You're thinking that map/reduce is going to go and whiz-bang through all your data at the speed of light, and distill a terabyte of data down to a single page report in a second... maybe two tops.  We'll thats not realistic.  And besides CouchDB views are only updated on access (remember?) and the reduces for a single view run serially and not in parallel (remember?) so you'll be waiting for that... one... report... for... ever because you have 2^99 documents to process since you looked last.  Which leads to...

Assumption #2.  You think that your data needs to be available REALTIME.  After all banks do it that way, right? Yea, think again... They don't (and can't.)  They learned a long time ago what you're just starting to learn right now:  A little delay is OK.  Because how many times do you check your bank balance per day? Lets pretend it was a thousand times per day (O.C.D. much?) Thats still only once every 85ish seconds... not exactly realtime. If you cant let go of this idea then you need to bake your own solution, because this isn't going to work for you.

If you're still reading I'll assume you've decided that whole "REALTIME" thing was a bad idea (or at least you're wiling to humor me while evaluating the rest of what I've got to say.)  At this point it should be pretty obvious that if you don't actually need 1000 updates per second that you probably don't need 1000 documents per second either. DING DING DING we have a winner.

Ok, now that we have some assumptions out of the way lets distill the problem down into a cute cuddly little example.  We all know that most examples are oversimplifications of real world problems and this one is no different.  
Lets say you're running a website, and you want to track the time it takes to render pages.  You have n types of pages being rendered, and in n languages, and on n servers.  and you want to be able to take a look at the average render time by language, page type, or server.  So... Every pagerender you get an insert into (insert traditional rdbms or kv store with increment function here) like this:

 INSERT INTO `rendertimes` (`when`,`type`,`server`,`language`,`views`,`time`)
 VALUES('yyyy-mm-dd hh:mm:00', '$type', '$server', '$lang', 1, 0.4)
 ON DUPLICATE KEY UPDATE `views`=`views`+1, `time`=`time`+0.4

First off this does the job of aggregating the data quite a bit.  Then you could compress the data even farther down into a single document per minute with the general form of.

document.time = n
document[lang1] = { time: x, views: y }
document[type1] = { time: x, views: y }
document[server1] = { time: x, views: y }
[...]

you would then insert this document into couchdb and end up with 14,400 documents per day rather than 86,400,000 If your data is viewed hourly you could drop it down to 24 docs per day
