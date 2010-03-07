#format wiki
#language en

= Authentication and Authorization =

== Disclaimer ==

These pages attempt to collect strands of thoughts that concern authentication and authorization in CouchDB.  These pages do not describe the currently available support for authentication and authorization in CouchDB or any agreed implementation plans.

== Discussion threads ==

The following discussions address authentication and authorization concerns:

[[http://thread.gmane.org/gmane.comp.db.couchdb.devel/5325|2009-09-07]] Per-DB Auth Ideas and Proposal

[[http://thread.gmane.org/gmane.comp.db.couchdb.devel/4099|2009-07-10]] : Cookie Auth

[[http://thread.gmane.org/gmane.comp.db.couchdb.user/2980|2009-07-08]] : CouchDB shared hosting

[[http://thread.gmane.org/gmane.comp.db.couchdb.devel/3792|2009-06-25]] : CouchDB Authentication and Authorization

[[http://www.mail-archive.com/dev@couchdb.apache.org/msg02631.html|2009-04-29 : Baking Cookie-Based Authentication into CouchDB]]

[[http://thread.gmane.org/gmane.comp.db.couchdb.user/2065|2009-04-20]] : Authentication and Authorisation for webmail project  

[[http://thread.gmane.org/gmane.comp.db.couchdb.user/1953|2009-04-12]] : auth using Nginx as proxy

[[http://thread.gmane.org/gmane.comp.db.couchdb.user/1953|2009-04-10]] : security and validation API?

[[http://thread.gmane.org/gmane.comp.db.couchdb.user/1488|2009-03-08]] : Proposal for digital signatures of documents (user@couchdb)

[[http://thread.gmane.org/gmane.comp.db.couchdb.devel/1658|2008-11-21]] : New Security and Validation Features

[[http://article.gmane.org/gmane.comp.db.couchdb.devel/1026|2008-07-02]] : Security and Validation

[[http://article.gmane.org/gmane.comp.db.couchdb.devel/664|2008-04-28]] : CouchDB 1.0 work

[[http://thread.gmane.org/gmane.comp.db.couchdb.devel/3031|2009-04-21]] : LDAP Authentication handler

[[http://thread.gmane.org/gmane.comp.db.couchdb.devel/232|2008-01-09]] : The planned security model for CouchDB

[[http://thread.gmane.org/gmane.comp.db.couchdb.devel/942|2008-06-16]] : How to contribute - especially authentication

== JIRA issues ==

The following issues address authentication and authorization concerns:

<strike>[[http://issues.apache.org/jira/browse/COUCHDB-34|COUCHDB-34]]</strike> : Enable replicator to use HTTP authentication.

<strike>[[http://issues.apache.org/jira/browse/COUCHDB-263|COUCHDB-263]]</strike> : Require valid user for all database operations.

<strike>[[http://issues.apache.org/jira/browse/COUCHDB-420|COUCHDB-420]]</strike> : OAuth authentication support (2-legged initially) and cookie-based authentication.

[[https://issues.apache.org/jira/browse/COUCHDB-438|COUCHDB-438]] : Add per database (OAuth) authentication to couchdb

[[http://issues.apache.org/jira/browse/COUCHDB-329|COUCHDB-329]] : Replication from Futon does not copy design docs with admin authentication.

[[http://issues.apache.org/jira/browse/COUCHDB-256|COUCHDB-256]] : Replicating from a write-protected server fails

[[http://issues.apache.org/jira/browse/COUCHDB-438|COUCHDB-438]] : Add per database (OAuth) authentication to couchdb


== Definitions ==

 Authentication:: any process by which you verify that someone is who they claim they are.
 Authorization:: any process by which someone is allowed to be where they want to go, or to have information that they want to have.

== References ==

[[Security_Features_Overview]]

[[http://httpd.apache.org/docs/2.2/howto/auth.html|Apache 2.2 Authentication, Authorization and Access Control]]

[[http://tomcat.apache.org/tomcat-6.0-doc/realm-howto.html|Apache Tomcat 6 Realms and AAA]]

[[http://db.apache.org/derby/docs/10.5/ref/rrefproper13766.html|Apache Derby derby.authentication.provider]]

[[http://tools.ietf.org/html/rfc2617|RFC 2617: HTTP Authentication: Basic and Digest Access Authentication]]

[[http://db.apache.org/derby/docs/10.4/ref/rrefsqljgrant.html|Apache Derby GRANT Syntax]]

[[http://db.apache.org/derby/docs/10.4/ref/rrefsistabssystableperms.html|Apache Derby SYSTABLEPERMS Table]]

[[http://db.apache.org/derby/docs/10.4/ref/rrefsistabssyscolperms.html|Apache Derby SYSCOLPERMS Table]]

[[http://www.kernel.org/pub/linux/libs/pam/|Pluggable Authentication Modules for Linux]]

[[http://www.rabbitmq.com/faq.html#authentication-authorization|RabbitMQ FAQ]]

[[http://tools.ietf.org/html/rfc4422|RFC 4422: Simple Authentication and Security Layer (SASL)]]

[[http://www.rabbitmq.com/admin-guide.html#access-control|RabbitMQ Access Control]]

[[http://willcodeforfoo.com/2009/07/13/announcing-alice/|Announcing Alice and Wonderland]]

[[http://dev.rabbitmq.com/wiki/ManagementAndMonitoring|RabbitMQ Management and Monitoring Wiki]]

[[https://dev.rabbitmq.com/wiki/AccessControlDesign|RabbitMQ Access Control Design Wiki]]

[[http://hg.rabbitmq.com/rabbitmq-server/file/dc753bc0c54e/src/rabbit_access_control.erl|rabbit_access_control.erl]]

[[http://www.oasis-open.org/committees/tc_home.php?wg_abbrev=xacml|OASIS eXtensible Access Control Markup Language (XACML) TC]]

[[http://www.ibm.com/developerworks/xml/library/x-xacml/?S_TACT=105AGX06&S_CMP=EDU|XML Security: Control information access with XACML]]

[[http://incubator.apache.org/projects/shiro.html|Incubating Shiro (aka Ki, JSecurity) project]]

[[http://www.erlang-fr.org/erlang.org/lib/inets-3.0/doc/html/mod_auth.html|Erlang inet mod_auth]]

== Authentication use cases ==

The following use-cases describe potential usage scenarios for an authentication system.
The catalog of use-cases could be helpful to describe the feature set of
any proposals and to identify any architectural issues.

NO-IDENTITY: The user is not authenticated.  All access is controlled by the rights
granted to anonymous users.

FIXED-IDENTITY: The user is specified via configuration.

DECLARED-IDENTITY: The user is specified in the request and not authenticated.

PROXY-AUTH: A reverse proxy authenticates the user and optionally rewrites the
request to include the remote user.  The authentication handler would extract
the remote user from the rewritten request (similar to DECLARED-IDENTITY).
The "Via" header could be used to distinguished proxied requests from
local or tunnelled requests which could be granted elevated privileges 
(like local or tunnelled would get <<"_admin">> with current authorization system).

IP-IDENTITY: The originating IP address is used to identify the user.
Could be useful for replicating nodes.  Local origination could
result in elevated privileges.

BASIC-IDENTITY: HTTP Basic Authentication is used to identify
the user.

DIGEST-IDENTITY: HTTP Digest Authentication is used to identify
the user.

OAUTH-IDENTITY: OAuth is used to identify the user.

LDAP-IDENTITY: LDAP is used to identify the user.

SSL-IDENTITY: An SSL certificate is used to identify the user.

COOKIE-IDENTITY: A cookie is sent that is used for  
to provide the identity.

HYBRID-AUTH: An option of different means may be offered
to validate the user.


== Authentication hooks ==

CouchDB 0.9.x allows the user to configure an authentication handler in local.ini like: 

{{{
[httpd]
authentication_handler = {modulename, functionname}
}}}

SVN HEAD and 0.10.x allow specification of multiple authentication handlers using:

{{{
[httpd]
authentication_handlers = {modulename, functionname}, (modulename, functionname}
}}}


The module must be available on the code path.  User provided handlers
should be placed in ~couchdb (need to confirm that would be the current
working directory) or in a subdirectory under ROOT/lib where root is
the Erlang/OTP installation directory.

If not specified in local.ini, the authentication handler specified in default.ini, 
{couch_httpd, default_authentication_handler}, will be used.

The specified handler is called in couch_httpd::handle_request:

{{{
handle_request(MochiReq, DefaultFun,
        UrlHandlers, DbUrlHandlers, DesignUrlHandlers) ->
...
    AuthenticationFun = make_arity_1_fun(
            couch_config:get("httpd", "authentication_handler")),
...

    {ok, Resp} =
    try
        HandlerFun(HttpReq#httpd{user_ctx=AuthenticationFun(HttpReq)})
    catch
}}}

The handler takes an httpd record and returns an user_ctx record.  The return value replaces
the existing user_ctx member of the httpd record and is passed to a handler for the current
request.


user_ctx is defined in src/couch_db.hrl as:
{{{
-record(user_ctx,
    {name=null,
    roles=[]
    }).
}}}

== Authentication handlers ==

=== couch_httpd::default_authentication_handler ===

If the http request contains basic authentication, the user name and password are checked 
against a configured user list.  If the user is recognized as an administrator, the user name and
<<"_admin">> (bit stream representation of "_admin") role are added to the user context, 
otherwise, an exception is thrown.
If basic authentication is not present and there are admins defined in the user list,
an empty context is returned.  If basic authentication is not present and there are no admins
defined, then the _admin role is added to the context.


=== couch_httpd::null_authentication_handler ===

Any request is granted the <<"_admin">> role.

=== couch_httpd::special_test_authentication_handler ===

If the WWW-Authentication header has a value like "X-Couch-Test-Auth username:password",
the user name and password are checked against a hard-coded list of username/password
combinations.  If the request matches, the user name (but not the <<"_admin">> role) is added,
otherwise an exception is thrown.  If the WWW-Authentication header is not present
or does not match the pattern, the <<"_admin role">> is added.

=== couch_httpd_oauth::oauth_authentication_handler ===

[[http://issues.apache.org/jira/browse/COUCHDB-420|COUCHDB-420]] implemented an
[[http://oauth.net/|OAuth]] authentication handler now in SVN HEAD and to be
included in 0.10.x.  The patch also changes
couch_httpd to accept a list of authentication handlers instead of a single
authentication handler.

Steps to get OAuth authentication working (with the patch installed):

 1. in default.d create a file oauth.ini, with contents:
  
  {{{ 
[oauth_consumer_secrets]
example.com = sekr1t
[oauth_token_secrets]
user1 = tokensekr1t
[oauth_token_users]
user1 = admin_user
}}}

 1. In Couchdb, create a user document in _users with username = "admin_user", and add the "_admin" role to its "roles" list.
 1. In default.ini, change the authentication_handlers line to:
  {{{
authentication_handlers = {couch_httpd_oauth, oauth_authentication_handler}
}}}
 1. Install Leah Culver's version of the python oauth library: http://github.com/leah/python-oauth/tree/master
 1. Run the following command from the command line (should be one long line):
  {{{
python -c "URL='http://127.0.0.1:5984/_session';KEY='example.com';TOKEN='user1';SECRET='tokensekr1t';import oauth,httplib;consumer=oauth.OAuthConsumer(KEY,'sekr1t');token=oauth.OAuthToken(TOKEN,SECRET);rq=oauth.OAuthRequest.from_consumer_and_token(consumer,token=token,http_method='GET',http_url=URL,parameters={});rq.sign_request(oauth.OAuthSignatureMethod_HMAC_SHA1(),consumer,token); con=httplib.HTTPConnection('localhost:5984'); con.request('GET',URL,headers=rq.to_header()); print con.getresponse().read()"
}}}

If all is well, you should see this response:
 {{{
{"ok":true,"name":"admin_user","roles":["_admin"]}
}}}

== Authorization use cases ==

The following use-cases describe potential usage scenarios for an authorization system.
The catalog of use-cases could be helpful to describe the feature set of
any proposals and to identify any architectural issues.

ADMIN-PARTY: All requests are authorized.

CONFIGURED-ROOT: All requests are authorized for a configured user or class of users. 

DESIGNDOC-AUTHORIZATION: All requests are authorized by evaluating the
request against rules stored in design document or documents.  This would likely need to involve
passing a message to a process that tracks the design documents and which would
be able to respond with a go/no-go decision.

VALID-USER: All requests are authorized for authenticated users.

READ-ONLY-ANON: Only read requests are authorized for unauthenticated users.

DENY-ANON: All requests are denied for unauthenticated users.

PER-DB-AUTHORIZATION: Different databases has different authorization schemes.

CUSTOM-AUTHORIZATION: An admin can configure a custom authorization handler.

CONTENT-SENSITIVE: The authorization scheme may evaluate the document 
(and previous document on updates) before authorizing a GET or PUT.

VIEW-VALUES-ONLY: The authorization scheme may allow a user to retrieve
the values from a view, but will reject an attempt to include documents.

PREAPPROVAL: User can request an evaluation if a proposed action
would (likely) be approved.  This could be used to disable certain
parts of a UI that are not appropriate for the user.


== Authorization hooks ==

Authorization is not configurable in CouchDB 0.9.x or the current SVN HEAD.
The user_ctx record is examined in couch_db::check_is_admin/1 and 
couch_db::validate_doc_update/3.

The user_ctx record can be displayed using http://localhost:5984/_whoami on the SVN HEAD.

validate_doc_update functions (see [[Security_Features_Overview]]) can examine the user_ctx
and reject document modifications.

== Proposals ==


[[http://issues.apache.org/jira/browse/COUCHDB-441|COUCHDB-441]] : Insert _user and _timestamp on document writes.

[[http://issues.apache.org/jira/browse/COUCHDB-442|COUCHDB-442]] :  Add a "view" or "format" function to process source doc on query.
