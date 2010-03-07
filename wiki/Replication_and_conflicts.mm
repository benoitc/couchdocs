= Replication and conflict model =

Let's take the following example to illustrate replication and conflict
handling.

 * Alice has a document containing Bob's business card
 * She synchronizes it between her desktop PC and her laptop
 * On the desktop PC, she updates Bob's E-mail address. Without
 syncing again, she updates Bob's mobile number on the laptop.
 * Then she replicates the two to each other again

So on the desktop the document has Bob's new E-mail address and his old mobile number, and on the laptop it has his old E-mail address and his new mobile number.

The question is, what happens to these conflicting updated documents?

== CouchDB replication ==

CouchDB works with JSON documents inside databases.  Replication of
databases takes place over HTTP, and can be either a "pull" or a "push", but
is unidirectional.  So the easiest way to perform a full sync is to do a
"push" followed by a "pull" (or vice versa).

So, Alice creates v1 and sync it. She updates to v2a on one side and v2b on
the other, and then replicates. What happens?

The answer is simple: ''both'' versions exist on both sides!

{{{
     DESKTOP                          LAPTOP
   +---------+
   | /db/bob |                                     INITIAL
   |   v1    |                                     CREATION
   +---------+

   +---------+                      +---------+
   | /db/bob |  ----------------->  | /db/bob |     PUSH
   |   v1    |                      |   v1    |
   +---------+                      +---------+

   +---------+                      +---------+  INDEPENDENT
   | /db/bob |                      | /db/bob |     LOCAL
   |   v2a   |                      |   v2b   |     EDITS
   +---------+                      +---------+

   +---------+                      +---------+
   | /db/bob |  ----------------->  | /db/bob |     PUSH
   |   v2a   |                      |   v2a   |
   +---------+                      |   v2b   |
                                    +---------+

   +---------+                      +---------+
   | /db/bob |  <-----------------  | /db/bob |     PULL
   |   v2a   |                      |   v2a   |
   |   v2b   |                      |   v2b   |
   +---------+                      +---------+
}}}

After all, this is not a filesystem, so there's no restriction that only one
document can exist with the name /db/bob. These are just "conflicting"
revisions under the same name.

Because the changes are always replicated, the data is safe. Both machines
have identical copies of both documents, so failure of a hard drive on
either side won't lose any of the changes.

Another thing to notice is that peers do not have to be configured or
tracked.  You can do regular replications to peers, or you can do one-off,
ad-hoc pushes or pulls.  After the replication has taken place, there is no
record kept of which peer any particular document or revision came from.

So the question now is: what happens when you try to read /db/bob? By
default, CouchDB picks one arbitrary revision as the "winner", using a
deterministic algorithm so that the same choice will be made on all peers.
The same happens with views: the deterministically-chosen winner is the only
revision fed into your map function.

Let's say that the winner is v2a. On the desktop, if Alice reads the
document she'll see v2a, which is what she saved there. But on the laptop,
after replication, she'll also see only v2a. It could look as if the changes
she made there have been lost - but of course they have not, they have just
been hidden away as a conflicting revision. But eventually she'll need these
changes merged into Bob's business card, otherwise they ''will'' effectively
have been lost.

Any sensible business-card application will, at minimum, have to present the
conflicting versions to Alice and allow her to create a new version
incorporating information from them all. Ideally it would merge the updates
itself.

== Conflict avoidance ==

When working on a single node, CouchDB will avoid creating conflicting
revisions by returning a 409 HTTP error.  This is because, when you PUT a
new version of a document, you must give the _rev of the previous version. 
If that _rev has already been superceded, the update is rejected with a 409.

So imagine two users on the same node are fetching Bob's business card,
updating it concurrently, and writing it back:

{{{
USER1    ----------->  GET /db/bob
         <-----------  {"_rev":"1-aaa", ...}

USER2    ----------->  GET /db/bob
         <-----------  {"_rev":"1-aaa", ...}

USER1    ----------->  PUT /db/bob?rev=1-aaa
         <-----------  {"_rev":"2-bbb", ...}

USER2    ----------->  PUT /db/bob?rev=1-aaa
         <-----------  409 Conflict  (not saved)
}}}

