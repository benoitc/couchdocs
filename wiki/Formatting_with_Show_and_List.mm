Note that this is only available in CouchDB 0.9 or newer — The API might still change.

The basics of formatting documents using `show` and `list` functions. These functions convert documents and views, respectively, into non-JSON formats. The rows of each view are processed individually, which keeps long lists from becoming memory hogs.

They are designed to be cacheable. CouchDB handles generating Etags for show and list responses.

Show and list functions are side effect free and idempotent. They can not make additional HTTP requests against CouchDB. Their purpose is to render JSON documents in other formats.

== Showing Documents ==
Show functions are stored in your design document, under the `shows` key. Here's an example set of show functions:

{{{
{
"_id" : "_design/examples",
"shows" : {
  "posts" : "function(doc, req) {... return responseObject;}",
  "people" : "function(doc, req) { ... }"
}
}}}
Assuming these functions were in a design document named "`examples`" in a database named "`db`", they could be queried like this:

{{{
GET /db/_design/examples/_show/posts/somedocid

GET /db/_design/examples/_show/people/otherdocid

GET /db/_design/examples/_show/people/otherdocid?format=xml&details=true
}}}
The `show` function is run with two arguments. The first is the document corresponding to the requested `docid`, and the second describes the HTTP request's query string, Accept headers, and other per-request information. The function returns an object describing its HTTP response.

Example `show` function

{{{
function(doc, req) {
  return {
    body: "Hello World"
  }
}
}}}
If the show function is queried with document id that has no corresponding document in the database, `doc` is `null` and the submitted document shows up in `req.docId`. This is useful for creating new documents with a name, like in a wiki.

If the show function is queried without a document id at all, doc is `null` and `req.docId` is `null`. This is useful for creating new documents where the user specifies the new document id in a user interface, like in a CMS.

{{{
function(doc, req) {
  if(doc) {
    // regular doc display logic
  } else { // document not found
    if(req.docId) {
      // handle unused doc id
    } else {
      // handle unspecified doc id
    }
  }
}
}}}
The request and response objects are of the same format used by `_external` functions, as documented in ExternalProcesses.

== Listing Views with couchdb 0.9 ==
List functions are stored under the `lists` key of a design document. Here's an example design doc with list functions, in addition to views:

{{{
{
"_id" : "_design/examples",
"views" {
  "posts-by-date" : "function(doc){...}",
  "posts-by-tag" : "function(doc){...}",
  "people-by-name" : "function(doc) {...}"
},
"lists" : {
  "index-posts" : "function(head, row, req, row_info) {...}",
  "browse-people" : "function(head, row, req, row_info) { ... }"
}
}}}
These lists are run by querying URLs like:

{{{
GET /db/_design/examples/_list/index-posts/posts-by-date?descending=true&limit=10

GET /db/_design/examples/_list/index-posts/posts-by-tag?key="howto"

GET /db/_design/examples/_list/browse-people/people-by-name?startkey=["a"]&limit=10
}}}
[As above, we assume the database is named "db" and the design doc "examples".]

Couchdb 0.10 supports an alternate form of URL which allows you to use a list function and a view from different design documents.  This is particularly useful when you want to use a different language for the list and for the view.  These URLs are very similar to the above examples, but instead of the tail portion being the name of the view, the tail portion can consist of two parts - a design doc name and the name of the view in that second document.  For example:

{{{
GET /db/_design/examples/_list/index-posts/other_ddoc/posts-by-tag?key="howto"
}}}
[As above, we assume the database is named "db" and the design doc with the list is named "examples", while the design doc with the view is "other_ddoc".]

A list function has a more interesting signature, as it is passed the head of the view on first invocation, then each row in turn, then called one more time for the tail of the view. The function should check the `head` and `row` parameters to identify which state it's being called in; the sequence of calls to `listfn`, for a view with three rows, would look like:

{{{
  listfn(head, null,    req, null    );  // Before the first row: head is non-null
  listfn(null, rows[0], req, row_info);  // First row
  listfn(null, rows[1], req, row_info);  // Subsequent rows...
  listfn(null, rows[2], req, row_info);
  listfn(null, null,    req, row_info);  // After last row: row=null
}}}
The `head` parameter -- which is only passed into the first call -- contains an object with information about the view that is to be iterated over. It's much like the response object returned from a view query in the CouchDB JavaScript API; useful properties include `total_rows` and `offset`.

The `row_info` parameter contains an object with information about the iteration state. Its properties include:

 * `row_number` (the current row number)
 * `first_key` (the first key of the view to be listed)
 * `prev_key` (the key of the row in the previous iteration)

Example list function:

{{{
function(head, row, req, row_info) {
  if (head) {
    return "<p>head: "+JSON.stringify(head)+"</p><ul>";
  } else if (row) {
    return "<li>"+JSON.stringify(row)+"</li>";
  } else {
    return "</ul><h4>the tail</h4>"
  }
}
}}}
== Listing Views with couchdb 0.10 ==
The list API has changed significantly from 0.9 to 0.10.

Example `list` function

{{{
function(head, req){
  var row;
  while(row = getRow()) {
    send(row.value);
  }
}
}}}
== Other Fun Things ==
=== Stopping iteration in a `_list` ===
If you want to terminate iteration of a `_list` early you can return a `{stop: true}` JSON object from any of the calls to the function that include a row object.

=== Sending a Redirect ===
In the call to `_show` or when `_list` is called with a head object you can control the headers and status code sent to the client. An example of this would be to send a redirect notification.

{{{
function(doc)
{
    return {"code": 302, "body": "See other", "headers": {"Location": "/"}};
}
}}}
For CouchDB version 0.9:

{{{
function(head, row, req, row_info) {
  if (head) {
    return {"code": 302, "body": "See other", "headers": {"Location": "/"}};
  } else if (row) {
    return {stop: true};
  } else {
    return "."
  }
}
}}}
For CouchDB version 0.10:

{{{
function(head, req) {
  start({"code": 302, "headers": {"Location": "/"}});
}
}}}
=== Specifying Content-Type Response Header ===
There are two ways to deal with a content-type header in the response to a show or list request. The first way is to specify the content type as a member of the _show function's response object:

{{{
return {
   "headers" : {"Content-Type" : "application/xml"},
   "body" : new XML('<xml><node foo="bar"/></xml>')
}
}}}
=== Responding to different Content-Type Request Headers ===
The second way to deal with content-type headers is to rely on some global helper methods defined by CouchDB's ''<couchdb>/server/main.js'' file. The ''registerType'' method lets you register a type key with one or more content-type strings. Please refer to the ''main.js'' file to see content-types registered by default.

{{{
registerType("foo", "application/foo", "application/x-foo");
}}}
The other global helper method for handling varying Content-Type headers is ''respondWith''. This helper method allows you to specify different response objects depending on the type key that corresponds to the content-type request header. The first argument is the request object, and the second argument is a key-value object that maps type keys to functions. Each function is expected to return an HTTP response object customized for the requested Content-Type.

{{{
//... in your show function...
return respondWith(req, {
         html : function() {
           return {
             body:"Ha ha, you said \"" + doc.word + "\"."
           };
         },
         foo : function() {
           return {
             body: "foofoo"
           };
         },
         fallback : "html"
       });
}}}
Since CouchDB 0.10.0 there is no responseWith-Method anymore. Please use the provides Method instead. For CouchDB version 0.10:

{{{
//... in your show function...
provides("html", function() {return "<b>doc.title</b>";});
provides("xml", function() {return "<text class="title">doc.title</text>";});
}}}
Hopefully this is enough to get started. For a more complete set of examples, see the CouchDB test suite, especially show_documents.js and list_views.js
