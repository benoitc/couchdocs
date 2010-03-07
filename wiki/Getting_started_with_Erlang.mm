## page was renamed from Getting Started With Erlang
## page was renamed from GettingStartedErlang
Getting started with Erlang and the CouchDB API.

= couchbeam =

couchbeam is a simple erlang CouchDB framework. couchbeam provides you a full featured and easy client to access and manage multiple couchdb Nodes.

  http://bitbucket.org/benoitc/couchbeam

== Features ==

 * A full client in sync with latest CouchDB version
 * full otp application
 * Use [[http://bitbucket.org/etc/lhttpc/overview/|lhttpc]] as http client
 * multi CouchDB servers and databases support
 * Authentification support. 


= eCouch =

eCouch is an Erlang application that provides an API to a CouchDB server. Code and documentation can be obtained at:

  http://code.google.com/p/ecouch

== Characteristics ==

  * Uses the [[http://www.lshift.net/blog/2007/02/17/json-and-json-rpc-for-erlang|rfc4627]] module from [[http://www.lshift.net/|LShift]]
  * eCouch design was inspired by the article [[http://www.trapexit.org/Building_a_Non-blocking_TCP_server_using_OTP_principles|Building a Non-blocking TCP server using OTP principles]]
  * It assumes that the [[http://www.erlang.org/doc/apps/inets/index.html|inets]] application is running

== Features ==

  * Follows all the OTP design principles
  * Can run stand-alone with its own supervision tree or be included inside an existing supervision tree
  * Guarantees synchronism between calls and their responses

= erlcouch =

It is quite easy to throw together a quick interface to CouchDB in Erlang using inets or ibrowse because CouchDB API is so easy. On such interface currently exists at:

  http://code.google.com/p/erlcouch/

Documentation can be found as part of the library.

'''NOTE:''' erlcouch was discontinued, but picked up and pushed along at http://github.com/bdionne/erl-couch/


= erlang_couchdb =

Another Erlang library exists as erlang_couchdb. It is actively development and tries to do as little as possible.

  http://github.com/ngerakines/erlang_couchdb/

There's a branch implementing a transactional layer for it. Scroll down for documentation:
  http://github.com/astro/erlang_couchdb/tree/couch_lier
