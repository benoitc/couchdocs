== Summary ==
This page focuses on how to create a test case for couchdb and run it.  Creating failing test cases to identify a problem is a great way to contribute to couchdb.

== Context ==
 * You run the tests via clicking in your browser
 * The tests require the server to be running
 * All tests exist in one file:
  * (couch source)/share/www/script/couch_tests.js
  * tests are js functions and begin with: foo: function(debug)
 * Running tests this way may seem awkward at first
  * But the process is pretty quick
  * I can modify a test and see the results within a few seconds
 * This page assumes you've built couchdb from source

== To run the existing tests ==
 * Go to: http://localhost:5984/_utils
 * Click: Test Suite
 * Click: the triangle button next to the test you want to run

== When a test is failing ==
 * Currently the tests only run correctly in Firefox.
 * When a test is failing, re-run the single test repeatedly.

== To create a new test ==
 * Go to: (couch source)/share/www/script/couch_tests.js
 * Either:
  * Add lines to an existing test
  * Create a new test in the 'tests' hash

== Steps to run your test ==
 * 1: Run this command from your couchdb source dir
  * sudo make install
 * 2: Run the tests in your browser
  * reload first
  * see 'To run the existing tests' heading above

== Example ==
I added these lines to the 'lots_of_docs' method, to make the test fail:

{{{
     // Check _all_docs with descending=true again (now that there are many docs)
     var desc = db.allDocs({descending:true});
     T(desc.total_rows == desc.rows.length);
}}}

Then I attached the diff to an existing Jira bug that described the issue.


== Ideas for future ==
 * davisp mentioned the idea of building a UI in futon
  * Which will allow you to create/modify tests
