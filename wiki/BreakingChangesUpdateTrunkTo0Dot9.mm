The latest CouchDB update brings a mature replication model for distributed updates. This involved quite a lot of changes to the internal handling of MVCC tokens. The result is what we think will be a stable and scalable model for distributed updates. It also means that both the replication API and the database file format have changed at the same time.

Normally when the database file format changes upgrading can be accomplished by launching two copies of CouchDB on two different ports and replicating between them. In this case that won't work as the replication API has changed.

I've written a script to do the replication for you. It's linked there and embedded below. It's not perfectly awesome (see caveats later) but it does the trick and won't blow up on databases with lots of docs. Nor does it fill up your filesystem with intermediate data.

== Usage ==
First you need the latest CouchRest Ruby gem (0.2.2). I never met a packaging system I didn't hate, so I won't even suggest that you attempt to install CouchRest from a remote gem server. Instead do this:

{{{
git clone git://github.com/jchris/couchrest.git
cd couchrest
gem build couchrest.gemspec 
sudo gem install couchrest-*.gem
}}}

Now that you have the latest CouchRest, you can download the script (see the bottom of this page) save it into a file `couchdb_trunk_update_script.rb`, adjust the `OLD_HOST` and `NEW_HOST` to reflect your environment, and start it up. It does give some output every 100 docs, so you won't be totally at a loss to what's happening.

{{{
ruby couchdb_trunk_update_script.rb
}}}

It assumes that none of the databases on your `OLD_HOST` exist on your `NEW_HOST`. If they do exist it will skip them.

It also assumes that none of your individual attachments are larger than the memory you can dedicate to the Ruby runtime. Coding a streaming attachment solution would be a fair amount more work. If you need it patches are welcome but I think you might be better off with a different approach. My script batches updates into blocks of 100 docs.

If you have giant attachments, I'd do the docs one at a time, and stream each attachment individually. It'd probably be easier to shell out to curl from Ruby than to try to code it as a Ruby `Net::HTTP` operation.

Dueling Couches
To run CouchDB in two ports at once, you should run them in separate directories. The easiest way to do this from the source package is with the make dev target. You'll want to checkout CouchDB trunk in one directory, like so:

{{{
svn co https://svn.apache.org/repos/asf/couchdb/trunk
}}}

And then there's a handy tag of the last time the old file format was available, so check it out in another directory:

{{{
svn co https://svn.apache.org/repos/asf/couchdb/tags/bulk_transactions
}}}

Once you have make dev completed in both checkouts, copy your existing old-format databases (the `.couch` files) to the `tmp/lib` directory of the bulk_transactions checkout. When you run it with utils/run you should be able to browse those databases in Futon.

Now, edit the trunk CouchDB's configuration so that it runs on port 5985 instead of 5984. This you can do by changing the `etc/couchdb/local_dev.ini` file that was created by `make dev`. Once that's done you can launch trunk CouchDB with `utils/run`

== The Script ==
{{{
require 'rubygems'
require 'couchrest'
 
# this is the CouchDB where all the old databases are
OLD_HOST = "http://127.0.0.1:5984"
 
# this is the CouchDB we want to copy to
NEW_HOST = "http://127.0.0.1:5985"
 
old_couch = CouchRest.new(OLD_HOST)
new_couch = CouchRest.new(NEW_HOST)
 
databases = old_couch.databases
 
databases.each do |dbname|
  if new_couch.databases.include?(dbname)
    puts "the database '#{dbname}' already exists on the target"
    puts "patches welcome for picking this process up in the middle"
    puts "for now if it fails in the middle you could just comment out these lines"
    puts "but you'll do double work and end up with spurious conflicts"
    puts
    puts
  else
    upgrader = CouchRest::Upgrade.new(dbname, old_couch, new_couch)
    upgrader.clone!  
  end
end
}}}


Output should look something like:

{{{
$ ruby upgrade.rb 
canon - 1 docs
posting 1 bulk docs to http://jchrisa.net:5985/canon/_bulk_docs?all_or_nothing=true
commit-hooks - 2 docs
posting 2 bulk docs to http://jchrisa.net:5985/commit-hooks/_bulk_docs?all_or_nothing=true
drl - 297 docs
posting 100 bulk docs to http://jchrisa.net:5985/drl/_bulk_docs?all_or_nothing=true
posting 100 bulk docs to http://jchrisa.net:5985/drl/_bulk_docs?all_or_nothing=true
posting 98 bulk docs to http://jchrisa.net:5985/drl/_bulk_docs?all_or_nothing=true
sofa-ajax - 2 docs
posting 2 bulk docs to http://jchrisa.net:5985/sofa-ajax/_bulk_docs?all_or_nothing=true
sofa-blog - 23 docs
posting 23 bulk docs to http://jchrisa.net:5985/sofa-blog/_bulk_docs?all_or_nothing=true
sofa-dev - 4 docs
posting 4 bulk docs to http://jchrisa.net:5985/sofa-dev/_bulk_docs?all_or_nothing=true
twitter-client-design - 1 docs
posting 1 bulk docs to http://jchrisa.net:5985/twitter-client-design/_bulk_docs?all_or_nothing=true
twitter-client - 14027 docs
posting 100 bulk docs to http://jchrisa.net:5985/twitter-client/_bulk_docs?all_or_nothing=true
posting 100 bulk docs to http://jchrisa.net:5985/twitter-client/_bulk_docs?all_or_nothing=true
...
}}}
