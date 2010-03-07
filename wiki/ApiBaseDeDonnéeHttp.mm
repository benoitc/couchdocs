#language fr

Une introduction à l'API Base de Données HTTP de CouchDB.

== Nommage et Adressage ==

Le nom d'une base de données doit être composé de caractères minuscules (a-z), chiffres (0-9) ou n'importe lequel de ces caractères ''_$()+-/'' et doit finir avec un '/' dans l'URL. Le nom noit commencer avec des caractères.

{{{
http://couchserver/databasename/
http://couchserver/another/databasename/
http://couchserver/another/database_name(1)/
}}}

''Les caractères en majuscules NE SONT PAS AUTORISÉS dans le nom d'une base de données.''

{{{
http://couchserver/DBNAME/ (invalid)
http://couchserver/DatabaseName/ (invalid)
http://couchserver/databaseName/ (invalid)
}}}

Attention le caractère ''/'' dans le nom d'une base doit être échappé lorsqu'il est utilisé dans une URL, si votre base est nommée ''his/her'' alors elle sera accessible à l'adresse ''http://localhost:5984/his%2Fher''.

''Raisons de ces restrictions''

Les noms de bases de données ont des restrictions strictes afin de simpilfier l'association nom-fichier. Comme les bases de données peuvent être repliquées à travers différents systèmes d'exploitation, la façon de nommer les fichiers doit utiliser le plus petit commun dénominateur. Par exemple, ne pas autoriser les caractères en majuscules les rends compatibles avec les systèmes de fichiers ne respectant pas la casse.


== Liste des bases de données ==

Pour obtenir la liste des bases de données dans un serveur CouchDB utilisez l'URI ''/_all_dbs'' :

{{{
GET /_all_dbs HTTP/1.01
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

Réponse :

{{{
HTTP/1.1 200 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Length: 37
Content-Type: application/json
Connection: close

["somedatabase", "anotherdatabase"]
}}}

== PUT (Créer une nouvelle base de donnée) ==

Pour créer une nouvelle base de donnée, envoyez une requête PUT à l'URL de la base de donnée. Actuellement le contenu de la requête PUT est ignoré par le serveur web.

En cas de succès le code HTTP ''201'' est retourné. Si la base de donnée existe déjà une erreur ''409'' est retournée.

{{{
PUT /somedatabase/ HTTP/1.0
Content-Length: 0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

La réponse du seveur :

{{{
HTTP/1.1 201 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Length: 13
Content-Type: application/json
Connection: close

{"ok": true}
}}}

== DELETE ==

Pour supprimer une base de données, envoyez une requête DELETE sur l'URL de la base de donnée.

En cas de succès un code HTTP ''202'' est retourné. Si la base de données n'existe pas une erreur 404 est renvoyée.

{{{
DELETE /somedatabase/ HTTP/1.0
Content-Length: 1
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}

La réponse du serveur :

{{{
HTTP/1.1 202 OK
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
Content-Length: 67
Content-Type: application/json
Connection: close

{"ok": true}
}}}

== Informations d'une base de données  ==

Pour récuperer les informations d'une base de donnée, envoyer une requête GET sur l'URL de la base de donnée, ex:

{{{
GET /somedatabase/ HTTP/1.0
}}}

La réponse du serveur est un objet JSON similaire à celui-ci :

{{{
{"db_name": "dj", "doc_count":5, "doc_del_count":0, "update_seq":13, "compact_running":false, "disk_size":16845}
}}}

== Compactage ==

Les bases de données peuvent être compactées afin de réduire l'usage disque. Pour plus de détail voir [[Compactage]].
