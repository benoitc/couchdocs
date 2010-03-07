A list of HTTP statuses used by CouchDB and their respective meanings.

=== 200 - OK ===

Request completed successfully.

=== 201 - Created ===

Document created successfully.

=== 202 - Accepted ===

Request for database compaction completed successfully.

=== 304 - Not Modified ===

Etag not modified since last update.

=== 400 - Bad Request ===

Request given is not valid in some way.

=== 404 - Not Found ===

Such as a request via the HttpDocumentApi for a document which doesn't exist.

=== 405 - Resource Not Allowed ===

Request was accessing a non-existent URL.  For example, if you have a malformed URL, or are using a third party library that is targeting a different version of CouchDB.

=== 409 - Conflict ===

Request resulted in an update conflict.

=== 412 - Precondition Failed ===

Request attempted to created database which already exists.

=== 500 - Internal Server Error ===

Request contained invalid JSON, probably happens in other cases too.

''As you can see, this document is incomplete, please update.''
