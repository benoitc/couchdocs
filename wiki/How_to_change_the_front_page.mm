To change the default request page, edit your local.ini file adding a section like:
{{{
[httpd_global_handlers]
/ = {couch_httpd, send_redirect, "/blogdb/_design/sofa/_list/index/recent-posts?descending=true&limit=5"}

}}}

When you goto http://127.0.0.1:5984/ instead of the usual version information, it will redirect to the page you specified.

----

For more advanced modifications to url handling see [[http://medevyoujane.com/blog/2009/4/10/power-couchdb-basic-http-handlers.html|power http handling]].
