## page was renamed from InstallingSpiderMonkeyFromSource

== Installing from sources ==

 1. Get one of the source tarballs from http://ftp.mozilla.org/pub/mozilla.org/js/ (1.7.0 or 1.8.0-rc1 will do).
 1. Unpack the tarball. Note that once extracted the source are in the directory "js", without the expected version suffix.
 1. Go to the js/src directory.
 {{{
cd js/src
}}}
 1. Build SpiderMonkey. There is no default Makefile, use Makefile.ref. The default build is debug, use BUILD_OPT=1 for an optimized build.
 {{{
make BUILD_OPT=1 -f Makefile.ref
}}}
 1. Install SpiderMonkey. Instead of "install" the target to use is "export". Instead of PREFIX the target directory is specified with JS_DIST.
 {{{
sudo make BUILD_OPT=1 JS_DIST=/usr/local -f Makefile.ref export
}}}

== Notes when installing on OS X ==

 * The export needs to be run as root so use $ sudo sh
 * When running ./configure for couchdb you will need to use the --with-js-include and --with-js-lib options
 * You will need to make sure /usr/local/spidermonkey/lib is in  DYLD_LIBRARY_PATH {{{export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/spidermonkey/lib}}}
 * If you're still getting {{{dyld: Library not loaded: Darwin_OPT.OBJ/libjs.dylib}}} when trying to start couchdb, run {{{ranlib /usr/local/spidermonkey/libjs.a}}}

== Notes when installing on Linux ==

It would be best if you can install the SpiderMonkey libraries via your system's package management system, eg:

{{{
apt-get install libmozjs-dev
}}}

Or:

{{{
yum install js-devel
}}}

Warning: Yum may install an older version of SpiderMonkey (1.5) that doesn't work with CouchDB. If you see build errors related to JSOPTION_NATIVE_BRANCH_CALLBACK, you will need to build a newer version of SpiderMonkey as mentioned above.

However, if you need to install from source you should make sure spidermonkey's lib directory is in LD_LIBRARY_PATH:

{{{
export LD_LIBRARY_PATH=/usr/local/spidermonkey/lib
}}}

Or if this does not work for you, set the /lib and /include locations when running ./configure by using something similar to:

{{{
./configure --with-js-lib=/usr/local/spidermonkey/lib --with-js-include=/usr/local/spidermonkey/include
}}}

If you get a message like this during "yum install js-devel":

{{{
No package js-devel available.
Nothing to do
}}}

you may need to add a yum repository. Add rpmforge.repo in /etc/yum.repos.d containing:

{{{
# Name: RPMforge RPM Repository for Red Hat Enterprise 5 - dag
# URL: http://rpmforge.net/
[rpmforge]
name = Red Hat Enterprise $releasever - RPMforge.net - dag
baseurl = ftp://ftp.pbone.net/mirror/atrpms.net/el5-i386/atrpms/stable
enabled = 1
protect = 0
gpgcheck = 0
}}}

(Put "x86_64" instead of "i386" if when appropriate.)

Now run:

{{{
yum clean all
yum install js-devel
}}}

and you should be OK.
