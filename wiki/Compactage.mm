#language fr
== Présentation ==

Le compactage réecrit le fichier de base de données en supprimant les anciennes révisions de documments et les documents effacés. C'est disponible dans CouchDB dans SVN depuis 2008-04-07 et depuis la version 0.8-incubating dans les sources téléchargeables.

Le compactage est géré manuellement par base de données. La gestion de queue de compactage sur plusieurs bases de données est prévue.

=== Exemple ===

Le compactage est initié par une requête HTTP POST sur la sous-resource _compact de la base de données. En cas de succès un code HTTP 200 est retourné.

{{{
    # POST http://localhost/ma_db/_compact via curl
    curl -X POST http://localhost/ma_db/_compact
    #=> {"ok":true}
}}}

une requête HTTP GET sur l'url de la base de données ( http://localhost/ma_db ) renvoie un tableau(hash) des états sous la forme suivante :

{{{
    curl http://localhost/ma_db
    #=> {"db_name":"ma_db","doc_count":0,"doc_del_count":1,"update_seq":3,"compact_running":false,"disk_size":14341}
}}}

La clé compact_running est à true pendant le compactage.

=== Compactage de bases de données lourdement chargées en écritures ===

Compacter une base de données proche de sa limite en écritures n'est pas une bonne idée. Le processus de compactage peut ne pas prendre en compte les écritures, si jamais il les laisse passer, et peut en outre manquer d'espace disque.

Le compactage doit s'effectuer sur une base de données qui n'a pas atteint sa limite en écritures. La charge en lectures ne l'empêchera pas de s'effectuer.

CouchDB travaille ainsi pour avoir le moins d'impact sur les clients, la base de données reste en ligne et complètement opérationnelle en lecture/écriture. C'est un choix de conception d'empêcher le compactage d'une base de données lorsqu'elle a atteint sa limite en écritures. Il est recommandé d'effectuer ce compactage lors des heures où la base est moins chargée.

Dans un environnement cluster, l'écriture peut être stoppée pour chaque noeud avant le compactage et autorisée à nouveau lorsque celui-ci est terminé.

Dans le futur, un noeud CouchDB pourra être modifié pour stopper ou faire échouer les mises à jour si la charge en écriture est trop intense pour lui permettre de compléter celles-ci dans un délai raisonnable.
