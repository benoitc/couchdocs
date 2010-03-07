== Overview ==

CouchDB does not overwrite updated documents in place, instead it creates a new document at the end of the database file, with the same `_id` but a new `_rev` identifier. This type of storage system is space-wasteful so regular [[Compaction]] is needed to reclaim disk space. Note that the older revisions are not available to [[Views]].

Document revisions are used for optimistic concurrency control. If you try to update a document using an old revision the update will be in conflict. These conflicts should be resolved by your client, usually by requesting the newest version of the document, modifying and trying the update again.

@@ How does this relate to replication conflicts?

=== Revision History ===

'''You cannot rely on document revisions for any other purpose than concurrency control.'''

Due to compaction, revisions may disappear at any time. You cannot use them for a client revision system.

[[Replication]] has also an impact on revisions, i.e. '''Replication only replicates the last version of a document''', so it will be impossible to access, on the destination database, previous versions of a document that was stored on the source database.

If you wish to implement revisions in your client system, a number of patterns have been suggested:

 * Using attachments to store old revisions.
 * Using multiple documents to store old revisions.

@@ Please add to this list and flesh out the solutions as you see fit.
