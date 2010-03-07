There is a nascent interface being built for [[http://www.cincomsmalltalk.com|Cincom Smalltalk]].  To try that out, you'll need to:

 * [[http://www.cincomsmalltalk.com/scripts/CommunityDownloadPage.ssp|Download Cincom Smalltalk]]
 * Get an Account in the [[http://www.cincomsmalltalk.com/CincomSmalltalkWiki/Public+Store+Repository|Cincom Smalltalk Public Repository]]
 * Load the "CouchDB" package from the repository

Once it's loaded, you can try things like this:

{{{
"A simple interface to Couch DB.  To create, delete, and query databases, try:"
CouchDB.Interface default databases.
CouchDB.Interface default create: 'mydb'.
CouchDB.Interface default delete: 'mydb'.
CouchDB.Interface default database: 'mydb'

"Further, you can then manipulate documents in a database, try:"
myDatabase := CouchDB.Interface default database: 'mydb'.
documentRecord := myDatabase save: myDatabase address.
myDatabase document: (documentRecord at: 'id').
myDatabase delete: (documentRecord at: 'id') revision: (documentRecord at: 'rev').



}}}


The APIs for database are fully implemented, and, other than attachments, the APIs for documents are fully implemented as well
