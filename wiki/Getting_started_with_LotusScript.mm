## page was renamed from Getting Started With LotusScript
## page was renamed from GettingStartedLotusScript
Getting started with !LotusScript and the CouchDB API.

This is an example of wrapper classes that use LS2J to send requests to a CouchDB server from !LotusScript. This could be useful to move data between Domino databases and CouchDB databases. The !LotusScript code roughly tracks the structure of the Ruby code.

== Basic API ==

{{{
Option Public
Uselsx "*javacon"
}}}

{{{
Sub Initialize
%REM
LotusScript LS2J classes for CouchDb
Copyright (C) 2006  Alan Bell - Dominux Consulting

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
%ENDREM
  'right now this just implements the basic database operations
  'feel free to fix bugs and add functionailty to it in the Wiki
  'there is a total lack of releasing of objects right now so it will leak memory like a sieve
  'error handling would be nice too.
  Dim cserver As couchserver
  Set cserver=New couchserver("http://localhost","5984","")
  'create a database
  Call cserver.put("/ls2couch/","")
  'create a document
  Call cserver.put("/ls2couch/document_id", |{"type":"comment","body":"First Post!"}|)
  'retrieve the document
  Print cserver.cget("/ls2couch/document_id")
  'delete the database
  Call cserver.del("/ls2couch/")
End Sub
}}}

{{{
Class couchserver
  Private host As String
  Private port As String
  Private options As String
  Private proxyserver As String
  Private proxyport As String
  Private jses As JAVASESSION
  Private jclass As JAVACLASS
  Private jurl As JAVAOBJECT
  Private jcon As JAVAOBJECT
  Sub new(host As String,port As String,options As String)
    'this corresponds to the initialise method in the Ruby classes
    Me.host=host
    Me.port=port
    Me.options=options
    Set Me.jses=New JAVASESSION()
  End Sub

  Sub setproxy(proxyserver As String,proxyport As String)
    'this should do something. At the moment it does not.
    Me.proxyserver=proxyserver
    Me.proxyport=proxyport
  End Sub

  Sub del(uri As String)
  'this corresponds to the delete method in the Ruby classes
    Set Me.jclass=jses.GetClass("java/net/URL")
    Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
    Set jcon=jurl.openConnection()
    Me.jcon.setRequestMethod("DELETE")
    Call Me.jcon.connect()
    Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
    Call ist.close()
  End Sub

  Function cget(uri As String) As String
    'this corresponds to the get class in Ruby. "get" is a reserved word
    Set Me.jclass=jses.GetClass("java/net/URL")
    Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
    Set jcon=jurl.openConnection()
    Me.jcon.setRequestMethod("GET")
    Call Me.jcon.connect()
    Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
    Set Me.jclass=jses.GetClass("java/io/InputStreamReader")
    Set ireader=Me.jclass.CreateObject("(Ljava/io/InputStream;)V",ist)
    Set Me.jclass=jses.GetClass("java/io/BufferedReader")
    Set bReader=Me.jclass.CreateObject("(Ljava/io/Reader;)V",ireader)
    cget=bReader.readLine()
    Call ist.close()
  End Function

  Sub put (uri As String,xml As String)
    Set Me.jclass=jses.GetClass("java/net/URL")
    Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
    Set jcon=jurl.openConnection()
    Me.jcon.setRequestMethod("PUT")
    Me.jcon.setdooutput(True)
    Call Me.jcon.connect()
    Set ost=jcon.getOutputStream()
    Set Me.jclass=jses.GetClass("java/io/OutputStreamWriter")
    Set owriter=Me.jclass.CreateObject("(Ljava/io/OutputStream;)V",ost)
    Call owriter.write(xml,0,Len(xml))
    Call owriter.flush()
    Call ost.write(32)
    Call ost.flush()
    Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
    Call ist.close()
  End Sub

  Sub post(uri As String,xml As String)
    Set Me.jclass=jses.GetClass("java/net/URL")
    Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
    Set jcon=jurl.openConnection()
    Me.jcon.setRequestMethod("PUT")
    Me.jcon.setdooutput(True)
    Call Me.jcon.connect()
    Set ost=jcon.getOutputStream()
    Call ost.write(32)
    Call ost.flush()
    Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
    Call ist.close()
  End Sub

End Class
}}}

== Advanced API ==

This !LotusScript API for couch is designed to be familiar to !LotusScript developers. It wraps up all the communication with the CouchDB server, all the JSON code and looks quite a lot like dealing with documents in a domino database. This is very much a work in progress.

To copy a Notes database to a CouchDB database you might use the following code in an agent:

{{{
Sub Initialize
  Dim doc As couchdoc
  Dim ses As New NotesSession
  Dim db As notesdatabase
  Set db=ses.currentdatabase
  Dim cserver As couchserver
  Set cserver=New couchserver("http://localhost","5984","")	'replace with your server location
  Set cdb=New couchdb(db.name,cserver)
  If Not cdb.exists Then
    cdb.create
  End If
  Dim ndoc As NotesDocument
  Dim dbdocs As notesdocumentcollection
  Set dbdocs=db.alldocuments
  Set ndoc=dbdocs.GetFirstDocument
  While Not ndoc Is Nothing
    Set doc=cdb.createdocument(ndoc.UniversalID)
    Forall i In ndoc.Items
      Call doc.additem(i.name,i.text)
    End Forall
    doc.save
    Set ndoc=dbdocs.GetNextDocument(ndoc)
  Wend
End Sub
}}}

