Installing on RHEL5 x86_64

(Note: [[https://issues.apache.org/jira/browse/COUCHDB-315|COUCHDB-315]] has an attached patch for the CouchDB README which adds instructions for RHEL 5.)

1. Install prerequisites. You will need [[http://fedoraproject.org/wiki/EPEL|EPEL]] for js and erlang (or build those from source).

{{{
yum install ncurses-devel openssl-devel icu libicu-devel js js-devel curl-devel erlang
}}}

2. Install CouchDB

The configure line below is for 64-bit, adjust for your arch (or leave out --with-erlang if configure can find out for itself). You can use a release tarball instead of a checkout, in that case skip right to the ./confgure line.

{{{
svn checkout http://svn.apache.org/repos/asf/couchdb/trunk couchdb
cd couchdb
./bootstrap
./configure --with-erlang=/usr/lib64/erlang/usr/include && make && make install
}}}

3. Edit config file to suit

{{{
vi /usr/local/etc/couchdb/local.ini
}}}

4. Create user, modify ownership and permissions

Create the couchdb user:

{{{
adduser -r --home /usr/local/var/lib/couchdb -M --shell /bin/bash --comment "CouchDB Administrator" couchdb
}}}

See the README for additional chown and chmod commands to run.

5. Launch! In console:
{{{
sudo -u couchdb couchdb
}}}
or as daemon:
{{{
sudo /usr/local/etc/rc.d/couchdb start
}}}

6. Run as daemon on start-up:
{{{
sudo ln -s /usr/local/etc/rc.d/couchdb /etc/init.d/couchdb
sudo chkconfig --add couchdb
}}}
