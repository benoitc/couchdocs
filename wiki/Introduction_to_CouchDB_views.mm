= Introduction to CouchDB Views =
<<TableOfContents(2)>>

A simple introduction to CouchDB views.

== Concept ==
Views are the primary tool used for querying and reporting on CouchDB documents. There are two different kinds of views: permanent and temporary views.

'''Permanent views''' are stored inside special documents called design documents, and can be accessed via an HTTP ''GET'' request to the URI ''/{dbname}/{docid}/{viewname}'', where ''{docid}'' has the prefix ''_design/'' so that CouchDB recognizes the document as a design document, and ''{viewname}'' has the prefix ''_view/'' so that CouchDB recognizes it as a view.

'''Temporary views''' are not stored in the database, but rather executed on demand. To execute a temporary view, you make an HTTP ''POST'' request to the URI ''/{dbname}/_temp_view'', where the body of the request contains the code of the view function and the ''Content-Type'' header is set to ''application/json''.

'''NOTE''': '''Temporary views are only good during development'''. Final code should not rely on them as they are very expensive to compute each time they get called and they get increasingly slower the more data you have in a database. If you think you can't solve something in a permanent view that you can solve in an ad-hoc view, you might want to reconsider. (TODO: add typical examples and solutions).

For both kinds of views, the view is defined by a !JavaScript function that maps view keys to values (although it is possible to use other languages than !JavaScript by plugging in third-party view servers).

Note that by default views are not created and updated when a document is saved, but rather, when it is accessed. As a result, the first access might take some time depending on the size of your data while CouchDB creates the view. If preferable the views can also be updated when a document is saved using an external script that calls the views when updates have been made. An example can be found here: RegeneratingViewsOnUpdate

Note that all views in a single design document get updated when one of the views in that design document gets queried.

Note on !JavaScript API change: Prior to Tue, 20 May 2008 (Subversion revision r658405) the function to emit a row to the map index, was named "map". It has now been changed to "emit".

== Basics ==
=== Map Functions ===
Here is the simplest example of a map function:

{{{#!highlight javascript
function(doc) {
  emit(null, doc);
}
}}}
This function defines a table that contains all the documents in a CouchDB database, with no particular key.

A view function should accept a single argument: the document object. To produce results, it should call the implicitly available ''emit(key, value)'' function. For every invocation of that function, a result row is added to the view (if neither the ''key'' nor the ''value'' are undefined). As documents are added, edited and deleted, the rows in the computed table are updated automatically.

Here is a slightly more complex example of a function that defines a view on values computed from customer documents:

{{{#!highlight javascript
function(doc) {
  if (doc.Type == "customer") {
    emit(null, {LastName: doc.LastName, FirstName: doc.FirstName, Address: doc.Address});
  }
}
}}}
For each document in the database that has a Type field with the value ''customer'', a row is created in the view. The ''value'' column of the view contains the ''!LastName'', ''!FirstName'', and ''Address'' fields for each document. The key for all the documents is null in this case.

To be able to filter or sort the view by some document property, you would use that property for the key. For example, the following view would allow you to lookup customer documents by the ''!LastName'' or ''!FirstName'' fields:

{{{#!highlight javascript
function(doc) {
  if (doc.Type == "customer") {
    emit(doc.LastName, {FirstName: doc.FirstName, Address: doc.Address});
    emit(doc.FirstName, {LastName: doc.LastName, Address: doc.Address});
  }
}
}}}
Here is an example of the results of such a view:

{{{
{
   "total_rows":4,
   "offset":0,
   "rows":
   [
     {
       "id":"64ACF01B05F53ACFEC48C062A5D01D89",
       "key":"Katz",
       "value":{"FirstName":"Damien", "Address":"2407 Sawyer drive, Charlotte NC"}
     },
     {
       "id":"64ACF01B05F53ACFEC48C062A5D01D89",
       "key":"Damien",
       "value":{"LastName":"Katz", "Address":"2407 Sawyer drive, Charlotte NC"}
     },
     {
       "id":"5D01D8964ACF01B05F53ACFEC48C062A",
       "key":"Kerr",
       "value":{"FirstName":"Wayne", "Address":"123 Fake st., such and such"}
     },
     {
       "id":"5D01D8964ACF01B05F53ACFEC48C062A",
       "key":"Wayne",
       "value":{"LastName":"Kerr", "Address":"123 Fake st., such and such"}
     },
   ]
}
}}}
''This example output was reformatted for readability.''

