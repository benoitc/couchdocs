= Breaking Changes =
<<TableOfContents(3)>>

This page documents backwards-incompatible changes made during the evolution of CouchDB. While not all such changes will necessarily affect all users, most of them probably will. This page should show you what changed and how you'll need to adapt your code.

== Changes Between 0.10.x and 0.11.0 ==

=== show, list, update and validation functions ===
The `req` argument to show, list, update and validation functions now contains the member `method` with the specified HTTP method of the current request. Previously, this member was called `verb`. `method` is following RFC 2616 (HTTP 1.1) closer.

=== _admins -> _security ===
The /db/_admins handler has been removed and replaced with a /db/_security object. Any existing `_admins` will be dropped and need to be added to the security object again. The reason for this is that the old system made no distinction between names and roles, while the new one does, so there is no way to automatically upgrade the old admins list.

The security object has 2 special fields, `admins` and `readers`, which contain lists of names and roles which are admins or readers on that database. Anything else may be stored in other fields on the security object. The entire object is made available to validation functions.

=== json2.js ===
JSON handling in the query server has been upgraded to use json2.js. This allows us to use faster native JSON serialization when it is available.

In previous versions, attempts to serialize `undefined` would throw an exception, causing the doc that emitted undefined to be dropped from the view index. The new behavior is to serialize undefined as `null`. Applications depending on the old behavior will need to explicitly check for undefined.

Another change is that E4X's XML objects will not automatically be stringified. XML users will need to call my_xml_object.toXMLString() to return a string value.

