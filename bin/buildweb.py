#!/usr/bin/env python
# -*- coding: utf-8 -
#
# This file is part of gunicorn released under the MIT license. 
# See the NOTICE for more information.

from __future__ import with_statement

import codecs
import datetime
import optparse as op
import os
import sys

from jinja2 import Environment
from jinja2.loaders import FileSystemLoader
from jinja2.utils import open_if_exists

__usage__ = "usage: %prog [OPTIONS]"

class Config(dict):
    def __getattr__(self, name):
        return self.__getitem__(name)

class Site(object):    
    def __init__(self, cfg):
        self.cfg = cfg
        self.url = cfg.SITE_URL.rstrip('/')

        fs_loader = FileSystemLoader(cfg.TEMPLATES_PATH, encoding="utf-8")
        self.env = Environment(loader=fs_loader)
        self.env.charset = 'utf-8'
        self.env.filters['rel_url'] = self.rel_url

    def rel_url(self, value):
        return value.split(self.url)[1]

    def render(self):
        INPUT_PATH = self.cfg.INPUT_PATH
        OUTPUT_PATH = self.cfg.OUTPUT_PATH
        for curr_path, dirs, files in os.walk(INPUT_PATH):
            tgt_path = curr_path.replace(INPUT_PATH, OUTPUT_PATH)
            if not os.path.isdir(tgt_path):
                os.makedirs(tgt_path)
            self.process(files, curr_path, tgt_path)

    def process(self, files, curr_path, tgt_path):
        for f in files:
            page = Page(self, f, curr_path, tgt_path)
            if not page.needed():
                continue
            
            path = os.path.relpath(page.source, self.cfg.INPUT_PATH)
            print "Page: %s" % path
            page.write()
            
    def get_template(self, name):
        return self.env.get_template(name)

    def template_ts(self):
        ts = 0
        for path, dnames, fnames in os.walk(self.cfg.TEMPLATES_PATH):
            for fn in fnames:
                fn = os.path.join(path, fn)
                ts = max(ts, os.stat(fn).st_mtime)
        return ts

class Page(object):
    
    def __init__(self, site, filename, curr_path, tgt_path):
        self.site = site
        self.filename = filename
        self.source = os.path.join(curr_path, filename)
        self.headers = {}
        self.body = ""

        with open(self.source, 'Ur') as handle:
            raw = handle.read()
        
        try:
            headers, body = raw.split("\n\n", 1)
        except ValueError:
            headers, body = "", raw

        try:
            for line in headers.splitlines():
                name, value = line.split(':', 1)
                self.headers[name.strip()] = value.strip()
        except ValueError:
            self.headers = {}
            body = "\n\n".join([headers, body])
        self.headers['pubDate'] = ctime = os.stat(self.source).st_ctime
        self.headers['published'] = datetime.datetime.fromtimestamp(ctime)

        basename, oldext = os.path.splitext(filename)
        oldext = oldext.lower()[1:]
        converter = getattr(self, "convert_%s" % oldext, lambda x: x)
        self.body = converter(body)

        newext = self.headers.get('ext', '.html')
        self.target = os.path.join(tgt_path, "%s%s" % (basename, newext))
                
    def url(self):
        path = self.target.split(self.site.cfg.OUTPUT_PATH)[1].lstrip('/')
        return "/".join([self.site.url, path])

    def needed(self):
        for f in "force --force -f":
            if f in sys.argv[1:]:
                return True
        
        if not os.path.exists(self.target):
            return True
    
        smtime = os.stat(self.source).st_mtime
        tmtime = os.stat(self.target).st_mtime
        if tmtime < smtime:
            return True
        # Rebuild for a change to any template.
        if tmtime < self.site.template_ts():
            return True
        return False

    def write(self):
        contents = self.render()
        with codecs.open(self.target, 'w', 'utf-8') as tgt:
            tgt.write(contents)

    def render(self):
        tmpl_name = self.headers.get('template')
        if not tmpl_name:
            return self.body

        kwargs = {
            "cfg": self.site.cfg,
            "body": self.body,
            "url": self.url()
        }
        kwargs.update(self.headers)
        return self.site.get_template(tmpl_name).render(kwargs)

    def convert_md(self, body):
        from markdown import markdown
        return markdown(body)

    def convert_rst(self, body):
        from docutils.core import publish_parts
        parts = publish_parts(source=body, writer_name="html")
        return parts['html_body']

def main():
    opts = [
        op.make_option('-c', '--config', dest='cfg', default="conf.py",
            help="Specify an alternate config file. [%default]")
    ]
    parser = op.OptionParser(usage=__usage__, option_list=opts)
    opts, args = parser.parse_args()
    if len(args):
        parser.error("Unrecognized arguments: %s" % ' '.join(args))

    if not os.path.isfile(opts.cfg):
        parser.error("Failed to find config file: %s" % opts.cfg)

    cfg = Config({"__file__": opts.cfg})
    try:
        with open(opts.cfg) as handle:
            data = handle.read()
            code = compile(data, opts.cfg, 'exec')
            exec code in cfg
    except Exception, inst:
        parser.error("Failed to read config: %s" % str(inst))

    Site(cfg).render()
    
if __name__ == "__main__":
    main()
