== Full-text Indexing and Searching ==

Lucene integration with CouchDB is available with an external project called couchdb-lucene (http://github.com/rnewson/couchdb-lucene).


=== Index interface ===

couchdb-lucene's indexing process is configured with update notification as follows;

{{{
[update_notification]
indexer=/usr/bin/java -jar /path/to/couchdb-lucene-<version>-jar-with-dependencies.jar -index
}}}

=== Search interface ===

couchdb-lucene's search process is configured as an external process accessible via an httpd_handler as follows;

{{{
[couchdb]
os_process_timeout=60000 ; increase the timeout to 60 seconds.

[external]
fti=/usr/bin/java -jar /path/to/couchdb-lucene-<version>-jar-with-dependencies.jar -search

[httpd_db_handlers]
_fti = {couch_httpd_external, handle_external_req, <<"fti">>}
}}}

You can install the httpd_handler as anything you like, but the name must match between the [external] and [httpd_db_handlers] section. The rest of the document assumes 'fti'.

 q:: the query to run (e.g, subject:hello)
 sort:: the comma-separated fields to sort on. Prefix with / for ascending order and \ for descending order (ascending is the default if not specified).
 limit:: the maximum number of results to return
 skip:: the number of results to skip
 include_docs::  whether to include the source docs
 stale=ok:: If you set the stale option ok, couchdb-lucene may not perform any refreshing on the index. Searches may be faster as Lucene caches important data (especially for sorting). A query without stale=ok will use the  latest data committed to the index.
 debug:: if false, a normal application/json response with results appears. if true, an pretty-printed HTML blob is returned instead.

=== Lucene reference implementation ===

You must supply a index function in order to enable couchdb-lucene as by default, nothing will be indexed.

You may add any number of index views in any number of design documents. All searches will be constrained to documents emitted by those view functions.

Declare your functions as follows;

{{{
{
  "views": {
    // conventional view code goes here
  },
  "fulltext": {
    "by_subject": {
      "defaults": { "store":"yes" },
      "index":"function(doc) { var ret=new Document(); ret.add(doc.subject); return ret }"
    }
  }
}
}}}

You can perform queries within this view with a URL such as;

{{{
http://localhost:5984/dbname/_fti/design_doc_name/by_subject?q=hello
}}}

==== Dependencies ====

couchdb-lucene uses Maven 2 to manage dependencies, so you shouldn't have to deal with them directly.

At least Java version 5 is needed.

==== Compiling ====

The Lucene search engine is not build as part of the CouchDB. 

You need to:
 * setup a Java developer environment (at least version 5). 
 * Checkout CouchDB source with git clone git://github.com/rnewson/couchdb-lucene.git
 * cd couchdb-lucene
 * type 'mvn'

As result you should get a file target/couchdb-lucene-<version>-jar-with-dependencies.jar.
