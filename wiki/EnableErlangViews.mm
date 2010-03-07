Since version 0.10.0, CouchDB has a native Erlang view server, allowing you to write your map/reduce functions in Erlang. There is no-longer the need to manually install [[http://github.com/mmcdanie/erlview|erlview]], unless you are running an old version of CouchDB.

First, you'll need to edit your `local.ini` to include a native_query_servers section:
{{{
[native_query_servers]
erlang = {couch_native_process, start_link, []}
}}}

Your `local.ini` will most likely be at `/usr/local/etc/couchdb/local.ini` or `/etc/couchdb/local.ini`. To see these changes you will also need to restart the server:
{{{
sudo /etc/init.d/couchdb restart
}}}

To test out using Erlang views, visit the Futon admin interface, create a new database and open a temporary view. You should now be able to select erlang from the language drop-down. 

Let's try an example of map/reduce functions which count the total documents at each number of revisions (there are x many documents at version "1", and y documents at "2"... etc). Add a few documents to the database, then enter the following functions as a temporary view:

{{{
%% Map Function
fun({Doc}) ->
  <<K,_/binary>> = proplists:get_value(<<"_rev">>, Doc, null),
  V = proplists:get_value(<<"_id">>, Doc, null),
  Emit(<<K>>, V)
end.

%% Reduce Function
fun(Keys, Values, ReReduce) -> length(Values) end.
}}}

If all has gone well, after running the view you should see a list of the total number of documents at each revision number. 
