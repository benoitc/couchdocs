By Patrick Antivackis:

This is a Virtual Host config to use Apache as a reverse Proxy for CouchDB.
You need at least to configure apache with the --enable-proxy --enable-proxy-http options and use a version equal or higher than Apache 2.2.7
in order to use the nocanon option in the proxypass directive.

{{{
<VirtualHost *:80>
   ServerAdmin webmaster@dummy-host.example.com
   DocumentRoot "/opt/websites/web/www/dummy"
   ServerName couchdb.localhost
   AllowEncodedSlashes On
   ProxyRequests Off
   KeepAlive Off
   <Proxy *>
      Order deny,allow
      Deny from all
      Allow from 127.0.0.1
   </Proxy>
   ProxyPass / http://localhost:5984/ nocanon
   ProxyPassReverse / http://localhost:5984/
   ErrorLog "logs/couchdb.localhost-error_log"
   CustomLog "logs/couchdb.localhost-access_log" common
</VirtualHost>
}}}

Note from Wout Mertens:
I tried the above, but I had lots of tests fail on Apache 2.2.8/Solaris. When I removed the nocanon directive, less tests failed. I'm not in a position to upgrade Apache just now so I can't test with newer versions.

Note from Rune Larsen:
On linux Apache 2.2.10 you must use nocanon - otherwise many tests fail.

Note from Thomas Lang:
I had to remove the trailing slashes on ProxyPass and ProxyPassReverse in order to get a request to '/_uuids' give the right response. Changed lines:

{{{
ProxyPass / http://localhost:5984 nocanon
ProxyPassReverse / http://localhost:5984
}}}

Before this change apache would add an extra slash before every request to a resource beginning with '_', resulting in this: 'GET' //_utils 500




== Apache Reverse Proxy for same origin and authentication ==

Browsers will typically enforce the same origin policy and will reject requests to fetch data unless the protocol, port and host are identical to the source of the current page.  Using a reverse proxy allows browser-hosted applications to access CouchDB while conforming to the same origin policy.


The following snippet will:
 
 * Require validation of all users, checking username and password against the contents of /var/auth/digest_pw.
 * Forward any requests that start with /db/ to CouchDB.
 * Add user=username to the list of parameters to any request to CouchDB for use with a custom authentication_handler.

The snippet requires that the proxy, proxy_http, rewrite and auth_digest modules be enabled.

{{{
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
...

     <Location />
           AuthType Digest
           AuthName "CouchDB"
	   AuthDigestDomain /
           AuthDigestProvider file
           AuthUserFile /var/auth/digest_pw
           Require valid-user
     </Location>

     BrowserMatch "MSIE" AuthDigestEnableQueryStringHack=On

    ProxyRequests Off
    <Proxy *>
           Order Allow,Deny
           Allow from all
    </Proxy>


     RewriteEngine On
     RewriteOptions Inherit

     RewriteRule ^/db/(.*) http://127.0.0.1:5984/$1?user=%{LA-U:REMOTE_USER} [QSA,P]

</VirtualHost>


}}}

If you are implementing your own security layer by using a reverse proxy, you might need to disable the default authentication handlers of couchdb, otherwise the user might get queried twice about credentials:

{{{
[httpd]
authentication_handlers = {couch_httpd_auth, null_authentication_handler}
}}}
