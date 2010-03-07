Nginx can serve as a reverse proxy to CouchDB for scenarios such as URL rewriting, load-balancing, access restriction, etc. 

Here's a basic excerpt from an nginx config file in <nginx config directory>/sites-available/default. This will proxy all requests from http://domain.com/... to http://localhost:5984/...

{{{
location / {
                proxy_pass http://localhost:5984;
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}}}


== Reverse proxy for a subdirectory ==
Here's an excerpt of a basic nginx configuration that proxies the URL "http://domain.com/couchdb" to "http://localhost:5984" so that requests appended to the subdirectory, such as "http://domain.com/couchdb/db1/doc1" are proxied to "http://localhost:5984/db1/doc1".

{{{
location /couchdb {
                rewrite /couchdb/(.*) /$1 break;
                proxy_pass http://localhost:5984;
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}}}

=== Known Test Suite issue with reverse proxy from subdirectory URL ===
If the reverse proxy configuration also rewrites the URL for a subdirectory, the test suite will fail because it relies on the absolute root path for HTTP requests. This is a known issue and a patch has been submitted by Jack Moffitt at https://issues.apache.org/jira/browse/COUCHDB-321.

== Authentication with reverse proxy ==
Here's a sample config setting with basic authentication enabled:

{{{
        location /couchdb {
                auth_basic "Restricted";
                auth_basic_user_file htpasswd;
                rewrite /couchdb/(.*) /$1 break;
                proxy_pass http://localhost:5984;
                proxy_redirect off;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
}}}

=== Issues with reverse proxy authentication ===
Enabling basic authentication in Nginx will pass the HTTP authentication header to CouchDB, invoking its authentication handler as well. This configuration causes the Nginx basic authentication prompt to appear in the browser, followed by a second authentication prompt from Couchdb, even if CouchDB authentication is not enabled. 

You can either use the same username and password combinations for both Nginx and CouchDb, or set CouchDB to use the null_authentication_handler.

{{{ In the local.ini file...
[httpd]
authentication_handler = {couch_httpd, null_authentication_handler}
}}}

Note: As an Nginx newbie, it's probable that the original author of this wiki post just didn't know which headers to suppress or how to suppress them :-) I tried "proxy_hide_header Authorization" and "proxy_hide_header WWW-Authenticate".


Note 2: While "proxy_hide_header" does not work, setting the header Authorization to "" seems to work.

{{{
  location / {
    auth_basic            "CouchDB Admin";
    auth_basic_user_file  /etc/nginx/passwd;
    proxy_pass http://localhost:5984;
    proxy_redirect off;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Authorization "";
  }
}}}
