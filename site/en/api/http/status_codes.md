template: page.html
title: HTTP Status Codes

A list of HTTP statuses used by CouchDB and their respective meanings.

<table>
  <tr>
    <th>200 OK</th>
    <td>Request completed successfully.</td>
  </tr>
  <tr>
    <th>201 Created</th>
    <td>Document created successfully.</td>
  </tr>
  <tr>
    <th>202 Accepted</th>
    <td>Request for database compaction completed successfully.</td>
  </tr>
  <tr>
    <th>304 Not Modified</th>
    <td>Etag not modified since last update.</td>
  </tr>
  <tr>
    <th>400 Bad Request</th>
    <td>The request was not valid in some way.</td>
  </tr>
  <tr>
    <th>404 Not Found</th>
    <td>
      Such as a request via the HttpDocumentApi for a document which
      doesn't exist.
    </td>
  </tr>
  <tr>
    <th>405 Method Not Allowed</th>
    <td>The provided method is not valid for this resource.</td>
  </tr>
  <tr>
    <th>409 Conflict</th>
    <td>Request resulted in an update conflict.</td>
  </tr>
  <tr>
    <th>412 Precondition Failed</th>
    <td>Request attempted to create a database which already exists.</td>
  </tr>
  <tr>
    <th>500 Internal Server Error</th>
    <td>CouchDB had an internal error.</td>
  </tr>
</table>

As you can see, this document is incomplete, please update.
