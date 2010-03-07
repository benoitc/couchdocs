Explanation and solution of error messages you may experience while building or running CouchDB.


 * [[#InstallationErrors|Installation Errors]]
  * [[#Missingicu-config|Missing icu-config]]
  * [[#Erlang-version-less-5.6.0|Erlang version is less than 5.6.5]]
  * [[#IncorrectLD_LIBRARY_PATH|Incorrect LD_LIBRARY_PATH]]
  * [[#BinaryArchitectureMismatchOSX|Binary Architecture Mismatch OSX]]
  * [[#BinaryArchitectureMismatchSolarisSPARC|Binary Architecture Mismatch Solaris/SPARC]]
  * [[#UnavailablePort|Unavailable Port]]
  * [[#MissingOpenSSL|Missing OpenSSL]]
  * [[#IncorrectPermissions|Incorrect Permissions or Missing Directories]]
  * [[#CrashOnStartup|Crash On Startup]]
 * [[#RuntimeErrors|Runtime Errors]]
  * [[#functionraisedexceptionCannotencodeundefinedvalueasJSON|function raised exception (Cannot encode 'undefined' value as JSON)]]
  * [[#replicationreceivedexceptionerrorbadmatchreasonerroralreadypresent|replication received exception ({"error":"badmatch","reason":"{error,already_present}"})]]

<<Anchor(InstallationErrors)>>
= Installation errors =

<<Anchor(Missingicu-config)>>
== Missing icu-config ==

=== Problem ===

{{{
*** The icu-config script could not be found. Make sure it is
*** in your path, and that taglib is properly installed.
*** Or see http://ibm.com/software/globalization/icu/
}}}

=== Solution ===

Install ICU and use `locate` to find the `icu-config` command:

{{{
locate icu-config
}}}

For me on Ubuntu 8.04 server I just did:
{{{
sudo apt-get install libicu-dev
}}}

Take the directory from the output of this command and add it to your `PATH`:

{{{
export PATH="$PATH:/usr/local/bin"
}}}

<<Anchor(Erlang-version-less-5.6.5)>>
== Erlang version is less than 5.6.5 (R12B) ==

=== Problem ===

Even after doing sudo apt-get install erlang you are getting the following error on ubuntu 8.04:
{{{
configure: error: The installed Erlang version is less than 5.6.5 (R12B).
}}}

=== Solution ===

To get a later version without bothering with installing from source edit /etc/apt/sources.list and locate the following line:
{{{
deb http://us.archive.ubuntu.com/ubuntu/ hardy universe
}}}

Change it to the following
{{{
deb http://us.archive.ubuntu.com/ubuntu/ intrepid universe
}}}

Save and then run:
{{{
apt-get update
}}}

You should now be able to install it by doing:
{{{
apt-get install erlang-nox erlang-dev
}}}

Test you version and confirm you see something greater than 5.6.0 
{{{
erl
}}}

<<Anchor(IncorrectLD_LIBRARY_PATH)>>
== Incorrect LD_LIBRARY_PATH ==

=== Problem ===

{{{
$ couchdb      
Apache CouchDB 0.8.0-incubating (LogLevel=info)
Apache CouchDB is starting.

{"init terminating in do_boot",{error,{open_error,-10}}​}

Crash dump was written to: erl_crash.dump
init terminating in do_boot ()
}}}

or

{{{
$ couchdb
Apache CouchDB 0.8.1-incubating (LogLevel=info)
Apache CouchDB is starting.

{"init terminating in do_boot","libjs.so: cannot open shared object file: No such file or directory"}

Crash dump was written to: erl_crash.dump
init terminating in do_boot (libjs.so: cannot open shared object file: No such file or directory)
}}}

=== Solution ===

You must correctly set your `LD_LIBRARY_PATH` environment variable so that it picks up your installed libraries. On Mac OS X, the equivalent variable is `DYLD_LIBRARY_PATH`.

Example running as normal user:

{{{
LD_LIBRARY_PATH=/usr/local/lib:/usr/local/spidermonkey/lib couchdb
}}}

Example running as `couchdb` user:

{{{
echo LD_LIBRARY_PATH=/usr/local/lib:/usr/local/spidermonkey/lib couchdb | sudo -u couchdb sh
}}}

Similar instructions are on the InstallingSpiderMonkey page.

<<Anchor(BinaryArchitectureMismatchOSX)>>
== Binary Architecture Mismatch OSX ==

On Mac OS X, libraries and executables can be ''fat binaries'' that support multiple processor architectures (PPC and x86, 32 and 64 bit). But that also means you will run into problems when trying to load a library into an application if that library doesn't support the architecture used by the application process.

=== Problem ===

{{{
$ couchdb      
Apache CouchDB 0.8.0-incubating (LogLevel=info)
Apache CouchDB is starting.

{"init terminating in do_boot",{error,{open_error,-12}}​}

Crash dump was written to: erl_crash.dump
init terminating in do_boot ()
}}}

=== Solution ===

You've probably built Erlang with the 64 bit option enabled. The problem is that ICU, which CouchDB attempts to load at startup time, has not been compiled with 64 bit support, so it can't be loaded into the 64bit Erlang process.

For now you'll have to recompile Erlang, and resist the temptation to build a 64 bit binary (just omit the `--enable-darwin-64bit` option). The `--enable-darwin-universal` option works okay, but note that currently there's no universal build of ICU available.

<<Anchor(BinaryArchitectureMismatchSolarisSPARC)>>
== Binary Architecture Mismatch Solaris/SPARC ==

=== Problem ===
{{{
Apache CouchDB 0.8.1-incubating (LogLevel=info)
Apache CouchDB is starting.

{"init terminating in do_boot","ld.so.1: beam.smp: fatal: relocation
error: file
/opt/couchdb-0.8.1//lib/couchdb/erlang/lib/couch-0.8.1-incubating/priv/lib/couch_erl_driver.so:
symbol ucol_close_4_0: referenced symbol not found"}
init terminating in do_boot (ld.so.1: beam.smp: fatal: relocation error:
file
/opt/couchdb-0.8.1//lib/couchdb/erlang/lib/couch-0.8.1-incubating/priv/lib/couch_erl_driver.so:
symbol ucol_close_4_0: r
}}}

=== Solution ===

Solaris provides an old version of the ICU library.  On SPARC hardware, when building the current version of ICU, it defaults to 64bits, while erlang and spidermonkey defaulted to 32bit, so when linking, the linker picks the outdated version.

The solution is to rebuild ICU for 32bits.  At the ./configure step, add this flag, "--enable-64bit-libs=no".

Also, use LD_LIBRARY_PATH or crle to make /usr/local/lib earlier in the search path than /usr/lib.

<<Anchor(UnavailablePort)>>
== Unavailable Port ==

=== Problem ===

{{{
$ couchdb      
Apache CouchDB 0.9.0a747640 (LogLevel=info) is starting.
Failure to start Mochiweb: eaddrinuse
{"init terminating in do_boot",{{badmatch,{error,shutdown}},[{couch_server_sup,start_server,1},{erl_eval,do_apply,5},{erl_eval,exprs,5},{init,start_it,1},{init,start_em,1}]}}
}}}

=== Solution ===

Edit your `/etc/couchdb/couch.ini` file and change the `Port` setting to an available port.

<<Anchor(MissingOpenSSL)>>
== Missing OpenSSL ==

=== Problem ===

{{{
$ bin/couchdb
Apache CouchDB 0.8.0-incubating (LogLevel=info)
Apache CouchDB is starting.                                                                       

{"init terminating in do_boot",{undef,[{crypto,start,[]},{erl_eval,do_apply,5},{init,start_it,1},{init,start_em,1}]}}  

Crash dump was written to: erl_crash.dump
init terminating in do_boot ()
}}}

=== Solution ===

You are missing erlang SSL support.

You may not have installed the package that provides it (for example, erlang-ssl).  Check $(libdir)/erlang/lib/ssl-*/ and make sure it contains more than just an include/ subdirectory.

If you compiled by hand, you need to install the OpenSSL libraries and recompile Erlang with SSL enabled.

<<Anchor(IncorrectPermissions)>>
== Incorrect Permissions or Missing Directories ==

=== Problem ===

{{{
$ bin/couchdb
Apache CouchDB 0.9.0a691361-incubating (LogLevel=info) is starting.
{"init terminating in do_boot",{{badmatch,{error,shutdown}},[{couch_server_sup,start_server,1},{erl_eval,do_apply,5},{erl_eval,exprs,5},{init,start_it,1},{init,start_em,1}]}}

Crash dump was written to: erl_crash.dump
init terminating in do_boot ()
}}}

=== Solution ===

You need to make sure that the user running couchdb has permissions to write to /usr/local/var/lib/couchdb and /usr/local/var/log/couchdb. This error message may also appear if CouchDB is trying to bind to a port that is already in use.

Also check that the directories specified in your local.ini are there, like the database_dir and the directory where the log file is created. If they are not there, create them.

<<Anchor(CrashOnStartup)>>
== Crash On Startup ==

=== Problem ===

{{{
$ sudo couchdb
Apache CouchDB 0.9.0a720049-incubating (LogLevel=info) is starting.
{"init terminating in do_boot","Driver is an inappropriate Mach-O file"}

Crash dump was written to: erl_crash.dump
init terminating in do_boot (Driver is an inappropriate Mach-O file)
}}}

=== Solution ===

This is related to an update made in erlang (http://www.nabble.com/OS-X-fixes-(HiPE,-ddll-unload)-td19411880.html) Upgrading to version R12B-5 or higher should fix things.

<<Anchor(RuntimeErrors)>>
= Runtime Errors =

<<Anchor(functionraisedexceptionCannotencodeundefinedvalueasJSON)>>
== function raised exception (Cannot encode 'undefined' value as JSON) ==

=== Problem ===

A view index fails to build, CouchDB Logs this error message:

{{{
function raised exception (Cannot encode 'undefined' value as JSON)
}}}

=== Solution ===

The JavaScript code you are using for the map or reduce function is using an object member that is not defined. Consider this document

{{{
{
  "_id":"XYZ123",
  "_rev":"1BB2BB",
  "field":"value"
}
}}}

And this map function:

{{{
function(doc) {
  emit(doc.name, doc.address);
}
}}}

Use guarding to make sure to only access members when they exist in the passed-in document:

{{{
function(doc) {
  if(doc.name && doc.address) {
      emit(doc.name, doc.address);
  }
}
}}}

While the above guard will work in most cases, it's worth bearing !JavaScript's falsy set of values in mind. Testing against a property with a value of `0` (zero), `''` (empty String), `false` or `null` will return false. If this is undesired a guard of the form `if (doc.foo !== undefined)` should do the trick.

<<Anchor(replicationreceivedexceptionerrorbadmatchreasonerroralreadypresent)>>
== replication received exception ({"error":"badmatch","reason":"{error,already_present}"}) ==

=== Problem ===

A replication request receives the following HTTP response

{{{
HTTP/1.1 500 Internal Server Error - {"error":"badmatch","reason":"{error,already_present}"}
}}}

=== Solution ===

Alas, there is no information about this at present - it is being looked into. Observed on a 0.9 release running on x86_64 Linux
