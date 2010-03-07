This page describes how the CouchDB source repository is organized.

= The Repository =

The main and central repository lives at http://svn.apache.org/repos/asf/couchdb/. If you prefer git to svn, you can use the official [[http://git.apache.org/|Apache Git mirror]]. It mirrors the svn repository's structure.

(Committers should use the SSL-secured server at https://svn.apache.org/repos/asf/couchdb/).


== trunk ==

http://svn.apache.org/repos/asf/couchdb/trunk or ''trunk'' is where day-to-day development happens. New features and bugfixes are committed here. [[Feature Branches|http://wiki.apache.org/couchdb/Branch_management]] are merged into trunk in case new features have been developed in isolation.


== branches/z.y.x ==

Branches that are not feature branches are ''release branches''. ''Major versions'' are represented by the first number (z) in the version triplet. The middle number (y) denotes minor versions and the third number (z) represents ''bugfix releases''.

Once the developers decide trunk is in a good state to produce a new version of CouchDB, a release branch is created with the appropriate version numbers: Say trunk is deemed ready to be the basis for a future 0.11.0 release (where the current release is 0.10.1), a new branch branches/0.11.x is created to ''track'' the development of the 0.11.x series of CouchDB releases.

Each release of major version (1.0.0, 1.0.1, ..., 1.1.0, 1.1.1, etc) is guaranteed to work in backwards compatible ways (as well as we humanly guarantee it :). New major versions may have incompatibilities. Upgrades between bugfix versions (0.11.0 to 0.11.1) should be seamless, upgrading minor or major versions might require extra work.

== tags/z.x.y ==

When the 0.11.x branch is deemed ready for a first release a new ''tag'' tags/0.11.0 is created that is a snapshot of the CouchDB source code that is the 0.11.0 release. Bugfixes to the 0.11.x line of release go into branches/0.11.x. When a new version 0.11.1 is released because enough bugfixes went into branches/0.11.x, a new tag tags/0.11.1 is created to snapshot the next release and so on.
