The documented way to do replication is available at this URL [[http://wiki.apache.org/couchdb/Frequently_asked_questions#how_replication|here]]

== Expanded explanation ==

Fire up Futon and head over to the replication option. The URL is http://localhost:5984/_utils/replicator.html

The replication option prompts you to either specify a CouchDB instance to push towards or a CouchDB instance to pull from. If the replication is not within the same CouchDB instance you will need to specific a URI.
The correct format for the URI is: http://<address>:<port>/<database name>

''remote database:'' http://192.168.197.132:5984/test_suite_db_b to ''local database:'' test_suite_db_b

This will replicate the information at the remote database URI to the local database test_suite_db_b.

It is important to specific the database name in the URL as Futon does not assume anything with respect to the source or destination database based upon the originating or destination database.

== Operational Hints ==

Replication is one-way. In a multi-master scenario you have to issue one replication from A to B, and a separate one from B to A.

Currently it seems that "pull" replication where you have a remote source and and a local target is much more reliable than "push" where you have it the other way around.

== Playing with Replication ==

You may replicate between two databases in the same couchdb instance.

However if you prefer a more realistic test, you can also set up two test couchdb instances on the same machine and replicate between them. Here is local1.ini:

{{{
; Remember to create the directories:
;   mkdir -p /var/tmp/couchdb1/{data,log}
;
; Start using:
;   couchdb -c /usr/local/etc/couchdb/default.ini -c local1.ini

[couchdb]
database_dir = /var/tmp/couchdb1/data

[log]
file = /var/tmp/couchdb1/log/couch.log

[httpd]
port = 5001
}}}

Similarly local2.ini:

{{{
; Remember to create the directories:
;   mkdir -p /var/tmp/couchdb2/{data,log}
;
; Start using:
;   couchdb -c /usr/local/etc/couchdb/default.ini -c local2.ini

[couchdb]
database_dir = /var/tmp/couchdb2/data

[log]
file = /var/tmp/couchdb2/log/couch.log

[httpd]
port = 5002
}}}

Test they are both running:

{{{
$ curl http://localhost:5001/
{"couchdb":"Welcome","version":"0.9.0a738034-incubating"}
$ curl http://localhost:5002/
{"couchdb":"Welcome","version":"0.9.0a738034-incubating"}
}}}

=== Create and replicate a document ===

{{{
$ curl -X PUT http://localhost:5001/sampledb
{"ok":true}
$ curl -X PUT http://localhost:5002/sampledb
{"ok":true}

$ curl -X PUT -d '{"hello":"world"}' http://localhost:5001/sampledb/doc1
{"ok":true,"id":"doc1","rev":"3851869530"}

$ curl -X POST -d '{"source":"http://127.0.0.1:5001/sampledb","target":"sampledb"}' \
    http://localhost:5002/_replicate
{
  "ok":true,
  "session_id":"7118d54c40761eba83454aabae8ea91b",
  "source_last_seq":0,
  "history":
  [
    {
      "start_time":"Wed, 28 Jan 2009 16:26:09 GMT",
      "end_time":"Wed, 28 Jan 2009 16:26:09 GMT",
      "start_last_seq":0,
      "end_last_seq":1,
      "missing_checked":1,
      "missing_found":1,
      "docs_read":1,
      "docs_written":1
    }
  ]
}
}}}

''POST response has been reformatted for clarity''

{{{
$ curl http://127.0.0.1:5001/sampledb/doc1
{"_id":"doc1","_rev":"3851869530","hello":"world"} 
$ curl http://127.0.0.1:5002/sampledb/doc1
{"_id":"doc1","_rev":"3851869530","hello":"world"} 
}}}

=== Introduce conflicting updates ===

''Note: the updates have to be made on separate databases. Update conflicts can't occur within a single database; because you provide the original _rev, if someone else has already changed the document, the second update is rejected.''

{{{
$ curl -X PUT -d '{"_rev":"3851869530","hello":"fred"}' http://localhost:5001/sampledb/doc1
{"ok":true,"id":"doc1","rev":"132006080"}
$ curl -X PUT -d '{"_rev":"3851869530","hello":"jim"}' http://localhost:5002/sampledb/doc1
{"ok":true,"id":"doc1","rev":"2575525432"}

$ curl -X POST -d '{"source":"http://127.0.0.1:5001/sampledb","target":"sampledb"}' \
    http://localhost:5002/_replicate
{"ok":true,"session_id":"fe1ec1c66b0b916e7e87dd635b4dc572","source_last_seq":0,"history":
[{"start_time":"Wed, 28 Jan 2009 16:28:36 GMT","end_time":"Wed, 28 Jan 2009 16:28:36 GMT",
"start_last_seq":0,"end_last_seq":2,"missing_checked":1,"missing_found":1,"docs_read":1,"docs_written":1}]}

$ curl http://127.0.0.1:5001/sampledb/doc1
{"_id":"doc1","_rev":"132006080","hello":"fred"}
$ curl http://127.0.0.1:5002/sampledb/doc1
{"_id":"doc1","_rev":"2575525432","hello":"jim"}
}}}

At this point you can see the two databases still have different ideas about this document. You need to replicate back the other way as well:

{{{
$ curl -X POST -d '{"target":"http://127.0.0.1:5001/sampledb","source":"sampledb"}' \
    http://localhost:5002/_replicate

{"ok":true,"session_id":"da0a07a0f9c9fb5c2d2e2769229257df","source_last_seq":0,"history":
[{"start_time":"Wed, 28 Jan 2009 16:30:23 GMT","end_time":"Wed, 28 Jan 2009 16:30:23 GMT",
"start_last_seq":0,"end_last_seq":3,"missing_checked":2,"missing_found":1,"docs_read":1,"docs_written":1}]}

$ curl http://127.0.0.1:5001/sampledb/doc1?revs=true
{"_id":"doc1","_rev":"2575525432","hello":"jim","_revs":["2575525432","3851869530"]}
3$ curl http://127.0.0.1:5002/sampledb/doc1?revs=true
{"_id":"doc1","_rev":"2575525432","hello":"jim","_revs":["2575525432","3851869530"]}
}}}

The two machines now agree on one document and revision history, but the conflict (and conflicting version) is not shown. You have to ask for this explicitly with ''conflicts=true''

{{{
$ curl http://127.0.0.1:5001/sampledb/doc1?conflicts=true
{"_id":"doc1","_rev":"2575525432","hello":"jim","_conflicts":["132006080"]}
$ curl http://127.0.0.1:5002/sampledb/doc1?conflicts=true
{"_id":"doc1","_rev":"2575525432","hello":"jim","_conflicts":["132006080"]}
}}}

=== Compaction ===

The conflict status, and the conflicting versions, remain even after compaction. However the very original version, which was not in conflict, does not.

{{{
$ curl -X POST http://localhost:5001/sampledb/_compact
{"ok":true}
$ curl -X POST http://localhost:5002/sampledb/_compact
{"ok":true}
$ curl http://127.0.0.1:5001/sampledb/doc1?conflicts=true
{"_id":"doc1","_rev":"2575525432","hello":"jim","_conflicts":["132006080"]}
$ curl http://127.0.0.1:5001/sampledb/doc1?rev=132006080
{"_id":"doc1","_rev":"132006080","hello":"fred"}
$ curl http://127.0.0.1:5001/sampledb/doc1?rev=2575525432
{"_id":"doc1","_rev":"2575525432","hello":"jim"}
$ curl http://127.0.0.1:5001/sampledb/doc1?rev=3851869530
{"error":"{not_found,missing}","reason":"3851869530"}
}}}

=== Conflict Resolution ===

All nodes see the same conflict state and history, so any of them can resolve the conflict.

Nodes can continue to add new versions, but conflict remains:

{{{
$ curl -X PUT -d '{"_rev":"2575525432","hello":"resolved"}' http://localhost:5001/sampledb/doc1
{"ok":true,"id":"doc1","rev":"923422654"}
$ curl http://127.0.0.1:5001/sampledb/doc1?conflicts=true
{"_id":"doc1","_rev":"923422654","hello":"resolved","_conflicts":["132006080"]}
}}}

Once the application is satisfied that it has resolved the conflict, it simply has to DELETE the conflicting revision. Couch actually keeps a separate list of deleted conflict revisions that you can view with "deleted_conflicts=true"

{{{
$ curl -X DELETE http://127.0.0.1:5001/sampledb/doc1?rev=132006080
{"ok":true,"id":"doc1","rev":"3699698383"}
$ curl http://127.0.0.1:5001/sampledb/doc1?conflicts=true
{"_id":"doc1","_rev":"804871722","hello":"resolved"}
$ curl http://127.0.0.1:5001/sampledb/doc1?deleted_conflicts=true
{"_id":"doc1","_rev":"804871722","hello":"resolved","_deleted_conflicts":["3699698383"]}
}}}

=== Sample shell script ===

Running this script gives an easy way to set up a replication conflict so you can examine it and resolve it.

{{{
#!/bin/sh
set -xe

HOST1=http://localhost:5001
HOST2=http://localhost:5002
LOCAL1=sampledb
LOCAL2=sampledb
DB1="$HOST1/$LOCAL1"
DB2="$HOST2/$LOCAL2"

curl -X DELETE "$DB1"
curl -X DELETE "$DB2"
curl -X PUT "$DB1"
curl -X PUT "$DB2"

resp=`curl -sX PUT -d "{\"hello\":\"world\"}" "${DB1}/doc1"`
echo "$resp"
rev=`expr "$resp" : '.*"rev":"\([^"]*\)"'`

# Replicate
curl -X POST -d "{\"source\":\"$DB1\",\"target\":\"$LOCAL2\"}" "$HOST2/_replicate"
curl -s "$DB1/doc1" | grep world
curl -s "$DB2/doc1" | grep world

# Now make conflicting changes
curl -sX PUT -d "{\"_rev\":\"$rev\",\"hello\":\"fred\"}" "${DB1}/doc1"
curl -sX PUT -d "{\"_rev\":\"$rev\",\"hello\":\"jim\"}" "${DB2}/doc1"
curl -s "$DB1/doc1" | grep fred
curl -s "$DB2/doc1" | grep jim

# Replicate again, A->B. Conflict seen on B side only.
curl -X POST -d "{\"source\":\"$DB1\",\"target\":\"$LOCAL2\"}" "$HOST2/_replicate"
echo "*** On first DB ***"
curl -s "$DB1/doc1?conflicts=true"
echo "*** On second DB ***"
curl -s "$DB2/doc1?conflicts=true"

# Replicate again, B->A. Identical conflict on both sides.
curl -X POST -d "{\"target\":\"$DB1\",\"source\":\"$LOCAL2\"}" "$HOST2/_replicate"
echo "*** On first DB ***"
curl -s "$DB1/doc1?conflicts=true"
echo "*** On second DB ***"
curl -s "$DB2/doc1?conflicts=true"
}}}

=== Further reading ===

 * [[http://blogs.23.nu/c0re/2009/12/running-a-couchdb-cluster-on-amazon-ec2/|Running a CouchDB cluster on Amazon EC2]] explains how to do password protected Replication over the Internet.
 * [[http://code.google.com/p/couchdb-python/source/browse/couchdb/tools/manual_replication.py| manual_replication]] is a script to trigger various replication scenarios.
