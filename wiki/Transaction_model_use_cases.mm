This page describes use cases that require a transaction model not currently supported by CouchDB: inter-document all-or-nothing transactions with conflict checking.

Please add real world use cases with enough details as to explain why the transactions might be necessary, the consequences of not having it, etc. Then we can examine the use cases and see if the current CouchDB models can work, or if CouchDB is really appropriate, or if we need new transaction models to support the use cases.

== Template ==

Description of a real-world use case of why single-node, inter-document transaction are needed.

'''''Discussion as to how to model the above use case in CouchDB without single-node, inter-document transactions'''''



== DVCS ==

I may as well throw this one out there -- it seems like an obvious use case for a document-oriented db in general and Couch in particular. Given the constant arguments over the available choices there's clearly no _winner_ yet, so what the hell -- why not in Couch? The only way I can imagine an implementation with the current transaction semantics is to keep each branch as a document and drop docs in as attachments, but this is probably less than optimal. Correct me if I'm wrong.

== Update Product and Categories ==

I'm trying to model a simple shopping cart solution on couchdb, just to find out the solutions to the problems that have come to my mind so far. Let's say, I have 2 types of documents, products and categories, where product may belong to multiple categories. I expect product to hold an array of category ids. A simple use case:
 1. user A updates an existing product, and updates a category(-ies), say, increasing product count property
 2. the same category at the same time is being updated by user B, by uploading an updated image to it

'''''You shouldn't have a categories count that gets manually updates. Instead, create a "products by category view" and use a reduction to count the number of each category. -Damien'''''

'''''I do realize that I can rework the model in this specific scenario. Maybe it's a bad example as is... -Andrius'''''

If the operations happen in this exact order (1,2), user B will get a concurrent modification warning, and will have to reapply his changes.

But what if the product gets updated, then the category gets updated with a new image, and then the product count is increased on that category? The last step will fail, and the data in the system will remain in (logically) inconsistent state.

== Simple example involving money ==

documents Account A (1000$), Account B (1000$), with balance property.

2 operations in progress:
 1. Transfer 100$ from A to B
 2. Deposit 50$ to B

What happens:
 1. A-100$, balance = 900$
 2. B+50$, balance = 1050$
 3. B+100$, update fails because B's revision is not the one being expected. Balance A(900), B(1050), 100$ short.

'''''The proper way to do this is treat CouchDB as a ledger, with each line item as a new document. Then to do a transfer a single document that shows the money subtracted from account A and added to account B. To get the balance of an account, create a view of transactions by account and use a reduction to add up all the transactions for each account.'''''

== Harder example involving money ==

Documents store a transaction log -- from account, recipient account and amount transfered. A view exists to give a balance for each account. At all times, every accounts' balance should be greater-or-equal to zero. Balance of account A is $100. Two transactions proposed, "Transfer $80 from A to B", and "Transfer $60 from
A to C":

 1. Check Balance of A >= $80 (query view)
 2. Check Balance of A >= $60 (query view)
 3. Transfer $80 from A to B (add new document)
 4. Transfer $60 from A to C (add new document)
 5. Check Balance of A --> -$40 (query view)

No explicit conflicts even appear in this case to alert you to the problem...

I guess writing the transfer function as:

 1. Tentatively transfer AMOUNT from ACCOUNT to DESTINATION (add new document, marked tentative)
 2. Wait for document to have been replicated to all other hosts
 3. Determine balance of ACCOUNT (query view)
 4. If balance >= 0: remove tentative mark from transaction
 5. Otherwise: delete transaction

might be feasible, but getting the right semantics for the second step seems hard.

== Users, groups and relationships ==

Documents: User, Group;
User has a list of group id's he belongs to. 

1. A group X that is being referenced from multiple users is being deleted. (expected behavior - all users referencing the group X are found, group reference is removed, user is saved into database; when done, group X is deleted)
2. A user that already references group X, is assigned to a new group, Y. 

if 2) happens somewhere in the middle of 1), results will be inconsistent, 
 * that user will still contain a reference to the deleted group if we ignore this error
 * a few users will be removed from the group, and some won't, if we break the operation when the concurrent modification exception occurs. 

'''''Store the users name in the group document, not the other way around.'''''

Alternative use case: user is being deleted. References need to be removed from multiple groups. Database dies in the middle because of the power outage?

'''''Put the user into an "about to delete" state. Then remove the user from all groups, then completely delete the user. To deal with failures in the process, periodically search for users in the "about to delete" state and remove them from all groups, then delete the user. This is how Lotus Notes handles it.'''''


== User content publishing system ==

There's a MMO community portal, where users are able to publish their own content. The content is moderated. The users might get one of a few bonuses for publishing good articles, i.e., 30 pieces of virtual silver. Articles might be pretty big (with attachments and such), so you can't embed them directly into the user document. The user has a log of transactions, that specify what bonuses and when he received, with reference to the article id. Transaction log can't be moved to the article document either, because it may contain any type of micro-payments to and by the user. 

 1. User writes an article, and submits it; 
 2. Moderator approves it; user receives a bonus. 

At least 2 documents are updated: user gets a piece of gold, and the article status is updated to 'available to all'. A parallel update on user object, say a password change, or database crash, leaves the db state inconsistent, with the user missing out on his payment. 

Alternative use case:
Each user has to be invited by someone to be able to register. Hence, all users participate in a 2nd-tier bonus program, and they also get an additional 10% (3 pieces of silver) for the content their invitee generated. This needs to be reflected in their transaction log. Once again, database crash or any concurrent access violation screws up the whole math. 
