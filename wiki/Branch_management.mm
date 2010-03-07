== Feature Branches ==

The CouchDB project uses feature branches to develop experimental features or refactorings without disrupting stability of the main trunk code.

All branches are kept directly under the `incubator/couchdb/branches/` directory in the repository.

=== Creating a Branch ===

Feature branches are usually based on trunk. To create a branch, something like the following svn incantation should be used:

{{{
  svn cp https://svn.apache.org/repos/asf/incubator/couchdb/trunk \
    https://svn.apache.org/repos/asf/incubator/couchdb/branches/feature-name
}}}

Note that it's preferable to create the branch by specifying the full URLs to `svn cp`, as that won't let you end up with a branch based on different revisions of trunk, possibly because you forgot to `svn up` before creating the copy.

When that's done, checkout the new branch and initialize [[http://www.orcaware.com/svn/wiki/Svnmerge.py|svnmerge]], which we'll use to keep the branch in sync with trunk. For example:

{{{
  svn co https://svn.apache.org/repos/asf/incubator/couchdb/branches/feature-name
  cd feature-name
  svnmerge init
  svn commit -m "Initialized svnmerge."
}}}

=== Keeping the Branch in Sync ===

Changes made in trunk need to be ported to the branch. This is done by utilizing [[http://www.orcaware.com/svn/wiki/Svnmerge.py|svnmerge]].

To see the changes available for being merged, use the `svnmerge avail --log` command.

To merge all the changes, use `svnmerge merge`. Or you can cherry-pick the changes to mark by specifying the revisions, for example `svnmerge merge -r 123-125,188`. If there's some change that you don't want to port (possibly because it no longer applies to the code on the branch), use `svnmerge block -r 122`.

As always with merging (and patching), be careful about properly resolving conflicts.

=== Merging the Branch Back into Trunk ===

When the branch has reached a certain level of stability, it should be merged back into trunk (assuming there's consensus that the branch is good and ready).

First, make sure that the feature branch is in sync with trunk, that is, merge any remaining changes on trunk to the branch as explained above.

Then, switch into the directory containing your working copy of trunk, use `svn up` to learn the latest revision (we'll pretend that's 12345), and issue an `svn merge` command like the following:
{{{
  cd trunk
  svn up
  svn merge https://svn.apache.org/repos/asf/incubator/couchdb/trunk@12345 \
    https://svn.apache.org/repos/asf/incubator/couchdb/branches/feature-name@12345
}}}

After the merge is done, please remember to clear the `svnmerge`-related properties from the trunk directory, to avoid problems with future branches:

{{{
  cd trunk
  svnmerge uninit
}}}

=== Further Reading ===

See the [[http://svnbook.red-bean.com/en/1.4/svn.branchmerge.commonuses.html#svn.branchmerge.commonuses.patterns.feature|Feature Branches]] chapter in the [[http://svnbook.red-bean.com/|SVN book]], as well as the [[http://www.orcaware.com/svn/wiki/Svnmerge.py|svnmerge documentation]] for more information.
