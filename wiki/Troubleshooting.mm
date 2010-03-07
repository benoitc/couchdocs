== Upgrade ==

Have you built CouchDB from the Subversion repository?

Did you do a `svn up` that seemed to break everything?

After every update you must run the following command:

{{{
./bootstrap
}}}

If you still have problems building try the next troubleshooting tip.

== First Run ==

Having problems getting CouchDB to run for the first time?

Follow this simple procedure and report back to mailing list (or IRC) with the
output of each step.

 1. Note down the name of your operating system and your processor architecture.

 2. Note down the installed versions of CouchDB's dependancies.

 3. Follow the [[http://couchdb.apache.org/community/code.html|checkout instructions]] to get a fresh copy of trunk.

 4. Bootstrap from the `couchdb` directory:

  {{{
./bootstrap
}}}

  FreeBSD users: if you get "{{{aclocal: not found}}}" you need to install {{{automake}}}.

 5. Build into a temporary directory:

  {{{
./configure --prefix=/tmp/couchdb && make && make install
}}}

  FreeBSD users: if you get "{{{Syntax error: end of file unexpected}}}" when you run {{{make}}}, you need to run {{{gmake}}} instead.

 6. Run the couchdb command and log the output:

  {{{
/tmp/couchdb/bin/couchdb
}}}

 7. Use your system's kernel trace tool and log the output of the above command.

  1. Linux systems should use strace:

    {{{
strace /tmp/couchdb/bin/couchdb 2> strace.out
}}}

  2. Please add documentation for your system...

 8. Report back to the mailing list (or IRC) with the output from each step.

== invalid UTF-8 JSON ==

When upgrading from old versions of CouchDB, it is best to really get rid of everything old.  If you get strange errors and all but the simplest actions appear to be broken, and especially if you are seeing {"error":"bad_request","reason":"invalid UTF-8 JSON"} type of errors in Futon, then you should try something like the following:

{{{
find /usr/local -name \*couch* | xargs rm -rf 
make && sudo make install
}}}

This was discussed on 13 Dec 2009 on the users mailing list, and the resolution is discussed 
[[http://mail-archives.apache.org/mod_mbox/couchdb-user/200912.mbox/%3c200912130717.39605.sh@widetrail.dk%3e|here]] and 
[[http://mail-archives.apache.org/mod_mbox/couchdb-user/200912.mbox/%3c20091214091547.GA7543@uk.tiscali.com%3e|here]]


== Misc Errors ==
CouchDB using a lot of memory (several hundred MB) on startup?  This one seems to especially affect Dreamhost installs.  It's really an issue with the Erlang VM pre-allocating data structures when ulimit is very large or unlimited.  A detailed dicussion can be found [[http://www.erlang.org/cgi-bin/ezmlm-cgi/4/46168|on the erlang-questions list]], but the short answer is that you should decrease ulimit -n or define ERL_MAX_PORTS to something reasonable like 1024.

Erlang backtraces are quite "hard" to read for non-Erlangers. The list here tries to give keywords to help you pinpointing your problem and suggests possible solutions

 system_limit, erlang, open_port:: Erlang has a default limit of 1024 ports, where each FD, tcp connection, and linked-in driver uses one port. You seem to have exceeded this. You can change it at runtime using the ERL_MAX_PORTS env variable.
 (by Adam Kocoloski, [[https://bugs.edge.launchpad.net/ubuntu/+source/couchdb/+bug/459241]])


== Map/Reduce debugging ==
You can debug your Map and Reduce functions in the js command line. The fact that documents and function definitions are real javascript code makes it trivial to copy and paste both into SpiderMonkey.

First you assign a document to a variable. I like to copy from the Source tab of a doc in Futon:
{{{
js> doc = {
   "_id": "image-5",
   "_rev": "3-3e1b61291d9102d84e71e27cb46266fc",
   "status": 200,
   "style": "original"
}
[object Object]
}}}
Next you assign your function to another variable. Again I like to copy from the Source tab of a design doc in Futon:
{{{
js> map = function(doc) { emit(doc.style, doc) }
function (doc) {
    emit(doc.style, doc);
}
}}}
Don't forget to define the emit function as well. I just alias the print function:
{{{
js> emit = print
function print() {
    [native code]
}
}}}
Now you can manually apply your map function to this document, and see what gets emitted:
{{{
js> map(doc)
original [object Object]
}}}
From here, just keep redefining map and applying it to doc until you are emitting the desired output.
