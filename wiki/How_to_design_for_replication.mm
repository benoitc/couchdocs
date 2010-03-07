See also: [[Replication_and_conflicts]]

= Designing an application to work with replication =

Whilst CouchDB includes replication and a conflict-flagging mechanism, this
is not the whole story for building an application which replicates in a way
which users expect.

Here we consider a simple example of a bookmarks application. The idea is
that a user can replicate their own bookmarks, work with them on another
machine, and then synchronise their changes later.

Let's start with a very simple definition of bookmarks: an ordered, nestable
mapping of name to URL. Internally the application might represent it like
this:

{{{
/* example A */
[
  {"name":"Weather", "url":"http://www.bbc.co.uk/weather"},
  {"name":"News", "url":"http://news.bbc.co.uk/"},
  {"name":"Tech", "bookmarks":[
    {"name":"Register", "url":"http://www.theregister.co.uk/"},
    {"name":"CouchDB", "url":"http://couchdb.apache.org/"}
  ]}
]
}}}

It can then present the bookmarks menu and submenus by traversing this
structure.

Now consider this scenario: the user has a set of bookmarks on her PC, and
then replicates it to her laptop. On the laptop, she changes the News link
to point to CNN, renames "Register" to "The Register", and adds a new link
to slashdot just after it. On the desktop, her husband deletes the Weather
link, and adds a new link to CNET in the Tech folder.

So after these changes, the laptop has:

{{{
/* example B */
[
  {"name":"Weather", "url":"http://www.bbc.co.uk/weather"},
  {"name":"News", "url":"http://www.cnn.com/"},
  {"name":"Tech", "bookmarks":[
    {"name":"The Register", "url":"http://www.theregister.co.uk/"},
    {"name":"Slashdot", "url":"http://www.slashdot.new/"},
    {"name":"CouchDB", "url":"http://couchdb.apache.org/"}
  ]}
]
}}}

and the PC has:

{{{
/* example C */
[
  {"name":"News", "url":"http://www.cnn.com/"},
  {"name":"Tech", "bookmarks":[
    {"name":"Register", "url":"http://www.theregister.co.uk/"},
    {"name":"CouchDB", "url":"http://couchdb.apache.org/"},
    {"name":"CNET", "url":"http://news.cnet.com/"},
  ]}
]
}}}

Upon the next synchronisation, we want the expected merge to take place.
That is: links which were changed, added or deleted on one side are also
changed, added or deleted on the other side - with no human intervention
required unless absolutely necessary.

We will also assume that both sides are doing a CouchDB "compact" operation
periodically, and are disconnected for more than this time before they
resynchronise.

== Approach 1: Single JSON doc ==

The above structure is already valid Javascript, and so could be represented
in CouchDB just by wrapping it in an object and storing as a single
document:

{{{
{"bookmarks":
  ... same as above
}
}}}

This makes life very easy for the application, as the ordering and nesting
is all taken care of. The trouble here is that on replication, only two sets
of bookmarks will be visible: example B and example C. One will be chosen as
the main revision, and the other will be stored as a conflicting revision.

At this point, the semantics are very unsatisfactory from the user's point
of view. The best that can be offered is a choice saying "Which of these two
sets of bookmarks do you wish to keep: B or C?" However neither represents
the desired outcome. There is also insufficient data to be able to correctly
merge them, since the base revision A is lost.

This is going to be highly unsatisfactory for the user, who will have to
apply one set of changes again manually.

== Approach 2: Separate document per bookmark ==

An alternative solution is to make each field (bookmark) a separate document
in its own right. Adding or deleting a bookmark is then just a case of
adding or deleting a document, which will never conflict (although if the
same bookmark is added on both sides, then you will end up with two copies
of it). Changing a bookmark will only conflict if both sides made changes to
the same one, and then it is reasonable to ask the user to choose between
them.

Since there will now be lots of small documents, you may either wish to keep
a completely separate database for bookmarks, or else add an attribute to
distinguish bookmarks from other kinds of document in the database. In the
latter case, a view can be made to return only bookmark documents.

Whilst replication is now fixed, care is needed with the "ordered" and
"nestable" properties of bookmarks.

