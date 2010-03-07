= CouchDB Proposal: Forward document references =

Within any document a single-key object with the following format will be
considered a reference to another document within the same database.
    { "_document": "documentid" }

For an example, let's take a friendship structure where each person is stored
in their own document and can have a number of "friends" which are references
to other documents in the database.
((Each object is a separate document, document id is noted in _id as with the HTTP API))

    {
      "_id": "fbigg",
      "FirstName": "Fred",
      "LastName": "Biggins",
      "Friends": [
        { "_document": "hherbert" }
      ]
    }

    {
      "_id": "crobin",
      "FirstName": "Claire",
      "LastName": "Robins",
      "Friends": [
        { "_document": "fbigg" }
      ]
    }

    {
      "_id": "hherbert",
      "FirstName": "Hugh",
      "LastName": "Herbert",
      "Friends": [
        { "_document": "crobin" }
      ]
    }

You'll notice this structure is cycilic. This structure was picked for the example
so we can also note how tolerant the proposal is to any sort of recursion.

There are no changes to the standard API (read: all current queries to the rest
API will return the exact same expected structure as they currently do). So this
means that querying the database for /friendsdb/fbigg will return you the document:
    {
      "_id": "fbigg",
      "FirstName": "Fred",
      "LastName": "Biggins",
      "Friends": [
        { "_document": "hherbert" }
      ]
    }

The difference in the API comes when you add the ?recursive=true parameter to the
url of the query. The recursive option changes the output structure from a single
document to an object with document ids as the key.
When ?recursive is enabled CouchDB looks for any { "_document": "documentid" }
objects inside of the document and if it finds any that document is fetched as
well and returned. As it is doing this CouchDB keeps a hash of the document ids
that it has fetched so far (perhaps it could even use the object it is already building)
((off note: if you want more performance, CouchDB is free to index a list of
document references in the document on create/update and operate off that index
in a known location instead of querying the json for any _document keys))

For our example if we made a query to /friendsdb/fbigg?resursive=true then we
would expect to get this output.
    {
      "fbigg": {
        "_id": "fbigg",
        "FirstName": "Fred",
        "LastName": "Biggins",
        "Friends": [
          { "_document": "hherbert" }
        ]
      },
      "crobin": {
        "_id": "crobin",
        "FirstName": "Claire",
        "LastName": "Robins",
        "Friends": [
          { "_document": "fbigg" }
        ]
      },
      "hherbert": {
        "_id": "hherbert",
        "FirstName": "Hugh",
        "LastName": "Herbert",
        "Friends": [
          { "_document": "crobin" }
        ]
      }
    }

This method does not place the actual document object in place of the reference
the advantage is because we are not substituting the data we can have as many
cycilic references as we want and we do not encounter any infinite loops.

In programs it is easy to handle the returned data format like so:
((JavaScript 1.8 pesudocode))

    var db = new CouchDB('friends');
    var hash = db.get('fbigg', {recursive:true});
    var fbigg = hash.fbigg.Friends.map(function(friend) hash[friend._document]);
    fbigg; // JSON Structure
    {
      "_id": "fbigg",
      "FirstName": "Fred",
      "LastName": "Biggins",
      "Friends": [
        {
          "_id": "hherbert",
          "FirstName": "Hugh",
          "LastName": "Herbert`
          "Friends": [
            { "_document": "crobin" }
          ]
        }
      ]
    }

While this is a simple example, it is actually perfectly possible for a CouchDB
client side library to find any _document keys it can find within the JSON document and replace
those with the object for that document. This can be done in a way that preserves
the cycilic nature and something like (fbigg.Friends[0].Friends[0].Friends[0] === fbigg)
would return true.


== Why? ==

... unfinished ...
  * To note, example code for generating views for inverse document relations and index like info.
