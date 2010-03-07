CouchDB comes with code in a variety of different languages. While the core is written in Erlang, there are some parts written in C, others written in HTML, CSS, and Javascript, and then there are also shell scripts, Makefiles, et cetera.

First, some general rules:

 * Always use spaces for indentation, not tabs, except in Makefiles.
 * Use four spaces for indentation in Erlang and C code, two spaces in HTML, CSS, and Javascript.
 * Try to keep lines shorter than 80 characters.
 * When you edit a file, try to stick with the conventions used in the surrounding code.
 * Avoid trailing spaces and newlines in your files. Good editors usually have a configuration option that prevents this from happening.
 * Avoid mixing purely cosmetic changes (such as removing trailing white-space) with functional changes, as that makes review of the actual change (whether it’s a check-in or a patch) much more difficult.

For more detailed coding conventions for Erlang code, please see the [[http://www.erlang.se/doc/programming_rules.shtml|Erlang Programming Rules and Conventions]].
