== Using the port system ==

Use the official precompiled package

{{{
$ sudo pkg_add apache-couchdb
}}}

or compile it yourself using the port:

{{{
$ cd /usr/ports/databases/apache-couchdb/
$ sudo make install
}}}

== Alternatives (not needed anymore due to port) ==

This worked for me on a brand new install of [[http://www.openbsd.org/|OpenBSD 4.4]]

{{{
# pre-requisite: spidermonkey
cd /usr/ports/lang/spidermonkey
make
make install
make clean
# prerequisite: icu
cd /usr/ports/textproc/icu4c
make
make install
make clean
# pre-requisite: erlang
cd
pkg_add erlang
# yes, but i would prefer the latest erlang
pkg_add wget
pkg_add gmake
mkdir /usr/tools
cd /usr/tools
mkdir erlang
cd erlang
wget http://www.erlang.org/download/otp_src_R12B-5.tar.gz
tar zxf otp_src_R12B-5.tar.gz
mkdir otp_R12B-5
cd otp_src_R12B-5
export LANG=C
./configure --help
./configure --prefix=/usr/tools/erlang/otp_R12B-5 --with-ssl
gmake
gmake install
PATH=/usr/tools/erlang/otp_R12B-5/bin:$PATH
cd /usr/tools
mkdir couchdb
cd couchdb
# the following url is a copy/paste from what
# http://www.apache.org/dyn/closer.cgi?path=/incubator/couchdb/0.8.1-incubating/apache-couchdb-0.8.1-incubating.tar.gz
# gave as a link
wget http://mir2.ovh.net/ftp.apache.org/dist/incubator/couchdb/0.8.1-incubating/apache-couchdb-0.8.1-incubating.tar.gz
tar zxf apache-couchdb-0.8.1-incubating.tar.gz
mkdir couchdb-0.8.1
cd apache-couchdb-0.8.1-incubating
./configure --prefix=/usr/tools/couchdb/couchdb-0.8.1
gmake
gmake install
cd ../couchdb-0.8.1/bin
./couchdb&
cd /tmp
wget localhost:5984
cat index.html
}}}

You could also use this ports tested on -current and 4.3 :  

http://benoitc.org/files/couchdb.tgz  

Don't forget to make update-plist to reflect latest changes.
