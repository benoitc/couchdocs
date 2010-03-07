This page is for documenting and discussing the proposed database partitioning support in CouchDB. Most of the features described here don't exist yet. If you'd like to help with implementation please bring it up on the dev@ mailing list.

== High-Level Design Goals ==
 * Increase total write throughput by allowing a database to scale across multiple physical machines
 * Increase total read throughput for multiple concurrent clients when fetching documents by id
 * Increase total storage capacity by spreading the storage across multiple machines
 * Make the partitioned database appear as a single database via the HTTP API, keeping compatibility with existing client implementations
 * Allow the partition topology to be configurable to support different performance needs

== Scenarios/Use Cases ==
Here are the initial use cases we want to support, and then subsequent use cases we want to target.

I am using the "CouchDB system" to describe the overall server system, as this may involve both a server and some kind of proxy that knows how to route requests to the proper node, plus any other moving parts that may need to be introduced (hopefully not too many).

=== Initial Use Cases ===
 * A user finds that a single machine is not big enough to hold all of their data or does not give them the performance they need, and wants to split the database across two or more machines.  '''While the system is still running''', the user configures the CouchDB system to specify the machines to be used, and the CouchDB system automatically splits the data across the new nodes.  All client requests to the server continue to work as before.  

 * A user finds that the current cluster configuration is not sufficient and wants to grow the cluster.  '''While the system is still running''', the user reconfigures the CouchDB system to include more machines, and the CouchDB system automatically repartitions the data as needed while continuing to service incoming client requests.

=== Later Use Cases ===

 * A node in the cluster goes down (either by accident or for planned maintenance), but the CouchDB system (and all data it serves) continues to be available.

 * A node comes back up, and the CouchDB system automatically brings that node back into the cluster.

 * A user wants to upgrade their CouchDB system without having to bring the system down.  The user follows a reasonably easy procedure to upgrade each node in the cluster, and the system continues servicing requests.

 * A user decides to reduce the size of the cluster.  The user reconfigures the system, and the system automatically repartitions the data to the smaller cluster while continuing to service requests.

 * The CouchDB system is running out of space or other resources.  The system warns the user that space is becoming scarce

 * If a CouchDB system is running out of a resource, it degrades gracefully rather than failing suddenly or catastrophically

== Initial Implementation Thoughts ==

=== Avoid JSON Overhead ===
Partition nodes should communicate via native Erlang terms instead of doing Erlang -> JSON -> Erlang conversion. This implies an Erlang API for interacting with Couch which doesn't officially exist yet.

=== Take Advantage of Erlang's Distributed Features ===
Erlang has some great tools for inter-node communication and process management; we should strive to utilize these over rolling our own node communication.

=== Tree Partition Topology ===
Support a tree partition topology that can be as shallow or deep as the user needs. It should be possible to have a flat tree with only one root and many leaf nodes, a binary tree structure, or any variant in-between.

=== Consistent Hashing Algorithm ===
The mapping of IDs to nodes should use a [[http://www.spiteful.com/2008/03/17/programmers-toolbox-part-3-consistent-hashing/|Consistent Hashing Algorithm]]. What hasn't been decided on fully (I don't think) is if a proxy node just maps IDs to its direct children or if a proxy node knows how to map IDs directly to a leaf node all the way down the tree. With this type of hashing algorithm, adding or removing a storage node just requires moving data around on its neighbors and not the entire system. Also, node failover (which is out of the scope of this document) becomes easier since you know exactly what data needs to be replicated to which servers to maintain a redundant copy of each node and the failed node's load gets spread among the remaining servers instead of just one.

=== Proxy and Storage Nodes ===
Allow a node to be a proxy node, a storage node, or both. Storage nodes contain the data and would typically be the leaf nodes of a tree. Proxy nodes combine results from multiple storage nodes before passing them up the tree (or back to the client). The distinction is entirely in configuration and only exists to simplify the mental model. If a node's ID hash points all requests to other nodes, that node is a proxy node. If a node's ID hash points all requests to itself, it is a storage node. If a node's ID hash points some requests to other nodes and some requests to itself, it is both.
