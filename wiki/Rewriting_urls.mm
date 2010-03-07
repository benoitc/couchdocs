This is an overview of http rewrite handler

== The HTTP Rewrite Handler ==

The http rewrite handler. All rewriting is done from 
/dbname/_design/ddocname/_rewrite by default.

each rules should be in rewrites member of the design doc.
Ex of a complete rule :
{{{

{ 
    .... 
    "rewrites": [ 
    { 
        "from": "", 
        "to": "index.html", 
        "method": "GET", 
        "query": {} 
    } 
    ] 
} 


}}}

 * '''from''': is the path rule used to bind current uri to the rule. It use pattern matching for that.
 * '''to''': rule to rewrite an url. It can contain variables depending on binding variables discovered during pattern matching and query args (url args and from the query member.)
 * '''method''': method to bind the request method to the rule. by default "*"
 * '''query''': query args you want to define they can contain dynamic variable by binding the key to the bindings

to and from are path with  patterns. pattern can be string starting with ":" or
"*". ex:
/somepath/:var/*

This path is converted in erlang list by splitting "/". Each var are 
converted in atom. "*" is converted to '*' atom. The pattern matching is done
by splitting "/" in request url in a list of token. A string pattern will 
match equal token. The star atom ('*' in single quotes) will match any number 
of tokens, but may only be present as the last pathtern in a pathspec. If all 
tokens are matched and all pathterms are used, then the pathspec matches. It works
like webmachine. Each identified token will be reused in to rule and in query

The pattern matching is done by first matching the request method to a rule. by 
default all methods match a rule. (method is equal to "*" by default). Then
It will try to match the path to one rule. If no rule match, then a 404 error 
is displayed.

Once a rule is found we rewrite the request url using the "to" and
"query" members. The identified token are matched to the rule and 
will replace var. if '*' is found in the rule it will contain the remaining
part if it exists.

Examples:

|| '''Rule'''  || '''Url''' || '''Rewrite to''' || '''Tokens''' ||
|| {"from": "/a/b", "to": "/some/"} ||         /a/b?k=v ||        /some/k=v||       k = v ||
|| {"from": "/a/b",  "to": "/some/:var"}   ||       /a/b ||             /some/b?var=b  ||      var = b ||
|| {"from": "/a", "to": "/some/*"}||            /a ||               /some || ||
|| {"from": "/a/*", "to": "/some/*} ||          /a/b/c ||          /some/b/c  || ||
|| {"from": "/a", "to": "/some/*"} ||         /a ||              /some  || ||
|| {"from": "/a/:foo/*","to": "/some/:foo/*||     /a/b/c ||          /some/b/c?foo=b ||    foo = b ||
|| {"from": "/a/:foo", "to": "/some",  "query": {  "k": ":foo"  }} ||  /a/b ||          /some/?k=b&foo=b ||   foo =:= b ||
|| {"from": "/a",  "to": "/some/:foo" } ||        /a?foo=b  ||      /some/b&foo=b  ||           foo = b ||


Paths are relative to the design doc, so "/" mean the design doc too and "../" mean the path above the design doc and so on.
