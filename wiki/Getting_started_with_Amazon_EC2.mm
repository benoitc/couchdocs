## page was renamed from GettingStartedWithAmazonEC2
## page was renamed from Getting Started With Amazon EC2
## page was renamed from GettingStartedAmazon

If you have a credit card and can swing ten cents per hour, here is a method to conveniently try the latest CouchDB code without having to install local software.  This procedure will have you quickly running an Ubuntu 8.10 server and building what you need from the source code.

 1. Set up your Amazon AWS EC2 account, firewall ruleset, etc.  (For example, see [[http://www.proven-corporation.com/2009/03/04/how-to-run-a-quick-throwaway-ubuntu-ec2-instance/|this article]], steps 1 through 2.6.)
 1. Start the Ubuntu 8.10 server image, ami-5059be39
 1. When it is up, copy the public DNS name and run: {{{ssh -l ubuntu <public dns name>}}}
 1. Once logged in, install the prerequisites:
   1. {{{sudo apt-get update && sudo apt-get -y upgrade}}}
   1. {{{sudo apt-get install erlang libmozjs-dev libicu-dev libcurl4-gnutls-dev make subversion automake autoconf libtool help2man}}}
 1. Fetch, build, and run CouchDB:
   1. {{{svn checkout http://svn.apache.org/repos/asf/couchdb/trunk couchdb}}} # (Instead of trunk, you could try {{{ tags/0.8.0 }}}, {{{ tags/0.8.1 }}}, etc.)
   1. {{{cd couchdb}}}
   1. {{{./bootstrap && ./configure && make && sudo make install}}}
   1. {{{sudo adduser --system --home /usr/local/var/lib/couchdb --no-create-home --shell /bin/bash --group --gecos 'CouchDB account' couchdb}}}
   1. {{{sudo chown -R couchdb.couchdb /usr/local/var/{lib,log}/couchdb}}}
   1. ''(Optional)'' Enable direct web access.  '''NOTE: This step makes your CouchDB instance available for everyone. See [[http://wiki.apache.org/couchdb/Frequently_asked_questions#secure_remote_server|the FaQ]] for some (but not all) security options.'''
     1. {{{sudo vim /usr/local/etc/couchdb/local.ini }}}
     1. Search for "bind_address", uncomment it, and change it to 0.0.0.0
     1. Save and exit
   1. ''(Alternative option)'' Set up port forwarding to access your DB, for example with SSH.
     1. {{{ssh -L 5984:localhost:5984 -l ubuntu <public DNS name>}}}
     1. Leave that session open as long as you need the proxy to work
     1. Your new DB URL will be http://127.0.0.1:5984/ instead.
   1. {{{sudo -i -u couchdb couchdb }}}
 1. Test it by going to {{{http://<public dns name>:5984/_utils/}}}

You can also of course install and try out client libraries.  For example, with [[http://github.com/jchris/couchrest/tree/master|CouchRest]]:

 1. {{{sudo apt-get install libxml2-dev libxslt-dev rubygems ruby1.8-dev irb}}}
 1. {{{sudo gem install couchrest archive-tar-minitar nokogiri rcov hoe}}}
 1. Try it!
 {{{irb
irb(main):001:0> require 'rubygems'
=> true
irb(main):002:0> require 'couchrest'
=> true
irb(main):003:0> db = CouchRest.database! 'http://127.0.0.1:5984/my_db'
=> #<CouchRest::Database:0xb7acb338 @root="127.0.0.1:5984/my_db", @bulk_save_cache_limit=50, @server=#<CouchRest::Server:0xb7b335c8 @uri="127.0.0.1:5984", @uuid_batch_count=1000>, @bulk_save_cache=[], @host="127.0.0.1:5984", @name="my_db", @streamer=#<CouchRest::Streamer:0xb7acb1f8 @db=#<CouchRest::Database:0xb7acb338 ...>>>
irb(main):004:0> response = db.save :key => 'val', 'another key' => 23
=> {"rev"=>"1954890697", "id"=>"1ba0b605480824c5d8aa6ba6fdbd7add", "ok"=>true}
irb(main):005:0> doc = db.get(response['id'])
=> {"_rev"=>"1954890697", "_id"=>"1ba0b605480824c5d8aa6ba6fdbd7add", "another key"=>23, "key"=>"val"}
}}}
