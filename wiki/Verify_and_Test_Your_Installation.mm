=== Using the Couchdb init.d script ===
Run this command:
{{{
$ sudo /etc/init.d/couchdb status
}}}

You should see a message like this:
{{{
Apache CouchDB is running as process 15102, time to relax.
}}}

=== Using curl ===
Use { { {curl} } } to access your Couchdb instance. It will bind to { { {localhost} } } on port '''5984''' by default.

Run this command:
{{{
$ curl http://localhost:5984/
}}}

You should see a message like this (the version may differ):
{{{
{"couchdb":"Welcome","version":"0.9.0a729754-incubating","start_time":"Sat, 03 Jan 2009 16:41:48 GMT"}
}}}

=== Starting Couchdb ===

Start Couchdb by issuing the following command:
{{{
$ sudo /etc/init.d/couchdb start
}}}

You should see this message:
{{{
Apache CouchDB has started. Time to relax.
}}}

Open Futon and browse your Couchdb database: 
http://localhost:5984/_utils/

Read more about Futon in [[Getting_started_with_Futon]].
