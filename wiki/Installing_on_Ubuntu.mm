CouchDB has an Ubuntu package for Ubuntu 8.10 (Intrepid Ibex) and 9.04 (Jaunty Jackalope) - just do:

{{{
aptitude install couchdb
}}}
== From Source ==
If you want the latest version of Couchdb but everything else from the repositories then:
  * In Synaptic select couchdb, this will also select the dependencies (erlang etc.) then unselect couchdb and apply the dependencies
  * sudo apt-get build-dep couchdb
  * sudo apt-get install libmozjs-dev libicu-dev libcurl4-gnutls-dev libtool
  * download the latest couchdb .tar.gz file
  * tar -zxvf apache-couchdb-0.9.0.tar.gz
  * cd apache-couchdb-0.9.0
  * ./configure
  * make
  * sudo make install
now you can run "sudo couchdb" and browse to [[http://localhost:5984/_utils]] to check it is all working

Because you installed all the dependencies of Couchdb from synaptic, but not Couchdb itself some of the dependencies may think they are not required and update manager may suggest that they are removed. Should you do this Couchdb will fail to start, perhaps with an error such as 
{{{
{"init terminating in do_boot",{undef,[{crypto,start,[]},{erl_eval,do_apply,5},{init,start_it,1},{init,start_em,1}]}}
}}}
If this happens simply re-install the dependencies (possibly erlang-nox but it could vary)

== External Articles ==
 * [[http://barkingiguana.com/2008/06/28/installing-couchdb-080-on-ubuntu-804|Installing CouchDB 0.8.0 on Ubuntu 8.04]]
 * [[http://japhr.blogspot.com/2009/03/yak-shaving-is-new-dependency-hell.html|Installing Couchdb 0.9 on Ubuntu 9.04]]
