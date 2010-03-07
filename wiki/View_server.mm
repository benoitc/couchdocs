A simple introduction to the CouchDB view server.

== The View Server ==
CouchDB delegates computation of [[Views]] to external query servers. It communicates with them over standard input/output, using a very simple, line-based protocol. The default query server is written in Javascript, running via Mozilla !SpiderMonkey. You can use other languages by setting a MIME type in the ''language'' property of a design document or the Content-Type header of a temporary view. Design documents that do not specify a ''language'' property are assumed to be of type ''javascript'', as are ad hoc queries that are ''POST''ed to ''_temp_view'' without a ''Content-Type'' header.

To register query servers with CouchDB, add a line for each server to ''local.ini''. The basic syntax is:

{{{
[query_servers]
python=/usr/bin/couchpy
ruby=/wherever/couchobject/bin/couch_ruby_view_requestor
}}}
== Basic API ==
This shows you how the view server implementation for your language should behave. If in doubt, look at the ''share/server/main.js'' file in your CouchDB source tree for reference.

CouchDB launches the view server and starts sending commands. The server responds according to its evaluation of the commands. There are only three commands the view server needs to understand.

=== reset ===
This resets the state of the view server and makes it forget all previous input. If applicable, this is the point to run garbage collection.

CouchDB sends:

{{{
["reset"]\n
}}}
The view server responds:

{{{
true\n
}}}
=== add_fun ===
When creating a view, the view server gets sent the view function for evaluation. The view server should parse/compile/evaluate the function he receives to make it callable later. If this fails, the view server returns an error. CouchDB might store several functions before sending in any actual documents.

CouchDB sends:

{{{
["add_fun", "function(doc) { if(doc.score > 50) emit(null, {"player_name": doc.name}); }"]\n
}}}
When the view server can evaluate the function and make it callable, it returns:

{{{
true\n
}}}
If not:

{{{
{"error": "some_error_code", "reason": "error message"}\n
}}}
=== map_doc ===
When the view function is stored in the view server, CouchDB starts sending in all the documents in the database, one at a time. The view server calls the previously stored functions one after another with the document and stores its result. When all functions have been called, the result is returned as a JSON string.

CouchDB sends:

{{{
["map_doc", {"_id":"8877AFF9789988EE","_rev":"3-235256484","name":"John Smith","score": 60}]\n
}}}
If the function above is the only function stored, the views server answers:

{{{
[[[null, {"player_name":"John Smith"}]]]\n
}}}
That is, an array with the result for every function for the given document.

If a document is to be excluded from the View, the array should be empty.

CouchDB sends:

{{{
["map_doc", {"_id":"9590AEB4585637FE","_rev":"1-674684684","name":"Jane Parker","score": 43}]\n
}}}
The views server answers:

{{{
[[[]]]\n
}}}
=== reduce ===
If the view has a {{{reduce}}} function defined, CouchDB will enter into the reduce phase. The view server will receive a list of reduce functions and some map results on which it can apply them. The map results are given in the form {{{[[key, id-of-doc], value]}}}.

CouchDB sends:

{{{
["reduce",["function(k, v) { return sum(v); }"],[[[1,"699b524273605d5d3e9d4fd0ff2cb272"],10],[[2,"c081d0f69c13d2ce2050d684c7ba2843"],20],[[null,"foobar"],3]]]
}}}
@@ Is there any guarantee on the ordering? The example appears unordered (null trailing)

The view-server answers:

{{{
[true, [33]]
}}}
Note that even though the view server receives the map results in the form {{{[[key, id-of-doc], value]}}}, the function may receive them in a different form. For example, the JavaScript view-server applies functions on the list of keys and the list of values.

=== rereduce ===
When building a view, CouchDB will apply the {{{reduce}}} step directly to the output of the map step and the {{{rereduce}}} step to the output of a previous {{{reduce}}} step.

CouchDB will send a list of values, with no keys or document ids, to the rereduce step.

CouchDB sends:

{{{
["rereduce",["function(k, v, r) { return sum(v); }"],[33,55,66]]
}}}
The view-server answers:

{{{
[true, [154]]
}}}
=== log ===
At any time, the view-server may send some information that will be saved in CouchDB's log file. This is done by sending a special object with just one field, {{{log}}}, on a separate line.

The view-server sends

{{{
["log", "A kuku!"]
}}}
CouchDB answers nothing.

The following line will appear in {{{couch.log}}}, mutatis mutandum:

{{{
[Sun, 22 Jun 2008 22:51:25 GMT] [info] [<0.72.0>] Query Server Log Message: A kuku!
}}}
If you use the JavaScript view-server, you achieve this effect by calling the function {{{log}}} in your view. To do the same thing in ClCouch, call {{{logit}}}.

== Implementations ==
 * [[http://svn.apache.org/repos/asf/couchdb/trunk/share/server/|JavaScript]] (CouchDB native)
 * [[http://common-lisp.net/cgi-bin/darcsweb/darcsweb.cgi?r=submarine-cl-couch;a=summary|Common Lisp]]
 * [[http://jan.prima.de/~jan/plok/archives/93-CouchDb-Views-with-PHP.html|PHP]]
 * [[http://theexciter.com/articles/couchdb-views-in-ruby-instead-of-javascript.html|Ruby]] [[http://github.com/candlerb/couchdb_ruby_view|(fork)]]
 * [[http://couchdb-python.googlecode.com/svn/trunk/couchdb/view.py|Python]]
 * [[http://github.com/mmcdanie/erlview/tree/master|Erlang]]
 * [[http://github.com/tashafa/clutch/|Clojure]]
 * [[http://search.cpan.org/~hdp/CouchDB-View-0.003/lib/CouchDB/View/Server.pm|Perl]]
 * [[http://chicken.wiki.br/eggref/4/couchdb-view-server|Chicken Scheme]]
