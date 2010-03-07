For the original article this example was taken from, see http://blog.paulbonser.com/2008/07/04/storing-hierarchical-data-in-couchdb/
For comparison with how this is usually done with relational DBs, see http://www.sitepoint.com/article/hierarchical-data-database/

== Storing the Tree ==

Store the full path to each node as an attribute in that node's document.

For example:

{{{
[
    {"_id":"Food",   "path":["Food"]},
    {"_id":"Fruit",  "path":["Food","Fruit"]},
    {"_id":"Red",    "path":["Food","Fruit","Red"]},
    {"_id":"Cherry", "path":["Food","Fruit","Red","Cherry"]},
    {"_id":"Tomato", "path":["Food","Fruit","Red","Tomato"]},
    {"_id":"Yellow", "path":["Food","Fruit","Yellow"]},
    {"_id":"Banana", "path":["Food","Fruit","Yellow","Banana"]},
    {"_id":"Meat",   "path":["Food","Meat"]},
    {"_id":"Beef",   "path":["Food","Meat","Beef"]},
    {"_id":"Pork",   "path":["Food","Meat","Pork"]}
]
}}}

In a real system you'd probably want to use some sort of UUID for the _id field rather than descriptive strings, since conflicts between node names could be bad. In fact, it'd probably be much faster to just use numbers, since comparisons on numbers are generally much faster. For the purposes of this example, however, it's much easier to understand if the _id is descriptive text.  For the purposes of displaying the path for a particular document, however, it will generally be easier to store (at least) the descriptive name of each path element in the path array, as shown here.

Once that data is in your DB, it's time to get it out again!

== Retrieving the whole tree ==

The CouchDB map function to retrieve the whole tree is nice and simple:

{{{
function(doc) {
    emit(doc.path, doc)
}
}}}

Using the path as the key, the documents will be sorted as above, with each parent immediately followed by its children.

One option to get the data into an actual tree would be to add a reduce function to the view:

{{{
function(keys, vals) {
    tree = {};
    for (var i in vals)
    {
        current = tree;
        for (var j in vals[i].path)
        {
            child = vals[i].path[j];
            if (current[child] == undefined) 
                current[child] = {};
            current = current[child];
        } 
        current['_data'] = vals[i];
    }
    return tree;
}
}}}

'''''Note: don't use this reduce function, since it doesn't take the rereduce parameter into account, and would most likely not work correctly if a rereduce was done.'''''

Another option would be to use a client-side function to accomplish the same thing, for example in Python:

{{{#!python
class TreeNode(dict): pass

def tree_from_rows(list):
    tree = {}
    for item in list:
        current = tree
        for child in item.value['path']:
            current = current.setdefault(child, TreeNode())
        current.data = item.value
    return tree
}}}

This code does the job nicely and allows me to use the same function to build a tree from several different views without duplicating code.

== Getting a subtree ==

To get all the nodes which are underneath a specific node, I implemented the view's map function as follows:

{{{
function(doc) { 
    for (var i in doc.path) { 
        emit([doc.path[i], doc.path], doc) 
    } 
}
}}}

Again, this is pretty simple. The only difference from the last view is that I can now query this view with a startkey and endkey (see the HttpViewApi) to get only nodes under a certain node. You could actually do that with the previous view, except you'd have to include the full path to the node in the startkey, which is a bit too much.

For example, if you had CouchDB running on your machine right now with the above example data loaded and went to http://localhost:5984/tree/_view/tree/descendants?startkey=[%22Fruit%22]&endkey=[%22Fruit%22,{}]

== How Many Descendants ==

Getting the number of descendants for a given node is simple. The view is as follows:

{{{
'descendant_count': {
    'map':    'function(doc) { for (var i in doc.path) { emit(doc.path[i], 1) } }',
    'reduce': 'function(keys, values) { return sum(values) }'
}
}}}

This will count the parent node as well, so you will probably want to subtract one from it at some point. To use this view simply call it with the key parameter set to the id of the desired root node.

== Getting the immediate children of a node ==

Sometimes you just want to get a list of nodes which are immediately under a given node. This can be done by using a map with the following map function:

{{{
function(doc) { 
    emit([doc.path.slice(-2,-1)[0], doc.path], doc) 
}
}}}

This map function simply takes the second-to-last element from the path and uses that as the first element in the key. You can query this view in the same way as the "getting a subtree" view above.

== Adding a node ==

Adding a node to the tree is fairly simple. Set the new node's path to be the path of the desired parent node with the new node's ID appended to the end. That's it.

== Deleting a node ==

Deleting a node is a bit trickier since any given node may have some number of children. You can get the list of nodes in the subtree as outlined above and then do a bulk update to delete each of them.

Depending on the data being stored, deleting the whole sub-tree might not ever be something you want to do, in a discussion forum, for example, you might want to simply delete a single offensive post, leaving any replies which might have been posted. Even in this case, it's more likely that you'd want to set a flag indicating the deletion rather than actually deleting the post.

== Moving a node to another parent ==

This is an instance where being able to update just certain fields in a document would be handly, since bulk-updating a large chunk of documents could start to kill performance.

Either way, if something needs to be reparented, it's just a matter of getting all nodes which are children of a certain node, then doing a bulk update to change their paths to wherever they need to be.

This part worries me a bit, because there's a chance that somebody else could add a new child node while you are in the process of moving the sub-tree, leaving that new node dangling by itself in a sub-tree which no longer exists. I'm not sure of the best approach to avoid such a problem.

There is some example Python code to handle using the above views to fetch trees available at http://git.paulbonser.com/?p=couchdb.git;a=summary

== Searching by value and returning associated documents ==

Couchdb 0.11 adds a feature where you can emit a key,value pair linked to a different document ID. Hence it's possible to build a view where you can search for a value V ''and'' also return the ancestors or children for that value in adjacent rows. See [[Introduction_to_CouchDB_views#Linked_documents]]