Keep in mind that emit works by just storing the key/value pairs in an array and then, when all views in the same _design document have been calculated, returns all results at once. So if you use an object to make calculations and do multiple emits on the same document, you must create a copy and not emit the same object multiple times. For example:

{{{
function(doc) {
  if (doc.Type == "measurement") {
    var timestamp = new Date(doc.timestamp)
    emit(eval(uneval(timestamp)), doc.lastTemp);
    timestamp.setSeconds(timestamp.getSeconds - 30);
    emit(eval(uneval(timestamp)), doc.temp30secsAgo);
    timestamp.setSeconds(timestamp.getSeconds - 30);
    emit(eval(uneval(timestamp)), doc.temp1minAgo);
  }
}
}}}
''Note: For those unfamiliar with the convention eval(uneval(_obj_)), this simply clones _obj_. It is cleaner than traversing each element of _obj_ and it will always be true that uneval(eval(uneval(x))) == uneval(x) and eval(uneval(x)) == deep_copy_of_x . The actual method uneval(_obj_) is a Spidermonkey specific (as of 1.7) extension that is not part of ECMAScript.'' [[https://developer.mozilla.org/en/SpiderMonkey/JSAPI_Reference/JS_InitStandardClasses|1]] [[http://www.thespanner.co.uk/2008/04/10/javascript-cloning-objects/|2]] [[http://www.mozilla.org/rhino/rhino15R5.html|3]]

<<Anchor(reduce_functions)>>

=== Reduce Functions ===
Reduce is a powerful feature of CouchDB but is often misused which leads to performance problems. From 0.10 onwards, CouchDB uses a heuristic to detect reduce functions that won't scale to give the developer an early warning. A reduce function must reduce the input values to a smaller output value. If you are building a composite return structure in your reduce, or only transforming the values field, rather than summarizing it, you might be misusing this feature. See [[#reduced_value_sizes|Reduced Value Sizes]] for more details.

If a view has a reduce function, it is used to produce aggregate results for that view. A reduce function is passed a set of intermediate values and combines them to a single value. Reduce functions must accept, as input, results emitted by its corresponding map function '''as well as results returned by the reduce function itself'''. The latter case is referred to as a ''rereduce''.

Here is an example of a reduce function:

{{{
function (key, values, rereduce) {
    return sum(values);
}
}}}
Reduce functions are passed three arguments in the order ''key'', ''values'' and ''rereduce''

Reduce functions must handle two cases:

1. When ''rereduce'' is ''false'':

 * ''key'' will be an array whose elements are arrays of the form ''[key,id]'', where ''key'' is a key emitted by the map function and ''id'' is that of the document from which the key was generated.
 * ''values'' will be an array of the values emitted for the respective elements in ''keys''
 * i.e. {{{reduce([ [key1,id1], [key2,id2], [key3,id3] ], [value1,value2,value3], false)}}}

2. When ''rereduce'' is ''true'':

 * ''key'' will be ''null''
 * ''values'' will be an array of values returned by previous calls to the reduce function
 * i.e. {{{reduce(null, [intermediate1,intermediate2,intermediate3], true)}}}

Reduce functions should return a single value, suitable for both the ''value'' field of the final view and as a member of the ''values'' array passed to the reduce function.

Often, reduce functions can be written to handle rereduce calls without any extra code, like the summation function above. In that case, the ''rereduce'' argument can be ignored and in JavaScript, it can be omitted from the function definition entirely.

=== Reduce vs rereduce ===
On a large database objects to be reduced will be sent to your reduce function in batches. These batches will be broken up on B-tree boundaries, which may occur in arbitrary places.

[[http://mail-archives.apache.org/mod_mbox/couchdb-user/200903.mbox/<20090330084727.GA7913@uk.tiscali.com>|For example]], suppose you have a view which emits key->value pairs like this:

{{{
[X, Y, 0]  -> Object_A
[X, Y, 1]  -> Object_B1
[X, Y, 1]  -> Object_B1
[X, Y, 1]  -> Object_B1
[Z, Q, 0] ....
}}}
Your reduce function may receive

{{{
   [Object_A, Object_B1]
}}}
and then in a separate invocation

{{{
   [Object_B1, Object_B1]
}}}
The outputs of these two reduce functions will then be passed to your reduce function again with rereduce=true to make the final answer. You cannot rely on all four rows being passed to the initial reduce function.

Furthermore: due to reduce optimisations, you may only receive some of the blocks to be reduced. Example: take these three Btree nodes:

{{{
     [a b c d e f g] [h i j k l m n] [o p q r s t u]
            R1              R2              R3
}}}
The reduce value of all the items in each Btree node is stored within each node, e.g. {{{[a b c d e f g]}}} reduces to {{{R1}}}. Now suppose someone asks for a reduce value across a key range:

{{{
                      key range
              <----------------------------->
     [a b c d e f g] [h i j k l m n] [o p q r s t u]
}}}
CouchDB will call your reduce function to calculate a value for {{{[e f g]}}} and for {{{[o p q r]}}}, but will use the existing stored/calculated value of R2 across the middle block.

Therefore, it is wrong to attempt to maintain any sort of state in your reduce function between invocations. And because the Btree node boundaries can appear in any place, it is wrong to attempt to cross-reference adjacent documents too. Any cross-referencing needs to take place in the client, not in a reduce function.

=== Access Strategy ===
For queries which are not meant to actually condense the amount of information you often can live without a reduce function. A common strategy is to get the data you are interested to select by in into the ''key'' part and then use ''startkey'' and ''endkey'' on the result.

== Keys and values ==
=== Equal keys ===
CouchDB actually stores the [key,docid] pair as the key in the btree. This means that:

 * you always know which document the key and value came from (it's exposed as the 'id' field in the view result)
 * view rows with equal keys sort by increasing docid.

If you assign your docids in a time-based way then you can get documents with equal keys in a natural oldest-to-newest order. Couchdb has a feature to do this, which you can enable in local.ini:

{{{
[uuids]
algorithm = utc_random
}}}
=== Lookup Views ===
The second parameter of the ''emit()'' function can be ''null''. CouchDB then only stores the [key,docid] in the view. You can use the view as a compact lookup mechanism and fetch the document's details, if needed, in subsequent requests or by adding parameter ''include_docs=true''

=== Linked documents ===
''This is a new feature in couchdb trunk / 0.11''

If you emit an object value which has '''{'_id': XXX}''' then include_docs will fetch the document with id XXX rather than the document which was processed to emit the key/value pair.

This means that if one document contains the ids of other documents, it can cause those documents to be fetched in the view too, adjacent to the same key if required.

For example, if you have the following hierarchically-linked documents:

{{{
[
{ "_id": "11111" },
{ "_id": "22222", "ancestors": ["11111"], "value": "hello" },
{ "_id": "33333", "ancestors": ["22222","11111"], "value": "world" }
]
}}}
you can emit the values with the ancestor documents adjacent to them in the view like this:

{{{
function(doc) {
  if (doc.value) {
    emit([doc.value, 0], null);
    if (doc.ancestors) {
      for (var i in doc.ancestors) {
        emit([doc.value, Number(i)+1], {_id: doc.ancestors[i]});
      }
    }
  }
}
}}}
The result you get is:

{{{
{"total_rows":5,"offset":0,"rows":[
{"id":"22222","key":["hello",0],"value":null,
  "doc":{"_id":"22222","_rev":"1-0eee81fecb5aa4f51e285c621271ff02","ancestors":["11111"],"value":"hello"}},
{"id":"22222","key":["hello",1],"value":{"_id":"11111"},
  "doc":{"_id":"11111","_rev":"1-967a00dff5e02add41819138abb3284d"}},
{"id":"33333","key":["world",0],"value":null,
  "doc":{"_id":"33333","_rev":"1-11e42b44fdb3d3784602eca7c0332a43","ancestors":["22222","11111"],"value":"world"}},
{"id":"33333","key":["world",1],"value":{"_id":"22222"},
  "doc":{"_id":"22222","_rev":"1-0eee81fecb5aa4f51e285c621271ff02","ancestors":["11111"],"value":"hello"}},
{"id":"33333","key":["world",2],"value":{"_id":"11111"},
  "doc":{"_id":"11111","_rev":"1-967a00dff5e02add41819138abb3284d"}}
]}
}}}
which makes it very cheap to fetch a document plus all its ancestors in one query.

Note that the "id" in the row is still that of the originating document. The only difference is that include_docs fetches a different doc.

=== Complex Keys ===
Keys are not limited to simple values. You can use arbitrary JSON values to influence sorting. See ViewCollation for the rules.

When the key is an array, view results can be grouped by a sub-section of the key. For example, if keys have the form [''year'', ''month'', ''day''] then results can be reduced to a single value or by year, month, or day. See HttpViewApi for more information.

== Views in Practice ==
See HttpViewApi to learn how to work with views. [[View_Snippets]] contain a few examples.

== Grouping ==
The basic reduce operation with group=false (the default over HTTP) is to reduce to a single value. But by using startkey and endkey, you can get the summary value for any key interval.

Using group=true (which is Futon's default), you get a separate reduce value for each unique key in the map - that is, all values which share the same key are grouped together and reduced to a single value.

group_level=N queries are essentially a macro, which run one normal (group=false) reduce query automatically for each interval on a set of intervals as defined by the level.

So with group_level=1, and keys like

{{{
["a",1,1]
["a",3,4]
["a",3,8]
["b",2,6]
["b",2,6]
["c",1,5]
["c",4,2]
}}}
CouchDB will internally run 3 reduce queries for you. One that reduces all rows where the first element of the key = "a", one for "b", and one for "c".

If you were to query with group_level=2, you'd get a reduce query run for each unique set of keys (according to their first two elements), eg

{{{
["a",1], ["a",3], ["b",2"], ["c",1], ["c",4]
}}}
group=true is the conceptual equivalent of group_level=exact, so CouchDB runs a reduce per unique key in the map row set.

Note: map and reduce results are precomputed and stored in a btree. However, the intermediate reduction values are cached according to the btree structure, instead of according to the query params. So unless your range happens to match exactly the keys underneath a given inner node, you'll end up running at least one javascript reduction per reduce query. A group=true query effectively runs multiple reduce queries, so you may find it to be slower than you expect.

There is more detail in [[http://horicky.blogspot.com/2008/10/couchdb-implementation.html|this blog posting]] under the heading "Query Processing"

== Restrictions on map and reduce functions ==
The restriction on map functions is that they must be referentially transparent. That is, given the same input document, they will always emit the same key/value pairs. This allows CouchDB views to be updated incrementally, only reindexing the documents that have changed since the last index update.

To make incremental Map/Reduce possible, the Reduce function has the requirement that not only must it be referentially transparent, but it must also be commutative and associative for the array value input, to be able reduce on its own output and get the same answer, like this:

{{{
f(Key, Values) == f(Key, [ f(Key, Values) ] )
}}}
This requirement of reduce functions allows CouchDB to store off intermediated reductions directly into inner nodes of btree indexes, and the view index updates and retrievals will have logarithmic cost. It also allows the indexes to be spread across machines and reduced at query time with logarithmic cost.

For more details see [[http://damienkatz.net/2008/02/incremental_map.html|this blog post]]

Furthermore: you have no control over how documents are partitioned in reduce and re-reduce phases. You cannot rely on "adjacent" documents all being presented at the same time to the reduce function; it's quite possible that one subset will be reduced to R1, another subset will be reduced to R2, and then R1 and R2 will be re-reduced together to make the final reduce value. In the limiting case, consider that each of your documents might be reduced individually and that the reduce outputs will be re-reduced together (which also may happen as a single stage or in multiple stages)

So you should also design your reduce/re-reduce function so that

{{{
f(Key, Values) == f(Key, [ f(Key, Value0), f(Key, Value1), f(Key, Value2), ... ] )
}}}
<<Anchor(reduced_value_sizes)>>

=== Reduced Value Sizes ===
As CouchDB computes view indexes it also calculates the corresponding reduce values and caches this value inside each of the btree node pointers. This scheme allows CouchDB to reuse reduced values when updating the btree. This scheme requires some care to be taken with the amount of data returned from reduce functions.

As a rule of thumb, the data returned by reduce functions should remain "smallish" and not grow faster than log(num_rows_processed). Although violating this requirement will not cause an error, btree performance will degrade drastically. If you have a view that appears to work well on small data sets but grinds to a halt as more data is added you're probably violating the growth rate characteristics.

== Interactive CouchDB Tutorial ==
See [[http://labs.mudynamics.com/2009/04/03/interactive-couchdb/|this blog posting]] for an interactive tutorial (emulator in JavaScript) that explains map/reduce, view collation and how to query CouchDB RESTfully.

== Implementation ==
These blog posts include information about how map/reduce works, including how reduce values are kept in btree nodes.

 * http://damienkatz.net/2008/02/incremental_map.html
 * http://damienkatz.net/2008/02/incremental_map_1.html
 * http://horicky.blogspot.com/2008/10/couchdb-implementation.html
