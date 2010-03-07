#language fr
Ce document est une introduction sur l'API de vue HTTP de CouchDB.

== Bases ==
Les vues sont l'outil de base pour interroger et reporter des documents CouchDB.

Les vues sont définies avec des fonctions Javascript. Voici une fonction très simple, qui retourne l'ensemble des documents :

{{{
function(doc) {
  emit(null, doc);
}
}}}
Voir [[Vues]] pour plus d'informations.

== Créer des vues ==
Pour créer une vue permanente, les fonctions doivent d'abord être sauvées dans des documents spéciaux appelés ''documents design''. L'ID de ces documents doit commmencer par ''_design/'' et ces documents doivent avoir des attributs spécifiques contenant un membre ''map'' et optionnellement un membre ''reduce'' pour contenir les fonctions de vues. Toutes les vues dans un document design sont indexées à chaque fois qu'elles sont interrogées.

Un document design qui définit les vues ''all'', ''by_lastname'', et ''total_purchases'' peut ressembler à cela:

{{{
{
  "_id":"_design/company",
  "_rev":"12345",
  "language": "javascript",
  "views":
  {
    "all": {
      "map": "function(doc) { if (doc.Type == 'customer')  emit(null, doc) }"
    },
    "by_lastname": {
      "map": "function(doc) { if (doc.Type == 'customer')  emit(doc.LastName, doc) }"
    },
    "total_purchases": {
      "map": "function(doc) { if (doc.Type == 'purchase')  emit(doc.Customer, doc.Amount) }",
      "reduce": "function(keys, values) { return sum(values) }"
    }
  }
}
}}}
La propriété ''language'' indique à CouchDB le langage des fonctions de vue, ce qui est utilisé pour sélectionnner le ServeurDeVue approprié (définit dans le fichier ''couch.ini''). Par défaut CouchDB utilise Javascript, et cette propriété peut donc être omise pour les vues Javascript.

== Modifier/Changer les Vues ==
Pour changer une vue ou plusieurs vues, modifiez juste le document (voir ApiDocumentHttp) où elles sont stockées et enregistrez une nouvelle révision.

== Accéder/Interroger ==
Une fois que le document définissant les vues enregistré dans la base, la vue ''all'' peut être récupérée via l'URL :

 . http://localhost:5984/ma_bd/_view/company/all

Exemple :

{{{
GET /ma_bd/_view/company/all HTTP/1.0
Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
}}}
Ce qui entraine la réponse suivant :

{{{
 HTTP/1.1 200 OK
 Date: Thu, 17 Aug 2006 05:39:28 +0000GMT
 Content-Length: 318
 Connection: close

 {
    "total_rows": 3,
    "offset": 0,
    "rows": [{
        "id":"64ACF01B05F53ACFEC48C062A5D01D89",
        "key": null,
        "value": {
          "LastName":"Katz",
          "FirstName":"Damien",
          "Address":"2407 Sawyer drive, Charlotte NC",
          "Phone":012555754211
        }
      }, {
        "id":"5D01D8964ACF01B05F53ACFEC48C062A",
        "key": null,
        "value": {
          "LastName":"Kerr",
          "FirstName":"Wayne",
          "Address":"123 Fake st., such and such",
          "Phone":88721320939
        }
      }, {
        "id":"EC48C062A5D01D8964ACF01B05F53ACF",
        "key": null,
        "value":
        {
          "LastName":"McCracken",
          "FirstName":"Phil",
          "Address":"1234 Fake st., such and such",
          "Phone":7766552342
        }
      }
    ]
 }
}}}
== Vues Ad Hoc ==
Les requêtes temporaires (ex. les vues que vous ne souhaitez pas enregistrer dans CouchDB) peuvent être réalisées à travers la vue spéciale ''_temp_view'' :

{{{
POST /some_database/_temp_view  HTTP/1.0
Content-Length: 48
Date: Mon, 10 Sep 2007 17:11:10 +0200
Content-Type: application/json

{
  "map" : "function(doc) { if (doc.foo=='bar') { emit(null, doc.foo); } }"
}
}}}
Pouvant entraîner la réponse suivante :

{{{
{
  "total_rows": 1,
  "offset": 0,
  "rows": [{
      "id": "AE1AD84316B903AD46EF396CAFE8E50F",
      "key": null,
      "foo": "bar"
    }
  ]
}
}}}
== Options de requêtes ==
Les colonnes peuvent être une suite de valeur, il n'y a pas de limites au nombre de valeurs ou sur le volume des données que peuvent contenir les colonnes.

Les options suivantes peuvent être passées à l'URL de la requête :

 * key=valeurdeclé
 * startkey=valeurdeclé
 * startkey_docid=docid
 * endkey=valeurdeclé
 * count=nombre de lignes maximum à retourner
 * update=false
 * descending=true
 * skip=lignes à passer

''key'', ''startkey'', et ''endkey''  doivent être des valeurs codées en JSON (par exemple, startkey="chaine" pour une valeur de chaine(string)).

Si vous spécifiez ''?count=0'', vous ne récupererez pas les données mais les métadonnées de cette vue. Le nombre de documents dans cette vue par exemple. Si ''count'' est renseigné avec une valeur négative, vous recevrez autant de documents avant ''startkey''.

le paramètre ''skip'' devrait être seulement utilisé pour un petit nombre de valeurs, passer un grand nombre de documents de cette façon n'est pas efficace (couchdb parcourt alors l'index à partir de startkey, passe les N premiers documents mais nécessite quand même de lire tout l'index pour le faire). Pour une pagination efficace, utilisez ''startkey'' et/ou ''startkey_docid''.

L'option ''update'', positionée à ''false'', permet de ne pas récupérer les dernieres modifications de la vue. Cela peut être utilisée pour accroître les performances.

Les lignes de la vue sont triées par clé. Spécifier ''descending=true'' inversera l'ordre. L'option ''descending'' est appliquée '''avant''' tout filtrage des clés, il est donc parfois necessaire de modifier les valeurs des options ''startkey'' et ''endkey'' pour récupérer le résultat attendu. Pour plus d'information sur le tri, reportez vous à la page AssemblageVue.

== Traquer un problème dans les vues ==
Lors de la création des vues, CouchDB vérifie la syntaxe JSON, mais la syntaxe des fonctions de vue en elle même n'est pas vérifiée par l'interpréteur Javascript. Si l'une des vues possède des erreurs de syntaxes, aucune des autres fonctions dans le document design ne sera exécutée. Il est par contre possible de tester vos fonctions dans une vue temporaire avant de les sauver dans la base.

Depuis la révision r660140, une fonction ''log'' est disponible dans les vues, qui enregistre dans couch.log. Cela peut être utile pendant la résolution de problèmes mais peut coûter en performances. C'est donc à utiliser avec parcimonie sur un système en production.

{{{
{
  "map": "function(doc) { log(doc); }"
}
}}}
