Getting started with Python and the CouchDB API.

== Library ==
=== couchdbkit ===
 . http://couchdbkit.org/

Start using Couchdbkit by reading the [[http://couchdbkit.org/docs/gettingstarted.html|Getting Started tutorial]].

For django use the [[http://www.couchdbkit.org/docs/django-extension.html|django extension]] of couchdbkit. Other extension exists for [[http://docs.formalchemy.org/ext/couchdb.html|formalchemy]].

=== couchdb-python ===
The code for the Python library can be obtained from:

 . http://code.google.com/p/couchdb-python

From a terminal window:

{{{
$ wget http://peak.telecommunity.com/dist/ez_setup.py
$ sudo python ez_setup.py
$ wget http://pypi.python.org/packages/2.5/C/CouchDB/CouchDB-0.6-py2.5.egg
$ sudo easy_install CouchDB-0.6-py2.5.egg
}}}
This first downloads and installs the ''ez_setup.py'' script which runs python ''.egg'' files. The second part downloads the ''.egg'' file for CouchDB and installs it along with its dependencies.

=== couchquery ===
 . http://mikeal.github.com/couchquery/

== Tutorial on using couchdb-python with Django ==
A tutorial on using Django (a Python framework) with CouchDb can be found at

 . http://lethain.com/entry/2008/aug/18/an-introduction-to-using-couchdb-with-django/ http://www.eflorenzano.com/blog/post/using-couchdb-django/

Alternatively you can view just the source for that example at

 . http://github.com/lethain/comfy-django-example/tree/master

== Example Wrapper Class ==
Demonstration of basic API-interaction using Python. (note: as of python 2.6, one can use "import json" for the same functionality in this script.)

{{{#!python
#! /usr/bin/python2.4

import httplib, simplejson  # http://cheeseshop.python.org/pypi/simplejson
                            # Here only used for prettyprinting

def prettyPrint(s):
    """Prettyprints the json response of an HTTPResponse object"""

    # HTTPResponse instance -> Python object -> str
    print simplejson.dumps(simplejson.loads(s.read()), sort_keys=True, indent=4)

class Couch:
    """Basic wrapper class for operations on a couchDB"""

    def __init__(self, host, port=5984, options=None):
        self.host = host
        self.port = port

    def connect(self):
        return httplib.HTTPConnection(self.host, self.port) # No close()

    # Database operations

    def createDb(self, dbName):
        """Creates a new database on the server"""

        r = self.put(''.join(['/',dbName,'/']), "")
        prettyPrint(r)

    def deleteDb(self, dbName):
        """Deletes the database on the server"""

        r = self.delete(''.join(['/',dbName,'/']))
        prettyPrint(r)

    def listDb(self):
        """List the databases on the server"""

        prettyPrint(self.get('/_all_dbs'))

    def infoDb(self, dbName):
        """Returns info about the couchDB"""
        r = self.get(''.join(['/', dbName, '/']))
        prettyPrint(r)

    # Document operations

    def listDoc(self, dbName):
        """List all documents in a given database"""

        r = self.get(''.join(['/', dbName, '/', '_all_docs']))
        prettyPrint(r)

    def openDoc(self, dbName, docId):
        """Open a document in a given database"""
        r = self.get(''.join(['/', dbName, '/', docId,]))
        prettyPrint(r)

    def saveDoc(self, dbName, body, docId=None):
        """Save/create a document to/in a given database"""
        if docId:
            r = self.put(''.join(['/', dbName, '/', docId]), body)
        else:
            r = self.post(''.join(['/', dbName, '/']), body)
        prettyPrint(r)

    def deleteDoc(self, dbName, docId):
        # XXX Crashed if resource is non-existent; not so for DELETE on db. Bug?
        # XXX Does not work any more, on has to specify an revid
        #     Either do html head to get the recten revid or provide it as parameter
        r = self.delete(''.join(['/', dbName, '/', docId]))
        prettyPrint(r)

    # Basic http methods

    def get(self, uri):
        c = self.connect()
        headers = {"Accept": "application/json"}
        c.request("GET", uri, None, headers)
        return c.getresponse()

    def post(self, uri, body):
        c = self.connect()
        headers = {"Content-type": "application/json"}
        c.request('POST', uri, body, headers)
        return c.getresponse()

    def put(self, uri, body):
        c = self.connect()
        if len(body) > 0:
            headers = {"Content-type": "application/json"}
            c.request("PUT", uri, body, headers)
        else:
            c.request("PUT", uri, body)
        return c.getresponse()

    def delete(self, uri):
        c = self.connect()
        c.request("DELETE", uri)
        return c.getresponse()
}}}
== Usage Example ==
{{{#!python
def test():
    foo = Couch('localhost', '5984')

    print "\nCreate database 'mydb':"
    foo.createDb('mydb')

    print "\nList databases on server:"
    foo.listDb()

    print "\nCreate a document 'mydoc' in database 'mydb':"
    doc = """
    {
        "value":
        {
            "Subject":"I like Planktion",
            "Author":"Rusty",
            "PostedDate":"2006-08-15T17:30:12-04:00",
            "Tags":["plankton", "baseball", "decisions"],
            "Body":"I decided today that I don't like baseball. I like plankton."
        }
    }
    """
    foo.saveDoc('mydb', doc, 'mydoc')

    print "\nCreate a document, using an assigned docId:"
    foo.saveDoc('mydb', doc)

    print "\nList all documents in database 'mydb'"
    foo.listDoc('mydb')

    print "\nRetrieve document 'mydoc' in database 'mydb':"
    foo.openDoc('mydb', 'mydoc')

    print "\nDelete document 'mydoc' in database 'mydb':"
    foo.deleteDoc('mydb', 'mydoc')

    print "\nList all documents in database 'mydb'"
    foo.listDoc('mydb')

    print "\nList info about database 'mydb':"
    foo.infoDb('mydb')

    print "\nDelete database 'mydb':"
    foo.deleteDb('mydb')

    print "\nList databases on server:"
    foo.listDb()

if __name__ == "__main__":
    test()
}}}
== Sample Output ==
{{{#!java
Create database 'mydb':
{
    "ok": true
}

List databases on server:
[
    "mydb"
]

Create a document 'mydoc' in database 'mydb':
{
    "_id": "mydoc",
    "_rev": 362213977,
    "ok": true
}

Create a document, using an assigned docId:
{
    "_id": "CF29360495B2AAB44C7E43E5752A5123",
    "_rev": 627930386,
    "ok": true
}

List all documents in database 'mydb'
{
    "rows": [
        {
            "_id": "CF29360495B2AAB44C7E43E5752A5123",
            "_rev": 627930386
        },
        {
            "_id": "mydoc",
            "_rev": 362213977
        }
    ],
    "view": "_all_docs"
}

Retrieve document 'mydoc' in database 'mydb':
{
    "_id": "mydoc",
    "_rev": 362213977,
    "value": {
        "Author": "Rusty",
        "Body": "I decided today that I don't like baseball. I like plankton.",
        "PostedDate": "2006-08-15T17:30:12-04:00",
        "Subject": "I like Planktion",
        "Tags": [
            "plankton",
            "baseball",
            "decisions"
        ]
    }
}

Delete document 'mydoc' in database 'mydb':
{
    "_rev": 3811288472,
    "ok": true
}

List all documents in database 'mydb'
{
    "rows": [
        {
            "_id": "CF29360495B2AAB44C7E43E5752A5123",
            "_rev": 627930386
        }
    ],
    "view": "_all_docs"
}

List info about database 'mydb':
{
    "db_name": "mydb",
    "doc_count": 1,
    "update_seq": 3
}

Delete database 'mydb':
{
    "ok": true
}

List databases on server:
[]
}}}
