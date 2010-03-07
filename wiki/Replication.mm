== Overview ==

The replication is an incremental one way process involving two databases (a source and a destination).

The aim of the replication is that at the end of the process, all active documents on the source database are also in the destination database and all documents that were deleted in the source databases are also deleted (if exists) on the destination database.

The replication process only copies the last revision of a document, so all previous revisions that were only on the source database are not copied to the destination database.

'''Changes on the master will not automatically replicate to the slaves'''

=== Run Replication ===

Replication is triggered by sending a POST request to the `_replicate` URL with a JSON object in the body that includes a `source` and a `target` member.


{{{
POST /_replicate HTTP/1.1

{"source":"example-database","target":"http://example.org/example-database"}
}}}

`source` and `target` can both point at local databases, remote databases and any combination of these.

If your local CouchDB instance is secured by an admin account, you need to use the full URL format

{{{
POST /_replicate HTTP/1.1

{"source":"http://example.org/example-database","target":"http://admin:password@127.0.0.1:5984/example-database"}
}}}

The target database has to exist and is not implicitly created. Add `create_target:true` to the JSON object to create the target database (remote or local) prior to replication. The names of the source and target databases do not have to be the same.


Specifying a local `source` database and a remote `target` database is called ''push replication'' and a remote `source` and local `target` is called ''pull replication''. As of CouchDB 0.9, pull replication is a lot more efficient and resistant to errors, and it is suggested that you use pull replication in most cases, especially if your documents are large or you have large attachments.

=== Continuous replication ===

To make replication continuous, add "continuous":true parameter to JSON, for example:

{{{
POST /_replicate HTTP/1.1

{"source":"http://example.org/example-database","target":"http://admin:password@127.0.0.1:5984/example-database", "continuous":true}
}}}

At this time, CouchDB doesn’t remember continuous replications over a server restart. For more info visit http://books.couchdb.org/relax/reference/replication - CouchDB: The Definitive Guide, chapter Replication.


See also: 
 * [[Replication_and_conflicts|Replication and conflicts]]
 * [[How_to_design_for_replication|How to design for replication]]
