#language fr

Une FAQ pour toutes les questions autour de CouchDB.

Si vous avez une question dont la réponse n'existe pas dans cette FAQ, merci de l'ajouter à la fin. Revenez au bout de quelques jours, quelqu'un y aura peut-être répondu.

== Qu'est-ce que CouchDB? ==

CouchDB est une base de données orientée document non relationnelle (NRDBMS). La page d'[[http://incubator.apache.org/couchdb/docs/intro.html|Introduction]] possède plus d'information sur le système de CouchDB.

== Quel est le statut de CouchDB ? ==

version Alpha. Il manque encore d'importantes fonctionnalités, mais est suffisamment utilisable pour être testée.

== Qu'est-ce que Couch signifie ? ==

C'est un acronyme pour Cluster Of Unreliable Commodity Hardware. Il résume les objectifs long terme de CouchDB qui sont d'être facilement extensible et fortement disponible sur des machines sensibles aux pannes. La nature distribuée et la structure à plat des données de la base permettra le partionnement horizontal pour étendre le stockage (avec du map/reduce pour les requêtes) et du cluster pour la disponibilité et la résistance aux pannes.

== En quel langage est écrit CouchDB ? ==

Erlang, un langage fonctionnel concurrent temps réel et distribué, qui possède des fonctionnalités de tolérance aux pannes. Les premières versions de CouchDB étaient en C mais furent remplacées par la plateforme Erlang OTP. Erlang montre depuis qu'il correspond parefaitement à ce type de projet.

CouchDB utilise la bibliothèque Javascript Mozilla's Spidermonkey en C.

== Quelles plateformes sont supportées ? ==

La plupart des systèmes POSIX, ce qui inclue GNU/Linux et OS X.

Windows n'est pas officiellement supporté mais devrait fonctioner, si c'est le cas tenez-nous au courant.

== Quelle est la license ? ==

[[http://www.apache.org/licenses/LICENSE-2.0.html|Apache 2.0]]

== Quelle volume de données je peux stocker dans CouchDB ? ==

Avec un système réparti, virtuellement illimité. Pour une seule instance de base de donnée, la limite n'est pas encore connue.

== Comment je fais des suites ? ==

Ou autrement dit, où est AUTO_INCREMENT ?! Avec la réplication les suites sont difficiles à réaliser. Les suites sont souvent utilisées pour créer des identifiants uniques pour chaque ligne de la base de données. CouchDB peut générer des ids uniques ou vous pouvez créer les votres, vous n'avez donc pas forcemment besoin de suites. Si vous utilisez une suite pour autre chose, vous devez trouver un moyen de l'intégrer dans CouchDB.

== Comment j'utilise la réplication ? ==

{{{
POST /_replicate?source=$source_basededonnée&target=$destination_basededonnée
}}}

Où $source_basededonnée et $destination_basededonnée peuvent être les noms de bases locales ou des URIs correspondant à des bases de données distantes. Chacune des bases doit exister avant de lancer la réplication.

== Quelle est la rapidité des vues ? ==

Il est difficile de vous donner des chiffres significatifs. D'un point de vue architecture, une vue sur une table est comme un index (multi-colonnes) d'une table dans une base de données relationnelle (RDBMS) sur lequel on lance une recherche rapide. C'est donc en théorie très rapide.

Cependant, cette architecture a été conçue pour supporter un trafic important. Aucun blocage ne peut avoir lieu dans le module de stockage (MVCC & ...) autorisant ainsi un grand nombre de lectures et d'écritures sérialisées en parallèles. Avec la réplication vous pouvez même configurer plusieurs machines pour partitionner horizontalement ls données (dans le futur). (Voir [[http://jan.prima.de/~jan/plok/archives/72-Some-Context.html|le slide 13 de l'essai de Jan Lehnardt]] pour plus d'informations sur le module de stockage ou l'article complet.)

== Pourquoi CouchDB n'utilise pas Mnesia? ==

Plusieurs raisons :

  * La première est la limitation de 2giga par fichier.
  * La seconde est que cela requiert une validation et un cycle de réparation après un crash ou une panne de courant, donc même si la taille des fichiers était augmentée, le temps de réparation sur des gros fichiers est prohibitif.
  * Le système de réplication de Mnesia replication fonctionne sur des clusters mais pas pour du distribué ou du deconnecté. La plupart des fonctionnalités ""cool" de Mnesia ne sont pas utiles pour CouchDB.
  * Par ailleurs Mnesia n'est pas vraiment une base de donnée "scalable"(ndlr: trouver une traduction). C'est plus une base pour des données de configuration. les données qui s'y trouvent ne sont pas le centre de l'application mais nécessaires à son fonctionnement. Des chose comme les routeurs, les proxy HTTP ou les serveurs LDAP, des choses qui ont besoin d'être mises à jour, configurées et reconfigurées souvent, mais dont le volume de données est rarement important.


== Pourquoi n'existet-il pas d'autre moyens que HTTP pour communiquer avec CouchDB ? ==

Le modèle de donnée et l'API interne de CouchDB correspond si bien au modèle REST/HTTP que n'importe quel API ne ferait que réinventer un dérivé de HTTP. Cela n'aurait que peu de sens, il n'y a donc que l'api HTTP.
