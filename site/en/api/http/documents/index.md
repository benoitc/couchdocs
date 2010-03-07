template: page.html

HTTP Document API
=================

This is an introduction to the CouchDB HTTP document API.

Naming/Addressing
-----------------

Documents stored in a CouchDB have a DocID. DocIDs are case-sensitive string
identifiers that uniquely identify a document. Two documents cannot have the
same identifier in the same database, they are considered the same document.

    http://localhost:5984/test/some_doc_id
    http://localhost:5984/test/another_doc_id
    http://localhost:5984/test/BA1F48C5418E4E68E5183D5BD1F06476

The above URLs point to `some_doc_id`, `another_doc_id` and
`BA1F48C5418E4E68E5183D5BD1F06476` in the database `test`.

Documents
---------

A CouchDB document is simply a JSON object. You can use any JSON structure
with nesting. You can fetch the document's revision information by adding
`?revs=true` or `?revs_info=true` to the get request.

Here are two simple examples of documents:

    {
        "_id": "discussion_tables",
        "_rev": "D1C946B7"
        "Activities": [
            {
                "Duration": 2, 
                "DurationUnit": "Hours", 
                "Name": "Football"
            }, 
            {
                "Attendees": [
                    "Jan", 
                    "Damien", 
                    "Laura", 
                    "Gwendolyn", 
                    "Roseanna"
                ], 
                "Duration": 40, 
                "DurationUnit": "Minutes", 
                "Name": "Breakfast"
            }
        ], 
        "FullHours": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        "Sunrise": true, 
        "Sunset": false, 
    }

    {
     "_id":"some_doc_id",
     "_rev":"D1C946B7",
     "Subject":"I like Plankton",
     "Author":"Rusty",
     "PostedDate":"2006-08-15T17:30:12-04:00",
     "Tags":["plankton", "baseball", "decisions"],
     "Body":"I decided today that I don't like baseball. I like plankton."
    }

### Special Fields ###

Note that any top-level fields with a name that starts with a `_` prefix are
reserved for use by CouchDB itself. Also see [Reserved Words][reserved_words].
Current (0.10+) reserved fields are:

<table>
  <tr>
    <th>Field Name</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>_id</td>
    <td>The unique identifier of the document.</td>
  </tr>
  <tr>
    <td>_rev</td>
    <td>The current MVCC-token/revision of this document</td>
  </tr>
  <tr>
    <td>_attachments</td>
    <td>
      If the document has attachments, _attachments holds a (meta-)data
      structure (see the [attachments api][doc_api])
    </td>
  </tr>
  <tr>
    <td>_deleted</td>
    <td>
      Indicates that this document has been deleted and will be removed on
      next compaction run
    </td>
  </tr>
  <tr>
    <td>_revisions</td>
    <td>
      If the document was requested with *?revs=true* this field will hold
      a simple list of the documents history
    </td>
  </tr>
  <tr>
    <td>_rev_infos</td>
    <td>
      Similar to *_revisions*, but more details about the history and the
      availability of ancient versions of the document
    </td>
  </tr>
  <tr>
    <td>_conflicts</td>
    <td>Information about conflicts</td>
  </tr>
  <tr>
    <td>_deleted_conflicts</td>
    <td>Information about conflicts</td>
  </tr>
</table>

#### Document IDs ####

Document IDs don't have restrictions on what characters can be used. Although
it should work, it is recommended to use non-special characters for document
IDs. Using special characters you have to be aware of proper URL en-/decoding.
Documents prefixed with *_* are special documents:

<table>
  <tr>
    <th>Document ID prefix</th>
    <th>Description</th>
  </tr>
  <tr>
    <td>_design/</td>
    <td>are [Design Documents][design_docs]</td>
  </tr>
  <tr>
    <td>_local/</td>
    <td>are [Local Documents]</td>
  </tr>
</table>

You can have `/` as part of the document ID but if you refer to a document in a URL you must always encode it as `%2F`. One special case is `_design/` documents, those accept either `/` or `%2F` for the `/` after `_design`, although `/` is preferred and `%2F` is still needed for the rest of the DocID.

