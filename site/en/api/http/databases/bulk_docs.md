=== Fetch Multiple Documents With a Single Request ===

{{{_all_docs}}} implements the [[HTTP_view_API]] where each ''key'' is the doc _id, and each ''value'' is a JSON object containing the rev. This means that:

   * By adding {{{?include_docs=true}}} you can get the documents themselves, not just their id and rev
   * By adding {{{?startkey="xx"&endkey="yy"}}} you can get the documents with keys in a certain range
   * By POSTing to _all_docs you can get a set of documents with arbitrary keys

{{{
$ curl -d '{"keys":["bar","baz"]}' -X POST http://127.0.0.1:5984/foo/_all_docs?include_docs=true
{"total_rows":3,"offset":0,"rows":[
{"id":"bar","key":"bar","value":{"rev":"1-4057566831"},"doc":{"_id":"bar","_rev":"1-4057566831","name":"jim"}},
{"id":"baz","key":"baz","value":{"rev":"1-2842770487"},"doc":{"_id":"baz","_rev":"1-2842770487","name":"trunky"}}
]}

$ curl 'http://127.0.0.1:5984/foo/_all_docs?include_docs=true&startkey="ba"&endkey="bb"'
{"total_rows":3,"offset":0,"rows":[
{"id":"bar","key":"bar","value":{"rev":"1-4057566831"},"doc":{"_id":"bar","_rev":"1-4057566831","name":"jim"}},
{"id":"baz","key":"baz","value":{"rev":"1-2842770487"},"doc":{"_id":"baz","_rev":"1-2842770487","name":"trunky"}}
]}
}}}

=== Modify Multiple Documents With a Single Request ===

CouchDB provides a bulk insert/update feature. To use this, you make a ''POST'' request to the URI ''/{dbname}/_bulk_docs'', with the request body being a JSON document containing a list of new documents to be inserted or updated.

For example (with curl):
{{{
$ DB="http://127.0.0.1:5984/mydb"
$ curl -v -d '{"docs":[{"key":"baz","name":"bazzel"},{"key":"bar","name":"barry"}]}' -X POST $DB/_bulk_docs
$ curl -v -d @your_file.json -X POST $DB/_bulk_docs 
}}}

Doc formats below are as per CouchDB 0.9.x.

{{{
{
  "docs": [
    {"_id": "0", "integer": 0, "string": "0"},
    {"_id": "1", "integer": 1, "string": "1"},
    {"_id": "2", "integer": 2, "string": "2"}
  ]
}
}}}

If you omit the per-document ''_id'' specification, CouchDB will generate unique IDs for you, as it does for regular ''POST'' requests to the database URI.

The response to such a bulk request would look as follows (reformatted for clarity):

{{{
[
    {"id":"0","rev":"1-62657917"},
    {"id":"1","rev":"1-2089673485"},
    {"id":"2","rev":"1-2063452834"}
]
}}}

Updating existing documents requires setting the ''_rev'' member to the revision being updated. To delete a document set the ''_deleted'' member to true.

{{{
{
  "docs": [
    {"_id": "0", "_rev": "1-62657917", "_deleted": true},
    {"_id": "1", "_rev": "1-2089673485", "integer": 2, "string": "2"},
    {"_id": "2", "_rev": "1-2063452834", "integer": 3, "string": "3"}
  ]
} 
}}}

Note that CouchDB will return in the response an id and revision for every document passed as content to a bulk insert, even for those that were just deleted.

If the _rev does not match the current version of the document, then that particular document will ''not'' be saved and will be reported as a conflict, but this does not prevent other documents in the batch from being saved.

{{{
[
    {"id":"0","error":"conflict","reason":"Document update conflict."},
    {"id":"1","rev":"2-1579510027"},
    {"id":"2","rev":"2-3978456339"}
]
}}}


==== Transactional Semantics with Bulk Updates ====

