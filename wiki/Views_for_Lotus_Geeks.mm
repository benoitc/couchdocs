CouchDB and Lotus Notes are both document databases with many similarities in terms of the data model and the way views work. Many of the best practices and limitations are the same for each, but there is new terminology to learn and some pretty powerful extra things you can do in CouchDB.

== A simple view ==
For this example lets assume we have a database of really simple task documents, each consisting of four text fields. Like Notes CouchDB can have fields that contain arrays, in fact they can contain arbitarily complex data structures, and just like Notes it is schema free so not all documents have to contain a set collection of fields. For now, lets keep it simple with these documents:

{{{
Form:"Task"
Priority:"Medium"
Subject:"Service Car"
Created:"Wed Dec 4 00:00:00 2009"
}}}
{{{
Form:"Task"
Priority:"High"
Subject:"Book restaurant for mum's birthday"
Created:"Thu Dec 5 00:00:00 2009"
}}}
{{{
Form:"Task"
Priority:"Medium"
Subject:"Return library books"
Created:"Sat Jan 2 00:00:00 2010"
}}}
The first thing to notice is that the Created field is in a funny format for Notes, this is a C format datetime string, it is human readable and works well in C, Python and Javascript. It doesn't sort well as text, but can be converted to a sortable value in a javascript view function. We will come back to times and dates in views later, but one thing worth mentioning is that you don't use the current time in a couchdb view formula just like you don't use @now in a view selection or column formula for exactly the same reason.

In Notes we might display the documents in a flat view (categorisation comes later)

The Selection formula would be:

{{{
Select form="Task"
}}}
And view columns would be Priority (sorted), Created (sorted, hidden) and Subject
||<tablewidth="599px" tableheight="227px"style="font-weight: bold;">Priority ||<style="font-weight: bold;">Created ||<style="font-weight: bold;">Subject ||
||High || ||Book restaurant for mum's birthday ||
||Medium || ||Service Car ||
||Medium || ||Return library books ||




In CouchDB an equivalent view formula would be

{{{
function(doc) {
    if(doc.form=="Task"){
        emit([doc.priority,new Date.parse(doc.created)],[doc.priority,doc.subject])
    }
}
}}}
The selection formula in notes ends up in the javascript if statement, note the double "==" which is the operator to test for equality. In javascript a single "=" is the assignment operator (like := in formula language) if you use a single "=" then it would return all documents, with their form fields assigned to "Task".

The emit function has two parameters, the keys and the values. Keys are kind of like categories or sorted columns. Values are kind of like column values. If you want you can think of it like a view with hidden sorted columns as the keys followed by a set of unsorted columns - the values. In order to get the dates sorting correctly we are creating parsing the string with javascript to create a number of milliseconds from January 1st 1970
