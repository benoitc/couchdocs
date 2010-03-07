Thanks for your interest in growing CouchDB! This page will explain the process of submitting code to fix issues or add features.

In this document:
 * [[#pre|Prerequisites]]
 * [[#step1|Step 1: See if your bug/feature exists in JIRA]] 
 * [[#step2|Step 2: Run the tests]]
 * [[#step2|Step 3: Go forth and code!]]
 * [[#step3|Step 4: Create and Upload a Patch]]
 * [[#questions|Asking Questions And Getting Feedback]]

<<Anchor(pre)>>
== Prerequisites ==
Ensure that you've
 * Installed from source: [[Installing_from_source]]
 * Got your system running in Dev mode: [[Running CouchDB in Dev Mode]]

<<Anchor(step1)>>
== Step 1: See if your bug/feature exists in JIRA ==
 * JIRA is the issue tracker that CouchDB uses to track items of work.
 * Visit https://issues.apache.org/jira/browse/COUCHDB to see if your issue already exists. 
 * If it doesn't, you can open one by
  * Registering for a JIRA account here: https://issues.apache.org/jira/secure/Signup!default.jspa
  * Then opening a new issue here: https://issues.apache.org/jira/secure/CreateIssue!default.jspa
 * Either way, bookmark the link because you'll need it to comment or submit patches.

'''Note:''' You're still welcome to submit patches even if an issue has been assigned to someone else. In this case, it's probably better to add a comment before getting started. 

<<Anchor(step2)>>
== Step 2: Run the tests ==
 * Instructions are here: http://wiki.apache.org/couchdb/How_to_create_tests?action=show 
 * Run the tests at least before you start coding and when you're done.

<<Anchor(step3)>>
== Step 3: Go forth and code! ==
 * Take a look at the recommended coding standards here: [[Coding_Standards]]
 * Before starting, make sure that your local copy is up to the latest version
 * For those using the command-line subversion tools, run this before starting:
 {{{
$ cd YOUR-COUCHDB-CHECKOUT-DIR
$ svn update
 }}}
 * Don't forget to rebuild couchdb afterwards
 {{{
$ cd YOUR-COUCHDB-CHECKOUT-DIR
$ make dev
 }}}

<<Anchor(step4)>>
== Step 4: Create and Upload a Patch ==
 * Once you've completed the feature/fix you will need to create a patch
 * From the command line, call the following, giving your patch a name:
 {{{
$ cd YOUR-COUCHDB-CHECKOUT-DIR
$ svn diff > your_patch_file_name.patch
 }}}
 * Open up the issue link you found/created in Step 1
 * Click on '''Attach File''' under the '''Operations''' menu on the left
 * Add your file and add a comment about the change.

And you're done!

<<Anchor(questions)>>
== Asking Questions And Getting Feedback ==
You can contact the CouchDB developers to ask questions and propose ideas by:
 * Sending a mail to the Dev mailing list: http://wiki.apache.org/couchdb/Mailing_lists or,
 * Chatting on IRC: #couchdb on Freenode (irc.freenode.net)               

All issues created in JIRA are mailed to the Dev mailing list.
