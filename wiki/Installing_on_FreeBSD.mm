= Installing CouchDB on FreeBSD 6.x and 7.x and 8.0 =
== Installation from ports ==
{{{
cd /usr/ports/databases/couchdb
make install clean
}}}
This will install CouchDB 0.9.0 from the ports collection.

== Post install ==
In case the install script fails to install a noninteractive user "couchdb" to be used for the database, the user needs to be created manually:

I used the {{{pw}}} command to add a user "couchdb" in group "couchdb":

{{{
shell# pw user add couchdb
shell# pw user mod couchdb -c 'CouchDB, time to relax' -s /usr/sbin/nologin -d /var/lib/couchdb
shell# pw group add couchdb
}}}
The user is added to {{{/etc/passwd}}} and should look similar to the following:

{{{
shell# cat /etc/passwd |grep couchdb
couchdb:*:1013:1013:Couchdb, time to relax:/var/lib/couchdb/:/usr/sbin/nologin
}}}
To change any of these settings, please refrain from editing {{{/etc/passwd}}} and instead use {{{pw user mod ...}}} or {{{vipw}}}. Make sure that the user has no shell, but instead uses {{{/usr/sbin/nologin}}}. The '*' in the second field means that this user can not login via password authorization. For details use {{{man 5 passwd}}}.

== Start script ==
On FreeBSD, you use the following to start CouchDB:

{{{
shell# /usr/local/etc/rc.d/couchdb start
}}}
This script responds to the arguments start, stop, status, rcvar etc..

The following options for {{{/etc/rc.conf}}} or {{{/etc/rc.conf.local}}} are supported by the start script:

{{{
couchdb_enable="NO"
couchdb_enablelogs="YES"
couchdb_user="couchdb"
}}}
(Defaults shown.)

The start script will also use settings from the following config files:

{{{
/usr/local/etc/couchdb/default.ini
/usr/local/etc/couchdb/local.ini
}}}
Administrators should use default.ini as reference and only modify the local.ini file.

The logfile is configured to be written to

{{{
/var/log/couchdb/couch.log
}}}
In case the port does not set up correct permissions on the database directory, a command analogous to the following should be used:

{{{
shell# chown couchdb:couchdb /var/log/couchdb
}}}
command to have the couchdb process own the directory which allows it to write couch.log there. The other directories are "root:wheel" or "root:network". And I expected "/usr/local/var.." as location.

Starting CouchDB with

{{{
shell# /usr/local/etc/rc.d/couchdb start
}}}
should allow you to look at "http://localhost:5984" and see this JSON doc:

{{{
{"couchdb":"Welcome","version":"0.9.0"}
}}}
Then you should try "http://localhost:5984/_utils/" to see the "Futon" web interface,

I tried creating a database "db1" there and got an error. The solution was to

{{{
shell# chown couchdb:couchdb /var/lib/couchdb
}}}
Anyway, after this futon did report OK and I found a "/var/lib/couchdb/db1.couch" data file.

== Installing from sources ==
When building from sources obtained from {{{git clone git://github.com/halorgium/couchdb.git}}}, you can get a strange "{{{Syntax error: end of file unexpected}}}". You need to use {{{gmake}}} instead of {{{make}}}.

If you get {{{aclocal: not found}}} on {{{./bootstrap}}} you need to {{{pkg_add -r automake19}}}.

If you get {{{libtoolize: not found}}} on {{{./bootstrap}}} you need to {{{pkg_add -r libtool}}}.

If you get {{{error: Could not find the js library}}} on {{{./configure}}} you need to {{{pkg_add -r spidermonkey}}}.

If you get {{{error: Library requirements (ICU) not met}}} on {{{./configure}}} you need to {{{pkg_add -r icu}}}.

If you get {{{error: Library requirements (curl) not met}}} on {{{./configure}}} you need to {{{pkg_add -r curl}}}.

= Current TODO =
 * Change /var/lib/couchdb/ to /var/db/couchdb/
 * Create /var/log/couchdb/
 * Create a couchdb user with port install

= Questions? =
Please check out the github repository, or email TillKlampaeckel.
