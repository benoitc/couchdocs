Some useful talking points for discussing CouchDB.

  * CouchDB is not a relational database management system (RDBMS). CouchDB != SQL
  * Updating documents creates new documents. There are no partial updates or stored diffs.
  * Views are crucial to CouchDB. Similar in nature to indexes in a traditional RDBMS but lazily evaluated following a MapReduce paradigm. Views let you sort and filter data.
  * Reduce is tricky, yet powerful.
  * Complex key collation is important, yet can also be tricky.
  * Replication can create conflicts. This is unavoidable. System design should explicitly account for possible conflicts as they '''will''' happen.
  * The internal revisioning system is '''only''' for conflict detection and optimistic locking (Multi-Version Concurrency Control MVCC).
  * The internal revisioning system is '''not''' usable as a revision control system.
