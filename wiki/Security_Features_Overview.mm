An overview of security features focusing on what CouchDB provides out of the box.

=== Authentication ===
CouchDB ships with basic authentication that compares user credentials to Admin accounts. See [[Setting_up_an_Admin_account]] for more details.

You can specify a custom authentication handler and the web authentication scheme in the configuration file. The example below specifies that CouchDB will use the default_authentication_handler method defined in the [[http://svn.apache.org/viewvc/couchdb/trunk/src/couchdb/couch_httpd.erl?view=markup|couch_httpd]] module:

{{{
authentication_handler = {couch_httpd, default_authentication_handler}
WWW-Authenticate = Basic realm="administrator"
}}}

Other notes: The "null_authentication_handler" in "couch_httpd" allows any user credentials to run as admin. Web servers such as Apache or Nginx can also provide an authentication layer as a reverse-proxy to CouchDB.

=== Authorization ===
CouchDB supports one role, the "admin" group, which can execute any of the HTTP API on any database in the CouchDB instance. See [[Setting_up_an_Admin_account]] for more details.

CouchDB does not support other roles at this time. Support for read access restriction is planned for the 1.0 release. 

=== Validation ===
A design document may define a member function called "validate_doc_update". Requests to create or update a document are validated against every "validate_doc_update" function defined in the database. The validation functions are executed in an unspecified order. A design document can contain only one validation function. Errors are thrown as javascript objects. 

Example of a design document that validates the presence of an "address" field and returns :

{{{
{
   _id: "_design/myview",
   validate_doc_update: "function(newDoc, oldDoc, userCtx) {
      if(newDoc.address === undefined) {
         throw {forbidden: 'Document must have an address.'};
      }"
}
}}}

The result of a document update without the address field will look like this:
{{{
HTTP/1.1 403 Forbidden
WWW-Authenticate: Basic realm="administrator"
Server: CouchDB/0.9.0 (Erlang OTP/R12B)
Date: Tue, 21 Apr 2009 00:02:32 GMT
Content-Type: text/plain;charset=utf-8
Content-Length: 57
Cache-Control: must-revalidate

{"error":"forbbiden","reason":"Document must have an address."} 
}}}


The "validate_doc_update" function accepts three arguments:
 1. newDoc - The document to be created or used for update.
 1. oldDoc - The current document if document id was specified in the HTTP request
 1. userCtx - User context object, which contains three properties:
   a. db - String name of database
   a. name - String user name
   a. roles - Array of roles to which user belongs. Currently only admin role is supported.
