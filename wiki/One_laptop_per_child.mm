The One Laptop Per Child XO laptop is based on Fedora Linux, it can run CouchDB. The OLPC user interface and the applications (or activities in OLPC terminology) are written in Python with the ''python-gtk'' library. It would seem logical to have a CouchDB client written in Python for this platform.

== Applications ==

  * One database per child with a replica of each on the teachers laptop.
    * Personal Journal
    * Homework assignments with marking replicating back from the teacher to the student
  * One database per class with replicas on every laptop in the class
  * Polls
  * Synchronous/asynchronous chat messaging

== Features ==

  * Opportunistic replication

  If a couchDB server sees another one on the local network via Avahi it should replicate databases in common.

  * Real time replication when available

  All client applications should always be pointing at the local couchdb server. Real time replication when available would mean there is never a distinction between using the local replica and server replicas. If there is connectivity then updates should happen just as fast as if the clients were talking to the server directly.

  * Database list discovery

  A couchdb server should be able to discover databases in common between it and another couchdb server. Initially this would be by iterating through the databases and passing each other a big list. It would be good to have a URL that returns the server name and an MD5 hash of it's list of databases. This would allow one laptop to meet another and quickly decide whether or not the database list of the other has changed since they last met.
