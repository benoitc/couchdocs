For a simple Ruby wrapper around CouchDB's RESTful API, see [[http://github.com/jchris/couchrest/tree/master|CouchRest]], which keeps you fairly close the metal, as well as having a few helpful wrappers, like a builtin view pager and companion libraries like [[http://github.com/mattly/couchmodel/tree/master|CouchModel]] (for document id and lifecycle management) and [[http://github.com/atduskgreg/slipcover/tree/master|Slipcover]] (for parallel query execution).

Easy install for CouchRest: 

{{{ gem install jchris-couchrest -s http://gems.github.com }}}

----

You can get started fairly quickly using [[http://couchobject.rubyforge.org|Couch Object]]

To download the edge version using git, run ''git clone git://gitorious.org/couchobject/mainline.git''

CouchObject gives you an easy way to connect to and work with CouchDB.
Its main strengths are that it lets you save and load Ruby objects to and from the database using the CouchObject::Persistable module.

As of version 0.6 it supports has_many, has_one and belongs_to relations, in addition to amongst others time stamps.
Please have a look at the [[http://couchobject.rubyforge.org/rdoc/|Rdoc]] for more information.

----

Alternatively, the [[http://datamapper.org|DataMapper]] Ruby ORM has a CouchDB adapter (just install the ''dm-core'' gem for datamapper and the ''dm-more'' gem for the adapter).

----

[[http://github.com/paulcarey/relaxdb/wikis|RelaxDB]] offers a similar idiom to !ActiveRecord for persisting objects to CouchDB

----

A quick note: If you have any problems like bad_utf8_character_code make sure you use unicode:

{{{
$KCODE='u'
require 'jcode'
}}}

and use active_support 'chars' method.

----

[[http://github.com/candlerb/couchtiny|CouchTiny]] is an experimental library inspired by CouchRest but designed to be closer to the metal, with a smaller and simpler code base. It does not have properties or validations.