Working With Documents Over HTTP
--------------------------------

### GET
To retrieve a document, simply perform a `GET` operation at the document's URL:

    GET /somedatabase/some_doc_id HTTP/1.0

Here is the server's response:

    HTTP/1.1 200 OK
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close

    {
     "_id":"some_doc_id",
     "_rev":"946B7D1C",
     "Subject":"I like Plankton",
     "Author":"Rusty",
     "PostedDate":"2006-08-15T17:30:12Z-04:00",
     "Tags":["plankton", "baseball", "decisions"],
     "Body":"I decided today that I don't like baseball. I like plankton."
    }

#### Accessing Previous Revisions
See DocumentRevisions for additional notes on revisions.

The above example gets the current revision. You may be able to get a specific revision by using the following syntax:

    GET /somedatabase/some_doc_id?rev=946B7D1C HTTP/1.0

To find out what revisions are available for a document, you can do:

    GET /somedatabase/some_doc_id?revs=true HTTP/1.0

This returns the current revision of the document, but with an additional field, *_revisions*, the value being a list of the available revision IDs. *Note though that not every of those revisions of the document is necessarily still available.* For example, the content of an old revision get removed by compacting the database, or it may only exist in a different database if it was replicated.

To get more detailed information about the available document revisions, use the *revs_info* parameter instead. In this case, the JSON result will contain a *_revs_info* property, which is an array of objects, for example:

    {
      "_revs_info": [
        {"rev": "123456", "status": "disk"},
        {"rev": "234567", "status": "missing"},
        {"rev": "345678", "status": "deleted"},
      ]
    }

Here, *disk* means the revision content is stored on disk and can still be retrieved. The other values indicate that the content of that revision is not available.

You can fetch the bodies of multiple revisions at once using the parameter `open_revs=["rev1","rev2",...]`, or you can fetch all leaf revisions using `open_revs=all` (see [[Replication_and_conflicts]]). The JSON returns an array of objects with an "ok" key pointing to the document, or a "missing" key pointing to the rev string.

    [
    {"missing":"1-fbd8a6da4d669ae4b909fcdb42bb2bfd"},
    {"ok":{"_id":"test","_rev":"2-5bc3c6319edf62d4c624277fdd0ae191","hello":"foo"}}
    ]


### PUT
To create new document you can either use a *POST* operation or a *PUT* operation. To create/update a named document using the PUT operation, the URL must point to the document's location.

The following is an example HTTP *PUT*. It will cause the CouchDB server to generate a new revision ID and save the document with it.

    PUT /somedatabase/some_doc_id HTTP/1.0
    Content-Length: 245
    Content-Type: application/json

    {
      "Subject":"I like Plankton",
      "Author":"Rusty",
      "PostedDate":"2006-08-15T17:30:12-04:00",
      "Tags":["plankton", "baseball", "decisions"],
      "Body":"I decided today that I don't like baseball. I like plankton."
    }

Here is the server's response.

    HTTP/1.1 201 Created
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close

    {"ok": true, "id": "some_doc_id", "rev": "946B7D1C"}

To update an existing document, you also issue a *PUT* request. In this case, the JSON body must contain a *_rev* property, which lets CouchDB know which revision the edits are based on. If the revision of the document currently stored in the database doesn't match, then a *409* conflict error is returned.

If the revision number does match what's in the database, a new revision number is generated and returned to the client.

For example:

    PUT /somedatabase/some_doc_id HTTP/1.0
    Content-Length: 245
    Content-Type: application/json
    
    {
      "_id":"some_doc_id",
      "_rev":"946B7D1C",
      "Subject":"I like Plankton",
      "Author":"Rusty",
      "PostedDate":"2006-08-15T17:30:12-04:00",
      "Tags":["plankton", "baseball", "decisions"],
      "Body":"I decided today that I don't like baseball. I like plankton."
    }

Here is the server's response if what is stored in the database is revision *946B7D1C* of document *some_doc_id*.

    HTTP/1.1 201 Created
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close
    
    {"ok":true, "id":"some_doc_id", "rev":"2774761002"}

