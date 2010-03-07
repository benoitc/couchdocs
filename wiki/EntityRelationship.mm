= Modeling Entity Relationships in CouchDB =

This page is mostly a translation of Google's [[http://code.google.com/appengine/articles/modeling.html|Modeling Entity Relationships]] article in CouchDB terms. It could use more code examples and more examples of actual output. Since this is a wiki, feel free to update this document to make things clearer, fix inaccuracies etc. This article is also related to [[http://wiki.apache.org/couchdb/Transaction_model_use_cases|Transaction model use cases]] discussion, as it involves multiple document updates.

As a quick summary, this document explains how to do things that you would normally use SQL JOIN for.

== Why would I need entity relationships? ==
Imagine you are building a snazzy new web application that includes an address book where users can store their contacts. For each contact the user stores, you want to capture the contacts name, birthday (which they mustn't forget!) their address, telephone number and company they work for.
When the user wants to add an address, they enter the information in to a form and the form saves the information in a model that looks something like this:
{{{
{
  "_id":"some unique string that is assigned to the contact",
  "type":"contact",
  "name":"contact's name",
  "birth_day":"a date in string form",
  "address":"the address in string form (like 1600 Ampitheater Pkwy., Mountain View, CA)",
  "phone_number":"phone number in string form",
  "company_title":"company title",
  "company_name":"name of the company",
  "company_description":"some explanation about the company",
  "company_address":"the company address in string form"
}
}}}
(Note that ''type'' doesn't mean anything to CouchDB, we're just using it here for our own convenience. ''_id'' is the only thing CouchDB looks at)

That's great, your users immediately begin to use their address book and soon the datastore starts to fill up. Not long after the deployment of your new application you hear from someone that they are not happy that there is only one phone number. What if they want to store someone's work telephone number in addition to their home number? No problem you think, you can just add a work phone number to your structure. You change your data structure to look more like this:
{{{
  "phone_number":"home phone in string form",
  "work_phone_number":"work phone in string form",
}}}
Update the form with the new field and you are back in business. Soon after redeploying your application, you get a number of new complaints. When they see the new phone number field, people start asking for even more fields. Some people want a fax number field, others want a mobile field. Some people even want more than one mobile field (boy modern life sure is hectic)! You could add another field for fax, and another for mobile, maybe two. What about if people have three mobile phones? What if they have ten? What if someone invents a phone for a place you've never thought of?
Your model needs to use relationships.

== One to Many ==
The answer is to allow users to assign as many phone numbers to each of their contacts as they like.

In CouchDB, there are 2 ways to achieve this.
 1. Use separate documents
 2. Use an embedded array

=== One to Many: Separate documents ===

When using separate documents, you could have documents like this for the phone numbers:
{{{
{
  "_id":"the phone number",
  "type":"phone",
  "contact_id":"id of the contact document that has this phone number",
  "phone_type":"string describing type of phone, like home,work,fax,mobile,..."
}
}}}
(Note the use of the ''_id'' field to store the phone number. Phone numbers are unique (when prefixed with country and area code) and therefore this makes a great ''natural key'')

The key to making all this work is the contact property. By storing the contact id in it, you can refer to the owning contact in a unique way, since ''_id'' fields are unique in CouchDB databases.

Creating the relationship between a contact and one of its phone numbers is easy to do. Let's say you have a contact named "Scott" who has a home phone and a mobile phone. You populate his contact info like this (using Perl and Net::CouchDB):
{{{
$db->insert({type => 'contact', _id => 'Scott', name => 'My Friend Scott'});
$db->insert({type => 'phone', _id => '(650) 555 - 2200', contact_id => 'Scott', phone_type => 'home'});
$db->insert({type => 'phone', _id => '(650) 555 - 2201', contact_id => 'Scott', phone_type => 'mobile'});
}}}

To get the contacts and their phone numbers from CouchDB in one search, you need to use a little trick: You need to create a view that sorts the contacts and their phone numbers in order. This is the view:

{{{
"map":function(doc) {
   if (doc.type == 'contact') {
      emit([doc._id, 0], doc);
   } else if (doc.type == 'phone') {
      emit([doc.contact_id, 1, doc.phone_type], doc);
   }
}
}}}

If you then query this view with the ''startkey'' parameter set to "[''''''"Scott"]" and endkey "[''''''"Scott",{}]", you'll get the contact details in the first row and the phone numbers in the following rows (sorted by phone_type as well). You can easily extend this system to have other types of one-to-many attributes in the same view by giving them a different number in the view above.

This is a little bit like a JOIN in SQL although in SQL the data fields would be joined together on a row where here they are on consecutive rows. This latter approach allows a variable number of data fields which is more flexible than SQL.

NOTE: This needs a code example showing how to use the output of the view. Feel free to add one.

Because CouchDB always sorts on keys, you can use this view to only get Scotts home phone numbers by querying with ''startkey'' set to "[''''''"Scott",1,"home"]" and ''endkey'' set to "[''''''"Scott",1,"home",{}]"

When Scott loses his phone, it's easy enough to delete that record. Just delete the phone document and it can no longer be queried for:
{{{
$db->doc('(650) 555 - 2200')->delete;
}}}

=== One to Many: Embedded Documents ===

The embedded array is only an option as long as you don't have "too many" items to store, since each document is always handled as a whole and bigger documents mean slower handling and slower network transfers whenever you want to change the list. Phone numbers should be ok unless you plan to store the whole company phonebook in there.

This is the easiest way to handle one-to-many as everything you need is in one place. Here's how the document for Scott would look:
{{{
{
  "_id":"Scott",
  "type":"contact",
  "name":"My Friend Scott",
  "phones":[{"number":"(650) 555 - 2200","type":"home"},{"number":"(650) 555 - 2201","type":"mobile"}],
}
}}}

or even more succinctly

{{{
{
  "_id":"Scott",
  "type":"contact",
  "name":"My Friend Scott",
  "phones":[{"home":"(650) 555 - 2200"},{"mobile":"(650) 555 - 2201"}],
}
}}}

Note how only the fields that we know are stored. Also note that the phone numbers are not simply an array, they are an array of associative hashes. We could extend this with no effort to add email addresses, IM names etc, even if IM names would need an extra attribute that has the service type. In essence, you're embedding child documents in the master document. That is the power of schema-less databases.

== Many to Many ==
One thing you would like to do is provide the ability for people to organize their contacts in to groups. They might make groups like "Friends", "Co-workers" and "Family". This would allow users to use these groups to perform actions en masse, such as maybe sending an invitation to all their friends for a hack-a-thon. Let's define a simple Group model like this:
{{{
{
  "_id":"unique group id",
  "type":"group",
  "name":"Elaborate group name",
  "description":"description"
}
}}}

You could make a one-to-many relation with Contact. However, this would allow contacts to be part of only one group at a time. For example, someone might include some of their co-workers as friends. You need a way to represent many-to-many relationships.

=== Many to Many: List of Keys ===
One very simple way is to create a list of keys on one side of the relationship, like we did in the "Embedded One to Many" section.

Our friend and colleague Scott would then get a new field in his contact document which holds group ''_id'' values:
{{{
  "groups":["Friends","Colleagues"]
}}}

Adding and removing a user to and from a group means working with a list of keys. Suppose we don't like Scott any more:
{{{
   my $scott = $db->doc('Scott');
   $scott->{groups} = grep { $_ ne 'Friends' } $scott->{groups};
   $scott->update;
}}}

To get all the members of a group, you'd create a view like this:
{{{
"map":function(doc) {
   if (doc.type == 'contact') {
      for (var i in doc.groups) {
         emit(i,doc.name);
      }
   } else if (doc.type == 'group') {
      emit(doc._id,doc);
   }
}
}}}

If you then query this view with search parameters
 * ''descending=true''
 * ''key="Friends"''
then you'll get all the names of members of the group Friends and the group information as the first row. (Hashes sort behind strings).

Here's a space optimization hint: If you make the view be
{{{
"map":function(doc) {
   if (doc.type == 'contact') {
      for (var i in doc.groups) {
         emit(i,null);
      }
   } else if (doc.type == 'group') {
      emit(doc._id,null);
   }
}
}}}
and query this view with search parameters
 * ''key="Friends"''
 * ''include_docs=true''
You'll get all documents that are pertinent to the group, but in no particular order. The size of your index will be smaller though.

For the most efficient changes to the relationship list, you should place the list on side of the relationship which you expect to have fewer values. In the example above, the Contact side was chosen because a single person is not likely to belong to too many groups, whereas in a large contacts database, a group might contain hundreds of members.

==== Querying by multiple keys ====
Some applications need to view the intersection of entities that have multiple keys. In the example above, this would be a query for the contacts who are in both the "Friends" and the "Colleagues" groups. The most straight-forward way to handle this situation is to query for one of the keys, and then to filter by the rest of the keys on the client-side. If the key frequencies vary greatly, it may also be worthwhile to make an initial call to determine the key with the lowest frequency, and to use that to fetch the initial document list from the database.

If this is not a good option, it is possible to index the combinations of the keys, though the growth of the index for a given document will be exponential with the number of its keys. Still, for small-ish key sets, this is an option, since the keys can be ordered, and keys which are prefixes of a larger key can be omitted. For instance, for the key set {{{[1 2 3]}}} the possible key combinations are {{{[1] [2] [3] [1 2] [1 3] [2 3] [1 2 3]}}} However, the index need only contain the keys {{{[3] [1 3] [2 3] [1 2 3]}}} since (for example) the documents matching the keys [1 2] could be obtained with a query for {{{startkey=[1,2,null] and endkey=[1,2,{}]}}} The number of index entries will be 2^(n-1) number of keys.

A final option is to use a separate index, such as couchdb-lucene to help with such queries.


=== Many to Many: Relationship documents ===

Another way of implementing many-to-many is by creating a separate document for each relationship.

You would use this method if you modify the key list frequently (i.e. if you get more conflicts than is acceptable), or if the key list is so large that transferring the document is unacceptably slow. Relationship documents enable frequent changes with less chance of conflict; however, you can access neither the contact nor group information in one request. You must re-request those specific documents by ID, keeping in mind that they may change or be deleted in the interim.

A document explaining that Scott is a Friend would look like
{{{
{
  "_id":"some unique id",
  "type":"relation",
  "contact_id":"Scott",
  "group_id":"Friends"
}
}}}


If you then want to know who is in a group you'll need to use the view (fetch descending to get the group info first)
{{{
"map":function(doc) {
   if (doc.type == 'relationship') {
      emit(doc.group_id,doc.contact_id);
   } else if (doc.type == 'group') {
      emit(doc._id,doc);
   }
}
}}}

To know what groups a contact belongs to you can use
{{{
"map":function(doc) {
   if (doc.type == 'relationship') {
      emit([doc.contact_id,1],doc.group_id);
   } else if (doc.type == 'contact') {
      emit([doc._id,0],doc);
   }
}
}}}
Note that this view uses key arrays to enforce sorting, just to show you the possible variations. The disadvantage is that you can't use ''key="Scott"'' to search for Scotts groups, you need to use ''startkey=[''''''"Scott"]&endkey=["Scott",{}]''.

Unlike the previous method, you can't use ''include_docs=true'' now to get all information about the contacts that are in a group or the groups that a contact has. The reason is that the original documents that were used in generating the view are not the contact or group documents, they are the relationship documents. If you want that information, you'll have to fetch it separately (you can use a POST view to ''/db/_all_docs'' to grab a bunch of documents in one go).

If this is becoming a problem due to roundtrip times to the database, an acceptable solution is to duplicate the needed information in the relationship documents. You trade the inconvenience of maintaining multiple copies of the same data for the low access time to that data. Unless you have extreme requirements however, you do not need to do this.

Here, CouchDB differs from traditional SQL systems. With SQL you would be able to get all the data in one go using two JOIN statements, but you would not be aware that that is in fact a pretty slow operation. CouchDB only allows you to do things that scale well.
