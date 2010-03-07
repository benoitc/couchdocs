How to page through results.

It is best to follow links when paginating. The next link is the key that showed up last, in the current query. Use it as startkey, and supply a limit and a skip value of 1.

So if you requested 10 results using ''http://couchdb/db/_design/mydesign/_view/myview?limit=10'', then you would get the next 10 results by requesting ''http://couchdb/db/_design/mydesign/_view/myview?limit=10&startkey=lastkey&skip=1'' , where lastkey is the value of the last key you received.

There are some implementations of paginating. This is a special purpose one in Ruby which give you all results with the same key, grouped together.

http://github.com/jchris/couchrest/tree/master/lib/couchrest/helper/pager.rb