And here is the server's response if there is an update conflict (what is currently stored in the database is not revision *946B7D1C* of document *some_doc_id*).


    HTTP/1.1 409 Conflict
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Length: 33
    Connection: close
    
    {"error":"conflict","reason":"Document update conflict."}

There is a query option *batch=ok* which can be used to achieve higher throughput at the cost of lower guarantees. When a *PUT* (or a document *POST* as described below) is sent using this option, it is not immediately written to disk. Instead it is stored in memory on a per-user basis for a second or so (or the number of docs in memory reaches a certain point). After the threshold has passed, the docs are committed to disk. Instead of waiting for the doc to be written to disk before responding, CouchDB sends an HTTP *202 Accepted* response immediately.

*batch=ok* is not suitable for crucial data, but it ideal for applications like logging which can accept the risk that a small proportion of updates could be lost due to a crash. Docs in the batch can also be flushed manually using the *_ensure_full_commit* API.

### POST
The *POST* operation can be used to create a new document with a server generated DocID. To create a named document, use the *PUT* method instead. It is recommended that you avoid *POST* when possible, because proxies and other network intermediaries will occasionally resend *POST* requests, which can result in duplicate document creation. If your client software is not capable of guaranteeing uniqueness of generated UUIDs, use a *GET* to */_uuids?count=100* to retrieve a list of document IDs for future *PUT* requests. Please note that the */_uuids*-call does not check for existing document ids; collision-detection happens when you are trying to save a document.

The following is an example HTTP *POST*. It will cause the CouchDB server to generate a new DocID and revision ID and save the document with it.

    POST /somedatabase/ HTTP/1.0
    Content-Length: 245
    Content-Type: application/json
    
    {
      "Subject":"I like Plankton",
      "Author":"Rusty",
      "PostedDate":"2006-08-15T17:30:12-04:00",
      "Tags":["plankton", "baseball", "decisions"],
      "Body":"I decided today that I don't like baseball. I like plankton."
    }

Here is the server's response:


    HTTP/1.1 201 Created
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close

    {"ok":true, "id":"123BAC", "rev":"946B7D1C"}

### DELETE
To delete a document, perform a *DELETE* operation at the document's location, passing the *rev* parameter with the document's current revision. If successful, it will return the revision id for the deletion stub.


    DELETE /somedatabase/some_doc?rev=1582603387 HTTP/1.0

As an alternative you can submit the *rev* parameter with the etag header field *If-Match*.

    DELETE /somedatabase/some_doc HTTP/1.0
    If-Match: "1582603387"

And the response:

    HTTP/1.1 200 OK
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close

    {"ok":true,"rev":"2839830636"}


### COPY
Note that this is a non-standard extension to HTTP.

You can copy documents by sending an HTTP COPY request. This allows you to duplicate the contents (and attachments) of a document to a new document under a different document id without first retrieving it from CouchDB. Use the *Destination* header to specify the document that you want to copy to (the target document).

It is not possible to copy documents between databases and it is not (yet) possible to perform bulk copy operations.

    COPY /somedatabase/some_doc HTTP/1.1
    Destination: some_other_doc

If you want to overwrite an existing document, you need to specify the target document's revision with a *rev* parameter in the *Destination* header:

    COPY /somedatabase/some_doc HTTP/1.1
    Destination: some_other_doc?rev=rev_id

The response in both cases includes the target document's revision:

    HTTP/1.1 201 Created
    Server: CouchDB/0.9.0a730122-incubating (Erlang OTP/R12B)
    Etag: "355068078"
    Date: Mon, 05 Jan 2009 11:12:49 GMT
    Content-Type: text/plain;charset=utf-8
    Content-Length: 41
    Cache-Control: must-revalidate

    {"ok":true,"id":"some_other_doc","rev":"355068078"}

### MOVE
For a ~6 month period CouchDB trunk between versions 0.8 and 0.9 included the nonstandard MOVE method. Since MOVE is really just COPY & DELETE and CouchDB can not reasonably guarantee atomicity between the COPY & MOVE operations on a single or on multiple nodes, this was removed before the release of CouchDB 0.9.

