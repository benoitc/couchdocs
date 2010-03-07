== What CouchDB is ==


 * A document database server, accessible via a RESTful JSON API.
 * Ad-hoc and schema-free with a flat address space.
 * Distributed, featuring robust, incremental replication with bi-directional conflict detection and management.
 * Query-able and index-able, featuring a table oriented reporting engine that uses Javascript as a query language.

== What it is Not ==

 * A relational database.
 * A replacement for relational databases.
 * An object-oriented database. Or more specifically, meant to function as a seamless persistence layer for an OO programming language.

== Key Characteristics ==

### Documents ###

A CouchDB document is an object that consists of named fields. Field values may be strings, numbers, dates, or even ordered lists and associative maps. An example of a document would be a blog post:

{{{
    "Subject": "I like Plankton"  
    "Author": "Rusty"  
    "PostedDate": "5/23/2006"  
    "Tags": ["plankton", "baseball", "decisions"]
    "Body": "I decided today that I don't like baseball. I like plankton."  
}}}

In the above example document, `Subject` is a field that contains a single string value "I like plankton". `Tags`  is a field containing the list of values "plankton",  "baseball", and "decisions".

A CouchDB database is a flat collection of these documents. Each document is identified by a unique ID.

=== Views ===

To address this problem of adding structure back to semi-structured data, CouchDB integrates a view model using Javascript for description. Views are the method of aggregating and reporting on the documents in a database, and are built on-demand to aggregate, join and report on database documents. Views are built dynamically and don’t affect the underlying document, you can have as many different view representations of the same data as you like.

=== Schema-Free ===

Unlike SQL databases which are designed to store and report on highly structured, interrelated data, CouchDB is designed to store and report on large amounts of semi-structured, document oriented data. CouchDB greatly simplifies the development of document oriented applications, which make up the bulk of collaborative web applications.

In an SQL database, as needs evolve the schema and storage of the existing data must be updated. This often causes problems as new needs arise that simply weren't anticipated in the initial database designs, and makes distributed 
"upgrades" a problem for every host that needs to go through a schema update.

With CouchDB, no schema is enforced, so new document types with new meaning can be safely added alongside the old. The view engine, using Javascript, is designed to easily handle new document types and disparate but similar 
documents.

=== Distributed ===

CouchDB is a peer based distributed database system. Any number of CouchDB hosts (servers and offline-clients) can have independent "replica copies" of the same database, where applications have full database interactivity (query, add, edit, delete). When back online or on a schedule, database changes are replicated bi-directionally.

CouchDB has built-in conflict detection and management and the replication process is incremental and fast, copying only documents and individual fields changed since the previous replication. Most applications require no special planning to take advantage of distributed updates and replication.

Unlike cumbersome attempts to bolt distributed features on top of the same legacy models and databases, it is the result of careful ground-up design, engineering and integration. The document, view, security and replication 
models, the special purpose query language, the efficient and robust disk layout are all carefully integrated for a reliable and efficient system.
