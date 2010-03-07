== Dependancies for CouchDB ==

In a first time, you need to grab the following slackbuilds to meet Coubhdb's requirements :

 * [[http://slackbuilds.org/repository/13.0/network/js/|js]]
 * [[http://slackbuilds.org/repository/13.0/libraries/icu4c/|icu4c]]
 * [[http://slackbuilds.org/repository/13.0/development/erlang-otp/|erlang-otp]]

Other [[http://books.couchdb.org/relax/appendix/installing-from-source|dependancies]] are met by slackaware's packages :
 * curl : you can check with :
{{{#!bash
curl-config --version
}}}
 * make & gcc

Then, you need to build those packages from the slackbuilds. Slackbuils are made by default for i486 platform; If you have a 64 bits platform, edit the file `<package>.Slackbuild` and modify `ARCH` for `x86_64`.

To build the package, you have to put the source archive file within the slackbuild directory.

{{{#!bash
tar xzf js.tar.gz
cd js
./js.SlackBuild
=> Slackware package /tmp/js-1.8.0_rc1-x86_64-1_SBo.tgz created.

tar xzf icu4c.tar.gz
cd ../icu4c
./icu4c.SlackBuild
=> Slackware package /tmp/icu4c-4.2.1-x86_64-1_SBo.tgz created

tar xzf erlang-otp.tar.gz
cd erlang-otp
./erlang-otp.SlackBuild
=> Slackware package /tmp/erlang-otp-13B03-x86_64-1_SBo.tgz created.
}}}

Install packages :

{{{#!bash
nicolas@cassis:/tmp$ sudo installpkg icu4c-4.2.1-x86_64-1_SBo.tgz
Verifying package icu4c-4.2.1-x86_64-1_SBo.tgz.
Installing package icu4c-4.2.1-x86_64-1_SBo.tgz:
PACKAGE DESCRIPTION:
# icu4c (International Components for Unicode)
#
# The International Components for Unicode (ICU) libraries provide
# robust and full-featured Unicode services on a wide variety of
# platforms.
#
# Homepage: http://www.icu-project.org/
#
Executing install script for icu4c-4.2.1-x86_64-1_SBo.tgz.
Package icu4c-4.2.1-x86_64-1_SBo.tgz installed.

nicolas@cassis:/tmp$ sudo installpkg js-1.8.0_rc1-x86_64-1_SBo.tgz
Verifying package js-1.8.0_rc1-x86_64-1_SBo.tgz.
Installing package js-1.8.0_rc1-x86_64-1_SBo.tgz:
PACKAGE DESCRIPTION:
# SpiderMonkey (Mozilla's JavaScript Engine)
#
# SpiderMonkey is the code-name for the Mozilla's C implementation of
# JavaScript. It can be used by applications such as elinks and others.
#
# This is the standalone version of the engine used by Firefox and other
# Mozilla applications.
#
# Homepage: http://www.mozilla.org/js/spidermonkey
#
Package js-1.8.0_rc1-x86_64-1_SBo.tgz installed.

nicolas@cassis:/tmp$ sudo installpkg erlang-otp-13B03-x86_64-1_SBo.tgz
Verifying package erlang-otp-13B03-x86_64-1_SBo.tgz.
Installing package erlang-otp-13B03-x86_64-1_SBo.tgz:
PACKAGE DESCRIPTION:
# Erlang (programming language)
#
# Erlang is a general-purpose concurrent programming language and
# runtime system.
# The sequential subset of Erlang is a functional language,
# with strict evaluation, single assignment, and dynamic typing.
# It was designed by Ericsson to support distributed,
# fault-tolerant, soft-real-time, non-stop applications.
#
# http://www.erlang.org/
#
Executing install script for erlang-otp-13B03-x86_64-1_SBo.tgz.
Package erlang-otp-13B03-x86_64-1_SBo.tgz installed.
}}}

== Installation of CouchDB ==

First you need to create a couchdb group & user :

{{{#!bash
groupadd -g 231 couchdb
useradd -u 231 -g couchdb -d /var/lib/couchdb -s /bin/sh couchdb
}}}

Grab the [[http://slackbuilds.org/repository/13.0/development/couchdb/|slacckbuild ofCouchDB]]

Following steps are :

{{{#!bash
tar xzf couchdb.tar.gz
cd couchdb
# Grab couchdb 0.10.1 source file and put it in the "couchdb" directory
# Edit the couchdb.SlackBuild file if needed
# Build package :
./couchdb.Slackbuild
=> Slackware package /tmp/SBo/couchdb-0.10.1-x86_64-1_SBo.tgz created.
}}}

Install package :

{{{#!bash
installpkg /tmp/SBo/couchdb-0.10.1-x86_64-1_SBo.tgz
}}}

== Automatic stop/start for CouchDB ==

For automatic start :

In `/etc/rc.d/rc.local`, add :

{{{#!bash
if [ -x /etc/rc.d/rc.couchdb ]; then
	. /etc/rc.d/rc.couchdb start
fi
}}}


For automatic stop :

In `/etc/rc.d/rc.local_shutdown`, add :

{{{#!bash
if [ -x /etc/rc.d/rc.couchdb ]; then
	. /etc/rc.d/rc.couchdb stop
fi
}}}

Open http://localhost:5984/_utils/

Now, time to relax...