Copy the code below into the declarations section of the agent:

{{{
 Class couchserver
 Private host As String
 Private port As String
 Private options As String
 Private proxyserver As String
 Private proxyport As String
 Private jses As JAVASESSION
 Private jclass As JAVACLASS
 Private jurl As JAVAOBJECT
 Private jcon As JAVAOBJECT
 Sub new(host As String,port As String,options As String)
      'this corresponds to the initialise method in the Ruby classes
   'basically creates a new connection to the server
   Me.host=host
   Me.port=port
   Me.options=options
   Set Me.jses=New JAVASESSION()
 End Sub

 Sub setproxy(proxyserver As String,proxyport As String)
      'this should do something. At the moment it does not.
   Me.proxyserver=proxyserver
   Me.proxyport=proxyport
 End Sub

 Sub del(uri As String)
      'this corresponds to the delete method in the Ruby classes
   Set Me.jclass=jses.GetClass("java/net/URL")
   Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
   Set jcon=jurl.openConnection()
   Me.jcon.setRequestMethod("DELETE")
   Call Me.jcon.connect()
   Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
   Call ist.close()
 End Sub

 Function cget(uri As String) As String
      'this corresponds to the get class in Ruby. "get" is a reserved word
   Set Me.jclass=jses.GetClass("java/net/URL")
   Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
   Set jcon=jurl.openConnection()
   Me.jcon.setRequestMethod("GET")
   Call Me.jcon.connect()
   On Error Resume Next
   Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
   Set Me.jclass=jses.GetClass("java/io/InputStreamReader")

   Set ireader=Me.jclass.CreateObject("(Ljava/io/InputStream;)V",ist)
   Set Me.jclass=jses.GetClass("java/io/BufferedReader")
   Set bReader=Me.jclass.CreateObject("(Ljava/io/Reader;)V",ireader)
   cget=bReader.readLine()
   Call ist.close()
 End Function

 Sub put (uri As String,xml As String)
   Set Me.jclass=jses.GetClass("java/net/URL")
   Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
   Set jcon=jurl.openConnection()
   Me.jcon.setRequestMethod("PUT")
   Me.jcon.setdooutput(True)
   Call Me.jcon.connect()
   Set ost=jcon.getOutputStream()
   Set Me.jclass=jses.GetClass("java/io/OutputStreamWriter")
   'Set owriter=Me.jclass.CreateObject("(Ljava/io/OutputStream;)V",ost)
   Set owriter=Me.jclass.CreateObject("(Ljava/io/OutputStream;Ljava/lang/String;)V",ost,"UTF-8")
   Call owriter.write(xml,0,Len(xml))
   Call owriter.flush()
   Call ost.write(32)
   Call ost.flush()
   Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
   Call ist.close()
 End Sub

 Sub post(uri As String,xml As String)
   Set Me.jclass=jses.GetClass("java/net/URL")
   Set Me.jurl=Me.jclass.CreateObject("(Ljava/lang/String;)V",host+":"+port+uri)
   Set jcon=jurl.openConnection()
   Me.jcon.setRequestMet7hod("PUT")
   Me.jcon.setdooutput(True)
   Call Me.jcon.connect()
   Set ost=jcon.getOutputStream()
   Call ost.write(32)
   Call ost.flush()
   Set ist=jcon.getInputStream()'oddly enough java doesn't do anything with a URL until you read from it.
   Call ist.close()
 End Sub

 End Class
}}}

{{{
 Class couchdb
 'this represents a database on the couchdb server
 Public parentserver As couchserver
 Public name As String

 Sub new(dbname As String,server As couchserver)
   Me.name=dbname
   Set Me.parentserver=server
   'well this does not create a new database, just initialises the class and connects it to a database
   'the database might not exist
 End Sub

 Function exists As Boolean
   'tests to see if the parent server already contains a database with this name
   exists= (""<>parentserver.cget("/"+Me.name+"/"))
 End Function

 Sub create
   Call parentserver.put("/"+Me.name+"/","")
 End Sub

 Function createdocument(id As String) As couchdoc
   'this does not create a document on the couchdb server until the document is saved
   'it might check to see if id has already been used and return that document
   'it might create an ID of some kind if one is not provided
   Set createdocument=New couchdoc(Me,id)
 End Function

 End Class
}}}

{{{
 Class couchitem
 Public parentdoc As couchdoc
 'represents one field on a couchdb document
 Public value As Variant
 'does an item know it's own name? not sure.
 Sub new(value As Variant)
   Me.value=value
 End Sub
 Function json As String
   json=|"|+Replace(Me.value,|"|,|\"|)+|"|'escaping out double quotes
 End Function
 End Class
}}}