### Bulk Docs
For information about editing multiple documents at the same time, see [[HTTP_Bulk_Document_API]]

## All Documents
To get a listing of all documents in a database, use the special *_all_docs* URI. This is a specialized View so the Querying Options of the [[HTTP_view_API]] apply here.


    GET somedatabase/_all_docs HTTP/1.0

Will return a listing of all documents and their revision IDs, ordered by DocID (case sensitive):


    HTTP/1.1 200 OK
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close
    
    {
      "total_rows": 3, "offset": 0, "rows": [
        {"id": "doc1", "key": "doc1", "value": {"rev": "4324BB"}},
        {"id": "doc2", "key": "doc2", "value": {"rev":"2441HF"}},
        {"id": "doc3", "key": "doc3", "value": {"rev":"74EC24"}}
      ]
    }

Use the query argument *descending=true* to reverse the order of the output table:

Will return the same as before but in reverse order:

    HTTP/1.1 200 OK
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close

    {
      "total_rows": 3, "offset": 0, "rows": [
        {"id": "doc3", "key": "doc3", "value": {"rev":"74EC24"}}
        {"id": "doc2", "key": "doc2", "value": {"rev":"2441HF"}},
        {"id": "doc1", "key": "doc1", "value": {"rev": "4324BB"}},
      ]
    }

The query string parameters *startkey*, *endkey* and *limit* may also be used to limit the result set. For example:


    GET somedatabase/_all_docs?startkey="doc2"&limit=2 HTTP/1.0

Will return:


    HTTP/1.1 200 OK
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close

    {
      "total_rows": 3, "offset": 1, "rows": [
        {"id": "doc2", "key": "doc2", "value": {"rev":"2441HF"}},
        {"id": "doc3", "key": "doc3", "value": {"rev":"74EC24"}}
      ]
    }

Use *endkey* if you are interested  in a specific range of documents:


    GET somedatabase/_all_docs?startkey="doc2"&endkey="doc3" HTTP/1.0

This will get keys inbetween and including doc2 and doc3; e.g. *doc2-b* and *doc234*.

Both approaches can be combined with *descending*:


    GET somedatabase/_all_docs?startkey="doc2"&limit=2&descending=true HTTP/1.0

Will return:


    HTTP/1.1 200 OK
    Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
    Content-Type: application/json
    Connection: close

    {
      "total_rows": 3, "offset": 1, "rows": [
        {"id": "doc3", "key": "doc3", "value": {"rev":"74EC24"}}
        {"id": "doc2", "key": "doc2", "value": {"rev":"2441HF"}},
      ]
    }

If you add *include_docs=true* to a request to *_all_docs* not only metadata but also the documents themselves are returned.

## all_docs_by_seq
This allows you to see all the documents that were updated and deleted, in the order these actions are done:


    GET somedatabase/_all_docs_by_seq HTTP/1.0

Will return:


    HTTP/1.1 200 OK
    Date: Fri, 8 May 2009 11:07:02 +0000GMT
    Content-Type: application/json
    Connection: close

    {
      "total_rows": 4, "offset": 0, "rows": [
        {"id": "doc1", "key": "1", "value": {"rev":"1-4124667444"}},
        {"id": "doc2", "key": "2", "value": {"rev":"1-1815587255"}},
        {"id": "doc3", "key": "3", "value": {"rev":"1-1750227892"}},
        {"id": "doc4", "key": "4", "value": {"rev":"2-524044848", "deleted": true}}
      ]
    }

All the view parameters work on _all_docs_by_seq, such as startkey, include_docs etc. However, note that the startkey is exclusive when applied to this view. This allows for a usage pattern where the startkey is set to the sequence id of the last doc returned by the previous query. As the startkey is exclusive, the same document won't be processed twice.

## Attachments
Documents can have attachments just like email. There are two ways to use attachments. The first one is inline with your document and it described first. The second one is a separate REST API for attachments that is described a little further down.

