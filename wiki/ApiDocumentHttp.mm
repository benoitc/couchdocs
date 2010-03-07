#language fr

Une introduction à l'api Document HTTP.

== Nommage/Addressage ==

Les documents stockés dans CouchDB ont une DocID. Les DocIDs sont des identifiants uniques sous formes de chaines de caractères sensibles à la casse qui identifient un document. Deux documents ne peuvent avoir le même identifiant dans une même base de données. 

{{{
http://localhost:5984/test/some_doc_id
http://localhost:5984/test/another_doc_id
http://localhost:5984/test/BA1F48C5418E4E68E5183D5BD1F06476
}}}

Les URL ci_dessus pointent vers ''some_doc_id'', ''another_doc_id'' and ''BA1F48C5418E4E68E5183D5B!D1F06476'' dans la base ''test''.

=== Id Document valide ===

  Q: Quelle est la règle pour une id document valide ? L'exemple suggère-t-il que cela soit restreint à ''[a-zA-Z0-9_]'' ? Quid des caractères UTF8 multi-octets ? Des caractères non alphanumériques tel que ''_'' ?

  R: Il n'y a pour l'instant pas de restriction sur les ids de documents au niveau base de donnée. Cependant je n'ai pas testé ce qui arrive quand on utilise des caractères multi-octets dans l'URL. Cela peut fonctionner, mais plus probablement il sera nécessaire de coder ou échapper les caractères quelques part. Pour l'instant je me cantonne aux caractères valides dans une URI et rien de "spécial".

  Les noms de bases de données ont des restrictions strictes afin de simpilfier l'association nom-fichier. Comme les bases de données peuvent être repliquées à travers différents systèmes d'exploitation, la façon de nommer les fichiers doit utiliser le plus petit commun dénominateur.

== JSON ==

Un document CouchDB est un simple objet JSON. (Accompagnées des informations de révision si ''?full=true'' dans les arguments de l'URL.

Voici un exemple de document :

{{{
{
 "_id":"discussion_tables",
 "_rev":"D1C946B7",
 "Subject":"I like Planktion",
 "Author":"Rusty",
 "PostedDate":"2006-08-15T17:30:12-04:00",
 "Tags":["plankton", "baseball", "decisions"],
 "Body":"I decided today that I don't like baseball. I like plankton."
}
}}}

Un document peut être n'importe quel objet JSON, mais les champs de premier niveau ayant un nom commençant par ''_'' sont réservés à CouchDB. Les exemples évidents sont les champs ''_id'' et ''_rev'', comme on l'a vu ci-dessus.

Autre exemmple :

{{{
{
 "_id":"discussion_tables",
 "_rev":"D1C946B7",
 "Subrise":true,
 "Sunset":false,
 "FullHours":[1,2,3,4,5,6,7,8,9,10],
 "Activities": [
   {"Name":"Football", "Duration":2, "DurationUnit":"Hours"},
   {"Name":"Breakfast", "Duration":40, "DurationUnit":"Minutes", "Attendees":["Jan", "Damien", "Laura", "Gwendolyn", "Roseanna"]}
 ]
}
}}}

Attention, par défaut la structure est à plat; dans ce cas l'attribut ''Activities'' est une structure donnée par l'utilisateur.

== Tous les documents  ==

Pour obtenir une liste de tous les documents dans la base utilisez l'URI spéciale ''_all_docs'' :

{{{
GET somedatabase/_all_docs HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Qui retourne une liste de tous les documents avec leurs ids révisons, trié par DocId (sensible à la casse) :


{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{
  "total_rows": 3, "offset": 0, "rows": [
    {"id": "doc1", "key": "doc1", "value": {"_rev": "4324BB"}},
    {"id": "doc2", "key": "doc2", "value": {"_rev":"2441HF"}},
    {"id": "doc3", "key": "doc3", "value": {"_rev":"74EC24"}}
  ]
}
}}}

Utilisez l'argument ''descending=true'' pour inverser l'ordre dans cette table :

Ce qui retourne la même chose que ci-dessus mais dans l'ordre inverse :

{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{
  "total_rows": 3, "offset": 0, "rows": [
    {"id": "doc3", "key": "doc3", "value": {"_rev":"74EC24"}}
    {"id": "doc2", "key": "doc2", "value": {"_rev":"2441HF"}},
    {"id": "doc1", "key": "doc1", "value": {"_rev": "4324BB"}},
  ]
}
}}}

