= HTTP Database API =
<<TableOfContents(3)>>

An introduction to the CouchDB HTTP Database API.

== Naming and Addressing ==

A database must be named with all lowercase characters (a-z), digits (0-9), or any of the ''_$()+-/'' characters and must end with a slash in the URL. The name has to start with characters.

{{{
http://couchserver/databasename/
http://couchserver/another/databasename/
http://couchserver/another/database_name(1)/
}}}

''Uppercase characters are NOT ALLOWED in database names.''

{{{
http://couchserver/DBNAME/ (invalid)
http://couchserver/DatabaseName/ (invalid)
http://couchserver/databaseName/ (invalid)
}}}

Note also that a ''/'' character in a DB name must be escaped when used in a URL; if your DB is named ''his/her'' then it will be available at ''http://localhost:5984/his%2Fher''.

''Rationale for character restrictions''

The limited set of characters for database names is driven by the need to satisfy the lowest common denominator for file system naming conventions. For example, disallowing uppercase characters makes compliance with case insensitive file systems straightforward.

All database files are stored in a single directory on the file system. If your database includes a ''/'' CouchDB will create a sub-directory structure in the database directory. That is, a database named ''his/her'', the database file will be available at ''$dbdir/his/her.couch''. This is useful when you have a large number of databases and your file system does not like that.

== Working with Databases ==

=== List Databases ===

To get a list of databases on a CouchDB server, use the ''/_all_dbs'' URI:

