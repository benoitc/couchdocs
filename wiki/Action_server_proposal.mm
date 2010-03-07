This page is an exploration of uses for the plugin API, so that we can get a better feel for the requirements it needs to meet. Most of the features described here do not exist, at least in the development trunk of CouchDB. If you are interested in helping with these efforts, please bring it up on the list or on the IRC channel.

To read or add other possible use cases for plugins, please see [[Plugin_API_use_cases]].

== The Search Interface ==

The _search interface already exists, and forwards any requests to the query server, which uses a search indexer to find matching documents, and returns them in a JSON structure which is passed back to the requesting client.

Example: 

A request formed like this
{{{
http://localhost:5984:/my-db/_search?query=search%20string
}}}
appears to the query server as a JSON string:
{{{
{"db":"my-db","query":"search string"}
}}}
The query server then responds with:
{{{
{"status":"ok","results":[...]}
}}}
where the results is any array, probably of doc-ids, so the client can fetch the documents, but could be an array the documents themselves. The requirement is that the _search query server will respond with valid JSON.

== The Action Interface ==

The _action interface is similar to search, in that it works with an external server through the JSON line based protocol. However, the _action server should have the option of returning any string to the requesting client, not just JSON. One could use the _action interface to serve XML directly from CouchDB. 

The _action interface is similar to the _views interface, in that it allows multiple servers in different langauges, and loads the functions to be run from CouchDB itself. For instance, a request to _action/mycontroller/myaction would load _controllers/mycontroller, and look in it's actions field, for a subfield called myaction. Myaction is then sent to the action server to be run with the query params.

Example:

A request formed like this
{{{
http://localhost:5984:/my-db/_action/translate/atom?doc=my-json-feed-document&indent=4
}}}
would load the "translate" controller from /my-db/_controllers/translate and determine it's language (just like views). Then it would find the appropriate action server (based on couch.ini) and deliver the request as a JSON line:
{{{
{"db":"my-db","action":"function(params, db){var doc = db.open(params.doc); ...do some E4X magic to make ATOM...; return atom;}","params":{"doc":"my-json-feed-document","indent":4}}
}}}
The action server then runs the function, and returns the result in an envelope:
{{{
{"status":"ok","result":{"body":"<?xml version='1.0' encoding='UTF-8'?>...","headers":{"Content-Type":"application/atom+xml"} } }
}}}
CouchDB uses the envelope to set headers, etc, and then serves the body without wrapping it in JSON.


=== What you could do with _action: ===

 * Create JSON documents that would ordinarily require multiple requests against CouchDB to produce. Handy if you have existing API clients that expect a particular format.
 * Translate CouchDB's JSON into XML feeds or HTML pages. 
 * By using an HTTP proxy to restrict remote client's access to all but the _action interface, the _action interface could enforce read and write access controls, as well as validations.
 * Everyone's favorite :) partial updates. 
    PUT /my-db/_action/helpers/updatefield?doc=my-doc-id&field=just-one-field
      my doc will have this one field updated.


=== Getting there from here: ===

To get these _action and _search working, the first step is standardizing the JSON line protocol. Currently the view server has a facility for logging, and sends it's results followed by a single newline. The query server requires the results to be in the form {"status":"ok","results":[...]}, followed by two newlines. Making these the same, and adding the ability for the query server to respond with statuses other than "ok" is the first step.

To get _action up and running, a function in the couch_httpd.erl will need to be added that passes the request into the action server (like the _search interface), and that allows the action server to respond with an envelope containing non-JSON data. Also, in order to support action servers in multiple langauges, the Erlang side will need to parse the request to find which controller is being called, load the controller document, and check it's language field (defaulting to Javascript) in otder to know which action server to invoke.

In order to allow for Action servers in more than one language, couch.ini would need fields for them, similar to the views. Here is an example couch.ini.

{{{

[Couch View Servers]

javascript=/usr/local/bin/couchjs /usr/local/share/couchdb/server/main.js

ruby=/usr/local/bin/rubyview


[Couch Search Server]

query=/Users/jchris/code/couchprojects/query_servers/xapian/couchdb-xapian-query

update=/Users/jchris/code/couchprojects/query_servers/xapian/couchdb-xapian-index


[Couch Action Servers]

javascript=/usr/local/bin/couchjs /usr/local/share/couchdb/server/action.js

ruby=/usr/local/bin/rubyaction

}}}
