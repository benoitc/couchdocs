A Document Runner would provide functionality to run a transform function across all documents in the database. This way you could do maintenance and migrations, with incurring a bunch of http overhead.

The idea [[http://mail-archives.apache.org/mod_mbox/incubator-couchdb-user/200806.mbox/%3ce282921e0806130216w3d20dfdfh244ea5b491e12ee5@mail.gmail.com%3e|was originally floated on the couchdb-user mailing list]].

=== Requirements ===

Ability to specify a job in a view-server like context (Javascript other language function) and have it run across all docs (like a view is), but with the additional ability to write back to the document (through the http api, so we don't have to add a socket-based update interface).

Caveat: 

We may not be able to guarantee that runner functions see each document only once, so functions need to be aware only to modify documents that require modification.

=== Uses ===

 * Changing the format of a timestamp across all docs
 * Removing sensitive fields before replicating to another jurisdiction
 * (View runner... slightly different) Materializing the results of group=true reduce queries into a dataset for further map/reduce processing (a common pattern in Hadoop)