Les options ''startkey'' et ''count'' peuvent en outre être utilisées pour limiter le nombre de résultats obtenus :

{{{
GET somedatabase/_all_docs?startkey=doc2&count=2 HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Qui retourne :

{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{
  "total_rows": 3, "offset": 1, "rows": [
    {"id": "doc2", "key": "doc2", "value": {"_rev":"2441HF"}},
    {"id": "doc3", "key": "doc3", "value": {"_rev":"74EC24"}}
  ]
}
}}}

Combiné avec ''descending'' :

{{{
GET somedatabase/_all_docs?startkey=doc2&count=2&descending=true HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Retourne :

{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{
  "total_rows": 3, "offset": 1, "rows": [
    {"id": "doc3", "key": "doc3", "value": {"_rev":"74EC24"}}
    {"id": "doc2", "key": "doc2", "value": {"_rev":"2441HF"}},
  ]
}
}}}

== Travailler sur les documents en HTTP ==

=== GET ===

Pour récupérer un document, envoyez simplement un ''GET'' sur l'URL du document :

{{{
GET /somedatabase/some_doc_id HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Voici la réponse du serveur :

{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{
 "_id":"123BAC",
 "_rev":"946B7D1C",
 "Subject":"I like Planktion",
 "Author":"Rusty",
 "PostedDate":"2006-08-15T17:30:12Z-04:00",
 "Tags":["plankton", "baseball", "decisions"],
 "Body":"I decided today that I don't like baseball. I like plankton."
}
}}}

=== Accéder aux révisions précedentes ===

Voir [[RevisionsDeDocuments]] pour plus d'information sur les révisions.

L'exemple ci-dessus récupère la révisions en cours. Vous pouvez récupérer une révision particulière avec la syntaxe suivante :

{{{
GET /somedatabase/some_doc_id?rev=946B7D1C HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Pour obtenir la liste des révisions disponibles d'un document, vous pouvez faire :

{{{
GET /somedatabase/some_doc_id?revs=true HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Cela retourne la dernière révisions du document mais avec le champ ''_revs'', la valeur devient une liste de toutes les IDs révison disponibles. Attention toutes les révisons ne sont pas forcemment encore stockées sur le disque. Par exemple, une ancienne révision a pu être supprimée lors du compactage de la base, ou peu exister seulement dans une base différente si celle-ci a été répliquée.

Pour obtenir plus d'informations sur les révisiosn d'un document disponibles, utilisez le paramètre ''revs_info'' à la place. Dans ce cas le résultat JSON contiendra une propriété ''revs_info'' qui est un tableau d'objets :

{{{
{
  "_revs_info": [
    {"rev": "123456", "status": "disk"},
    {"rev": "234567", "status": "missing"},
    {"rev": "345678", "status": "deleted"},
  ]
}
}}}

Ici ''disk'' signifie que la révision est enregistrée sur le disque et peut encore être recupérée. Les autres valeurs indiquent que le contenu de la révision n'est plus disponible.

=== PUT ===

Pour créer un nouveau document vous pouvez soit envoyer une requête ''POST'', soit une requête ''PUT''. Pour créer/mettre à jour un document nommé, uttilisez PUT, l'URL doit pointer ver l'emplacement du document. 

L'exemple suivant est une requête HTTP ''PUT''. CouchDB va créer une nouvelle ID révision et sauver le document avec.

{{{
PUT /somedatabase/some_doc_id HTTP/1.0
Content-Length: 245
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json

{
  "Subject":"I like Planktion",
  "Author":"Rusty",
  "PostedDate":"2006-08-15T17:30:12-04:00",
  "Tags":["plankton", "baseball", "decisions"],
  "Body":"I decided today that I don't like baseball. I like plankton."
}
}}}

Voici la réponse du serveur.

{{{
HTTP/1.1 201 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{"ok": true, "id": "some_doc_id", "rev": "946B7D1C"}
}}}

Pour mettre à jour un document existant, vous pouvez aussi envoyer une requête ''PUT''. Dans ce cas l'objet JSON doit contenir une propriété ''_rev'' qui permet à CouchDB de connaître sur quelle révison la modification est basée. Si la dernière révison du document qui est stockée, ne correspond pas, une erreur de conflit ''409'' est renvoyée.

Si le numéro de révision correspond à ce qui est dans la base, un nouveau numéro de révision est généré et renvoyé au client.

Par exemple :

{{{
PUT /somedatabase/some_doc_id HTTP/1.0
Content-Length: 245
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json

{
  "_id":"some_doc_id",
  "_rev":"946B7D1C",
  "Subject":"I like Planktion",
  "Author":"Rusty",
  "PostedDate":"2006-08-15T17:30:12-04:00",
  "Tags":["plankton", "baseball", "decisions"],
  "Body":"I decided today that I don't like baseball. I like plankton."
}
}}}

Ici la réponse du serveur si la révision courante du document ''some_doc_id'' enregistrée dans la base est ''946B7D1C''.

{{{
HTTP/1.1 201 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{"ok":true, "id":"some_doc_id", "rev":"946B7D1C"}
}}}

Ici la réponse du serveur, si la mise à jour crée un conflit (si la révision courante du document ''some_doc_id'' stockée dans la base est ''946B7D1C'').


{{{
HTTP/1.1 409 CONFLICT
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Length: 33
Connection: close

{"error":{"id":"conflict","reason":"3073715634"}}
}}}

=== POST ===

La requête ''POST'' peut être utilisée pour créer un document dont l'ID est génerée par le serveur. Pour créer un document nommé, utilisez à la place la méthode ''PUT''.

L'exemple suivant est une requête ''POST''. Le serveur COUCHDB va générer un nouveau DocID et une ID révision et enregistrer le document avec.

{{{
POST /somedatabase/ HTTP/1.0
Content-Length: 245
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json

{
  "Subject":"I like Planktion",
  "Author":"Rusty",
  "PostedDate":"2006-08-15T17:30:12-04:00",
  "Tags":["plankton", "baseball", "decisions"],
  "Body":"I decided today that I don't like baseball. I like plankton."
}
}}}

La réponse du serveur :

{{{
HTTP/1.1 201 Created
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{"ok":true, "id":"123BAC", "rev":"946B7D1C"}
}}}

=== Modifiez plusieurs documents en une seule requête ===

CouchDB propose une fonctionnalité d'insertion/mise à jour en masse. Pour l'utilisez envoyez une requete ''POST'' à l'URI ''/{dbname}/_bulk_docs'', avec un document JSON contenant la liste de tous les documents à insérer ou mettre à jour. Le format actuel de la requête et de la réponse diffèrent entre CouchdDB 0.7.2 et 0.8.9-incubating (ou le trunk).

'''CouchDB 0.7.2''':

{{{
[
  {"_id": "0", "integer": 0, "string": "0"},
  {"_id": "1", "integer": 1, "string": "1"},
  {"_id": "2", "integer": 2, "string": "2"}
]
}}}

'''CouchDB 0.8.0-incubation (et trunk)''':

{{{
{
  "docs": [
    {"_id": "0", "integer": 0, "string": "0"},
    {"_id": "1", "integer": 1, "string": "1"},
    {"_id": "2", "integer": 2, "string": "2"}
  ]
}
}}}

Si vous omettez le paramètre ''_id'', CouchdBD va génerer des IDs uniques pour vous comme il le fait pour une simple requête''POST'' sur l'URI de la base.

La réponse pour une telle requête de masse:

'''CouchDB 0.7.2''':

{{{
{
  "ok":true,
  "results": [
    {"ok": true, "id": "0", "rev": "3682408536"},
    {"ok": true, "id": "1", "rev": "3206753266"},
    {"ok": true, "id": "2", "rev": "426742535"}
  ]
}
}}}

'''CouchDB 0.8.0-incubating (et trunk)''':

{{{
{
  "ok":true,
  "new_revs": [
    {"id": "0", "rev": "3682408536"},
    {"id": "1", "rev": "3206753266"},
    {"id": "2", "rev": "426742535"}
  ]
}
}}}

La mise à jour de documents existants requière le membre ''_rev'' de la révison à mettre à jour. Pour effacer un document mettez ''_deleted'' à true. '''CouchDB 0.8.0-incubating (ou trunk)''':

{{{
{
  "docs": [
    {"_id": "0", "_rev": "3682408536", _deleted=true},
    {"_id": "1", "_rev": "3206753266", "integer": 2, "string": "2"},
    {"_id": "2", "_rev": "426742535", "integer": 3, "string": "3"}
  ]
}
}}}

Attention, CouchDB retourne une réponse avec l'id et la révision de chaque document passé dans l'insertion/mise à jour en masse, même si ceux-ci viennent d'être supprimés.

=== DELETE ===

Pour supprimer un document, envoyez une requête ''DELETE'' sur l'URL du document avec le paramètre ''rev'' de la révison courante du document. Si celle-ci réussit, l'ID de la révison correspondant à la suppression est renvoyée.


{{{
DELETE /somedatabase/some_doc?rev=1582603387 HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Réponse:

{{{
HTTP/1.1 202 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Type: application/json
Connection: close

{"ok":true,"rev":"2839830636"}
}}}

== Attachements ==

Les documents peuvent avoir des attachements comme les emails. À la création, les attachements vont dans un attribut du document spécial ''_attachments''. Ils correspondent à une structure JSON qui contient le nom, le content_type et la donnée codée en base64 de l'attachement. Un document peut avoir n'importe quel nombre d'attachements.

Lorsque vous récupérez les documents, seles les métadonnées de l'attachement sont incluses, pas le contenu. Il doit être téléchargé à part en utilisant une URI spéciale.

Création d'un document avec un attachement :

{{{
{
  "_id":"attachment_doc",
  "_attachments":
  {
    "foo.txt":
    {
      "content_type":"text\/plain",
      "data": "VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ="
    }
  }
}
}}}

Attention les données base64 envoyées doivent être sur ''une seule ligne'', donc préparez vos données en supprimant tous retours à la ligne et nouvelles lignes.

Récupérer le document :

{{{
GET /database/attachment_doc
}}}

CouchDB répond:

{{{
{
  "_id":"attachment_doc",
  "_rev":1589456116,
  "_attachments":
  {
    "foo.txt":
    {
      "stub":true,
      "content_type":"text\/plain",
      "length":29
    }
  }
}
}}}

Notez l'attribut ''"stub":true'' qqui montre que ce n'est pas un attachement complet. Notez aussi la taille de l'atttribut ajoutée automatiquement.

Récupérez l'attachement :

{{{
GET /database/attachment_doc/foo.txt
}}}

CouchDB retoune

{{{
This is a base64 encoded text
}}}

Automatiquement décodé!

=== Plusieurs Attachments ===
Créer un document avec un attachement:

{{{
{
  "_id":"attachment_doc",
  "_attachments":
  {
    "foo.txt":
    {
      "content_type":"text\/plain",
      "data": "VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ="
    },

   "bar.txt":
    {
      "content_type":"text\/plain",
      "data": "VGhpcyBpcyBhIGJhc2U2NCBlbmNvZGVkIHRleHQ="
    }
  }
}
}}}

== ETags/Cache ==

CouchDB envoie un entête ''ETag'' à chaque requête de document. L'entête Etag est simplement une révison de document.

Par exemple pour une requête ''GET'':

{{{
GET /database/123182719287
}}}

Résultat en réponse contenant les headers suivants :

{{{
cache-control: no-cache,
pragma: no-cache
expires: Tue, 13 Nov 2007 23:09:50 GMT
transfer-encoding: chunked
content-type: text/plain;charset=utf-8
etag: "615790463"
}}}

les requêtes ''POST'' retournent aussi un entête ''ETag'' pour les nouveaux documents crées ou les mises à jour de documents.
