## page was renamed from FAQ
## page was renamed from Faq
A handy FAQ for all your CouchDB related questions.

=== About Couchdb ===
  * [[#what_is_couchdb|What is CouchDB?]]
  * [[#is_couchdb_ready_for_production|Is CouchDB Ready for Production?]]
  * [[#what_does_couch_mean|What Does Couch Mean?]]
  * [[#what_language|What Language is CouchDB Written in?]]
  * [[#what_platform|What Platforms are Supported?]]
  * [[#what_license|What is the License?]]

=== Using Couchdb ===
  * [[#how_much_stuff|How Much Stuff can I Store in CouchDB?]]
  * [[#how_sequences|How Do I Do Sequences?]]
  * [[#how_replication|How Do I Use Replication?]]
  * [[#how_find_conflicts|How do I find out which conflicts occurred during replication]]
  * [[#how_spread_load|How can I spread load across multiple nodes?]]
  * [[#why_no_mnesia|Why Does CouchDB Not Use Mnesia?]]
  * [[#i_can_has_no_http|Can I talk to CouchDB without going through the HTTP API?]]
  * [[#unicode_data|Erlang has been slow to adopt Unicode. Is Unicode or UTF-8 a problem with CouchDB?]]
  * [[#transactions|How do I use transactions with CouchDB?]]

=== Views ===
  * [[#how_fast_views|How Fast are CouchDB Views?]]
  * [[#slow_view_building|Creating my view index takes ages, WTF?]]
  * [[#update_views_more_often|I want to update my view indexes more often than only when a user reads it. How do I do that best?]]
  * [[#relationships|How do I model relationships in CouchDB? / Where are my JOINs?]]
  * [[#view_share_code|How do I share code/functions between views? / Why can I not?]]

=== Security ===
  * [[#secure_remote_server|I use CouchDB on a remote server and I don't want it to listen on a public port for security reasons. Is there a way to connect to it from my local machine or can I still use Futon with it?]]

=== Couchdb on your system ===
  * [[#finding_the_logfiles|Where are the Couchdb logfiles located?]]

If you have a question not yet answered in this FAQ please hit the edit button and add your question at the end. Check back in a few days, someone may have provided an answer.

<<Anchor(what_is_couchdb)>>
== What is CouchDB? ==

CouchDB is a document-oriented, Non-Relational Database Management Server (NRDBMS). The [[http://incubator.apache.org/couchdb/docs/intro.html|Introduction]] and [[http://incubator.apache.org/couchdb/docs/overview.html|Overview]] provide a high level overview of the CouchDB system.

<<Anchor(is_couchdb_ready_for_production)>>
== Is CouchDB Ready for Production? ==

Beta Release. CouchDB has not yet reached version 1.0. However, there are projects successful using CouchDB in a variety of contexts. See InTheWild for a partial list of projects using CouchDB.

<<Anchor(what_does_couch_mean)>>
== What Does Couch Mean? ==

It's an acronym, Cluster Of Unreliable Commodity Hardware. This is a statement of Couch's long term goals of massive scalablility and high reliability on fault-prone hardware. The distributed nature and flat address space of the database will enable node partitioning for storage scalabilty (with a map/reduce style query facility) and clustering for reliability and fault tolerance.

<<Anchor(what_language)>>
== What Language is CouchDB Written in? ==

Erlang, a concurrent, functional programming language with an emphasis on fault tolerance. Early work on CouchDB was started in C++ but was replaced by Erlang OTP platform. Erlang has so far proven an excellent match for this project.

CouchDB's default view server uses Mozilla's Spidermonkey Javscript library which is written in C. It also supports easy integration of view servers written in any language.

<<Anchor(what_platform)>>
== What Platforms are Supported? ==

Most POSIX systems, this includes GNU/Linux and OS X.

Windows is not officially supported but it should work, please let us know.

<<Anchor(what_license)>>
== What is the License? ==

[[http://www.apache.org/licenses/LICENSE-2.0.html|Apache 2.0]]

<<Anchor(how_much_stuff)>>
== How Much Stuff can I Store in CouchDB? ==

With node partitioning (done via your application logic), virtually unlimited. For a single database instance, the practical scaling limits aren't yet known.

You may also look into [[http://tilgovi.github.com/couchdb-lounge/|couchdb-lounge]].

<<Anchor(how_sequences)>>
== How Do I Do Sequences? ==

Or, where is my AUTO_INCREMENT?! With replication sequences are hard to realize. Sequences are often used to ensure unique identifiers for each row in a database table. CouchDB generates unique ids from its own and you can specify your own as well, so you don't really need a sequence here. If you use a sequence for something else, you might find a way to express in CouchDB in another way.

<<Anchor(how_replication)>>
== How Do I Use Replication? ==

{{{
POST /_replicate
}}}
with a post body of {{{
{"source":"$source_database","target":"$target_database"}
}}}

Where $source_database and $target_database can be the names of local database or full URIs of remote databases. Both databases need to be created before they can be replicated from or to.

<<Anchor(how_find_conflicts)>>
== How do I review conflicts occured during replication? ==

Use a view like this:

{{{
map: function(doc) {if(doc._conflicts){emit(null,null);}}
}}}

See also [[Replication_and_conflicts]]

<<Anchor(how_spread_load)>>
== How can I spread load across multiple nodes? ==

Using an http proxy like nginx, you can load balance GETs across nodes, and direct all POSTs, PUTs and DELETEs to a master node. CouchDB's triggered replication facility can keep multiple read-only servers in sync with a single master server, so by replicating from master -> slaves on a regular basis, you can keep your content up to date.


<<Anchor(why_no_mnesia)>>
== Why Does CouchDB Not Use Mnesia? ==

Several reasons:

  * The first is a storage limitation of 2 gig per file.
  * The second is that it requires a validation and fixup cycle after a crash or power failure, so even if the size limitation is lifted, the fixup time on large files is prohibitive.
  * Mnesia replication is suitable for clustering, but not disconnected, distributed edits. Most of the "cool" features of Mnesia aren't really useful for CouchDB.
  * Also Mnesia isn't really a general-purpose, large scale database. It works best as a configuration type database, the type where the data isn't central to the function of the application, but is necessary for the normal operation of it. Think things like network routers, HTTP proxies and LDAP directories, things that need to be updated, configured and reconfigured often, but that configuration data is rarely very large.

<<Anchor(i_can_has_no_http)>>
== Can I talk to CouchDB without going through the HTTP API? ==

CouchDB's data model and internal API map the REST/HTTP model so well that any other API would basically reinvent some flavour of HTTP. However, there is a plan to refactor CouchDB's internals so as to provide a documented Erlang API.

<<Anchor(unicode_data)>>
== Erlang has been slow to adopt Unicode. Is Unicode or UTF-8 a problem with CouchDB? ==
CouchDB uses Erlang binaries internally. All data coming to CouchDB must be UTF-8 encoded.


<<Anchor(transactions)>>
== How do I use transactions with CouchDB? ==

CouchDB uses an "optimistic concurrency" model. In the simplest terms, this just means that you send a document version along with your update, and CouchDB rejects the change if the current document version doesn't match what you've sent.

It's deceptively simple, really. You can reframe many normal transaction based scenarios for CouchDB. You do need to sort of throw out your RDBMS domain knowledge when learning CouchDB, though. It's helpful to approach problems from a higher level, rather than attempting to mold Couch to a SQL based world.

Keeping track of inventory

The problem you outlined is primarily an inventory issue. If you have a document describing an item, and it includes a field for "quantity available", you can handle concurrency issues like this:

Retrieve the document, take note of the _rev property that CouchDB sends along
Decrement the quantity field, if it's greater than zero
Send the updated document back, using the _rev property
If the _rev matches the currently stored number, be done!
If there's a conflict (when _rev doesn't match), retrieve the newest document version
In this instance, there are two possible failure scenarios to think about. If the most recent document version has a quantity of 0, you handle it just like you would in a RDBMS and alert the user that they can't actually buy what they wanted to purchase. If the most recent document version has a quantity greater than 0, you simply repeat the operation with the updated data, and start back at the beginning. This forces you to do a bit more work than an RDBMS would, and could get a little annoying if there are frequent, conflicting updates.

Now, the answer I just gave presupposes that you're going to do things in CouchDB in much the same way that you would in an RDBMS. I might approach this problem a bit differently:

I'd start with a "master product" document that includes all the descriptor data (name, picture, description, price, etc). Then I'd add an "inventory ticket" document for each specific instance, with fields for product_key and claimed_by. If you're selling a model of hammer, and have 20 of them to sell, you might have documents with keys like hammer-1, hammer-2, etc, to represent each available hammer.

Then, I'd create a view that gives me a list of available hammers, with a reduce function that lets me see a "total". These are completely off the cuff, but should give you an idea of what a working view would look like.

Map

{{{
function(doc) 
{ 
    if (doc.type == 'inventory_ticket' && doc.claimed_by == null ) { 
        emit(doc.product_key, { 'inventory_ticket' :doc.id, '_rev' : doc._rev }); 
    } 
}
}}}

This gives me a list of available "tickets", by product key. I could grab a group of these when someone wants to buy a hammer, then iterate through sending updates (using the id and _rev) until I successfully claim one (previously claimed tickets will result in an update error).

Reduce

{{{
function (keys, values, combine) {
    return values.length;
}
}}}
This reduce function simply returns the total number of unclaimed inventory_ticket items, so you can tell how many "hammers" are available for purchase.

Caveats

This solution represents roughly 3.5 minutes of total thinking for the particular problem you've presented. There may be better ways of doing this! That said, it does substantially reduce conflicting updates, and cuts down on the need to respond to a conflict with a new update. Under this model, you won't have multiple users attempting to change data in primary product entry. At the very worst, you'll have multiple users attempting to claim a single ticket, and if you've grabbed several of those from your view, you simply move on to the next ticket and try again

(This FaQ entry was borrowed from [[http://stackoverflow.com/questions/299723/can-i-do-transactions-and-locks-in-couchdb]] with permission from the author.)

<<Anchor(update_views_more_often)>>
== I want to update my view indexes more often than only when a user reads it. How do I do that best? ==

To get on write view update semantics, you can create a little daemon
script to run alongside CouchDB and specified in couch.ini,
as described in ExternalProcesses. This daemon gets sent a 
notification each time the database is changed and could in turn
trigger a view update every N document inserts or every Y seconds,
whichever occurs first. The reason not to integrate each doc as
it comes in is that it is horribly inefficient and CouchDB is designed
to do view index updates very fast, so batching is a good idea.
See RegeneratingViewsOnUpdate for an example.

To get a list of all views in a database, you can do a 
GET /db/_all_docs?startkey=_design/&endkey=_design/ZZZZ
(we will have a /db/_all_design_docs view to make the ZZZZ-hack
go away).

That should solve your problem.

Yes, such a daemon should be shipped with CouchDB, but we
haven't got around to work on the deployment infrastructure yet.
Any contributions to this are very welcome. I think the developer's
choice of language for helper scripts is Python, but any will do,
whatever suits you best.

<<Anchor(secure_remote_server)>>
== I use CouchDB on a remote server and I don't want it to listen on a public port for security reasons. Is there a way to connect to it from my local machine or can I still use Futon with it? ==

On you local machine, set up an ssh tunnel to your server and 
tell it to forward requests to the local port 5984 to the remote
server's port 5984:

{{{
$ ssh -L5984:127.0.0.1:5984 ssh.example.com
}}}

Now you can connect to the remote CouchDB through
http://localhost:5984/

<<Anchor(how_fast_views)>>
== How Fast are CouchDB Views? ==

It would be quite hard to give out any numbers that make much sense. From the architecture point of view, a view on a table is much like a (multi-column) index on a table in an RDBMS that just performs a quick look-up. So this theoretically should be pretty quick.

The major advantage of the architecture is, however, that it is designed for high traffic. No locking occurs is the storage module (MVCC and all that) allowing any number of parallel readers as well as serialized writes. With replication, you can even set up multiple machines for a horizontal scale-out and data partitioning (in the future) will let you cope with huge volumes of data. (See [[http://jan.prima.de/~jan/plok/archives/72-Some-Context.html|slide 13 of Jan Lehnardt's essay]] for more on the storage module or the whole post for detailed info in general).

<<Anchor(slow_view_building)>>
== Creating my view index takes ages, WTF? ==

A couple of reasons:

1) Your reduce function is not reducing the input data to a small enough output. See [[Introduction_to_CouchDB_views#reduce_functions]] for more details.

2) If you have a lot of documents or lots of large documents (going into the millions and Gigabytes), the first time a view index is created just takes the time it is needed to run through all documents.

3) If you use the `emit()`-function in your view with `doc` as the second parameter you effectively copy your entire data into the view index. This takes a lot of time. Consider rewriting your `emit()` call to `emit(key, null);` and query the view with the `?include_docs=true` parameter to get all doc's data with the view without having to copy the data into the view index.

4) You are using Erlang release R11B (or 5.5.x). Update to at least R12B-3 (or 5.6.3).

<<Anchor(relationships)>>
== How do I model relationships in CouchDB? / Where are my JOINs? ==

See: http://www.cmlenz.net/archives/2007/10/couchdb-joins

<<Anchor(view_share_code)>>
== How do I share code/functions between views? / Why can I not? ==

See: [[HTTP_view_API#view_share_code]]

<<Anchor(finding_the_logfiles)>>
== Where are the Couchdb logfiles located? ==

* For a default linux/unix installation the logfiles are located here:
 {{{
/usr/local/var/log/couchdb/couch.log
 }}}

 This is set in the { { {default.ini} } } file located here:
 {{{
/etc/couchdb/default.ini
 }}}

* If you've installed from source and are running couchdb in dev mode the logfiles are located here:
 {{{
YOUR-COUCHDB-SOURCE-DIRECTORY/tmp/log/couch.log
 }}}

 Read [[Running_Couchdb_in_Dev_Mode]] for more information.
