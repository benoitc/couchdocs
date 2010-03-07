The maximum request size to CouchDB is defined in src/mochiweb/mochiweb_request.erl

% Maximum recv_body() length of 1MB
-define(MAX_RECV_BODY, (1024*1024)).

As this is the maximum request size, the maximum document size is less than 1MB.  The maximum document size is not a constant value as the JSON encoding is variable on a per document basis and is best defined as MAX_RECV_BODY - the size of the JSON key and formatting data.

You can edit MAX_RECV_BODY to a higher value.

Note that this will either be a configuration option or there will be no limit to the document size in CouchDB 0.9 (that is currently in development)