(see commit [[http://github.com/apache/couchdb/commit/8d3b7ab31c1289e1425d1f4f348b7ca0021ab7fe|8d3b7ab3]])

=== WWW-Authenticate (popup) ===
The default configuration has been changed to avoid causing basic-auth popups which result from sending the WWW-Authenticate header. To enable basic-auth popups, uncomment the WWW-Authenticate line in local.ini.

=== Query server line protocol ===
The query server line protocol has changed for all functions except map, reduce, and rereduce. This allows us to cache the entire design document in the query server process, which results in faster performance for common operations. It also gives more flexibility to query server implementators and shouldn't require major changes in the future when adding new query server features.

=== UTF8 JSON ===
JSON request bodies are validated for proper UTF-8 before saving, instead of waiting to fail on subsequent read requests.

=== _changes line format ===
Continuous changes are now newline delimited, instead of having each line followed by a comma.


== Changes Between 0.9.x and 0.10.0 ==

=== Modular Configuration Directories ===

CouchDB now loads configuration from the following places (glob(7) syntax) in order:

 * `PREFIX/default.ini`
 * `PREFIX/default.d/*`
 * `PREFIX/local.ini`
 * `PREFIX/local.d/*`

The configuration options for `couchdb` script have changed to:

{{{
  -a FILE     add configuration FILE to chain
  -A DIR      add configuration DIR to chain
  -n          reset configuration file chain (including system default)
  -c          print configuration file chain and exit
}}}

=== Show and List API change ===
Show and List functions must have a new structure in 0.10. See [[Formatting_with_Show_and_List]] for details.

=== Stricter enforcing of reduciness in reduce-functions ===
Reduce functions are now required to reduce the number of values for a key.

=== View query reduce parameter strictness ===
CouchDB now considers the parameter reduce=false to be an error for queries of map-only views, and responds with status code 400.

== Changes Between 0.8.x and 0.9.0 ==

=== Response to Bulk Creation/Updates ===

The response to a bulk creation / update now looks like this

{{{
[
    {"id": "0", "rev": "3682408536"},
    {"id": "1", "rev": "3206753266"},
    {"id": "2", "error": "conflict", "reason": "Document update conflict."}
]
}}}

=== Database File Format ===

The database file format has changed. CouchDB itself does yet not provide any tools for migrating your data. In the meantime, you can use third-party scripts to deal with the migration, such as the dump/load tools that come with the development version (trunk) of [[http://code.google.com/p/couchdb-python/|couchdb-python]].

If you are running a version of trunk prior to revision 753448, have a look at the BreakingChangesUpdateTrunkTo0Dot9 page.

=== Renamed "count" to "limit" ===

As of r731159 the view query API has been changed: "count" has become "limit". This is a better description of what the parameter does, and should be a simple update in any client code.

=== Moved View URLs ===

The view URLs have been moved to design document resources. This means that paths that used to be like `http://hostname:5984/mydb/_view/designname/viewname?limit=10` will now look like `http://hostname:5984/mydb/_design/designname/_view/viewname?limit=10`. See the [[http://mail-archives.apache.org/mod_mbox/couchdb-dev/200902.mbox/thread?3|REST, Hypermedia, and CouchApps thread on dev]] for details.

=== Attachments ===

Names of attachments are no longer allowed to start with an underscore.

=== Error Codes ===

Some refinements have been made to error handling. CouchDB will send 400 instead of 500 on invalid query parameters. Most notably, document update conflicts now respond with `409 Conflict` instead of `412 Precondition Failed`. The error code for when attempting to create a database that already exists is now `412` instead of `409`.

=== ini file format ===

CouchDB 0.9 changes sections and configuration variable names in configuration files. Old `.ini` files won't work. See [[http://svn.apache.org/viewvc/couchdb/tags/0.9.0/etc/couchdb/local.ini?view=markup|local.ini]] for an example `.ini` file. Also note that CouchDB now ships with two `.ini` files where 0.8 used ''couch.ini'' there are now ''default.ini'' and ''local.ini''. ''default.ini'' contains CouchDB's standard configuration values. ''local.ini'' is meant for local changes. ''local.ini'' is not overwritten on CouchDB updates, so your edits are safe. In addition, the new runtime configuration system persists changes to the configuration in ''local.ini''.

== Changes Between 0.7.x and 0.8.0 ==

=== Database File Format ===

The database file format has changed. CouchDB itself does yet not provide any tools for migrating your data. In the meantime, you can use third-party scripts to deal with the migration, such as the dump/load tools that come with the development version (trunk) of [[http://code.google.com/p/couchdb-python/|couchdb-python]].

==== Migration Using the couchdb-python `dump`/`load` Tools ====

First, some important notes on the way these tools operate:
 * They work on a per-database basis, meaning you'll need to migrate all databases individually.
 * The dump tool retrieves all documents, including attachments, from a database and writes them to standard output in MIME multipart format.
 * The load tool expects that MIME multipart on the standard input stream, and recreates all the documents (including attachments) it contains. It should be used with an empty target database.
 * Documents of course retain their unique identifiers.
 * The revision history of the documents is completey discarded.

'''Note''': ''Do not upgrade CouchDB until you've gotten your data out using the procedure described below!''

'''Also note''': ''Please keep backups of both the original database files and the dump files, at least until you've verified that the migration worked completely.''

To use the tools, you'll have to install `couchdb-python` (currently from trunk), which in turn requires [[http://www.python.org/|Python 2.4]] and the [[http://code.google.com/p/httplib2/|httplib2]] and [[http://cheeseshop.python.org/pypi/simplejson|simplejson]] packages.

On the shell, enter the directory into which you checked out the `couchdb-python` code. First run to make sure the package is installed:

{{{
  ./setup.py install
}}}

Now, to dump the contents of a particular database into a file, run the following command:

{{{
  python couchdb/tools/dump.py http://127.0.0.1:5984/dbname > dbname.dump
}}}

Replace '''dbname''' with the name of the database to dump. This will create a file called `dbname.dump` in the current directory.

After you've done this for all the databases you want to migrate, you can upgrade CouchDB. You will need to completely clear the directory where CouchDB stored the old databases, as it will probably choke on files using the old format.

After the upgrade you can import all the data you previously exported. First, you'll need to create an empty database for every database dump you want to import. Then you execute the `load.py` script from the command-line as follows:

{{{
  python couchdb/tools/load.py http://127.0.0.1:5984/dbname < dbname.dump
}}}

Do that for all your databases, and you should be set. Please report any bugs in those scripts [[http://code.google.com/p/couchdb-python/issues/list|here]].

=== Document Structure Changes ===

In the JSON structure for attachments, the member name `content-type` has been changed to `content_type` (note the underscore). This change was made for consistency with the general naming scheme in CouchDB, and enable easier access from Javascript code.

=== View Definition Changes ===

Views now support optional reduce. For this to work, the structure of view definitions in design documents had to change. An example is probably the best way to illustrate this:

{{{
  {
    "_id":"_design/foo",
    "language":"javascript",
    "views": {
      "bar": {
        "map":"function... ",
        "reduce":"function..."
      }
    }
  }
}}}

Notable changes are the usage of a JSON object to define both the map and the reduce function instead of just a string for the map function. The `reduce` member may be omitted.

The `language` member is no longer a MIME type, instead, only the language name is specified. The language name maps exactly to the name chosen for a view server registration in `couch.ini`.

The `map(key, value)` function that map functions would use to produce output has been renamed to `emit(key, value)` to avoid confusion.

{{{
  function(doc) {
    emit(doc.foo, doc.bar);
  }
}}}

Temporary views now need to get `POST`ed a JSON document with `map` and `reduce` members instead of just `POST`ing the raw source of the map function:

{{{
  {
    "map":"function...",
    "reduce":"function..."
  }
}}}

Note that the language of the temporary view is no longer determined by the `Content-Type` header of the HTTP request. Since the definition is a JSON object, the `Content-Type` is always `application/json`. The view language is now specified via an optional `language` member in the JSON request body. If omitted, the language defaults to "javascript".

{{{
  {
    "language":"javascript"
    "map":"function...",
    "reduce":"function..."
  }
}}}

=== HTTP API Changes ===

=== DELETE Status Code ===

Successful deletion of a database or document using the `DELETE` HTTP method now results in a `200 OK` response instead of the `202 Accepted` response used before. The rationale for this change is that the deletion is performed immediately, while a 202 status code implies that the action has been triggered but may not have completed at the time of the response.

==== Bulk Updates ====

The JSON structure for bulk updates has been changed slightly for both requests and responses.

For requests, you previously posted a JSON array of document rows. Now, you post a JSON object with a `docs` member containing that array:

{{{
  {
    "docs": [
      {"_id": "foo", "_rev": "123456", "title": "Foo"},
      {"_id": "bar", "_rev": "234567", "title": "Bar"}
    ]
  }
}}}

Responses used to have a JSON object with a `results` member. Now, the response JSON structure looks as follows:

{{{
  {
    "ok": true,
    "new_revs": [
      {"_id": "foo", "rev": "345678"},
      {"_id": "bar", "rev": "456789"}
    ]
  }
}}}

''Note that bulk updates are now transactional: either all updates succeed or all fail. That's why the `ok` member moved to the top-level of the response.''