In previous releases of CouchDB, bulk updates were transactional - in particular, all requests in a bulk update failed if any request failed or was in conflict. There were a couple of problems with this approach:

   * This doesn't actually work with replication. Replication doesn't provide the same transactional semantics, so downstream replicas won't see "all-or-nothing" transactional semantics. Instead, they will see documents in an inconsistent state until replication of all documents involved in the bulk update completes. With bidirectional replication it can get even worse, because you can get edit conflicts that must be fixed manually.

   * If your database is partitioned (aka "sharded"), different documents within the transaction could live on different nodes in the cluster, and these kinds of transactional semantics don't work unless you use heavy, non-scalable approaches like two-phase commit.

With release 0.9 of CouchDB, bulk update semantics have been changed so that a CouchDB server behaves consistently in a single-node, replicated, and/or partitioned environment. Note that this change makes explicit the fact that CouchDB is not a relational store and does not guarantee relational consistency between documents. As a developer you need to be aware of these semantics and design your data model and your application with this in mind.

There are now two bulk update models supported:

   * '''non-atomic''' - This is the default behavior.  Some documents may successfully be saved and some may not.  The response will tell the application which documents were saved or not. In the case of a power failure, when the database restarts some may have been saved and some not.

   * '''all-or-nothing''' - To use this mode, include {{{"all_or_nothing":true}}} as part of the request.  In the case of a power failure, when the database restarts either all the changes will have been saved or none of them.  However, it does not do conflict checking, so the documents will be committed even if this creates conflicts.

{{{
{
  "all_or_nothing": true,
  "docs": [
    {"_id": "0", "_rev": "1-62657917", "integer": 10, "string": "10"},
    {"_id": "1", "_rev": "2-1579510027", "integer": 2, "string": "2"},
    {"_id": "2", "_rev": "2-3978456339", "integer": 3, "string": "3"}
  ]
}
}}}

In this case, all three documents will be saved, and the response will show success for all of them. However if the document with id 0 had a conflict, both versions will be present in the database, with an arbitrary choice made as to which appears in views. You can check for this status using a GET with {{{?conflicts=true}}}

All your updates will always be accepted - even if you give a non-existent _rev - so the term "all or nothing" really only applies to what happens in a crash scenario.

All or nothing transactions should not be used to enforce referential integrity, as some or all updated documents might become losing conflicts during the update. The transaction should be used to make sure all information is captured in an atomic operation, but conflicts may need to be addressed later. Applications that rely on this functionality should be able to tolerate some documents missing or being in a conflicted state until conflict resolution can occur.

Bulk updates work independently of replication, meaning document revisions originally saved as part of an all or nothing transaction will be replicated individually, not as part of a bulk transaction. This means other replica instances may only have a subset of the transaction, and if an update is rejected by the remote node during replication (e.g. not authorized error) the remote node may never have the complete transaction.

Note that POSTing a single document with {{{"all_or_nothing":true}}} behaves completely differently from a regular PUT, since it will save conflicting versions rather than rejecting a conflict.

{{{
$ DB="http://127.0.0.1:5984/tstconf"
$ curl -X PUT "$DB"
{"ok":true}
$ curl -X PUT -d '{"name":"fred"}' "$DB/person"
{"ok":true,"id":"person","rev":"1-877727288"}
$ curl -X POST -d '{"all_or_nothing":true,"docs":[{"_id":"person","_rev":"1-877727288","name":"jim"}]}' "$DB/_bulk_docs"
[{"id":"person","rev":"2-3595405"}]
$ curl -X POST -d '{"all_or_nothing":true,"docs":[{"_id":"person","_rev":"1-877727288","name":"trunky"}]}' "$DB/_bulk_docs"
[{"id":"person","rev":"2-2835283254"}]
$ curl "$DB/person?conflicts=true"
{"_id":"person","_rev":"2-3595405","name":"jim","_conflicts":["2-2835283254"]}
}}}