User2's changes are rejected, so it's up to the app to fetch /db/bob again,
and either:
 * apply the same changes as were applied to the earlier revision, and
 submit a new PUT
 * redisplay the document so the user has to edit it again
 * just overwrite it with the document being saved before (which is not
 advisable, as user1's changes will be silently lost)

So when working in this mode, your application still has to be able to
handle these conflicts and have a suitable retry strategy, but these
conflicts never end up inside the database itself.

== Conflicts in batches ==

There are two different ways that conflicts can end up in the database:
 1. Conflicting changes made on different databases, which are replicated
 to each other, as shown earlier.
 2. Changes are written to the database using _bulk_docs and all_or_nothing,
 which bypasses the 409 mechanism.

The _bulk_docs API lets you submit multiple updates (and/or deletes) in a
single HTTP POST.  Normally, these are treated as independent updates; some
in the batch may fail because the _rev is stale (just like a 409 from a PUT)
whilst others are written successfully.  The response from _bulk_docs lists
the success/fail separately for each document in the batch.

However there is another mode of working, whereby you specify
`{"all_or_nothing":true}` as part of the request.  This is CouchDB's nearest
equivalent of a "transaction", but it's not the same as a database
transaction which can fail and roll back.  Rather, it means that ''all'' of
the changes in the request will be forcibly applied to the database, even if
that introduces conflicts.  The only guarantee you are given is that they
will either all be applied to the database, or none of them (e.g.  if the
power is pulled out before the update is finished writing to disk).

So this gives you a way to introduce conflicts within a single database
instance.  If you choose to do this instead of PUT, it means you don't have
to write any code for the possibility of getting a 409 response, because you
will never get one.  Rather, you have to deal with conflicts appearing later
in the database, which is what you'd have to do in a multi-master
application anyway.

{{{
POST /db/_bulk_docs
{
  "all_or_nothing": true,
  "docs": [
    {"_id":"x", "_rev":"1-xxx", ...},
    {"_id":"y", "_rev":"1-yyy", ...},
    ...
  ]
}
}}}

== Revision tree ==

When you update a document in couchdb, it keeps a list of the previous revisions.
In the case where conflicting updates are introduced, this history branches into a
tree, where the current conflicting revisions for this document form the tips
(leaf nodes) of this tree.

{{{
      ,--> r2a
    r1 --> r2b
      `--> r2c
}}}

Each branch can then extend its history - for example if you read
revision r2b and then PUT with `?rev=r2b` then you will make a new revision
along that particular branch.

{{{
      ,--> r2a -> r3a -> r4a
    r1 --> r2b -> r3b
      `--> r2c -> r3c
}}}

Here, (r4a, r3b, r3c) are the set of conflicting revisions. The way you
resolve a conflict is to delete the leaf nodes along the other branches.
So when you combine (r4a+r3b+r3c) into a single merged document, you
would replace r4a and delete r3b and r3c.

{{{
      ,--> r2a -> r3a -> r4a -> r5a
    r1 --> r2b -> r3b -> (r4b deleted)
      `--> r2c -> r3c -> (r4c deleted)
}}}

Note that r4b and r4c still exist as leaf nodes in the history tree, but as
deleted docs. You can retrieve them but they will be marked `"_deleted":true`.

When you compact a database, the bodies of all the non-leaf documents are
discarded. However, the list of historical _revs is retained, for the benefit of
later conflict resolution in case you meet any old replicas of the database at
some time in future. There is "revision pruning" to stop this getting arbitrarily large.

= Working with conflicting documents =

== Single document API ==

The basic `GET /db/bob` operation will not show you any information about
conflicts. You see only the deterministically-chosen winner, and get no
indication as to whether other conflicting revisions exist or not.

{{{
{"_id":"test","_rev":"2-b91bb807b4685080c6a651115ff558f5","hello":"bar"}
}}}

If you do `GET /db/bob?conflicts=true`, and the document is in a conflict
state, then you will get the winner plus a _conflicts member containing an
array of the revs of the other, conflicting revision(s). You can then fetch
them individually using subsequent `GET /db/bob?rev=xxxx` operations.

{{{
{"_id":"test","_rev":"2-b91bb807b4685080c6a651115ff558f5","hello":"bar",
"_conflicts":["2-65db2a11b5172bf928e3bcf59f728970","2-5bc3c6319edf62d4c624277fdd0ae191"]}
}}}

If you do `GET /db/bob?open_revs=all` then you will get all the leaf nodes
of the revision tree. This ''will'' give you all the current conflicts, but will
also give you leaf nodes which have been deleted (i.e. parts of the conflict
history which have since been resolved). You can remove these by filtering
out documents with `"_deleted":true`.

{{{
[{"ok":{"_id":"test","_rev":"2-5bc3c6319edf62d4c624277fdd0ae191","hello":"foo"}},
{"ok":{"_id":"test","_rev":"2-65db2a11b5172bf928e3bcf59f728970","hello":"baz"}},
{"ok":{"_id":"test","_rev":"2-b91bb807b4685080c6a651115ff558f5","hello":"bar"}}]
}}}

The "ok" tag is an artefact of open_revs, which also lets you list explicit
revisions as a JSON array, e.g. `open_revs=[rev1,rev2,rev3]`. In this form,
it would be possible to request a revision which is now missing, because the
database has been compacted.

NOTE: the order of revisions returned by open_revs=all is NOT related to the
deterministic "winning" algorithm. In the above example, the winning revision is 2-b91b...
and happens to be returned last, but in other cases it can be returned in a
different position.

Once you have retrieved all the conflicting revisions, your application can then
choose to display them all to the user. Or it could attempt to merge them, write
back the merged version, and delete the conflicting versions - that is, to resolve
the conflict permanently.

As described above, you need to update one revision and delete all the conflicting
revisions explicitly. This can be done using a single POST to _bulk_docs, setting
`"_deleted":true` on those revisions you wish to delete.

== Multiple document API ==

You can fetch multiple documents at once using `include_docs=true` on a view. However,
a `conflicts=true` request is ignored; the "doc" part of the value never includes a
`_conflicts` member. Hence you would need to do another query to determine for each
document whether it is in a conflicting state.

{{{
$ curl 'http://127.0.0.1:5984/conflict_test/_all_docs?include_docs=true&conflicts=true'
{"total_rows":1,"offset":0,"rows":[
{"id":"test","key":"test","value":{"rev":"2-b91bb807b4685080c6a651115ff558f5"},
"doc":{"_id":"test","_rev":"2-b91bb807b4685080c6a651115ff558f5","hello":"bar"}}
]}
$ curl 'http://127.0.0.1:5984/conflict_test/test?conflicts=true'
{"_id":"test","_rev":"2-b91bb807b4685080c6a651115ff558f5","hello":"bar",
"_conflicts":["2-65db2a11b5172bf928e3bcf59f728970","2-5bc3c6319edf62d4c624277fdd0ae191"]}

}}}

== View map functions ==

Views only get the winning revision of a document. However they do also
get a _conflicts member if there are any conflicting revisions.  This means
you can write a view whose job is specifically to locate documents with
conflicts. Here is a simple map function which achieves this:

{{{
function(doc) {
  if (doc._conflicts) {
    emit(null, [doc._rev].concat(doc._conflicts));
  }
}
}}}

which gives the following output:

{{{
{"total_rows":1,"offset":0,"rows":[
{"id":"test","key":null,"value":["2-b91bb807b4685080c6a651115ff558f5",
"2-65db2a11b5172bf928e3bcf59f728970","2-5bc3c6319edf62d4c624277fdd0ae191"]}
]}
}}}

If you do this, you can have a separate "sweep" process which periodically
scans your database, looks for documents which have conflicts, fetches
the conflicting revisions, and resolves them.

Whilst this keeps the main application simple, the problem with this
approach is that there will be a window between a conflict being introduced
and it being resolved. From a user's viewpoint, this may appear that
the document they just saved successfully may suddenly lose their changes,
only to be resurrected some time later. This may or may not be acceptable.

Also, it's easy to forget to start the sweeper, or not to implement it
properly, and this will introduce odd behaviour which will be hard to track
down.

Couchdb's "winning" revision algorithm may mean that information drops out
of a view until a conflict has been resolved. Consider Bob's business card
again; suppose Alice has a view which emits mobile numbers, so that her
telephony application can display the caller's name based on caller ID. If there
are conflicting documents with Bob's old and new mobile numbers, and they
happen to be resolved in favour of Bob's old number, then the view won't
be able to recognise his new one. In this particular case, the application
might have preferred to put information from ''both'' the conflicting
documents into the view, but this currently isn't possible.

== Suggested code to fetch a document with conflict resolution ==

Pseudocode:
{{{
  1. GET docid?conflicts=true
  2. For each member in the _conflicts array:
       GET docid?rev=xxx
     If any errors occur at this stage, restart from step 1.
     (There could be a race where someone else has already resolved this
     conflict and deleted that rev)
  3. Perform application-specific merging
  4. Write _bulk_docs with an update to the first rev and deletes of
     the other revs.
}}}

This could either be done on every read (in which case you could replace all
calls to GET in your application with calls to a library which does the
above), or as part of your sweeper code.

And here is an example of this in Ruby using the low-level RestClient.

{{{
require 'rubygems'
require 'restclient'
require 'json'
DB="http://127.0.0.1:5984/conflict_test"

# Write multiple documents as all_or_nothing, can introduce conflicts
def writem(docs)
  JSON.parse(RestClient.post("#{DB}/_bulk_docs", {
    "all_or_nothing" => true,
    "docs" => docs,
  }.to_json))
end

# Write one document, return the rev
def write1(doc, id=nil, rev=nil)
  doc['_id'] = id if id
  doc['_rev'] = rev if rev
  writem([doc]).first['rev']
end

# Read a document, return *all* revs
def read1(id)
  retries = 0
  loop do
    # FIXME: escape id
    res = [JSON.parse(RestClient.get("#{DB}/#{id}?conflicts=true"))]
    if revs = res.first.delete('_conflicts')
      begin
        revs.each do |rev|
          res << JSON.parse(RestClient.get("#{DB}/#{id}?rev=#{rev}"))
        end
      rescue
        retries += 1
        raise if retries >= 5
        next
      end
    end
    return res
  end
end

# Create DB
RestClient.delete DB rescue nil
RestClient.put DB, {}.to_json

# Write a document
rev1 = write1({"hello"=>"xxx"},"test")
p read1("test")

# Make three conflicting versions
write1({"hello"=>"foo"},"test",rev1)
write1({"hello"=>"bar"},"test",rev1)
write1({"hello"=>"baz"},"test",rev1)

res = read1("test")
p res

# Now let's replace these three with one
res.first['hello'] = "foo+bar+baz"
res.each_with_index do |r,i|
  unless i == 0
    r.replace({'_id'=>r['_id'], '_rev'=>r['_rev'], '_deleted'=>true})
  end
end
writem(res)

p read1("test")
}}}

An application written this way never has to deal with a PUT 409, and is
automatically multi-master capable.

You can see that it's straightforward enough when you know what you're
doing.  It's just that CouchDB doesn't currently provide a convenient HTTP
API for "fetch all conflicting revisions", nor "PUT to supercede these N
revisions", so you need to wrap these yourself.  I also don't know of any
client-side libraries which provide support for this.

== Merging and revision history ==

Actually performing the merge is an application-specific function. It
depends on the structure of your data. Sometimes it will be easy: e.g. if a
document contains a list which is only ever appended to, then you can
perform a union of the two list versions.

Some merge strategies look at the changes made to an object, compared to its
previous version.  This is how git's merge function works.  For example, to
merge Bob's business card versions v2a and v2b, you could look at the
differences between v1 and v2b, and then apply these changes to v2a as well.

With CouchDB, you can sometimes get hold of old revisions of a document. 
For example, if you fetch `/db/bob?rev=v2b&revs_info=true` you'll get a list
of the previous revision ids which ended up with revision v2b.  Doing the
same for v2a you can find their common ancestor revision.  However if the
database has been compacted, the content of that document revision will have
been lost.  revs_info will still show that v1 was an ancestor, but report it
as "missing".

{{{
BEFORE COMPACTION           AFTER COMPACTION

     ,-> v2a                     v2a
   v1
     `-> v2b                     v2b
}}}

So if you want to work with diffs, the recommended way is to store those
diffs within the new revision itself.  That is: when you replace v1 with
v2a, include an extra field or attachment in v2a which says which fields
were changed from v1 to v2a.  This unfortunately does mean additional
book-keeping for your application.

= Comparison with other replicating data stores =

The same issues arise with other replicating systems, so it can be
instructive to look at these and see how they compare with CouchDB. Please
feel free to add other examples.

== Unison ==

[[http://www.cis.upenn.edu/~bcpierce/unison/|Unison]] is a bi-directional file
synchronisation tool. In this case, the business card would be a file,
say bob.vcf.

When you run unison, changes propagate both ways. If a file has changed on
one side but not the other, the new replaces the old. (Unison maintains a
local state file so that it knows whether a file has changed since the last
successful replication).

In our example it has changed on both sides. Only one file called "bob.vcf"
can exist within the filesystem.  Unison solves the problem by simply
ducking out: the user can choose to replace the remote version with the
local version, or vice versa (both of which would lose data), but the
default action is to leave both sides unchanged.

From Alice's point of view, at least this is a simple solution. Whenever
she's on the desktop she'll see the version she last edited on the desktop,
and whenever she's on the laptop she'll see the version she last edited
there.

But because no replication has actually taken place, the data is not
protected. If her laptop hard drive dies, she'll lose all her changes made
on the laptop; ditto if her desktop hard drive dies.

It's up to her to copy across one of the versions manually (under a
different filename), merge the two, and then finally push the merged version
to the other side.

Note also that the original file (version v1) has been lost by this point.
So it's not going to be known from inspection alone which of v2a and v2b has
the most up-to-date E-mail address for Bob, and which has the most
up-to-date mobile number.  Alice has to remember which she entered last.

== Git ==

[[http://git-scm.com/|Git]] is a well-known distributed source control system.
Like unison, git deals with files. However, git considers the state of a
whole set of files as a single object, the "tree". Whenever you save an
update, you create a "commit" which points to both the updated tree and the
previous commit(s), which in turn point to the previous tree(s). You
therefore have a full history of all the states of the files. This forms a
branch, and a pointer is kept to the tip of the branch, from which you can
work backwards to any previous state. The "pointer" is actually an SHA1 hash
of the tip commit.

If you are replicating with one or more peers, a separate branch is made for
each of the peers. For example, you might have
{{{
    master               -- my local branch
    remotes/foo/master   -- branch on peer 'foo'
    remotes/bar/master   -- branch on peer 'bar'
}}}

In the normal way of working, replication is a "pull", importing changes
from a remote peer into the local repository.  A "pull" does two things:
first "fetch" the state of the peer into the remote tracking branch for that
peer; and then attempt to "merge" those changes into the local branch.

Now let's consider the business card. Alice has created a git repo
containing bob.vcf, and cloned it across to the other machine. The
branches look like this, where AAAAAAAA is the SHA1 of the commit.

{{{{
  ---------- desktop ----------           ---------- laptop ----------
  master: AAAAAAAA                        master: AAAAAAAA
  remotes/laptop/master: AAAAAAAA         remotes/desktop/master: AAAAAAAA
}}}}

Now she makes a change on the desktop, and commits it into the desktop repo;
then she makes a different change on the laptop, and commits it into the
laptop repo.

{{{{
  ---------- desktop ----------           ---------- laptop ----------
  master: BBBBBBBB                        master: CCCCCCCC
  remotes/laptop/master: AAAAAAAA         remotes/desktop/master: AAAAAAAA
}}}}

Now on the desktop she does "git pull laptop". Firstly, the remote objects
are copied across into the local repo and the remote tracking branch is
updated:

{{{{
  ---------- desktop ----------           ---------- laptop ----------
  master: BBBBBBBB                        master: CCCCCCCC
  remotes/laptop/master: CCCCCCCC         remotes/desktop/master: AAAAAAAA

  (note: repo still contains AAAAAAAA
  because commits BBBBBBBB and
  CCCCCCCC point to it)
}}}}

Then git will attempt to merge the changes in. It can do this because it
knows the parent commit to CCCCCCCC is AAAAAAAA, so it takes a diff between
AAAAAAAA and CCCCCCCC and tries to apply it to BBBBBBBB. If this is
successful, then you'll get a new version with a merge commit.

{{{{
  ---------- desktop ----------           ---------- laptop ----------
  master: DDDDDDDD                        master: CCCCCCCC
  remotes/laptop/master: CCCCCCCC         remotes/desktop/master: AAAAAAAA
}}}}

Then Alice has to logon to the laptop and run "git pull desktop". A similar
process occurs. The remote tracking branch is updated:

{{{{
  ---------- desktop ----------           ---------- laptop ----------
  master: DDDDDDDD                        master: CCCCCCCC
  remotes/laptop/master: CCCCCCCC         remotes/desktop/master: DDDDDDDD
}}}}

then a merge takes place. This is a special-case: CCCCCCCC one of the parent
commits of DDDDDDDD, so the laptop can "fast forward" update from CCCCCCCC
to DDDDDDDD directly without having to do any complex merging. This leaves
the final state as:

{{{{
  ---------- desktop ----------           ---------- laptop ----------
  master: DDDDDDDD                        master: DDDDDDDD
  remotes/laptop/master: CCCCCCCC         remotes/desktop/master: DDDDDDDD
}}}}

Now this is all and good, but you may wonder how this is relevant when
thinking about couchdb.

Firstly, note what happens in the case when the merge algorithm fails. The
changes ''are'' still propagated from the remote repo into the local one,
and are available in the remote tracking branch; so unlike unison, you know
the data is protected. It's just that the local working copy may fail to
update, or may diverge from the remote version. It's up to you to create and
commit the combined version yourself, but you are guaranteed to have all the
history you might need to do this.

Note that whilst it's possible to build new merge algorithms into Git, the
standard ones are focussed on line-based changes to source code.  They don't
work well for XML or JSON if it's presented without any line breaks.

The other interesting consideration is multiple peers. In this case you have
multiple remote tracking branches, some of which may match your local
branch, some of which may be behind you, and some of which may be ahead of
you (i.e. contain changes that you haven't yet merged).

{{{
  master: AAAAAAAA
  remotes/foo/master: BBBBBBBB
  remotes/bar/master: CCCCCCCC
  remotes/baz/master: AAAAAAAA
}}}

Note that each peer is explicitly tracked, and therefore has to be
explicitly created.  If a peer becomes stale or is no longer needed, it's up
to you to remove it from your configuration and delete the remote tracking
branch.  This is different to couchdb, which doesn't keep any peer state in
the database.

Another difference with git is that it maintains all history back to time zero -
git compaction keeps diffs between all those versions in order to reduce size,
but couchdb discards them. If you are constantly updating a document, the size
of a git repo would grow forever. It is possible (with some effort) to use
"history rewriting" to make git forget commits earlier than a particular one.

== Amazon Dynamo ==

[[http://www.allthingsdistributed.com/2007/10/amazons_dynamo.html|Dynamo]]
is designed as an "always writeable" key-value store, so it has no equivalent to the
409 conflict avoidance. It encourages users to perform conflict resolution
on read: a read operation provides all the conflicting versions plus a
"context". The write operation supplies the same context and this
supercedes all the previous revisions in one go.
