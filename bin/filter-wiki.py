#! /usr/bin/env python

import fnmatch
import os
import sys

def is_ham(fname):
    with open(fname) as page:
        for line in page:
            if not line[:1] == "#":
                return False
            if line.startswith("##master-page"):
                return True
            if line.startswith("#redirect"):
                return True

def main():
    if len(sys.argv) != 2:
        print "usage: %s PATH" % sys.argv[0]
        exit(0)

    for path, dnames, fnames in os.walk(sys.argv[1], topdown=False):
        fnames = fnmatch.filter(fnames, "*.mm")
        for fn in fnames:
            fn = os.path.join(path, fn)
            if is_ham(fn):
                os.remove(fn)
        for dn in dnames:
            dn = os.path.join(path, dn)
            if not len(os.listdir(dn)):
                os.rmdir(dn)

if __name__ == '__main__':
    main()

