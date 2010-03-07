See [[HTTP_view_API]] for the view options that apply to many ''GET'' operations.

= CouchDB Server Level =

||/||Info||GET||Get MOTD and version||||
||/_all_dbs||Databases||GET||Get a list of databases||||
||/_config||Config||GET||Get configuration data||||
||/_uuids||UUIDs||GET /_uuids?count=1||Get a number of UUIDs||||
||/_replicate||Replication||POST /_replicate source=x&target=y||Replicate, see [[Replication]]||||
||/_stats||Statistics||GET /_stats||Statistics overview||||
||/_active_tasks||Active tasks||GET /_active_tasks||Active task list (compaction, replication, etc.)||||

= Database level =

'''Note''': Document names must always have embedded '''/''' translated to '''%2F'''. E.g. "GET /'''db'''/foo%2fbar" for the document named "foo/bar". Attachment names may have embedded slashes.

||/'''db'''||Creation||PUT /'''db'''||Database creation||||
||/'''db'''||Deletion||DELETE /'''db'''||Database deletion||||
||/'''db'''||Info||GET /'''db'''||Database information||||
||/'''db'''||Change feed||GET /'''db'''/_changes||Feed of changes in the database||||
||/'''db'''/_compact||Compaction||POST /'''db'''/_compact||Data compaction||||
||/'''db'''/_bulk_docs||Bulk document update||POST /'''db'''/_bulk_docs [{"foo": "bar"}]||Update many documents at once||||
||/'''db'''/_temp_view||Temporary view||POST /'''db'''/_temp_view {'''view-code'''}||Run an ad-hoc view||||
||/'''db'''/_view_cleanup||Cleanup view data||POST /'''db'''/_view_cleanup||Cleanup old view data (see [[Compaction]])||||
||/'''db'''/_design/'''design-doc'''/_view/'''view'''||View||GET /'''db'''/_design/'''design-doc'''/_view/'''view'''||View query (see [[HTTP_view_API]])||(in 0.9.x, this was /'''db'''/_view/'''design-doc'''/'''view''')||

See [[HTTP_database_API]] for more information.

= Documents level =

||/'''db'''/_all_docs||Documents||GET /'''db'''/_all_docs||List of all documents||||
||/'''db'''||Get document||GET /'''db'''/'''doc'''||Retrieve a document||||
||/'''db'''||Create document||POST /'''db''' {"foo": "bar"}||Create new document||||
||/'''db'''/'''doc'''||Update document||PUT /'''db'''/'''doc''' {"foo": "test"}||Save updated document||||
||/'''db'''/'''doc'''||Delete document||DELETE /'''db'''/'''doc'''||Delete document||||