A note on attachment names: Attachments may have embedded **/** characters that are sent unescaped to CouchDB. You can use this to provide a subtree of attachments under a document. A DocID must have any **/** escaped as **%2F**. So if you have document *a/b/c* with an attachment *d/e/f.txt*, you would be able to access it at [[http://couchdb/db/a/b/c/d/e/f.txt|http://couchdb/db/a%2fb%2fc/d/e/f.txt]] .

### Inline Attachments
On creation, attachments go into a special *_attachments* attribute of the document. They are encoded in a JSON structure that holds the name, the content_type and the base64 encoded data of an attachment. A document can have any number of attachments.

When retrieving documents, the attachment's actual data is not included, only the metadata. The actual data has to be fetched separately, using a special URI.

If you need to access attachments with the document in one request, you can pass in the `?attachments=true` URL parameter to get the data included in the JSON in the base64 encoded form. Since this puts a significant burden on CouchDB when you request this, you're not advised to use this feature unless you know what you are doing :)

Creating a document with an attachment:


    {
      "_id":"attachment_doc",
      "_attachments":
      {
        "foo.txt":
        {
          "content_type":"text\/plain",
          "data": "VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ="
        }
      }
    }

Please note that any base64 data you send has to be on **a single line of characters**, so pre-process your data to remove any carriage returns and newlines.

Requesting said document:


    GET /database/attachment_doc

CouchDB replies:


    {
      "_id":"attachment_doc",
      "_rev":1589456116,
      "_attachments":
      {
        "foo.txt":
        {
          "stub":true,
          "content_type":"text\/plain",
          "length":29
        }
      }
    }

Note that the *"stub":true* attribute denotes that this is not the complete attachment. Also, note the length attribute added automatically. When you update the document you must include the attachment stubs or CouchDB will delete the attachment.

Requesting the attachment:


    GET /database/attachment_doc/foo.txt

CouchDB returns:


    This is a base64 encoded text

Automatically decoded!

### Multiple Attachments
Creating a document with an attachment:


    {
      "_id":"attachment_doc",
      "_attachments":
      {
        "foo.txt":
        {
          "content_type":"text\/plain",
          "data": "VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ="
        },

       "bar.txt":
        {
          "content_type":"text\/plain",
          "data": "VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ="
        }
      }
    }

### Standalone Attachments
Note: This was added in version 0.9 of CouchDB. It is not available in earlier version.

CouchDB allows to create, change and delete attachments without touching the actual document. As a bonus feature, you do not have to base64 encode your data. This can significantly speed up requests since CouchDB and your client do not have to do the base64 conversion.

You need to specify a MIME type using the Content-Type header. CouchDB will serve the attachment with the specified Content-Type when asked.

To create an attachment:


    PUT somedatabase/document/attachment?rev=123 HTTP/1.0
    Content-Length: 245
    Content-Type: image/jpeg

    <JPEG data>

CouchDB replies:


    {"ok": true, "id": "document", "rev": "765B7D1C"}

Note that you can do this on a non-existing document. The document and attachment will be created implicitly for you. A revision id must not be specified in this case.

To change an attachment:


    PUT somedatabase/document/attachment?rev=765B7D1C HTTP/1.0
    Content-Length: 245
    Content-Type: image/jpeg

    <JPEG data>

CouchDB replies:


    {"ok": true, "id": "document", "rev": "766FC88G"}

To delete an attachment:


    DELETE somedatabase/document/attachment?rev=765B7D1C HTTP/1.0

CouchDB replies:


    {"ok":true,"id":"document","rev":"519558700"}

To retrieve an attachment:


    GET somedatabase/document/attachment HTTP/1.0

CouchDB replies


    Content-Type:image/jpeg
      
      <JPEG data>

## ETags/Caching
CouchDB sends an *ETag* Header for document requests. The ETag Header is simply the document's revision in quotes.

For example, a *GET* request:


    GET /database/123182719287

Results in a reply with the following headers:


    cache-control: no-cache,
    pragma: no-cache
    expires: Tue, 13 Nov 2007 23:09:50 GMT
    transfer-encoding: chunked
    content-type: text/plain;charset=utf-8
    etag: "615790463"

*POST* requests also return an *ETag* header for either newly created or updated documents.
