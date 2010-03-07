A simple introduction to CouchDB view collation.

== Basics ==

View functions specify a key and a value to be returned for each row. CouchDB collates the view rows by this key. In the following example, the !LastName property serves as the key, thus the result will be sorted by !LastName:

{{{
function(doc) {
  if (doc.Type == "customer") {
    emit(doc.LastName, {FirstName: doc.FirstName, Address: doc.Address});
  }
}
}}}

CouchDB allows arbitrary JSON structures to be used as keys. You can use complex keys for fine-grained control over sorting and grouping.

== Examples ==

The following clever trick would return both customer and order documents. The key is composed of a customer ''_id'' and a sorting token. Because the key for order documents begins with the ''_id'' of a customer document, all the orders will be sorted by customer. Because the sorting token for customers is lower than the token for orders, the customer document will come before the associated orders. The values ''0'' and ''1'' for the sorting token are arbitrary.

{{{
function(doc) {
  if (doc.Type == "customer") {
    emit([doc._id, 0], doc);
  } else if (doc.Type == "order") {
    emit([doc.customer_id, 1], doc);
  }
}
}}}

This trick was [[http://www.cmlenz.net/blog/2007/10/couchdb-joins.html|originally documented]] by Christopher Lenz.

=== Sorting by Dates ===

It maybe be convenient to store date attributes in a human readable format (i.e. as a String), but still sort by date. This can be done by converting the date to a number in the emit function. For example, given a document with a created_at attribute of 'Wed Jul 23 16:29:21 +0100 2008', the following emit function would sort by date
{{{
emit(Date.parse(doc.created_at), doc);
}}}

Alternatively, if you use a date format which sorts lexicographically, such as "2008/06/09 13:52:11 +0000" you can just 
{{{
emit(doc.created_at, doc);
}}}
and avoid the conversion. As a bonus, this date format is compatible with the Javascript date parser, so you can use ''new Date(doc.created_at)'' in your client side Javascript to make date sorting easy in the browser.

=== String Ranges ===

If you need start and end keys that encompass every string with a given prefix, it is better to use a high value unicode character, than to use a 'ZZZZ' suffix.

That is, rather than:
{{{
startkey="abc"&endkey="abcZZZZZZZZZ" 
}}}

You should use:
{{{
startkey="abc"&endkey="abc\u9999" 
}}}

== Collation Specification ==

This section is based on the ''view_collation'' function in ''couch_tests.js'':

{{{
// special values sort before all other types
null
false
true

// then numbers
1
2
3.0
4

// then text, case sensitive
"a"
"A"
"aa"
"b"
"B"
"ba"
"bb"

// then arrays. compared element by element until different.
// Longer arrays sort after their prefixes
["a"]
["b"]
["b","c"]
["b","c", "a"]
["b","d"]
["b","d", "e"]

// then object, compares each key value in the list until different.
// larger objects sort after their subset objects.
{a:1}
{a:2}
{b:1}
{b:2}
{b:2, a:1} // Member order does matter for collation.
           // CouchDB preserves member order
           // but doesn't require that clients will.
           // this test might fail if used with a js engine
           // that doesn't preserve order
{b:2, c:2}
}}}

Comparison of strings is done using [[http://site.icu-project.org/|ICU]] which implements the [[http://www.unicode.org/unicode/reports/tr10/|Unicode Collation Algorithm]], giving a dictionary sorting of keys. This can give surprising results if you were expecting ASCII ordering. Note that:

 * All symbols sort before numbers and letters (even the "high" symbols like tilde, 0x7e)
 * Differing sequences of letters are compared without regard to case, so a < aa but also A < aa and a < AA
 * Identical sequences of letters are compared with regard to case, with lowercase ''before'' uppercase, so a < A

You can demonstrate the collation sequence for 7-bit ASCII characters like this:

{{{
require 'rubygems'
require 'restclient'
require 'json'

DB="http://127.0.0.1:5984/collator"

RestClient.delete DB rescue nil
RestClient.put "#{DB}",""

(32..126).each do |c|
  RestClient.put "#{DB}/#{c.to_s(16)}", {"x"=>c.chr}.to_json
end

RestClient.put "#{DB}/_design/test", <<EOS
{
  "views":{
    "one":{
      "map":"function (doc) { emit(doc.x,null); }"
    }
  }
}
EOS

puts RestClient.get("#{DB}/_design/test/_view/one")
}}}

This shows the collation sequence to be:
{{{
  ` ^ _ - , ; : ! ? . ' " ( ) [ ] { } @ * / \ & # % + < = > | ~ $ 0 1 2 3 4 5 6 7 8 9
a A b B c C d D e E f F g G h H i I j J k K l L m M n N o O p P q Q r R s S t T u U v V w W x X y Y z Z
}}}

=== Key ranges ===

Take special care when querying key ranges. For example: the query

{{{
startkey="Abc"&endkey="AbcZZZZ"
}}}

will match "ABC" and "abc1", but not "abc". This is because UCA sorts as

{{{
  abc < Abc < ABC < abc1 < AbcZZZZZ
}}}

For most applications, to avoid problems you should lowercase the startkey, e.g.

{{{
startkey="abc"&endkey="abcZZZZZZZZ"
}}}

will match all keys starting with [aA][bB][cC]

=== Complex keys ===

The query {{{startkey=["foo"]&endkey=["foo",{}]}}} will match most array keys with "foo" in the first element, such as {{{["foo","bar"]}}} and {{{["foo",["bar","baz"]]}}}. However it will not match {{{["foo",{"an":"object"}]}}}

== _all_docs ==

The _all_docs view is a special case because it uses ASCII collation for doc ids, not UCA. For example,

{{{
startkey="_design/"&endkey="_design/ZZZZZZZZ"
}}}

will ''not'' find {{{_design/abc}}} because 'Z' comes before 'a' in the ASCII sequence. A better solution is:

{{{
startkey="_design/"&endkey="_design0"
}}}

== Raw collation ==

To squeeze a little more performance out of views, you can specify {{{ "options":{"collation":"raw"} }}} within the view definition for native Erlang collation, especially if you don't require UCA. This gives a different collation sequence:

{{{
1
false
null
true
{"a":"a"},
["a"]
"a"
}}}

Beware that `{}` is no longer a suitable "high" key sentinel value. Use a string like "~~~~~" instead.
