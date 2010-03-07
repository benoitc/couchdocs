Tags are stored as a list of strings inside the document:

{{{
{
 "_id":"123BAC",
 "_rev":"946B7D1C",
 "type":"post",
 "subject":"I like Planktion",
 "author":"Rusty",
 "created":"2006-08-15T17:30:12Z-04:00",
 "body":"I decided today that I don't like baseball. I like plankton.",
 "tags":["plankton", "baseball", "decisions"]
}
}}}

== CouchDB Views ==

'''Retrieve all tags with their counts:'''

''map''

{{{
function(doc) {
  if (doc.type == 'post' && doc.tags) {
    doc.tags.forEach(function(tag) {
      emit(tag, 1);
    });
  }
}
}}}

''reduce''

{{{
function(keys, values) {
  return sum(values);
}
}}}

Note: when retrieving data from this view, if the results are reduced to a single row, you may need to use the ?group=true option to get counts reduced by tag.  This may be a feature in version 0.8.0 and forward? see HttpViewApi.

'''Retrieve documents by a specific tag:'''

''map''

{{{
function(doc) {
  if (doc.type == 'post' && doc.tags) {
    doc.tags.forEach(function(tag) {
      emit(tag, doc);
    });
  }
}
}}}
