## page was renamed from InstallingOnRHEL4
Installing on Fedora Core 7 i386

1. install erlang
{{{
yum install erlang
}}}
2. install other dependencies (no external repos required).
{{{
yum install icu libicu-devel js js-devel
}}}
3. install couchdb
{{{
svn checkout http://svn.apache.org/repos/asf/couchdb/trunk couchdb
cd couchdb
./bootstrap
./configure
make && make install
}}}
4. create couchdb user 
{{{
sudo adduser -r -d /usr/local/var/lib/couchdb couchdb
sudo chown -R couchdb /usr/local/var/lib/couchdb
sudo chown -R couchdb /usr/local/var/log/couchdb
}}}
5. (optional) edit basic settings like Port and !BindAddress
{{{
vim /usr/local/etc/couchdb/couch.ini
}}}
6. start CouchDB server in your terminal
{{{
sudo -u couchdb couchdb
}}}
or as daemon
{{{
sudo /usr/local/etc/rc.d/couchdb start
}}}

Access http://localhost:5984/_utils/index.html
or http://hostname:5984/_utils/index.html if you edited the !BindAddress
