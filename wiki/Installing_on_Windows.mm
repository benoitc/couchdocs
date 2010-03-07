<<TableOfContents>>

This page describes how to build and install couchdb from source on Windows.  See also the [[Windows_binary_installer]].

= Building current couchdb versions =

As of couchdb 0.10, support for Windows is included in the standard build process.  View [[http://svn.apache.org/viewvc/couchdb/trunk/README?view=co|README]] in the root of the source tree for information about the dependencies and how to configure the build process.  In summary, you will need to:

 * Install the cygwin environment.

 * Install the MS C compiler.

 * Install and possibly build a number of pre-requisites, such as curl, icu, seamonkey, etc.

 * get the sources to erlang and couch

 * configure and build erlang according to the instructions.

 * configure and build couch according to the [[http://svn.apache.org/viewvc/couchdb/trunk/README?view=co|README]] file in couch

After executing 'make install', you will find a couchdb directory structure inside your erlang directory - that is, the couch build process simply installs its libraries into the erlang binaries you previously build.  This directory structure should be ready to roll - it can be zipped up, packaged by an installer, etc.

= Older instructions =

These instructions are for couch versions pre 0.10


There is a [[Windows_binary_installer]] in "beta testing". See the wiki page for it for more instructions.

CouchDB does not natively install on Windows but it is possible to install it by hand. '''Be aware that many unit tests fail due to IO-related features that aren't supported by Erlang on Windows.'''

Please update this guide as needed, we aim to collect feedback and roll the procedure into the official build.

These instructions currently refer to paths as they'd be set up in a default installation of Erlang OTP 5.7.1, with the couchDB distribution installed at

{{{
C:\Program Files\erl5.7.1\lib\apache-couchdb-0.9.0
}}}

== Dependencies ==

You will need the following software installed on your system:

  * [[http://www.erlang.org/download.html|Erlang/OTP]]
  * C Compiler/Linker (such as [[http://gcc.gnu.org/|GCC]] or [[http://msdn.microsoft.com/en-us/visualc/default.aspx|Visual C++]])
  * Make (such as [[http://www.gnu.org/software/make/|GNU Make]] or [[http://msdn.microsoft.com/en-us/library/dd9y37ha(VS.71).aspx|nmake]])
  * [[http://www.openssl.org/|OpenSSL]]
  * [[http://www.icu-project.org/|ICU]] (Tested with [[http://www.icu-project.org/download/4.0.html|binary build of 4.2 release]].)
  * [[http://www.mozilla.org/js/spidermonkey/|SpiderMonkey]]

== Install CouchDB as an Erlang Library Directory ==

After installing Erlang you should having something similar to:

{{{
C:\Program Files\erl5.7.1
}}}

Copy the whole CouchDB source tree to:

{{{
C:\Program Files\erl5.7.1\lib\apache-couchdb-0.9.0
}}}

Make the following empty directories:

{{{
C:\Program Files\erl5.7.1\lib\mochiweb-0.01\ebin
}}}

{{{
C:\Program Files\erl5.7.1\lib\apache-couchdb-0.9.0\ebin
}}}

== Provide ICU to Erlang ==

From ICU copy `icu*.dll` (and `libeay32.dll` for older versions of ICU) to:

{{{
C:\Program Files\erl5.7.1\erts-5.7.1\bin
}}}

== Build SpiderMonkey ==

The SpiderMonkey distribution's Windows build stuff is broken. See [[http://blog.endflow.net/?p=55&lang=en|this blog post]] for a working js.mak file. Don't bother trying to import the project file into a contemporary Visual Studio; just use the Visual Studio command line tools with the js.mak file referred to above.

CouchDB uses a custom JavaScript driver, which provides unicode and buffering improvements. In the !SpiderMonkey distribution, rename src/js.c to src/js.c.bak, and copy {{{C:\Program Files\erl5.6.3\lib\couchdb-0.8.1\src\couchdb\couch_js.c}}} from the CouchDB distribution to src/js.c in the !SpiderMonkey distribution. Before running nmake, edit the new js.c and change {{{#include <jsapi.h>}}} to {{{#include "jsapi.h"}}}.

Once you've built js.exe and js32.dll, copy them both to

{{{
C:\Program Files\erl5.7.1\erts-5.7.1\bin
}}}

and rename js.exe to couch_js.exe.

''Here are the binaries built according to the blog post: [[http://dl.getdropbox.com/u/118385/CouchDbBinaries/couchbd_spidermonkey_1.7_win32_32bit.zip|couchbd_spidermonkey_1.7_win32_32bit.zip]] . Just unzip the contents to the bin directory.''

== Build couchdb/couch_erl_driver.c ==

This is a wrapper to provide ICU features to CouchDB.

''Here is a binary (no worry! MS bleeding-edge technology proved!) built against ICU 4.2 in 32-bit Windows: [[attachment:couch_erl_driver.dll]]''

The simplest way to build a DLL is to create a Win32 DLL project in an IDE, add `couch_erl_driver.c` into the project, and change project settings to include the Erlang ERTS and ICU4C header paths. 

You must also include the various ICU `*.lib` files to the MSVC linker as inputs. MSVC doesn't know how to create a DLL with unresolved names.  In Visual Studio 2008 this can be accomplished by right clicking on the project, choosing properties, expanding the Linker node in the left panel, selecting Input, and adding the following to the 'Additional Dependencies' field:
 *icudt.lib 
 *icuin.lib 
 *icuio.lib 
 *icule.lib 
 *iculx.lib 
 *icutu.lib 
 *icuuc.lib 

The erlang include paths for this build for example were 

{{{
C:\otp_src_R13B\erts\emulator\sys\win32 
C:\otp_src_R13B\erts\emulator\beam
}}}

Make the following empty directory:

{{{
C:\Program Files\erl5.7.1\lib\apache-couchdb-0.9.0\priv
}}}

Copy the DLL to:

{{{
C:\Program Files\erl5.7.1\lib\apache-couchdb-0.9.0\priv\couch_erl_driver.dll
}}}

== Erlang Compilation ==

Create a the following file:

{{{
C:\Program Files\erl5.7.1\lib\apache-couchdb-0.9.0\src\Emakefile
}}}

Add the following content:

{{{
{'./couchdb/*', [{outdir,"../ebin"}]}.
{'./mochiweb/*', [{outdir,"../../mochiweb-0.01/ebin"}]}.
}}}

Launch `erl` (or `werl`) and execute the following command to change working directory:

{{{
cd("C:/Program Files/erl5.7.1/lib/apache-couchdb-0.9.0/src").
}}}

Execute this command to compile CouchDB:

{{{
make:all().
}}}

== Configuring ==

Copy the following file:

{{{
C:\Program Files\erl5.7.1\lib\apache-couchdb-0.9.0\etc\couchdb\default.ini.tpl.in
}}}

To this location:

{{{
C:/Program Files/erl5.7.1/bin/default.ini
}}}

or to this location:

{{{
C:/Program Files/erl5.7.1/lib/couchdb-0.9.0/default.ini
}}}

Edit the file to look something like this:

{{{
[couchdb]
database_dir = c:/data/couch
view_index_dir = c:/data/couch
util_driver_dir = C:/Program Files/erl5.7.1/lib/apache-couchdb-0.9.0/priv
ConsoleStartupMsg=Apache CouchDB is starting.
max_document_size = 4294967296 ; 4 GB
max_attachment_chunk_size = 4294967296 ; 4GB
os_process_timeout = 5000 ; 5 seconds. for view and external servers.
max_dbs_open = 100

[httpd]
port = 5984
bind_address = 127.0.0.1
authentication_handler = {couch_httpd, default_authentication_handler}
WWW-Authenticate = Basic realm="administrator"

[log]
file = c:/logs/couch.log
level = info

[daemons]
view_manager={couch_view, start_link, []}
external_manager={couch_external_manager, start_link, []}
db_update_notifier={couch_db_update_notifier_sup, start_link, []}
query_servers={couch_query_servers, start_link, []}
httpd={couch_httpd, start_link, []}
stats_aggregator={couch_stats_aggregator, start, []}
stats_collector={couch_stats_collector, start, []}

[httpd_global_handlers]
/ = {couch_httpd_misc_handlers, handle_welcome_req, <<"Welcome">>}
favicon.ico = {couch_httpd_misc_handlers, handle_favicon_req, "C:/Program Files/erl5.7.1/lib/apache-couchdb-0.9.0/share/www"}

_utils = {couch_httpd_misc_handlers, handle_utils_dir_req, "C:/Program Files/erl5.7.1/lib/apache-couchdb-0.9.0/share/www"}
_all_dbs = {couch_httpd_misc_handlers, handle_all_dbs_req}
_active_tasks = {couch_httpd_misc_handlers, handle_task_status_req}
_config = {couch_httpd_misc_handlers, handle_config_req}
_replicate = {couch_httpd_misc_handlers, handle_replicate_req}
_uuids = {couch_httpd_misc_handlers, handle_uuids_req}
_restart = {couch_httpd_misc_handlers, handle_restart_req}
_stats = {couch_httpd_stats_handlers, handle_stats_req}

[httpd_db_handlers]
_design = {couch_httpd_db, handle_design_req}
_temp_view = {couch_httpd_view, handle_temp_view_req}

[httpd_design_handlers]
_view = {couch_httpd_view, handle_view_req}
_show = {couch_httpd_show, handle_doc_show_req}
_list = {couch_httpd_show, handle_view_list_req}

}}}

Make sure that the `database_dir` exists and that the `LogFile` can be created.

== Running ==

Launch `erl` (or `werl`) and execute the following command:

{{{
couch_server:start().
}}}


If you encounter any trouble, set the log 'level' to 'debug' in default.ini

To check that everything has worked point your web browser to
[[http://localhost:5984/_utils/index.html]] and run the test suite.
