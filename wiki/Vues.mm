#language fr
Ce doccument est une simple introduction des vues CouchDB.

== Concept ==
Les vues sont l'outil de base pour interroger et reporter des documents CouchDB. Il y a deux types de vues : les vues permanentes et temporaires.

Les '''vues permanentes''' sont stockées au sein de documents spéciaux appelés documents design et sont accessibles via une requête HTTP ''GET'' sur l'URI ''/{dbname}/{docid}/{viewname}'', où ''{docid}'' a le préfixe  ''_view/'' afin que CouchDB le reconnaisse comme un document design.

Les '''vues temporaires''' ne sont pas enregistrées dans la base de données, mais executées à la demande. Pour exécuter une vue temporaire vous envoyez  HTTP ''POST'' à l'URI ''/{dbname}/_temp_view'', où le corps de cette requête contient le code de la vue et l'entête ''Content-Type'' est fixée à ''application/json''.

Pour les deux types de vues, on définit la vue par une fonction !JavaScript qui associe (map) les cles de la vue à leurs valeurs (il est néanmoins possible d'utiliser un autre langage que !JavaScript en utilisant un serveur de vue tiers.).

Attention, par défaut, les vues ne sont pas crées ni mises à jour lorsqu'un document est enregistré mais lorsqu'elles sont appelées. Le premier accès pourra donc prendre quelques temps en fonction de la taille des données, le temps que CouchDB crée la vue. Il est préférable de mettre à jour les vues après qu'un documents soit sauvé en utilisant un script externe appelées lors de la mise à jour des vues. Un exemple peut être touvée ici : RegénérationVuesÀlaMiseAjour.

Notez, que toutes les vues d'un document design sont mises à jour lorsque l'une des vues de celui-ci est appelée.

Attention changement API !JavaScript : Avant le Jeudi 20 mai 2008 (révision subversion r658405) la fonction pour émettre une ligne dans l'index d'associations (map) était nommée "map". Elle a été renommée "emit".

== Bases ==
Voici un simple exemple d'une fonction de vue :

{{{
function(doc) {
  emit(null, doc);
}
}}}
Cette fonction définit une table contenant tous les document dans la base de donnée CouchDB sans clé particulière.

Une fonction vue accepte un seul argument : l'objet document. Pour produire un résultat, elle doit appeler la fonction disponible implicitement  ''emit(key, value)''. À chaque appel de cette fonction, une ligne est ajoutée à la vue (si ni la ''clé''(key) ni la ''valeur''(value) sont indéfinies(undefined)). Quand les documents sont ajoutés, modifiés ou supprimés, les lignes de cette table sont mises à jour automatiquement.

Voici un exemple plus complexe d'une fonction définisant une vue sur les valeurs recupérées dans les documents des clients :

{{{
function(doc) {
  if (doc.Type == "customer") {
    emit(null, {LastName: doc.LastName, FirstName: doc.FirstName, Address: doc.Address});
  }
}
}}}
Pour chaque document de la base de donnée dont le champ Type a la valeur ''customer'', une ligne est crée dans la vue. La colonne ''value ''de la vue contient les champs''!LastName'', ''!FirstName'', and ''Address''  pour chaque document. La clé pour tous les documents est null dans ce cas.

Afin de pouvoir filtrer ou trier les documents par propriété, vous devez utiliser celle-ci pour la clé. Par exemple, la vue suivante va permettre de chercher les documents des clients par les champs ''!LastName'' ou ''!FirstName'' :

{{{
function(doc) {
  if (doc.Type == "customer") {
    emit(doc.LastName, {FirstName: doc.FirstName, Address: doc.Address});
    emit(doc.FirstName, {LastName: doc.LastName, Address: doc.Address});
  }
}
}}}
Le résultat d'une telle vue est le suivant :

{{{
{
   "total_rows":4,
   "offset":0,
   "rows":
   [
     {
       "id":"64ACF01B05F53ACFEC48C062A5D01D89",
       "key":"Katz",
       "value":{"FirstName":"Damien", "Address":"2407 Sawyer drive, Charlotte NC"}
     },
     {
       "id":"64ACF01B05F53ACFEC48C062A5D01D89",
       "key":"Damien",
       "value":{"LastName":"Katz", "Address":"2407 Sawyer drive, Charlotte NC"}
     },
     {
       "id":"5D01D8964ACF01B05F53ACFEC48C062A",
       "key":"Kerr",
       "value":{"FirstName":"Wayne", "Address":"123 Fake st., such and such"}
     },
     {
       "id":"5D01D8964ACF01B05F53ACFEC48C062A",
       "key":"Wayne",
       "value":{"LastName":"Kerr", "Address":"123 Fake st., such and such"}
     },
   ]
}
}}}
''Cet exemple a été reformaté pour le rendre plus lisible.''

== Vues de recherche ==
Le second paramètre d'une fonction ''emit()'' peut être ''NULL''. CouchDB stocke alors seulement les clés dans la vue. Il est aussi possible de retourner l'ID du document à la place de ''NULL'', ce qui permet d'utiliser la vue comme un mécanisme de recherche compact, pour récupérer les détails du document dans d'autres requêtes.

== Clés Complexes ==
Les clés ne sont pas limitées à des valeurs simples. Vous pouvez utiliser n'importe quelle valeur JSON pour influencer le tri. Voir AssemblageVue pour le fonctionnement.

== Les vues en pratique ==
Voir ApiVueHttp pour apprendre comment travailler avec les vues.