{{{
GET /_all_dbs HTTP/1.1
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

And the response:

{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Length: 37
Content-Type: application/json
Connection: close

["somedatabase", "anotherdatabase"]
}}}

=== PUT (Create New Database) ===

To create a new empty database, perform a PUT operation at the database URL. Currently the content of the actual PUT is ignored by the webserver.

On success, HTTP status ''201'' is returned. If a database already exists a ''412'' error is returned.

{{{
PUT /somedatabase/ HTTP/1.1
Content-Length: 0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Here is the server's response:

{{{
HTTP/1.1 201 Created
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Length: 13
Content-Type: application/json
Connection: close

{"ok": true}
}}}

=== DELETE ===

To delete a database, perform a DELETE operation at the database location.

On success, HTTP status ''200'' is returned. If the database doesn't exist, a ''404'' error is returned.

{{{
DELETE /somedatabase/ HTTP/1.1
Content-Length: 1
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Here is the server's response:

{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Length: 67
Content-Type: application/json
Connection: close

{"ok": true}
}}}

=== Database Information ===

To get information about a particular database, perform a GET operation on the database, e.g.:

{{{
GET /somedatabase/ HTTP/1.1
}}}

The server's response is a JSON object similar to the following:

{{{
{
    "compact_running": false, 
    "db_name": "dj", 
    "disk_format_version": 5, 
    "disk_size": 12377, 
    "doc_count": 1, 
    "doc_del_count": 1, 
    "instance_start_time": "1267612389906234", 
    "purge_seq": 0, 
    "update_seq": 4
}

}}}

==== Meaning of Result Hash ====

||'''Key'''||'''Description'''||'''CouchDB Version'''||
||''db_name''||Name of the database (string)||||
||''doc_count''||Number of documents (including design documents) in the database (int)||||
||''update_seq''||Current number of updates to the database (int)||||
||''purge_seq''||Number of purge operations (int)||||
||''compact_running''||Indicates, if a compaction is running (boolean)||||
||''disk_size''||Current size in Bytes of the database ('''Note''': Size of views indexes on disk are not included)||||
||''instance_start_time''|| Timestamp of CouchDBs start time (int in ms) ||||
||''disk_format_version''|| Current version of the internal database format on disk (int)||||

=== Accessing Database-specific options ===
Currently there is only one database specific option you can set via a PUT request. ''_revs_limit'' defines a upper bound of document revisions which CouchDB keeps track of, even after [[Compaction]]. The default is set to 1000 on CouchDB 0.11.

Set ''_revs_limit'' of a particular database:
{{{
curl -X PUT -d "1500" http://localhost:5984/test/_revs_limit
#=> {"ok":true}
}}}

Read ''_revs_limit'' of a particular database:
{{{
curl -X GET http://localhost:5984/test/_revs_limit
#=> 1500
}}}

=== Changes ===

A list of changes made to documents in the database, in the order they were made, can be obtained from the database's ''_changes'' resource.

  * GET
    * since=seqnum (default=0). Start the results from the change immediately after the given sequence number.
    * feed=normal|longpoll|continuous (default=normal). Select the type of feed.
    * heartbeat=time (milliseconds, default=60000). Period in milliseconds after which a empty line is sent in the results. Only applicable for ''longpoll'' or ''continuous'' feeds. Overrides any ''timeout''.
    * timeout=time (milliseconds, default=60000). Maximum period in milliseconds to wait for a change before the response is sent, even if there are no results. Only applicable for ''longpoll'' or ''continuous'' feeds.

By default all changes are immediately returned as a JSON object:

{{{
GET /somedatabase/_changes HTTP/1.1
}}}

{{{
{"results":[
{"seq":1,"id":"fresh","changes":[{"rev":"1-967a00dff5e02add41819138abb3284d"}]},
{"seq":3,"id":"updated","changes":[{"rev":"2-7051cbe5c8faecd085a3fa619e6e6337"}]},
{"seq":5,"id":"deleted","changes":[{"rev":"2-eec205a9d413992850a6e32678485900"}],"deleted":true}
],
"last_seq":5}
}}}

''results'' is the list of changes in sequential order. New and changed documents only differ in the value of the rev; deleted documents include the ''"deleted": true'' attribute.

''last_seq'' is the sequence number of the last update returned. (Currently it will always be the same as the ''seq'' of the last item in ''results''.)

Sending a ''since'' param in the query string skips all changes up to and including the given sequence number:

{{{
GET /somedatabase/_changes?since=3 HTTP/1.1
}}}

{{{
{"results":[
{"seq":5,"id":"deleted","changes":[{"rev":"2-eec205a9d413992850a6e32678485900"}],"deleted":true}
],
"last_seq":5}
}}}

==== Long-Polling (Efficient Polling) Feed ====

The ''longpoll'' feed (probably most useful used from a browser) is a more efficient form of polling that waits for a change to occur before the response is sent. ''longpoll'' avoids the need to frequently poll CouchDB to discover nothing has changed!

The response is basically the same JSON as is sent for the ''normal'' feed.

A ''timeout'' limits the maximum length of time the connection is open. If there are no changes before the timeout expires the response's ''results'' will be an empty list.

==== Continuous (Non-Polling) Feed ====

Polling the CouchDB server is not a good thing to do. Setting up new HTTP connections just to tell the client that nothing's happened puts unnecessary strain on CouchDB.

A ''continuous'' feed stays open and connected to the database until explicitly closed and changes are sent to the client as they happen, i.e. in near real-time.

The ''continuous'' feed's response is a little different than the other feed types to simplify the job of the client - each line of the response is either empty or a JSON object representing a single change, as found in the normal feed's ''results''.

{{{
GET /somedatabase/_changes?feed=continuous HTTP/1.1
}}}

{{{
{"seq":1,"id":"fresh","changes":[{"rev":"1-967a00dff5e02add41819138abb3284d"}]}
{"seq":3,"id":"updated","changes":[{"rev":"2-7051cbe5c8faecd085a3fa619e6e6337"}]}
{"seq":5,"id":"deleted","changes":[{"rev":"2-eec205a9d413992850a6e32678485900"}],"deleted":true}
... tum tee tum ...
{"seq":6,"id":"updated","changes":[{"rev":"3-825cb35de44c433bfb2df415563a19de"}]}
}}}

Obviously, "... tum tee tum ..." does not appear in the actual response but represents a long pause before the change with ''seq'' 6 occurred.

== Compaction ==

Databases may be compacted to reduce their disk usage.  For more details, see [[Compaction]].
