== Making a Release ==

=== Checklist ===

 1. Update the `README` file with important information.
 2. Update the `NEWS` and `CHANGES` files with important information.
 3. Update the [[Breaking changes]] document.
 4. Update the `acinclude.m4` file with version information.

=== Preparing the Community ===

Call a vote on the [[http://mail-archives.apache.org/mod_mbox/couchdb-dev/|couchdb-dev]] mailing list asking for a request for comments on the release. Ask all developers to specifically check the `NEWS` and `CHANGES` file for anything that has been added in this release.

=== Preparing the Release ===

{{{
repos="https://svn.apache.org/repos/asf/couchdb"

svn cp $repos/trunk $repos/branches/Y.Y.x -m 'branching Y.Y.x'
svn cp $repos/branches/Y.Y.x $repos/tags/Y.Y.Y -m 'tagging Y.Y.Y'
svn export $repos/tags/Y.Y.Y Y.Y.Y
}}}

You must then use the `Y.Y.Y` directory to prepare the release.

To build the source for distribution you should then run the following command:

{{{
./bootstrap && ./configure && make distsign
}}}

If everything was successful you should see the following files
sitting in the `export` directory ready for distribution:

 * apache-couchdb-Y.Y.Y.tar.gz
 * apache-couchdb-Y.Y.Y.tar.gz.asc
 * apache-couchdb-Y.Y.Y.tar.gz.md5
 * apache-couchdb-Y.Y.Y.tar.gz.sha

Move the files to the parent directory:

{{{
mv apache-couchdb* ..
}}}

Then clean the source:

{{{
make local-clean
}}}

Then bootstrap the source so that it mirrors the tarball:

{{{
./bootstrap
}}}

Then go to the parent directory and unpack the tarball:

{{{
tar -xvzf apache-couchdb*.tar.gz
}}}

Then compare the tarball with the boostrapped source:

{{{
diff -f apache-couchdb-Y.Y.Y Y.Y.x
}}}

Use your judgment here to figure out if anything is missing, or has been included by mistake.

Upload these to your `public_html` directory on `people.apache.org` and make sure they are world readable.

=== Calling a Vote ===

Call a vote on the [[http://mail-archives.apache.org/mod_mbox/couchdb-dev/|couchdb-dev]] mailing list:

  * [[http://mail-archives.apache.org/mod_mbox/couchdb-dev/200907.mbox/%3C20090716211304.GA17172@tumbolia.org%3E|example couchdb-dev vote]]
  * [[http://mail-archives.apache.org/mod_mbox/couchdb-dev/200907.mbox/%3C20090722214200.GA11737@tumbolia.org%3E|example couchdb-dev vote results]]

=== Making the Release ===

 * Copy the release directory to `/www/www.apache.org/dist/couchdb` on `people.apache.org`.
 * Wait for all changes to be synced to public mirrors.
 * Update http://couchdb.apache.org/downloads.html
 * Wait for all changes to be synced to the public site.
 * Make a release announcement to the [[http://mail-archives.apache.org/mod_mbox/www-announce/|announce@apache.org]], [[http://mail-archives.apache.org/mod_mbox/couchdb-user/|user@couchdb.apache.org]], and [[http://mail-archives.apache.org/mod_mbox/couchdb-dev/|dev@couchdb.apache.org]] mailing lists:
   * [[http://mail-archives.apache.org/mod_mbox/www-announce/200806.mbox/%3C20080625173452.GA14650@bytesexual.org%3E|example release announcement]]
 * [[https://issues.apache.org/jira/secure/project/ManageVersions.jspa?pid=12310780|Update versions]] in JIRA.
   * If the currently released version is 0.1.0, JIRA should have options for 0.1.1, 0.2.0, and 0.3.0.
   * The released version should be marked as released in JIRA.
 * Update the links on this page to most recent email archives.
 * Call a discussion on the [[http://mail-archives.apache.org/mod_mbox/couchdb-dev/|couchdb-dev]] mailing list about updating the [[http://couchdb.apache.org/roadmap.html|roadmap]] and archiving old releases.

== Useful Resources ==

 * http://www.apache.org/dev/release.html
 * http://incubator.apache.org/guides/releasemanagement.html#best-practice
