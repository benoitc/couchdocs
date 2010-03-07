## The basis for this page is originally from "Installing on Fedora10" which was itself renamed from InstallingOnRHEL4
Installing on Fedora Core 10 x86_64
Installing on Fedora Core 10 x86_64

1. install erlang
{{{
  # yum install erlang
}}}

Note : this currently results in a version R12B-4.3.fc10.

2. install other dependencies (no external repos required).

{{{
  # yum install icu libicu-devel js js-devel libcurl-devel
}}}

Note : this results in icu version 4.0-3.fc10 and js version 1.70-3.

3. install couchdb

The code can be gotten from subversion using

{{{
  $ svn checkout http://svn.apache.org/repos/asf/couchdb/trunk couchdb
  $ cd couchdb
  $ ./bootstrap
}}}

If bootstrap throws "libtoolize: command not found" you need to "# yum install libtool"

{{{
  $ ./configure
}}}

If configure throws "Could not find the `erl_driver.h' header" you need to tell it where the Erlang includes are; for example: "--with-erlang=/usr/lib64/erlang/usr/include/".

And then as root:

{{{
  # make install
}}}

The source can also be obtained from a released version using a tool like wget.  The example uses the primary site, whereas it is often faster to download from a mirror, e.g.,

  http://www.apache.org/dyn/closer.cgi?path=/incubator/couchdb/0.8.1-incubating/apache-couchdb-0.8.1-incubating.tar.gz

For example,

{{{
  $ wget http://www.apache.org/dist/incubator/couchdb/0.8.1-incubating/apache-couchdb-0.8.1-incubating.tar.gz
  $ tar -xzvf apache-couchdb-0.8.1-incubating.tar.gz 
  $ cd apache-couchdb-0.8.1-incubating
  $ ./configure  --with-erlang=/usr/lib64/erlang/usr/include/
  $ make && make install
}}}

4. create couchdb user 

{{{
  $ sudo adduser -r -d /usr/local/var/lib/couchdb couchdb
  $ sudo chown -R couchdb /usr/local/var/lib/couchdb
  $ sudo chown -R couchdb /usr/local/var/log/couchdb
}}}

5. (optional) edit basic settings like Port and !BindAddress

{{{
  $ emacs /usr/local/etc/couchdb/couch.ini
}}}

6. start CouchDB server in your terminal

{{{
  $ cd /usr/local/bin/
  $ sudo -u couchdb ./couchdb
}}}

or as daemon

{{{
  $ sudo /usr/local/etc/rc.d/couchdb start
}}}

Access 

  http://localhost:5984/_utils/index.html

or

  http://hostname:5984/_utils/index.html 

if you edited the !BindAddress
