== A Caveat ==

If you're running a version of CouchDB that's too out of date, Futon might do weird things. The entire point of this exercise is to make sure that you don't need to build CouchDB by hand just to hack on Futon though, so I'll just leave it as an exercise to the reader to keep things in sync. I'll post corresponding SVN URL's towards the bottom.

== Bleeding Edge Instructions ==

{{{
$ svn co http://svn.apache.org/repos/asf/couchdb/trunk/share/www futon
$ wget http://github.com/davisp/futonproxy/raw/617b47b138a5ce5ddece13db16f6ac7ca1ba192f/futonproxy.py
$ chmod +x futonproxy.py
$ ./futonproxy.py futon
}}}

Assuming CouchDB is running on http://127.0.0.1:5984 you can just open a web browser and point it to http://127.0.0.1:8080/_utils/.

== Futon Proxy ==

The latest version of Futon Proxy is at [[http://github.com/davisp/futonproxy|GitHub]]

== Getting trunk without building ==

If you're on Mac OS X 10.5 or newer, there are single click installers available to use. These directions should work just fine if you would like to use one of those. The installers can be found on [[http://github.com/janl/couchdbx-core/downloads|GitHub]]

== Futon Versions ==

If you're using an older version of CouchDB to run Futon against, you can check out a closer version of the HTML sources by adjusting the SVN url.

{{{
# 0.10.x
$ svn co http://svn.apache.org/repos/asf/couchdb/branches/0.10.x/share/www futon
# 0.9.x
$ svn co http://svn.apache.org/repos/asf/couchdb/branches/0.9.x/share/www futon
# 0.8.x
# Time to upgrade!
}}}
