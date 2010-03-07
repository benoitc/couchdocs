== Adding Client-Side Security with a Translucent Database ==

Many applications do not require a thick layer of security at the server. It is possible to use a modest amount of encryption and one-way functions to obscure the sensitive columns or key-value pairs, a technique often called a ''translucent database''. (See [[http://www.wayner.org/node/52|description]].)

The simplest solutions use one-way function like SHA-256 at the client to scramble the name and password before storing the information. Here's a quick example of what a table of store purchases might look like ''before'' the data is scrambled:

==== Before Translucency ====

||''name''||''password''||''product name''||''purchase date''||''size 1''||''size 2''||
||Bob Jones||Swordfish||Brawny Pants||Jan 24 2009||32||34||
||Bob Jones||Swordfish||Dancing Pants||Jan 24 2009||32||34||
||Mary Smith||plastics||Broadway Hat||Jan 24 2009||10||-||
||Mary Smith||plastics||Shopping Pants||Jan 25 2009||26||28||
||Constance Dalmation||greeny||Shopping Pants||Jan 26 2009||25||27||

==== After Translucency ====


||''SHA256(name&password)''||''product name''||''purchase date''||''size 1''||''size 2''||
||a67373bc873aacd99392||Brawny Pants||Jan 24 2009||32||34||
||a67373bc873aacd99392||Dancing Pants||Jan 24 2009||32||34||
||3c939a9d9939de993993||Broadway Hat||Jan 24 2009||10||-||
||3c939a9d9939de993993||Shopping Pants||Jan 25 2009||26||28||
||99929d99c9a999a9dd8d||Shopping Pants||Jan 26 2009||25||27||


This solution gives the client control of the data in the database without requiring a thick layer on the database to test each transaction. Some advantages are:

 * Only the client or someone with the knowledge of the name and password can compute the value of SHA256 and recover the data.
 * Some columns are still left in the clear, an advantage if the marketing department wants to compute aggregated statistics.
 * Computation of SHA256 is left to the client side computer which usually has cycles to spare.
 * The system prevents server-side snooping by insiders and any attacker who might penetrate the OS or any of the tools running upon it.

There are limitations:

 * There is no root password. If the person forgets their name and password, their access is gone forever. This limits its use to databases that can continue by issuing a new user name and password.

There are many variations on the theme detailed in the book [[http://www.wayner.org/node/46|''Translucent Databases'']] including:

 * Adding a backdoor with public-key cryptography.
 * Adding a second layer with steganography.
 * Dealing with typographical errors.
 * Mixing encryption with one-way functions.

Here are several case studies:

 * [[http://www.wayner.org/node/46|''Libraries'']]
 * [[http://www.wayner.org/node/21|''Department Stores'']]

=== Client-Side Libraries ===

Here are some Javascript libraries for implementing client-side security:

 * [[http://www.dojotoolkit.org/book/dojo-book-0-9/part-5-dojox/dojox-cryptography|DojoX Crypto]] A nice package, but the MD5 function should only be used in cases when not very much security is required. A number of successful attacks are well-known.

 * [[http://www.webtoolkit.info/javascript-sha256.html|Webtoolkit]] An implementation of SHA256.
