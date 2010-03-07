'''NOTE:''' Action.js has been removed from CouchDB trunk as it is more than we want to support right now. That said, it is still a good way to learn how to write your own external servers. For the time being, action.js can be found here: http://svn.apache.org/viewvc/couchdb/trunk/share/server/action.js?revision=727141&view=markup&pathrev=727141

'''See also:''' ExternalProcesses

Actions are a default included functionality that is made available by the new ExternalProcesses feature. ''_design/'' docs can now specify an ''actions'' member that is an object of ''key''/''function'' pairs.

Action functions are specified in JavaScript and have access to a CouchDB object that can make requests to the database.

== Example ''_design/'' Document ==

{{{
{
    "_id": "_design/an_action",
    "actions": {
        "times_two": "function(req, db) {return {code:200, json: {val: req.query.q * 2}};}"
    }
}
}}}

By default, this action is available at the URL:

{{{
http://127.0.0.1:5984/db_name/_external/action/times_two?q=2
}}}

== Example Using the Database ==

The ''db'' argument is a CouchDB instance. This class is defined in ''couch.js'' at:

{{{
http://127.0.0.1:5984/_utils/script/couch.js
}}}

For now the best references on the API are couch.js itself, and couch_tests.js that exercises it and most of CouchDB.

{{{
{
    _id: "_design/with_db",
    actions: {
        "get" : "function(req, db) { var doc = db.open(req.query.docid); return {json:doc} }",
    }
}
}}}

Accessed via:

{{{
http://127.0.0.1:5984/db_name/with_db/get?docid="_design/with_db"
}}}


== Caveats ==

The actions functionality is still a bit rough around the edges and there are efficiency questions on the implementation. Also, the error reporting is sub-par (to say the least...).

That said, it helps serve as a reference (and testable) example of _external.
