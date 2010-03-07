This document details item names that have a special system meaning. It also details recommended item names which are not enforced by the system, but may help interoperability of databases if consistent names are used.

== Reserved Item Names ==
System reserved items start with underscore, the other items listed are conventions. 
CouchDb does not allow any user-defined property to begin with an underscore.
=== _id ===
this is the unique ID of the document
=== _rev ===
This is the revision reference of the document
=== _attachments ===
This is an array of attachments on the document.
=== _conflicts ===
This attribute is set if the document has a conflict.



= Proposals =
These recommended names have never been used for anything and are proposals for future use.
== Reserved Document IDs ==
=== favicon ===
This contains an image representing the database. The icon is an attachment to this document, it can be in SVG or PNG format. A client application may scan all databases on a CouchDB server retrieving their icons.
=== Security ===
The security document may contain a datastructure that defines the rights users have to all or parts of the database. This may be enforced by a client library or perhaps by the database.
=== form ===
This contains a single text string to identify the user interface to be used to display the document. The text string could be the ID of another couchdb document which contains the definition of the form.
=== subject ===
The subject should contain a single text string with a human readable description of the document.
=== security ===
The security item contains a javascript function defining the identity of people and things allowed to read, update and delete this document. The function would be passed the document, the database security document, an object representing the person's LDAP entry (so groups etc can be looked up) and the operation requested (normally one of "read", "update", "delete" but others could be invented). It returns true to allow the operation to continue or false to prevent it. Using javascript in this way would allow time based security rules (e.g. allow updates for 1 hour after creation) and much more.
