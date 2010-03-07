= DRAFT =

Still working on this...

= Introduction =

The durability of data is a leading concern with any database and yet few databases are ever explicit about their durability properties. This page attempts to precisely describe the durability that CouchDB delivers under different configurations (both software and hardware).

The only operations with durability concerns are those where a client writes documents or attachments to couchdb. Other operations, like updating view indexes, or compaction, are safely and seamlessly resumable if interrupted by power failure, etc.

In all cases, durability is determined by calls to the operating system that flush data to persistent storage, typically a hard drive or a solid-state device. It is the precise moments that these calls are made, and their exact behavior, that will drive the rest of the page.

= How file:sync() works =

All data flushing is performed by file:sync(IoDevice). This function maps to fsync(fd) on most platforms, with the notable exception of OS/X where fcntl(F_FULLFSYNC) is called instead.

A call to fsync(fd) should ensure, on completion, that all pending writes have reached the disk. On many platforms, and Linux in particular, this promise is not upheld in the presence of write-caching disk controllers. On affected configurations, a call to fsync(fd) will complete as soon as all pending writes have reached the cache of the disk controller itself. If your controller has battery-backing, you might decide this is sufficiently durable. On OS/X, the fcntl(F_FULLFSYNC) really gets all pending writes to disk even in the presence of a write-caching disk controller. This is the reason that CouchDB is "slower" on OS/X.

= How CouchDB uses fsync() =

CouchDB uses a strictly append-only pattern when writing documents and attachments to the database file. In order to ensure database integrity, a footer is also included which contains, among other things, the location of the current root of the various B+Tree's that CouchDB uses internally. The order of writes is as follows;

 1. file:sync()
 1. append the header
 1. file:sync()

The appending of the header is bookended by sync() calls in order to ensure correct ordering of writes even through failure scenarios. Because of the strong checksum on the header, no failing write can corrupt the database. At worst, the database reflects the previous state. 

= Durability Matrix =

Since calling file:sync() twice for every document added is prohibitively expensive, CouchDB almost always does some degree of batching. Under normal circumstances, your document is appended to the file, but not sync'ed, along with any other writes from other clients. Within one second, all of those writes are sync'ed and the header is updated. You can increase write performance, and the cost of delaying durability, if you use the batch=ok parameter on your write request. Your write will eventually be durable, but no time commitment has been made (you will receive a "202 Accepted" instead of the usual "201 Created" to reflect this weaker promise). To ensure your write is durable before you get a response, you can add a custom HTTP header (X-Couch-Full-Commit: true) to your write request. Your data is sync'ed and the header of the database is written and sync'ed before your response is returned.

Below is a table that summarizes all the options currently available that affect durability;


TODO !



 
