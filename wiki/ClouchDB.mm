## page was renamed from GettingStartedWithLisp
Getting started with Common Lisp and the CouchDB API.

== Library ==

The code for Clouchdb, the Common Lisp CouchDB library, as well as full documentation and more detailed examples can be obtained from:

  http://common-lisp.net/project/clouchdb/

This library can also be installed with ASDF:

{{{
CL-USER> (asdf-install:install 'clouchdb)
CL-USER> (asdf:oos 'asdf:load-op '#clouchdb)
}}}

== Using the Library ==

{{{
;; Create a workspace package
(defpackage :clouchdb-user (:use :cl :clouchdb))
(in-package :clouchdb-user)

;; See what databases exist on default connection, which is 
;; host "localhost", port 5984
(list-dbs)

;; Create database "myDb"
(set-connection :db-name "myDb")
(create-db)

;; Create a document in database "myDb"
(create-document '((:Subject . "I like Plankton")
                   (:Author . "Rusty")
                   (:PostedDate . "2006-08-15T17:30:12-04:00")"
                   (:Tags . ("plankton" "baseball" "decisions"))
                  :id "myDoc")

;; Get all documents in "myDb"
(get-all-documents)

;; Get document "myDoc"
(get-document "myDoc")

;; Delete document "myDoc"
(delete-document :id "myDoc")

;; List information about database "myDb"
(get-db-info :db-name "myDb")
}}}
