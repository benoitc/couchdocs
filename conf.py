# -*- coding: utf-8 -
#
# This file is part of gunicorn released under the MIT license. 
# See the NOTICE for more information.

import os

# options
SITE_NAME = "CouchDB Documentation"
SITE_URL = "http://couchdocs.github.com/couchdocs"
SITE_DESCRIPTION = "Documentation Project for CouchDB"

# paths 
DOC_PATH = os.path.dirname(os.path.abspath(__file__))
TEMPLATES_PATH = os.path.join(DOC_PATH, "templates")
INPUT_PATH = os.path.join(DOC_PATH, "site")
OUTPUT_PATH = os.path.join(DOC_PATH, "htdocs")
