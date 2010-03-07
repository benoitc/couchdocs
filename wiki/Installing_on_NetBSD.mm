Tested on NetBSD 5.0

Install prerequisites:

{{{
pkg_add icu erlang spidermonkey gmake
}}}

Download the source tarball from http://couchdb.apache.org/downloads.html untar and `cd` in to the directory. Then configure and compile:

{{{
./configure --with-js-lib=/usr/pkg/lib --with-js-include=/usr/pkg/include --with-erlang=/usr/pkg/lib/erlang/usr/include
gmake
gmake install
}}}

Take care of permissions:

{{{
su
useradd couchdb
group add couchdb
touch /usr/local/var/run/couchdb.pid
chown couchdb:couchdb /usr/local/var/run/couchdb.pid
chown couchdb:couchdb /usr/local/var/log/couchdb/couch.log
chown couchdb:couchdb /usr/local/var/lib/couchdb
}}}

Start:

{{{
/usr/local/etc/rc.d/couchdb start
}}}

Test:
http://localhost:5984/
