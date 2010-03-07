= Generating HTML from Javascript shows and lists =
You can generate output from [[http://books.couchdb.org/relax/design-documents/shows|shows]] and [[http://books.couchdb.org/relax/design-documents/lists|lists]].  Typically this would be HTML intended for a browser but any format can be generated. CouchDB already includes [[http://en.wikipedia.org/wiki/ECMAScript_for_XML|Javascript support]] for XML derived formats (eg Atom feeds). It is impractical to output HTML directly so some sort of templating is recommended.

== Best Practise ==
Generate clear concise simple HTML from your show/list functions.  The resulting HTML interface should be usable from constrained devices (eg cell phones, set top boxes) as well as being accessible (eg screen readers) and easy to index for search engines.  This is also easier to automatically test.  You can then run Javascript in the browser (if the browser supports Javascript and it is turned on) to enhance what is being displayed (eg add extra information, tooltips, icons, previews of next/previous content, enhanced menus and interaction etc).

It is a '''very''' good idea to use a library that automatically escapes values (eg replacing < with ampersand lt semicolon) otherwise your application will be prone to [[http://en.wikipedia.org/wiki/Cross-site_scripting|cross site scripting attacks]].  It should also provide a way of disabling the escaping when you are intentionally providing raw HTML.

It is convenient if the library has functions for emitting html.  For example it may have a function to insert an image where you provide the URL and the function generates all the wrapping HTML, including width/height/caption attributes if you provided them.

 . '''Bad''': `<img src={{ url }} {{ if(width) }} width={{ width }} {{/if}} {{ if(height) }} height={{ height }}{{/if}} >`

 . '''Good''': `{{ img_tag(url, width, height) }}`

You should avoid having code in your template.  Some template libraries let you put any code you want between their tags.  This is as bad an idea as putting HTML sprinkled throughout your code.  It also makes the templates harder to translate (the translator has to understand the code) and is a maintenance burden (eg if you have similar code in multiple templates then they may all require changing for code updates).  Instead you should be able to define a meaningfully named function that is part of the data supplied to the template.

 . '''Bad''': `{{ if(info_level>3 && info_items.length>0  && show_issues) }} <h2>Important issues</h2> ... {{/if}}`

 . '''Good''': `{{ if (has_important()) }} <h2>Important issues</h2> ... {{/if}}`

== Constraints ==
The Javascript view server and the environment the code run in mean that some existing Javascript templating libraries will not work.

 * There is no network/file access so templates cannot be loaded over the network or from a file.  Instead they must be strings already included into your Javascript code.  (See the !json directive of couchapp which does this for you).  They must also return strings.
 * There is no [[http://en.wikipedia.org/wiki/Document_Object_Model|DOM]] available (templating libraries often assume that they are running in a browser working on the currently displayed document)
 * Some work on complete documents whereas your show and especially list functions are often working on multiple strings and template fragments
 * Some only do HTML - this is good if they ensure the result is correct HTML
 * Some do any form of templating (eg plain text) which means your resulting HTML can be invalid
 * Size can be a problem.  Some templating libraries are rather large and depend on other libraries. They can create many layers of intermediary functions and caching making it hard to debug what is happening.

== Solutions ==
The solutions listed below are known to work with CouchDB show and list functions, generating HTML and working with CouchDB deployment conventions (ie !json string templates and !code inclusion into the show/list functions).

 . '''Recommendation: '''Use mustache.js

=== John Resig's micro-templating ===
This engine is a screenful of code described at http://ejohn.org/blog/javascript-micro-templating (download a CouchDB version [[http://github.com/jchris/sofa/raw/master/vendor/couchapp/template.js|here]]).  You can read about using it in the [[http://books.couchdb.org/relax/design-documents/shows#Using%20Templates|CouchDB book]].  Example usage can be found in the [[http://github.com/jchris/sofa|Sofa blog application]].  It does not do HTML escaping so you will need to be very careful.  The templating is not HTML specific so you can generate other formats.  (The tags are HTML syntax though.)

This is an example of how to do conditionals:

{{{
<% if (o.foo) { %>
    Foo is true-ish
<% } else { %>
    Foo is not true-ish
<% } %>
}}}
Note that this library has no support, bug tracker or development/test/release process.

=== mustache.js ===
[[http://github.com/janl/mustache.js|mustache.js]] is a Javascript version of a Ruby templating library.  The name refers to the { and } characters looking like a mustache.  Download http://github.com/janl/mustache.js/raw/master/mustache.js to get the latest version which drops right in using !json/!code as is.

The library is complete and does not put Javascript code into your template, but does have all the expected features (looping, conditionals etc).  Although the intention is to generate HTML the templates are not HTML specific.  The only exception is that substitutions by default are HTML escaped (use triple braces for no escaping).  This is a very good thing.

=== underscore ===
[[http://documentcloud.github.com/underscore/|Underscore]] is a small library of miscellaneous functions that also includes simple [[http://documentcloud.github.com/underscore/#template|templating]] substantially similar to John Resig's micro templating above.  The templating is not HTML specific and there is no automatic HTML escaping.

=== closure ===
[[http://code.google.com/closure/templates/|closure templates]] are a Google project used behind the scenes in places like gmail and Google docs.  It is different from the other libraries in that the templates are compiled to Javascript code and you just include that Javascript code.  This has the advantage that errors in your templates are detected at build time not run time.  Values are automatically HTML escaped.  In order for soyutils.js to work, you should include this line before including it:

{{{
var navigator={userAgent: ""};
}}}
