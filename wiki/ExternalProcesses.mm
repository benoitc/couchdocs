= External Processes =
CouchDB now allows for the ability to develop custom behaviors via processes that communicate over ''stdin'' and ''stdout''. Requests to CouchDB that are captured by the external process handler are passed via JSON object to the external process over ''stdin'' and reads a JSON object from ''stdout''. Without further ado...

== JSON Requests ==
Requests capture information about the incoming HTTP request and transform it into a JSON object. I've formatted the object here, though in real life this object would contain no new lines and all embedded white space would be normalized to a single ' ' (space) character.

An example object:

{{{
{
    'body': 'undefined',
    'cookie': {
        '__utma': '96992031.3087658685658095000.1224404084.1226129950.1226169567.5',
        '__utmz': '96992031.1224404084.1.1.utmcsr'
    },
    'form': {},
    'info': {
        'compact_running': False,
        'db_name': 'couchbox',
        'disk_size': 50559251,
        'doc_count': 9706,
        'doc_del_count': 0,
        'purge_seq': 0,
        'update_seq': 9706},
    'path': [],
    'query': {},
    'method': 'GET'
}
}}}
In order:

 * ''body'' - Raw post body
 * ''cookie'' - Cookie information passed on from mochiweb
 * ''form'' - If the request's Content-Type is "application/x-www-form-urlencoded", a decoded version of the body
 * ''info'' - Same structure as returned by http://127.0.0.1:5984/db_name/
 * ''path'' - Any extra path information after routing to the external process
 * ''query'' - Decoded version of the query string parameters.
 * ''method'' - HTTP request verb

Note: Before CouchDB 0.11 `method` was `verb`.

== JSON Response ==
The response object has five possible elements

 * ''code'' - HTTP response code [Default is 200]. Note that this must be a number and cannot be a string (no "").
 * ''headers'' - An object with key-value pairs that specify HTTP headers to send to the client.
 * ''json'' - An arbitrary JSON object to send the client. Automatically sets the Content-Type header to "application/json"
 * ''body'' - An arbitrary CLOB to be sent to the client. Content-Type header defaults to "text/html"
 * ''base64'' - Arbitrary binary data for the response body, base64-encoded

While nothing breaks if you specify both a ''json'' and ''body'' member, it is undefined which response will be used. If you specify a Content-Type header in the ''headers'' member, it will override the default.

== Common Pitfalls ==
 * When responding to queries always remember to turn off buffering for ''stdout'' or issue a ''flush()'' call on the file handle.
 * All interaction is in the form of single lines. Each response should include *exactly* one new line that terminates the JSON object.
 * When using base64 encoders, be sure to strip any CRLF from the result - most encoders will add CRLF after 76 characters and at the end.
 * CouchDB 0.10 looks for a case-sensitive match of the Content-Type header -- a user-defined header must specify "Content-Type", not "content-type" or "CoNtEnT-type".  This is fixed in future releases.

== Configuration ==
Adding external processes is as easy as pie. Simply place key=command pairs in the ''[external]'' section of your ''local.ini'' and then map those handlers in the ''[httpd_db_handlers]'' section, like:

{{{
;Including [log] and [update_notification] for context

[log]
level = info

[external]
test = /usr/local/src/couchdb/test.py

[httpd_db_handlers]
_test = {couch_httpd_external, handle_external_req, <<"test">>}

[update_notification]
;unique notifier name=/full/path/to/exe -with "cmd line arg"
}}}
This configuration will make the ''/usr/local/src/couchdb/test.py'' responsible for handling requests from the url:

{{{
http://127.0.0.1:5984/${dbname}/_test
}}}
== Example External Process ==
Here is a complete Python external process that does a whole lot of nothing except show the mechanics.

{{{
import sys

try:
    # Python 2.6
    import json
except:
    # Prior to 2.6 requires simplejson
    import simplejson as json

def requests():
    # 'for line in sys.stdin' won't work here
    line = sys.stdin.readline()
    while line:
        yield json.loads(line)
        line = sys.stdin.readline()

def respond(code=200, data={}, headers={}):
    sys.stdout.write("%s\n" % json.dumps({"code": code, "json": data, "headers": headers}))
    sys.stdout.flush()

def main():
    for req in requests():
        respond(data={"qs": req["query"]})

if __name__ == "__main__":
    main()
}}}
A Java example can be found here: http://daily.profeth.de/2009/12/apache-couchdb-external-process-using.html
