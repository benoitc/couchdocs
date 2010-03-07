#language fr

Cette page décrit les modifications incompatibles introduites lors de l'évolution de CouchDB. Certains de ces changements n'ont pas d'incidence sur les utilisateurs, mais la plupart si. Cette pages vous décrit ces changements et comment adapter votre code.

== Changements entre 0.7.x et 0.8.0 ==

=== Format du fichier de base de donnée ===

Le format du fichier de base de donnée a changé. CouchDB actuellement ne fournit pas d'outil pour migrer vos données. Vous pouvez néanmoins utiliser des scripts tiers pour effectuer cette migration tel que les outils dump/load de [[http://code.google.com/p/couchdb-python/|couchdb-python]].

==== Migration en utilisant les outils `dump`/`load` de couchdb-python ====

Tout d'abord, quelques notes sur la façon dont fonctionnent ces outils :
 * Ils s'appliquent sur une base de donnée, ce qui signifie que vous devrez migrer chaque base de données individuellement.
 * L'outil dump récupère tous les documents avec leurs attachement d'une base de donnée dans un fichier au format MIME multipart.
 * L'outil load attend un flux d'entrée au format MIME multipart et recrée tous les documents (avec leurs attachements) qu'il contient. Il doit être utilisé sur une base de donnée vide.
 * Les documents conservent évidemment leurs identifiants uniques.
 * L'historique des révisions est perdu.

'''Attention'': ''Ne mettez pas à jour CouchDB avant d'avoir récupéré vos données avec la procédure ci-dessus !''

'''En outre''': ''N'oubliez pas de sauvegarder les fichiers d'origines ainsi que les fichiers de dump. Au  moins tant que vous n'êtes pas sur que la migration soit réussie.''

Pour utiliser ces outils, installez `couchdb-python` , qui requiert [[http://www.python.org/|Python 2.4 et sup]] et les paquets  [[http://code.google.com/p/httplib2/|httplib2]] et [[http://cheeseshop.python.org/pypi/simplejson|simplejson]].

Dans le shell récuperez le contenu d'une  base de donnée dans un fichier en lançant la commande :

{{{
  python couchdb/tools/dump.py http://127.0.0.1:5984/dbname > dbname.dump
}}}

Remplaçez '''dbname''' par le nom de la base de donnée à récuperer. Un fichier `dbname.dump` est créé à l'issue de cette commande dans le répertoire courant.

Après avoir lançé cette commande sur toutes les bases de données que vous souhaitez migrer, vous pouvez mettre à jour CouchDB. Vous aurez besoin de supprimer le dossier où CouchDB conservait les anciennes bases de données pour éviter tous problèmes avec l'ancien format.

Après la mise à jour, vous pouvez importez les données sauvegardées. Tout d'abord, créez une base de données pour chaque dump que vous souhaitez importer. Ensuite, exécutez le script `load.py` à partir de la ligne de commande :

{{{
  python couchdb/tools/load.py http://127.0.0.1:5984/dbname < dbname.dump
}}}

Faîtes cela pour chaque bases de données, et vous devriez être bon. Merci de reporter tout problème avec ces scripts [[http://code.google.com/p/couchdb-python/issues/list|ici]].

=== Changement de la structure des Documents ===

Dans la structure JSON des attachements, la propriété  `content-type` a été changée en `content_type` (notez le caractère de soulignement). ce changement étais nécessaire pour homogénéiser les noms dans CouchDB, et faciliter l'accès à partir du code Javascript.

=== Changement de la définition d'une Vue. ===

Les vues supportent maintenant la propriété optionnelle 'reduce'. Pour que cela soit mis en place, la structure des documents design devait être modifiée. Voici un exemple pour illustrer ce changement :

{{{
  {
    "_id":"_design/foo",
    "language":"javascript",
    "views": {
      "bar": {
        "map":"function... ",
        "reduce":"function..."
      }
    }
  }
}}}

Le principal changement est l'utilisation d'un objet JSON qui définit les fonctions map et reduce au lieu d'une simple chaine de caractère pour la fonction map. La propriété `reduce` peut être omise.

La propriété `language` n'est plus un type MIME, à la place seule le nom du langage est indiqué. Le nom du langage correspond à celui choisi pour le serveur de vue dans le fichier `couch.ini`.

la  fonction `map(key, value)`  que les fonctions map utilisent pour produire la sorte a été renommée `emit(key, value)` pour éviter toute confusion.

{{{
  function(doc) {
    emit(doc.foo, doc.bar);
  }
}}}

Les vues temporaires doivent maintenant `POST`er un document JSON avec les propriétés `map` et `reduce` au lieu de simplement `POST`er le source de la fonction map :

{{{
  {
    "map":"function...",
    "reduce":"function..."
  }
}}}

Attention, le langage de la vue temporaire n'est plus determiné par l'entête `Content-Type` de la reqête HTTP. Comme celle-ci est mainetant définie par un objet JSON, `Content-Type` est toujours `application/json`. Le langage de la vue est maintenant défini par une propriété `language` optionnelle dans l'objet JSON. Si cette propriété est omise, le langage par défaut est "javascript".

{{{
  {
    "language":"javascript"
    "map":"function...",
    "reduce":"function..."
  }
}}}

=== Changement API HTTP API ===

=== Code état DELETE ===

La suppression avec succès de documents en utilisant la méthode HTTP `DELETE` retourne mainetant une réponse `200 OK` à la place de `202 Accepted`. Le fait que la suppression soit immédiate explique ce changement, un code 202 impliquait en effet que l'action était dans la boucle mais n'avait pas encore été  effectuée lors de la réponse. 

==== Mise à jour en masse (Bulk updates) ====

La structure JSON d'une mise à jour en masse a été changée significativement tant pour la requête que la réponse.

Au niveau de la requête, vous postiez précedemment un tableau JSON avec un document par ligne. Maintenant vous postez une propriété `docs` qui contient ce tableau :

{{{
  {
    "docs": [
      {"_id": "foo", "_rev": "123456", "title": "Foo"},
      {"_id": "bar", "_rev": "234567", "title": "Bar"}
    ]
  }
}}}

Les réponse utilisaient un objet JSON avec une propriété `results`. Maintenant la structure JSON est la suivante :

{{{
  {
    "ok": true,
    "new_revs": [
      {"_id": "foo", "rev": "345678"},
      {"_id": "bar", "rev": "456789"}
    ]
  }
}}}

''Attention, les mises à jour en masse sont maintenant transactionnelles : toutes les mises à jours réussissent ou toutes échouent. C'est pourquoi la propriété `ok` se trouve maintenant au premier niveau.''
