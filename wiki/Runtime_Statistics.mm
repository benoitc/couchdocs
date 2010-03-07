Note, this applies to CouchDB 0.9 and newer.

CouchDB comes with a runtime statistics module that lets you inspect how CouchDB performs. The statistics module collects metrics like requests per second, request sizes and a multitude of other useful stuff.

You can get a list of all currently counted metrics by issuing a GET request to

{{{
/_stats
}}}
and CouchDB will return

{{{
{
  "couchdb": {
    "request_time": {
      "current": 0,
      "max": 0,
      "mean": 0.0,
      "description": "length of a request inside CouchDB without Mochiweb",
      "stddev": 0.0,
      "min": 0,
      "count": 2
    }
  },
  "httpd_request_methods": {
    "GET": {
      "current": 2,
      "max": 1,
      "mean": 0.00096946194861852,
      "description": "number of HTTP GET requests",
      "stddev": 0.0311210875797858,
      "min": 0,
      "count": 2063
    }
  },
  "httpd": {
    "requests": {
      "current": 2,
      "max": 1,
      "mean": 0.00096946194861852,
      "description": "number of HTTP requests",
      "stddev": 0.0311210875797858,
      "min": 0,
      "count": 2063
    }
  },
  "httpd_status_codes": {
    "200": {
      "current": 2,
      "max": 1,
      "mean": 0.00096946194861852,
      "description": "number of HTTP 200 OK responses",
      "stddev": 0.0311210875797858,
      "min": 0,
      "count": 2063
    }
  }
}
}}}
Your output may vary. Depending on the number and type of requests CouchDB has processed so far, the output will include more or less metrics. Let's break the above down for a bit.

Statistics are reported by 'group'. Often the group is just the couchdb module that counted the metric (`httpd` for the HTTP API for example), or it is a subgroup within a module, like `httpd_status_codes`. Each group or subgroup contains one or more 'keys'. Keys are unique identifies for a single metric in a module. The combination of group and key (`{httpd, requests}`) uniquely identifies a single metric.

Each metric is aggregated over four periods time. In the default output of `/_stats` the period of time is since CouchDB was started. The aggregate values are calculated on a per-second basis. So values `{httpd, requests}` will include the number of requests made against the HTTP API per second since CouchDB was started. `current` is the current value, the number of requests. `max` and `min` are the respective extreme values and `mean` is arithmetic mean value for the period of time with a standard deviation of `steddev`. `description` is a human-readable description of the metric and `count` is the number of times this metric was counted.

The three other periods of time are 60 seconds, 300, and 900 seconds (1, 5, 15 minutes). The aggregate values for these periods are reset at the end of each period and begin to count anew.

You can grab single statistics by querying

{{{
/_stats/group/key
}}}
for example

{{{
/_stats/httpd/requests
}}}
and the response will include only the aggregate values for this single metric.

{{{
{
  "httpd": {
    "requests": {
      "current": 3,
      "max": 1,
      "mean": 0.000978154548418653,
      "description": "number of HTTP requests",
      "stddev": 0.031260162541133,
      "min": 0,
      "count": 3067
    }
  }
}
}}}
If you want to query a different time period, use the `?range=60` (or `300` or `900`). You won't get useful results if you query any other time range and you can't yet configure the different time ranges.

If you are parsing the responses into native objects in your programming language, you can simply access all the aggregate values using the object-attribute accessor method of your language. Here is an example for JavaScript.

{{{
  // `var stats` is filled with an XMLHttpRequest.
  alert(stats.httpd.requests.max);
}}}
At the moment the following list of metrics is collected; it might expand in the future:

{{{
{couchdb, database_writes}, number of times a database was changed}
{couchdb, database_reads}, number of times a document was read from a database}
{couchdb, open_databases}, number of open databases}
{couchdb, open_os_files}, number of file descriptors CouchDB has open}
{couchdb, request_time}, length of a request inside CouchDB without MochiWeb}

{httpd, bulk_requests}, number of bulk requests}
{httpd, requests}, number of HTTP requests}
{httpd, temporary_view_reads}, number of temporary view reads}
{httpd, view_reads}, number of view reads}

{httpd_request_methods, 'COPY'}, number of HTTP COPY requests}
{httpd_request_methods, 'DELETE'}, number of HTTP DELETE requests}
{httpd_request_methods, 'GET'}, number of HTTP GET requests}
{httpd_request_methods, 'HEAD'}, number of HTTP HEAD requests}
{httpd_request_methods, 'MOVE'}, number of HTTP MOVE requests}
{httpd_request_methods, 'POST'}, number of HTTP POST requests}
{httpd_request_methods, 'PUT'}, number of HTTP PUT requests}

{httpd_status_codes, '200'}, number of HTTP 200 OK responses}
{httpd_status_codes, '201'}, number of HTTP 201 Created responses}
{httpd_status_codes, '202'}, number of HTTP 202 Accepted responses}
{httpd_status_codes, '301'}, number of HTTP 301 Moved Permanently responses}
{httpd_status_codes, '304'}, number of HTTP 304 Not Modified responses}
{httpd_status_codes, '400'}, number of HTTP 400 Bad Request responses}
{httpd_status_codes, '401'}, number of HTTP 401 Unauthorized responses}
{httpd_status_codes, '403'}, number of HTTP 403 Forbidden responses}
{httpd_status_codes, '404'}, number of HTTP 404 Not Found responses}
{httpd_status_codes, '405'}, number of HTTP 405 Method Not Allowed responses}
{httpd_status_codes, '409'}, number of HTTP 409 Conflict responses}
{httpd_status_codes, '412'}, number of HTTP 412 Precondition Failed responses}
{httpd_status_codes, '500'}, number of HTTP 500 Internal Server Error responses}
}}}
----
== Questions about Statistics from the mailing list ==
=== What exactly is 'current' & 'count'. What are each of them recording   and why is 'count' less than 'current' in my system (seems counter intuitive    to me). ===
Current is a sum of the values recorded. For things like HTTP requests, this is the total number of requsts.

Count is the number of updates for this metric in the given time span.

Stats works with two parts, a collector and an aggregator. The collector part receives messages from through out CouchDB and holds that data in a table. Once a second the aggregator will sweep through the collector and update its stats.

So, if you had 20K requests between to aggregator sweeps, Current would be incremented by 20K and Count is incremented by 1.

=== Can the 'mean' here be interpreted as average reads per second? ===
For requests, the mean is roughly the requests per second. Its not as theoretically correct as something like RRDtool because we don't interpolate, we just average the reads we take roughly once a second.

=== Is there any indication of exactly where within the 5 minute interval    we are? ===
No, but the current implementation (committed after 0.10.x was branched) does not reset statistic aggregators as the old code did. The new method is the more standard "these stats reflect all values seen in the last 5 minutes" regardless of when you query it.

== Another metric that I'm having trouble with is the 'request_time'. Querying it returns data similar to: ===

[snip]

=== Again, same question about exactly what the 'count' and 'current'    values mean for this metric. ===

Oh weird. So, Count has the same meaning as before, but here Current is the length of the last recorded request. The weirdness comes from the fact that this is averaging a set of distinct points, where as things like requests are averaging the relative change so current makes a bit more sense there.

=== Does the 'mean' represent the average time for a request in CouchDB in   seconds? ===

milliseconds.
