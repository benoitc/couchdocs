Getting started with !JavaScript and the CouchDB API.

== Simple Wrapper ==

There is a simple !JavaScript wrapper around CouchDB included in the distribution. When you install the server it is installed as http://localhost:5984/_utils/script/couch.js. You can see examples of its use in ''couch_tests.js'':

{{{
 var nc = {_id:"NC", cities:["Charlotte", "Raleigh"]};
 var ma = {_id:"MA", cities:["Boston", "Lowell", "Worcester", "Cambridge", "Springfield"]};
 var fl = {_id:"FL", cities:["Miami", "Tampa", "Orlando", "Springfield"]};

 db.save(nc);
 db.save(ma);
 db.save(fl);

 ...

 var nc_cities = db.open('NC').cities;
}}}

Obviously the ''couch.js'' API is by no means final since CouchDB itself is still in flux.

== Rolling Your Own ==

CouchDB speaks JSON. JSON means !JavaScript Object Notation. CouchDB also speaks Plain Old HTTP, so getting going with !JavaScript is a walk in the park with the XML!HttpRequest object:

{{{
// instantiate a new XMLHttpRequest object
var req = new XMLHttpRequest()
// Open a GET request to "/all_dbs"
req.open("GET", "/_all_dbs")
// Send nothing as the request body
req.send("")
// Get the response
req.responseText
["some_database", "another_database"]
}}}

Going from here is just a matter using the normal CouchDB HttpRestApi to get what you want.

There are numerous javascript libraries out there that wraps up both XML!HttpRequest and JSON in possibly nicer APIs, including:

  * [[http://www.prototypejs.org/|Prototype]]
  * [[http://jquery.com/|JQuery]]
  * [[http://dojotoolkit.org/|Dojo]]
  * [[http://moofx.mad4milk.net/|Moo]]
