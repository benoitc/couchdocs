CouchDocs
=========

Working on making better documentation for CouchDB.

Adding to the site
------------------

1. Make a file in the `site/` directory.
2. Add some stuff to it
3. Commit it and send a pull request to couchdocs.

Files that end in .md will be passed through a Markdown converter.
Files that end in .rst will be passed through a reST converter.
Other files will just be copied straight over to the output directory.

Files have metadata headers. See the existing files for examples.

Building the site
-----------------

    $ ./bin/buildweb.py

Or, if you have kicker installed (a ruby gem) you can have the site built
automatically when anything changes:

    $ kicker -e ./bin/buildweb.sh site/ htdocs/ templates/

Viewing the site locally
------------------------

If you have the WEBrick (another Ruby gem) installed you should be able
to run the `bin/serve.rb` script and have the site available on port 8080.

    $ ./bin/serve.rb

Uploading the site to Github pages
----------------------------------

    $ ghp-import -p ./htdocs/

Requires that you have installed ghp-import which can be found
[here][ghp-import].

[ghp-import]: http://github.com/davisp/ghp-import/

