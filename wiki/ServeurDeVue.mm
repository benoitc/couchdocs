#language fr
Ce document constitue une simple introduction aux serveurs de vues de CouchDB.

== Le serveur de vue ==
CouchDB délègue le calcul des [[Vues]] à des serveurs de requêtes externes. Il communique avec eux à travers l'entrée/sortie standard via un ensemble de lignes. Le serveur de requêtes par défaut est en en Javascript, fonctionnant avec Mozilla !SpiderMonkey. Il est possible d'utiliser d'autres languages en modifiant la propriété ''language'' dans le fichier ''couch.ini''. Si la propriété ''language'' n'est pas renseignée, Javascript est utilisé par défaut.

Pour enregistrer un serveur de requête auprès de CouchDB, il faut ajouter une ligne pour chaque serveur dans ''couch.ini''. La syntaxe est :

{{{
[Couch Query Servers]

javascript=/usr/local/bin/couchjs -f /usr/local/share/couchdb/server/main.js
ruby=/wherever/couchobject/bin/couch_ruby_view_requestor
}}}
== API ==
Ce document explique comment doit se comporter un serveur de vues. En cas de doute, référez vous au fichier ''share/server/main.js'' que vous pouvez trouver dans les sources de CouchDB.

CouchDB lance le serveur de vue et lui envoie des commandes. Le serveur lui répond en fonction de son évaluation de la commande. Il ya seulement 3 commandes que le serveur de vue a besoin de comprendre.

=== reset (réinitialisation) ===
Elle réinitialise le serveur de vue et lui fait supprimer toutes les entrées précedentes. Le cas échéant, le ramasse-miette (garbage collector) peut être lançé.

CouchDB envoie :

{{{
["reset"]\n
}}}
Le serveur de vue répond :

{{{
true\n
}}}
=== add_fun (ajout d'une fonction) ===
Lors de la création d'une vue, le serveur de vue reçoit la fonction de vue à évaluer. Le serveur de vue doit alors analyser/compiler/évaluer (selon le langage) la fonction qu'il reçoit et la rendre appelable depuis CouchDB. Si cela échoue, le serveur de vue retourne une erreur. CouchDB peut parfois stocker plusieurs fonctions avant d'envoyer des documents.

CouchDB envoie :

{{{
["add_fun", "function(doc) { map(null, doc); }"]\n
}}}
lorsque le serveur de vues peut évaluer la fonction et la rendre appelable, il retourne :

{{{
true\n
}}}
Sinon, un message d'erreur :

{{{
{"error": "some_error_code", "reason": "error message"}\n
}}}
=== map_doc (association) ===
Lorsque la fonction est enregistrée dans le serveur de vue, CouchDB commence à lui envoyer tous les documents un par un. Le serveur de vue applique les fonctions précedemment enregistrées l'une après l'autre sur le document et enregistre le résultat. Lorsque toutes les fonctions ont été appelées, le résultat est retourné sous forme d'une chaine de caractères JSON.

CouchDB envoie :

{{{
["map_doc", {"_id":"8877AFF9789988EE","_rev":46874684684,"field":"value","otherfield":"othervalue"}]\n
}}}
Si la fonction définie ci-dessus est la seule enregistrée, le serveur de vue répond :

{{{
[[[null, {"_id":"8877AFF9789988EE", "_rev":46874684684, "field":"value", "otherfield":"othervalue"}]]]\n
}}}
C'est un tableau avec le résultat de chaque fonction sur le document. Si un document est exclu de la vue, le tableau doit être vide.

=== reduce (réduction) ===
Si la vue a une fonction {{{reduce}}} de définie, CouchDB entre dans la phase de réduction. Le serveur reçoit une liste des fonctions reduce et les résultats d'association (map) sur lesquels ils doit les appliquer. Les résultats d'association sont donnés sous la forme {{{[[key, id-of-doc], value]}}}.

CouchDB envoie :

{{{
["reduce",["function(k, v) { return sum(v); }"],[[[1,"699b524273605d5d3e9d4fd0ff2cb272"],10],[[2,"c081d0f69c13d2ce2050d684c7ba2843"],20],[[null,"foobar"],3]]]
}}}
Le serveur de vue répond :

{{{
[33]
}}}
Attention: même si le serveur de vue reçoit les résultats d'association(map) sous la forme {{{[[key, id-of-doc], value]}}},la fonction peut être reçue de différentes manières. Par exemple, le serveur de vue Javascript applique les fonctions sur la liste des clés et sur la liste des valeurs.

=== rereduce ===
=== log ===
À n'importe quel moment, le serveur de vue peut envoyer des informations qui seront stockées dans le serveur de log de CouchDB. Cela est réalisé par l'envoi d'un objet spécial avec un seul champ {{{log}}} sur une ligne à part.

Le serveur de vue envoie :

{{{
{"log":"A kuku!"}
}}}
CouchDB ne répond rien.

La ligne suivante apparaitra dans le fichier {{/couchdb/couch.log?action=content|couch.log|width="100%",type="text/html"}}}, mutatis mutandum:

{{{
[Sun, 22 Jun 2008 22:51:25 GMT] [info] [<0.72.0>] Query Server Log Message: A kuku!
}}}
Si vous utilisez le serveur de vue javascript, vous pouvez obtenir cela en envoyant la fonction {{{log}}} dans votre vue. Pour faire la même chose dans ClCouch, appelez {{{logit}}}.

== Mise en œuvres ==
 * [[http://svn.apache.org/repos/asf/incubator/couchdb/trunk/share/server/main.js|JavaScript]] (CouchDB native)
 * [[http://common-lisp.net/cgi-bin/darcsweb/darcsweb.cgi?r=submarine-cl-couch;a=summary|Common Lisp]]
 * [[http://jan.prima.de/~jan/plok/archives/93-CouchDb-Views-with-PHP.html|PHP]]
 * [[http://theexciter.com/articles/couchdb-views-in-ruby-instead-of-javascript|Ruby]]
 * [[http://couchdb-python.googlecode.com/svn/trunk/couchdb/view.py|Python]]
