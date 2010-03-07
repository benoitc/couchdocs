= Adding Runtime Statistics =

CouchDB (since 0.9) comes with a runtime statistics module ("the stats module") that gathers all sorts of information during the lifetime of a CouchDB instance. This page explains how you can make the stats module collect information; either in new modules or existing ones.

see also [[Runtime_Statistics]]


== The Collector ==

The collector does all the real-time counting of stuff. It lives in the `src/couchdb/couch_stats_collector.erl` file.

There are three types of counters in the collector

=== Hit Counter ===

A hit counter is a monotonically increasing counter that simply counts events. Starting from 0 with now upper boundary. To count events, call

{{{
couch_stats_collector:increment({Module, Key}).
}}}

This registers the counter with the collector and increments it each time this line executed. We'll cover what `{Module, Key}` means in a minute.


=== Limit Counter ===

An limit counter is a lot like a hit counter, only that it can go down again. Think number of open databases, or currently running requests. When an event starts, the counter is incremented, when the event is over, decremented.

{{{
couch_stats_collector:increment({Module, Key}).
}}}

{{{
couch_stats_collector:decrement({Module, Key}).
}}}

=== Absolute Value Counter ===

An absolute value counter is not really a counter, it collects absolute values for one second. They are good for collecting information like the amount of time spent in an event or the size of some piece of data.

{{{
couch_stats_collector:record({Module, Key}).
}}}


== Keys ==

To uniquely identify a counter, use a tuple of the form `{Module, Key}`. `Module` should be the name of the module where the event takes place. And `Key` should be the name of the counter and must be unique within a module.

Look at existing counters to get a feel for the naming.


== The Aggregator ==

The aggregator is a second module that queries the collector module at certain intervals to collect current values and calculate aggregates like min, max, mean and stddev values. Hit and limit counters are just queried for their current value. The aggregator calculates the new aggregate values based on the previous values in constant time. Absolute value counters are queried for their current values and then flushed to avoid running out of memory.

The aggregator queries the collector at predefined intervals: Every second, every minute, every five minutes and every fifteen minutes. That way you can quickly see how changes affect CouchDB's performance.
