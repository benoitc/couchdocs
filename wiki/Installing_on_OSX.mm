== Unofficial Binary Packages ==
 * If you just want to give CouchDB a shot and don't like the command line based installation, you can get this unofficial binary release for Mac OS X 10.5 Leopard and Intel Macs only: http://janl.github.com/couchdbx/
 * Nightly build of CouchDB for OS X: http://couch.lstoll.net/nightly/

== MacPorts ==
To install CouchDB using MacPorts

{{{
$ sudo port install couchdb
}}}
should be enough. MacPorts takes care of installing all necessary dependencies. If you have already installed some of the CouchDB dependencies via MacPorts, run this command to check and upgrade any outdated ones, ''after installing CouchDB'':

{{{
$ sudo port upgrade couchdb
}}}
This will upgrade dependencies recursively, if there are more recent versions available. If you want to run CouchDB as a service controlled by the OS, load the launchd configuration which comes with the project, with this command:

{{{
$ sudo launchctl load -w /opt/local/Library/LaunchDaemons/org.apache.couchdb.plist
}}}
and it should be up and accessible via http://127.0.0.1:5984/_utils/index.html. It should also be restarted automatically after reboot (because of the -w flag).

If not, be sure to check permissions on couchdb files and repair them if neccessary:

{{{
$ sudo chown -R couchdb:couchdb /opt/local/var/lib/couchdb/ /opt/local/var/log/couchdb/
}}}
Updating the ports collection. The collection of port files has to be updated to reflect the latest versions of available packages. In order to do that run:

{{{
$ sudo port selfupdate
}}}
to update the port tree, and then install just as explained.

== Dependencies - Erlang ==
If Erlang fails to build with the error:

{{{
Command output: megaco_flex_scanner_drv.flex:31: unknown error processing section 1
}}}
You will need to upgrade flex: http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=465039

== Typical build process of a CouchDB developer build ==
{{{
$ svn co http://svn.apache.org/repos/asf/couchdb/trunk couchdb
$ cd couchdb
$ ./bootstrap && ./configure
$ make
$ sudo make install
}}}
== Installing from source on Mac OS X 10.6 Snow Leopard ==
Here is a recipe to install CouchDB from source on Mac OS X 10.6 Snow Leopard with needed dependencies.

1. Install ICU

{{{
$ curl -O http://download.icu-project.org/files/icu4c/4.2.1/icu4c-4_2_1-src.tgz
$ tar xvzf icu4c-4_2_1-src.tgz
$ cd icu/source
$ ./runConfigureICU MacOSX --with-library-bits=64 --disable-samples --enable-static # if this fails for you try: ./configure --enable-64bit-libs
$ make
$ sudo make install
}}}
2. Install SpiderMonkey

We need [[http://svn.macports.org/repository/macports/trunk/dports/lang/spidermonkey/files/patch-jsprf.c|jsprf patch]] from the MacPorts project to install SpiderMonkey.

{{{
$ curl -O http://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz
$ curl -O http://svn.macports.org/repository/macports/trunk/dports/lang/spidermonkey/files/patch-jsprf.c
$ tar xvzf js-1.7.0.tar.gz
$ cd js/src
$ patch -p0 -i ../../patch-jsprf.c
$ make -f Makefile.ref
$ sudo su
$ JS_DIST=/usr/local/spidermonkey make -f Makefile.ref export
$ exit
$ sudo ranlib /usr/local/spidermonkey/lib/libjs.a
}}}
'''NOTE:''' You may receive the following warning. You should be safe to ignore it and proceed with the instructions.

{{{
ranlib: file: /usr/local/spidermonkey/lib/libjs.a(jslock.o) has no symbols
}}}
==== Using DYLD_LIBRARY_PATH ====
add to your .profile this line :

{{{
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/spidermonkey/lib
}}}
then reload your env :

{{{
$ . ~/.profile
}}}
==== Avoding DYLD_LIBRARY_PATH ====
Not using DYLD_LIBRARY_PATH means that you don't need to worry about setting the environment for other users (ie, the couchdb user or root). Also, it avoids the need to tell the CouchDB ./configure script where to find spidermonkey.

{{{
$ sudo ln -s /usr/local/spidermonkey/include /usr/local/include/js
$ sudo ln -s /usr/local/spidermonkey/lib/libjs.dylib /usr/local/lib/libjs.dylib
# If you're feeling saucey, the js shell can be useful for quick syntax checking and the like.
$ sudo ln -s /usr/local/spidermonkey/bin/js /usr/local/bin/js
}}}
3. Install Erlang R13B01

{{{
$ curl -O http://erlang.org/download/otp_src_R13B01.tar.gz
$ tar xvzf otp_src_R13B01.tar.gz
$ cd otp_src_R13B01/
$ ./configure --enable-smp-support --enable-dynamic-ssl-lib --enable-kernel-poll --enable-darwin-64bit
$ make
$ sudo make install
}}}
4. Building CouchDB:

We will install it from the trunk, but installation from released source should work

{{{
$ svn co http://svn.apache.org/repos/asf/couchdb/trunk couchdb
$ cd couchdb
$ ./bootstrap && ./configure --with-js-include=/usr/local/spidermonkey/include --with-js-lib=/usr/local/spidermonkey/lib
$ make
}}}
==== NOTE ====
If you avoided using DYLD_LIBRARY_PATH when installing spidermonkey, you won't need to use the --with-js-[include|lib] flags.

5. Running

If you want to install run `make install` . For developement use do :

{{{
$ make dev
$ ./utils/run
}}}
