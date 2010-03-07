= Couch DB Quick Start =

(Tested with 0.9.0 on [[http://www.ubuntu/org'|Ubuntu]], wikified from my [[http://www.jroller.com/robertburrelldonkin/entry/couchdb_in_15_minutes|blog]])

== Install (very basic) ==
1. [[http://couchdb.apache.org/downloads.html|Download]], unpackage and cd to the directory
 1. Read the README then follow the instructions (for Unbuntu, use [[http://dbpedia.org/page/Debian|Debian]])
 1. (Ubuntu) Remember to apt-get the require libraries before building
 1. Start Couch from the command line and check everything looks good

== Create a new Database ==
1. Create new database
 1. Browse http://localhost:5984/_utils/
 1. Click "Create Database"
 1. Enter "example"

== "Hello, World!" (of course) ==
1. Now for "Hello, World!"
 1. Couch is RESTful so you'll need a HTTP client. These instructions are for telnet (those who dislike the command line could use [[http://localhost:5984/_utils/database.html?example/_design_docs|futon]] or, if you're using Mac OS X, [[http://ditchnet.org/httpclient/|HTTPClient]]).
 1. Type: {{{$ telnet localhost 5984}}}
 1. Response: {{{
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.}}}
 1. CutNPaste: {{{
PUT /example/some_doc_id HTTP/1.0
Content-Length: 29
Content-Type: application/json

{"greetings":"Hello, World!"} }}}
 1. Response: {{{
HTTP/1.0 201 Created
Server: CouchDB/0.9.0 (Erlang OTP/R12B)
Etag: "1-518824332"
Date: Wed, 24 Jun 2009 13:33:11 GMT
Content-Type: text/plain;charset=utf-8
Content-Length: 51
Cache-Control: must-revalidate

{"ok":true,"id":"some_doc_id","rev":"1-518824332"}
Connection closed by foreign host.}}}
 1. Browse http://localhost:5984/example/some_doc_id to see {{{
{"_id":"some_doc_id","_rev":"1-518824332","greetings":"Hello, World!"} }}}

== Document creation recap ==
1.Huh?
 1. Couch is a RESTful so to create a document PUT (as above) or POST
 1. Couch uses a JSON API. So PUT a document as JSON and GET results as JSON
 1. To view the data, use a view (Doh!)
 1. Each document has a unique "_id"
 1. Each document is versioned with a "_rev"

== Create a View and...view it ==
1. Relax and take a look at the view
 1. (Well, actually I'm going to use a "show" but it'll demonstrate the flavour)
 1. Again {{{
$ telnet localhost 5984
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
PUT /example/_design/render HTTP/1.0
Content-Length: 79
Content-Type: application/json

{"shows" : {"salute" : "function(doc, req) {return {body: doc.greetings}}"}} }}}
 1. Response: {{{
HTTP/1.0 201 Created
Server: CouchDB/0.9.0 (Erlang OTP/R12B)
Etag: "1-2041852709"
Date: Wed, 01 Jul 2009 06:08:59 GMT
Content-Type: text/plain;charset=utf-8
Content-Length: 55
Cache-Control: must-revalidate

{"ok":true,"id":"_design/render","rev":"1-2041852709"}
Connection closed by foreign host. }}}
 1. Browse http://localhost:5984/example/_design/render/_show/salute/some_doc_id

== Summary of what a View is and does ==
1. What Just Happened?
 1. A "show" directly renders a document using JavaScript
 1. "Shows" are added to a design document (in this case "/_design/render" via the "shows" property)
 1. "body: doc.greetings" fills the response body with the "greetings" property
 1. GET _design/render/_show/salute/some_doc_id to use the "salute" show to render the "some_doc_id" document added above
