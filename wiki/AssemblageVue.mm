## page was renamed from VueCollection
#language fr

Une simple introduction sur la l'assemblage de vue (view collation).

== Bases ==

Les fonctions vues définissent une clé et une valeur retournée à chaque ligne. CouchDB assemble les lignes de la vues par clé. Dans l'exemple suivant, la propriété  !LastName sert de clé, le résultat est alors trié par !LastName :

{{{
function(doc) {
  if (doc.Type == "customer") {
    emit(doc.LastName, {FirstName: doc.FirstName, Address: doc.Address});
  }
}
}}}

CouchDB autorise n'importe quelle structure JSON comme clé. Vous pouvez utiliser des clés complexe pour affiner le tri et le groupement.

== Exemples ==
Le truc suivant retourne à la fois les documents customer(client) et order(commande). La clé est composée de l' ''_id'' custommer et une valeur de classement. Parce que la clé des documents order commence avec l' ''_id'' d'un document customer, tous les orders(commandes) seront triés par customer(client). Parce que la valeur de classement des clients(custommers) est inférieure à celle des orders(commandes) , le document custommer(client) sera avant les orders(commandes) associées. Les valeurs ''0'' et ''1'' pour le classement sont arbitraires.


{{{
function(doc) {
  if (doc.Type == "customer") {
    emit([doc._id, 0], doc);
  } else if (doc.Type == "order") {
    emit([doc.customer_id, 1], doc);
  }
}
}}}

Ce truc a été [[http://www.cmlenz.net/blog/2007/10/couchdb-joins.html|documenté précedemment]] par Christopher Lenz.

== Spécification Assemblage ==

Cette section repose sur la fonction ''view_collation'' dans ''couch_tests.js'':

{{{
// valeurs spéciales triées avant les autres types
null
false
true

// ensuite les nombres
1
2
3.0
4

// puis le texte, sensible à la casse
"a"
"A"
"aa"
"b"
"B"
"ba"
"bb"

// ensuite les tableaux, compare éléments par élements tant que différentt
// tableaux sont triés par tailles ensuite.
["b"]
["b","c"]
["b","c", "a"]
["b","d"]
["b","d", "e"]

// Ensuite les objets. compare chaque couple clé valeur dans la liste tant que différent
// les objets sont triés par tailles ensuite.
{a:1}
{a:2}
{b:1}
{b:2}
{b:2, a:1} // L'odre des membres est pris en compte lors de l'assemblage.
           // CouchDB préserve l'ordre des membres
           // mais ne requiert pas que le client le doive.
           // ce test peut échouer si utilisé avec un moteur js
           //qui ne préserve pas l'ordre
{b:2, c:2}
}}}
