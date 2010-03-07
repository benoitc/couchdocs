= Using plain Rebol3 =

This is how you can use CouchDB from plain Rebol3 (which is currently in public Alpha).

And here you can get Rebol3 [[http://www.rebol.com/r3/downloads.html|Rebol3 Alpha download]]

== How to read data from CouchDB using Rebol ==

{{{
to-string read http://localhost:5984/db2/id
}}}

== How to write data to CouchDB using Rebol ==

{{{
to-string write http://localhost:5984/db2/id json-data
}}}

== How to create a new CouchDB Database using Rebol ==

{{{
to-string write http://localhost:5984/db2 [PUT [] ""]
}}}

== A complete console session ==

{{{
>> to-string write http://localhost:5984/hohtest [PUT]
== {{"ok":true}}

>> to-string write http://localhost:5984/hohtest {{"_id":"hello","data":"Hello World!"}}
== {{"ok":true,"id":"hello","rev":"1-a67aaac28adabcdd8d0718187741d49d"}}

>> to-string read http://localhost:5984/hohtest/hello
== {{"_id":"hello","_rev":"1-a67aaac28adabcdd8d0718187741d49d","data":"Hello World!"}}

>> to-string write http://localhost:5984/hohtest [DELETE]
== {{"ok":true}}
}}}

BTW, to-string is only needed to make it human readable. Without it, the return values would be binary.


= A Rebol3 module =

And here you can get a Rebol3 module, to make it even easier. especially working with json data.

[[http://www.rebol.org/view-script.r?script=couchdb3.r|couchdb3.r on rebol.org]]
