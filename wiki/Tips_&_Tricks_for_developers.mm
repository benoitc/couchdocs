Collecting tips and tricks that makes a CouchDB developer's life easier.

If you find yourself building CouchDB from scratch a lot the following shell script function might save some typing. This is sh-script, but only tested on bash. Add it to your `.bashrc` or `.profile` file or wherever you store shell customisations.

{{{
buildcouch()
{
    if test -z "$1"; then
        echo "speficy target dir"
        return
    fi
    ./bootstrap && \
    ./configure --prefix=$1 && \
    make -j4 && \
    make install
}
}}}

It gives you a new command in your shell `buildcouch` (just change the function name if you don't like it). Set the `make -j` value to the number of cores in your system `+1`.

{{{
cd Work/couchdb/trunk
buildcouch /path/to/testinstall
}}}
