This is a stub for a page to discuss how to actually get couchdb running in a distributed fashion.

Distributed CouchDB implementations:

 * CouchDB currently scales for reads, by allowing synchronization between multiple servers.

 * CouchDB does not currently support partitioning.

(couch-dev post from Jan Lehnardt - July 2008)
{{{
At the moment, CouchDB runs best on a single machine
with multiple machines for a cluster using replication to
synchronise data. Erlang allows a VM to run on multiple
machines and we do not yet take advantage of that fact.
This is an area that is worth investigating.

The road map is at http://incubator.apache.org/couchdb/roadmap.html

... scaling parts are Future Feature work.
A couple of people have voiced interest in contributing there
especially the database partitioning, but nothing has come
out of that yet.
}}}

== Editorial Notes ==

 * I see that there is replication via the 'replication' functionality on the http://localhost:5984/_utils console interface, but how does one distribute a database across, say 10 hosts?
 * Is there a way to specify the number of copies of a piece of data?  (Presumes not all hosts have copies of each piece of data)
 * Is there a piece of this that can be configured in the couch.ini file, such than when the topology changes (ie. server add or removal) that things can be put back into sync?

Excerpts from the Architectural Document, http://incubator.apache.org/couchdb/docs/overview.html :

{{{
Using just the basic replication model, many traditionally single server database applications can be made distributed with almost no extra work.
}}}

 * Let's try to document this.  What do we mean by '''distributed'''?

=== Distributed defined ===

Here's what some people might ''assume'' we mean by distributed data store:

 * We (couchdb) have a client which will '''shard''' the data by key, and direct it to the correct server (shard), such that the writes of the system will '''scale'''.  That is that there are many ''writers'', in a collision-free update environment.
 * Reads may scale if they outnumber the writes using some form of replication for read-only-clients.
 * If a master data store node is lost, then the client (or some proxy mechanism) can switch over to a new master data store, which is ''really up to date'' (ie. milliseconds), and the client will continue without a hitch.
