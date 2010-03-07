A handy list of all the key CouchDB [[http://bitworking.org/projects/URI-Templates/|URI templates]].

=== Databases and Documents ===

To see a listing of databases:

  /_all_dbs

To see some basic information about a database:

  /''dbname''/

To see all a listing of the data documents in a database:

  /''dbname''/_all_docs

To see a document:

  /''dbname''/''docid''

To download a file attachment:

  /''dbname''/''docid''/''filename''

=== Design Documents and Views ===

To see a design document:

  /''dbname''/_design/''designdocname''

To query a view.

  /''dbname''/_design/''designdocname''/_view/''viewname?''query''

NOTE: Apparently the structure depends on the version #.  In 0.8.1 the above doesn't work, but the below works: -- JohnWarden

  /''dbname''/_view/''designdocname''/''viewname?''query''



To query a temporary ("slow") view (with the custom view function in the body of the request):

  /''dbname''/_temp_view?''query''

=== Formatting ===

To format a document through a "show" template:

  /''dbname''/_design/''designdocname''/_show/''showname''/''docid''

To format a view through a "list" template:

  /''dbname''/_design/''designdocname''/_list/''listname''/''viewname''?''query''

=== View Query Syntax ===

The most common query parameters for accessing views are:

  * ?startkey=''keyvalue''
  * ?endkey=''keyvalue''
  * ?limit=''max rows to return''
  * ?skip=''number of rows to skip''

For the full query syntax, see the [[HTTP_view_API]].
