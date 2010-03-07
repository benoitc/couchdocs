The latest version is maintained at http://books.couchdb.org/relax/reference/views-for-sql-jockeys


= View Cookbook for SQL Jockeys =

This is a collection of some common SQL queries and how to get the same result in CouchDB. The key to remember here is that CouchDB does not work like an SQL database at all and that best practices from the SQL world do not translate well or at all to CouchDB. This cookbook assumes that you are familiar with the CouchDB basics like creating and updating databases and documents.

== Using Views (CREATE / ALTER TABLE) ==

Using views is a two step process. First you ''define'' a view, then you ''query'' it. This is analogous to defining a table structure (with indexes) using `CREATE TABLE` or `ALTER TABLE` and querying it using an SQL query.

=== Defining a View ===

Defining a view is done by creating a special document in a CouchDB database. The only actual speciality is the `_id` of the document: it starts with `_design/`, for example `_design/application`. Other than that, it is just a regular CouchDB document. To make sure CouchDB understands that you are defining a view, you need to prepare the contents of that design document in a special format. Here is an example:

{{{
{
  "_id": "_design/application",
  "_rev": "1-C1687D17",
  "views": {
    "viewname": {
      "map": "function(doc) { ... }",
      "reduce": "function(keys, values) { ... }"
    }
  }
}
}}}

We are defining a view `viewname`. The definition of the view consists of two functions. The ''map function'' and the ''reduce function''. Specifying a reduce function is optional. We'll look at the nature of the functions later. Note that `viewname` can be whatever you like; `users`, `by-name`, or `by date` are just some examples.

A single design document can also include multiple view definitions, each identified by a unique name:

{{{
{
  "_id": "_design/application",
  "_rev": "1-C1687D17",
  "views": {
    "viewname": {
      "map": "function(doc) { ... }",
      "reduce": "function(keys, values) { ... }"
    },
    "anotherview": {
      "map": "function(doc) { ... }",
      "reduce": "function(keys, values) { ... }"
    }
  }
}
}}}

=== Querying a View ===

The name of the design document and the name of the view are significant for querying the view. To query the view `viewname` you perform a HTTP `GET` request to the following URI:

{{{
/database/_design/application/_view/viewname
}}}

`database` is the name of the database you created your design document in. Next up is the design document name and then the view name prefixed with `_view/`. To query `anotherview` replace `viewname` in that URI with `anotherview`. If you want to query a view in a different design document adjust the design document name.


=== Map & Reduce Functions ===

Map/Reduce is a concept that solves problems by applying a two-step process; aptly named the ''map'' phase and the 'reduce' phase. The map phase looks at all documents in CouchDB separately one after the other and creates a ''map result''. The map result is an ordered list of key-value pairs. Both key and value can be specified by the user writing the map function. A map function may call the built-in `emit(key, value)` function 0 to N times per document, creating a row in the map result per invocation.

CouchDB is smart enough to only run a map function once for every document, even on subsequent queries on a view. Only changes to documents, or new documents need to be processed anew.

==== Map Functions ====

Map functions run in isolation for every document. They can't modify the document and they can't talk to the outside world; they can't have ''side-effects''. This is required so CouchDB can guarantee correct results without having to recalculate a complete result when only one document gets changed.

The map result looks like this:

{{{
{"total_rows":3,"offset":0,"rows":[
  {"id":"fc2636bf50556346f1ce46b4bc01fe30","key":"Lena","value":5},
  {"id":"1fb2449f9b9d4e466dbfa47ebe675063","key":"Lisa","value":4},
  {"id":"8ede09f6f6aeb35d948485624b28f149","key":"Sarah","value":6}
}
}}}

It is a list of rows sorted by the value of `key`. The `id` is added automatically and refers back to the document that created this row. The `value` is the data you're looking for. For example purposes, it's the girl's age.

The map function that produces this result is:

{{{
function(doc) {
  if(doc.name && doc.age) {
    emit(doc.name, doc.age);
  }
}
}}}

It includes a sanity check to see we're operating on the right fields and calls the emit function with the name and age as key and value.

==== Reduce Functions ====

The reduce functions are explained later.


== Lookup by Key (SELECT field FROM table WHERE value="key") ==

Use case: Get a ''result'' (that can be a record or set of records) associated with a ''key''.

To look something up quickly, regardless of the storage mechanism, an index is needed. An index is a data structure optimized for quick search and retrieval. CouchDB's map result is stored in such an index, which happens to be a b+-tree.

To look up a value by `"key"` we need to put all values into the key of a view. All we need is a simple map function:

{{{
function(doc) {
  if(doc.value) {
    emit(doc.value, null);
  }
}
}}}

This creates a list of documents that have a `value` field sorted by the data in the `value` field. We don't emit a value. The view result will give us a list of document ids that we can then query individually, or we can use the `?include_docs=true` view query option to have CouchDB retrieve the document data for us.


== Aggregate Functions (SELECT COUNT(field) FROM table) ==


== Get Unique Values (SELECT DISTINCT field FROM table) ==
