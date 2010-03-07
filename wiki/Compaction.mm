= Compaction =
<<TableOfContents(2)>>

== Database Compaction ==

Compaction compresses the database file by removing unused sections created during updates. Old revisions of documents are also removed from the database though a small amount of meta data is kept for use in conflict [[Replication|replication]] during replication. The number of revisions (default of 1000) can be configured using the ``_revs_limit`` URL endpoint (see [[HTTP_database_API#Accessing_Database-specific_options]]). It is available since version 0.8-incubating.

Compaction is manually triggered per database. Support for queued compaction of multiple databases is planned. Please note, that compaction will be run as a background task.

=== Example ===

Compaction is triggered by an HTTP post request to the _compact sub-resource of your database. On success, HTTP status 202 is returned immediately.

{{{
    curl -X POST http://localhost:5984/my_db/_compact
    #=> {"ok":true}
}}}

GET requesting your database base URL ( see [[HTTP_database_API#Database_Information]] ) gives a hash of statuses that look like this:

{{{
    curl -X GET http://localhost/my_db
    #=> {"db_name":"my_db", "doc_count":1, "doc_del_count":1, "update_seq":4, "purge_seq":0, "compact_running":false, "disk_size":12377, "instance_start_time":"1267612389906234", "disk_format_version":5}
}}}

The compact_running key will be set to true during compaction.

=== Compaction of write-heavy databases ===
Note, it is not a good idea to attempt compaction on a database node that is near full capacity for its write load. The problem is the compaction process may never catch up with the writes if they never let up, and eventually it will run out of disk space.

Compaction should be attempted when the write load is less than full capacity. Read load won't affect its ability to complete however.
CouchDB works like this to have the least impact possible on clients,  the database remains online and fully functional to readers and  
writers. It is a design limitation that database compaction can't complete when at capacity for write load. It may be reasonable to schedule compactions during off-peak hours. 

In a clustered environment the write load can be switched off for any node before compaction and brought back up to date with replication once complete. 

In the future, a single CouchDB node can be changed to stop or fail other updates if the write load is too heavy for it to complete in a reasonable time.


== View compaction ==

[[Introduction_to_CouchDB_views|Views]] need compaction like databases. There is a compact views feature introduced with CouchDB 0.11:
{{{
curl -X POST http://localhost:5984/dbname/_compact/designname
#=> {"ok":true}
}}}

This compacts the view index from the current version of the design document. The HTTP response code is 202 Accepted (like compaction for databases) and a compaction background task will be created. Information on running compations can be fetched with [[HTTP_view_API#Getting_Information_about_Design_Documents_.28and_their_Views.29|HTTP_view_API#Getting_Information_about_Design_Documents_(and_their_Views)]].

View indexes on disk are named after their MD5 hash of the view definition. When you change a view, old indexes remain on disk. To clean up all outdated view indexes (files named after the MD5 representation of views, that does not exist anymore) you can trigger a view cleanup:

{{{
curl -X POST http://localhost:5984/dbname/_view_cleanup
#=> {"ok":true}
}}}
