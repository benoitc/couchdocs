= Proposal for CouchDB history support =

 * Every time a document is changed, store the existing document as an attachment before writing the updated document.
 * For space efficiency, historical attachments are stored separately i.e. not inline with the historical JSON document.
 * The special "history" attachments will be stored using a special prefix of "_history/<_rev>".
 * If people need to add meta-data to the history, e.g. "last changed by", "last changed date/time", then the recommended way would be to use a custom _update handler to add these fields to the doc being saved, and these would propagate to the history attachment.
 * In future we can add delta support to further improve efficiency.

== Use cases ==

The main use case we want to support is the ability to recover from catastrophic user errors e.g. if they delete an important document, or overwrite something important.  I don't think supporting use cases such as rolling back to particular snapshots is within the scope of this proposal.

== Implementation ==

Native Erlang patch to core CouchDB.  We probably want the ability to turn this on/off on a per-db basis via a .ini config option.
