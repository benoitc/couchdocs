'''The Proposals have been submitted to the ASF GSoC Page at http://wiki.apache.org/general/SummerOfCode2009#couchdb. Do not edit this page any longer'''

Proposals for student projects to submit for this year's Google SummerOfCode. This is for collecting ideas, the proposals will be voted on on dev@couchdb.apache.org and submitted to the [[http://wiki.apache.org/general/SummerOfCode2009|ASF Summer of Code Wiki page]].

[[#couchdb|CouchDB]]

== Template ==
<<Anchor(asf-project-name)>>
<<Anchor(gsoc-project-id)>>
|| '''Subject ID''' || '''project-id''' ||
|| '''Title''' || '''''a short desciptive title of the subject''''' ||
|| '''ASF Project''' || ''the ASF project(s) tied to this subject'' ||
|| '''Keywords''' || ''keywords on this subject, like language, technology or concept used'' ||
|| '''Description''' || ''a paragraph describing what this subject is all about'' ||
|| '''Possible Mentors''' || ''volunteer mentors for this subject'' ||
|| '''Status''' || ''indicate whether this subject has already been assigned to a participating student'' ||

== Windows Support ==
<<Anchor(couchdb)>>
<<Anchor(couchdb-windows)>>
|| '''Subject ID''' || '''couchdb-windows''' ||
|| '''Title''' || ''''' Full fledged Windows support''''' ||
|| '''ASF Project''' || ''[[http://couchdb.apache.org|Apache CouchDB]]'' ||
|| '''Keywords''' || ''couchdb, windows, build, distribution, autotools'' ||
|| '''Description''' || ''Full fledged Windows support including a script that turns trunk and releases into a binary distribution. Work here would include familiarizing with the current autotools-based build system, determining the best build environment on Windows and suggesting modifications to CouchDB's build system and code to build, install, package and run CouchDB on Windows.'' ||
|| '''Possible Mentors''' || ''Jan Lehnardt, Noah Slater'' ||
|| '''Status''' || ''no students yet'' ||

== Erlang Test Suite ==
<<Anchor(couchdb)>>
<<Anchor(couchdb-erlang-unit-tests)>>
|| '''Subject ID''' || '''couchdb-erlang-unit-tests''' ||
|| '''Title''' || '''''Comprehensive Erlang-based unit-, and behaviour-test suite''''' ||
|| '''ASF Project''' || ''[[http://couchdb.apache.org|Apache CouchDB]]'' ||
|| '''Keywords''' || ''couchdb, erlang, test suite, unit tests, behaviour tests'' ||
|| '''Description''' || ''CouchDB currently lacks a comprehensive erlang-based test suite & tests. It should be determined which exisitng test suite is suitable for our purposes (if at all). A test suite framework would allow CouchDB developers to easily add test functions that cover new and existing code. Code coverage analysis or quickcheck integration are nice to have features.'' ||
|| '''Possible Mentors''' || ''Jan Lehnardt'' ||
|| '''Status''' || ''no students yet'' ||

== Erlang Benchmark Suite ==
<<Anchor(couchdb)>>
<<Anchor(couchdb-bencharks)>>
|| '''Subject ID''' || '''couchdb-bencharks''' ||
|| '''Title''' || ''''' Comprehensive standardized benchmark suite (so we can compare CouchDB across hardware)''''' ||
|| '''ASF Project''' || ''[[http://couchdb.apache.org|Apache CouchDB]]'' ||
|| '''Keywords''' || ''couchdb, erlang, benchmark suite, benchmarks'' ||
|| '''Description''' || ''CouchDB currently lacks a comprehensive Erlang-based benchmark suite. CouchDB users have a hard time finding out what performance to expect from CouchDB. An Erlang-based benchmark suite will include a set of common scenarios like mass data import, view generation on various levels, load-simulation for "typical" workloads, impact of replication and so on. The idea is that a user can run one or more of these benchmarks to determine whether CouchDB's performance is in line with their needs. The benchmark suite will also hel the CouhcDB development team to measure performance changes in new code and monitor improvements or degradation over time.'' ||
|| '''Possible Mentors''' || ''Paul Davis, Chris Anderson'' ||
|| '''Status''' || ''no students yet'' ||

== CouchDB Cluster ==
<<Anchor(couchdb)>>
<<Anchor(couchdb-cluster)>>
|| '''Subject ID''' || '''couchdb-cluster''' ||
|| '''Title''' || '''''Easy CouchDB cluster management solution.''''' ||
|| '''ASF Project''' || ''[[http://couchdb.apache.org|Apache CouchDB]]'' ||
|| '''Keywords''' || ''couchdb, erlang, cluster, management, high availability, scaling, infrastructure'' ||
|| '''Description''' || ''Enhance CouchDB with the necessary modules and infrastructure to easily create and maintain distributed clusters of CouchDB nodes for flexible scaling application backends.'' ||
|| '''Possible Mentors''' || ''Damien Katz, Chris Anderson'' ||
|| '''Status''' || ''no students yet'' ||


== Fullext Integration ==
<<Anchor(couchdb)>>
<<Anchor(couchdb-fulltext)>>
|| '''Subject ID''' || '''couchdb-fulltext''' ||
|| '''Title''' || '''''Add a fulltext solution that comes with CouchDB''''' ||
|| '''ASF Project''' || ''[[http://couchdb.apache.org|Apache CouchDB]]'' ||
|| '''Keywords''' || ''couchdb, fulltext, search, possibly lucene'' ||
|| '''Description''' || ''Make CouchDB out-of-the box Fulltext enabled.'' ||
|| '''Possible Mentors''' || ''Paul Davis'' ||
|| '''Status''' || ''no students yet'' ||

== Erlang Interface ==
<<Anchor(couchdb)>>
<<Anchor(couchdb-erlang-interface)>>
|| '''Subject ID''' || '''couchdb-erlang-interface''' ||
|| '''Title''' || '''''Erlang interface to CouchDB to bypass HTTP/JSON layer''''' ||
|| '''ASF Project''' || ''[[http://couchdb.apache.org|Apache CouchDB]]'' ||
|| '''Keywords''' || ''couchdb, erlang, interface'' ||
|| '''Description''' || ''This work would provide a direct interface to CouchDB.  It could be used by, e.g., wpart_* interfaces from Erlang-Web, or by appmods in YAWS.  It would interface directly to the CouchDB Erlang layer using Erlang term(), not JSON conversions.  There would be no HTTP involved, only direct Erlang message passing or fun calls to/from CouchDB.  If a message passing design is used, distributed access to one or more CouchDB nodes may be simplified (e.g. a cluster of web servers accessing one or more CouchDB nodes).  Interface should minimally provide same functionality as that available to view servers or via HTTP interface and allow for maintenance to keep parity when new functionality is added.  Since modifications/additions of CouchDB source is involved, additional value could be added by providing another interface to couch_query_servers which can pass lists of documents rather than a single document (to view servers and via the Erlang interface).  This would allow parallel map functions to run on subsets of the list provided by couch_query_servers. couch_query_server could dynamically check memory and adjust the number of documents sent.'' ||
|| '''Possible Mentors''' || ''Chris Anderson, Jan Lehnardt, Paul Davis, Damien Katz'' ||
|| '''Status''' || ''no students yet'' ||
