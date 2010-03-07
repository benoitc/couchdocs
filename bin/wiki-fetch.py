import os
import xmlrpclib

URL = "http://wiki.apache.org/couchdb/?action=xmlrpc2"
srcwiki = xmlrpclib.ServerProxy(URL)
 
allpages = srcwiki.getAllPages()
for idx, pagename in enumerate(allpages):
    print "%d of %d: %s" % (idx, len(allpages), pagename)
    path = os.path.join("wiki", pagename.encode("utf-8")) + ".mm"
    if os.path.exists(path):
        continue
    try:
        pagedata = srcwiki.getPage(pagename)
    except:
        print "FAILED TO GET: %s" % pagename
        continue
    try:
        os.makedirs(os.path.dirname(path))
    except:
        pass
    with open(path, "wb") as out:
        out.write(pagedata.encode('utf-8'))