For ordering, one suggestion is to give each item a floating-point index,
and then when inserting an object between A and B, give it an index which is
the average of A and B's indices. Unfortunately, this will fail after a
while when you run out of precision, and the user will be bemused to find
that their most recent bookmarks no longer remember the exact position they
were put in.

A better way is to keep a string representation of index, which can grow as
the tree is subdivided. This will not suffer the above problem, but it may
result in this string becoming arbitrarily long after time. They could be
renumbered, but the renumbering operation could introduce a lot of
conflicts, especially if attempted by both sides independently.

For "nestable", you can have a separate doc which represents a list of
bookmarks, and each bookmark can have a "belongs to" field which identifies
the list. It may be useful anyway to be able to have multiple top-level
bookmark sets (Bob's bookmarks, Jill's bookmarks etc). Some care is needed
when deleting a list or sublist, to ensure that all associated bookmarks are
also deleted, otherwise they will become orphaned.

Final note: building the entire bookmark set is probably going to have to be
done by the application. A 'reduce' operation isn't really suitable to build
a combined bookmark list because it would get larger on each reduce round,
and it is not permitted to do this.

TODO: insert fully-expanded example

== Approach 3: Immutable history ==

Another approach to consider is
[[http://martinfowler.com/eaaDev/EventSourcing.html|Event Sourcing]] or
Command Logging, implemented in object stores such as
[[http://madeleine.rubyforge.org/|Madeleine]]

In this model, instead of storing individual bookmarks, you store records of
''changes'' made - "Bookmark added", "Bookmark changed", "Bookmark moved",
"Bookmark deleted". These are stored in an append-only fashion. Since
records are never modified or deleted, only added to, there are never any
replication conflicts.

These records can also be stored as an array in a single CouchDB document.
Replication can cause a conflict, but in this case it is easy to resolve by
simply combining elements from the two arrays.

In order to see the full set of bookmarks, you need to start with a baseline
set (initially empty) and run all the change records since the baseline was
created; and/or you need to maintain a most-recent version and update it
with changes not yet seen.

Care is needed after replication when merging together history from multiple
sources. You may get different results depending on how you order them -
consider taking all A's changes before B's, taking all B's before A's, or
interleaving them (e.g. if each change has a timestamp)

Also, over time the amount of storage used can grow arbitrarily large, even
if the set of bookmarks itself is small. This can be controlled by moving
the baseline version forwards and then keeping only the changes after that
point. However, care is needed not to move the baseline version forward so
far that there are active replicas out there which last synchronised before
that time, as this may result in conflicts which cannot be resolved
automatically.

TODO: insert fully-expanded example

== Approach 4: Keep historic versions explicitly ==

If you are going to keep a command log history, then it may be simpler just
to keep old revisions of the bookmarks list itself around. The intention is
to subvert CouchDB's automatic behaviour of purging old revisions, by
keeping these revisions as separate documents.

You can keep a pointer to the 'most current' revision, and each revision can
point to its predecessor. On replication, merging can take place by diffing
each of the previous versions (in effect synthesising the command logs) back
to a common ancestor.

This is the sort of behaviour which revision control systems such as
[[http://git-scm.org/|Git]] implement as a matter of routine, although
generally comparing text files line-by-line rather than comparing JSON
objects field-by-field.

Systems like Git will accumulate arbitrarily large amounts of history
(although they will attempt to compress it by packing multiple revisions so
that only their diffs are stored). With Git you can use "history rewriting"
to remove old history, but this may prohibit merging if history doesn't go
back far enough in time.

There is even a git-backend written in CouchDB: [[http://github.com/ddollar/git-db|git-db]]

= Summary =

All the approaches which allow automated merging of changes rely on having
some sort of history back in time to the point where the replicas diverged.

CouchDB does not provide a mechanism for this itself. It stores arbitrary
numbers of old _ids for one document (trunk now has a mechanism for pruning
the _id history), for the purposes of replication. However it will not keep
the documents themselves through a compaction cycle, except where there are
conficting versions of a document.

So it is up to you to maintain history explicitly in whatever form makes
sense for your application, and to prune it to avoid excessive storage
utilisation, whilst not pruning past the point where live replicas last
diverged.
