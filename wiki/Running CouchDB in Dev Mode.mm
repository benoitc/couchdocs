## page was renamed from Running_Couchdb_in_Dev_Mode
This only applies if you need to make changes to the CouchDB server or to the Futon web front-end.

=== Prerequisites ===
You need to have installed CouchDB from source. See [[Installing_from_source]].

=== Create a Development Configuration ===
The following commands set up a CouchDB configuration that points to the location of your SVN checkout.

Run these commands:

{{{
$ cd YOUR_COUCHDB_CHECKOUT_DIRECTORY
$ ./bootstrap
$ ./configure
$ make dev
}}}
You can change defaults such as port number and passwords in `./etc/couchdb/local_dev.ini`. Now start CouchDB by calling this command:

{{{
$ utils/run
}}}
Your CouchDB server has been started as a foreground process.  You should see messages similar to this:

{{{
Apache CouchDB 0.11.0b885334 (LogLevel=info) is starting.
Apache CouchDB has started. Time to relax.
[info] [<0.32.0>] Apache CouchDB has started on http://127.0.0.1:5984/
}}}
You can change to background, reset config files, redirect output etc via command line arguments.  (Note only one dash in front of help.)

{{{
$ utils/run -help
}}}

=== Ubuntu 9.10 ===

This is how you can run the dev version side by side with the Ubuntu version. The main difficulties are Javascript engine paths as documented by [[http://mattgoodall.blogspot.com/2009/09/build-couchdb-on-ubuntu-910-karmic.html|Matt Goodall]].  You need to specify `LD_RUN_PATH=/usr/lib/xulrunner-1.9.1.7` before every command as well as provide extra parameters to configure.  (Note the final digit changes with each Firefox update - check your /usr/lib directory to find the correct number.  You also need to rebuild when that digit changes.)

Get all the needed build time packages:

{{{
$ sudo apt-get install libtool help2man erlang-nox erlang-dev libicu-dev xulrunner-dev libcurl4-openssl-dev build-essential automake 
}}}

Checkout source code and build it:
{{{
$ svn co http://svn.apache.org/repos/asf/couchdb/trunk couchdb
$ cd couchdb
$ ./bootstrap
$ LD_RUN_PATH=/usr/lib/xulrunner-1.9.1.7 ./configure --with-js-lib=/usr/lib/xulrunner-devel-1.9.1.7/lib/ --with-js-include=/usr/lib/xulrunner-devel-1.9.1.7/include
$ LD_RUN_PATH=/usr/lib/xulrunner-1.9.1.7 make dev
}}}

Now edit `./etc/default/local_dev.ini` and change the port.  I use 5984 (default) for the Ubuntu install and 5985 for this dev version.

{{{
$ LD_RUN_PATH=/usr/lib/xulrunner-1.9.1.7 utils/run
}}}
