#language fr

CouchDB ne s'installe pas nativement sur  Windows mais il est possible de l'installer à la main.

Merci de mettre à jour ce guide si nécessaire, nous souhaitons récupérer votre retour d'expérience afin de l'intégrer dans la procedédure d'installation officielle.


== Dépendances ==

Vous avez besoin des logiciels suivants installés sur votre système :

  * [[http://www.erlang.org/download.html|Erlang/OTP]]
  * C Compiler/Linker (such as [[http://gcc.gnu.org/|GCC]] or [[http://msdn.microsoft.com/en-us/visualc/default.aspx|Visual C++]])
  * Make (such as [[http://www.gnu.org/software/make/|GNU Make]] or [[http://msdn.microsoft.com/en-us/library/dd9y37ha(VS.71).aspx|nmake]])
  * [[http://www.openssl.org/|OpenSSL]]
  * [[http://www.icu-project.org/|ICU]]
  * [[http://www.mozilla.org/js/spidermonkey/|SpiderMonkey]]

== Installation de base ==

Après avoir installé Erlang vous devez obtenir quelque chose de similaire à :

{{{
C:\Program Files\erl5.6.3
}}}

Copiez l'arborescence complète du source de Couchdb ici :

{{{
C:\Program Files\erl5.6.3\lib\couchdb-0.8.0
}}}

Créeez le dossier vide suivant :

{{{
C:\Program Files\erl5.6.3\lib\mochiweb-0.01\ebin
}}}

À partir de ICU copiez `icu*.dll` et `libeay32.dll` vers :

{{{
C:\Program Files\erl5.6.3\erts-5.6.2\bin
}}}

De !SpiderMonkey copiez `js32.dll` et  `jsshell.exe` vers :

{{{
C:\Program Files\erl5.6.3\erts-5.6.2\bin
}}}


== Compilation C ==

=== couchdb/couch_erl_driver.c ===

C'est la couche qui fournit les fonctionnalités de ICU à CouchDB.

Le plus simple pour compiler une DLL est de créer un projet Win32 DLL dans un IDE, ajoutez `couch_erl_driver.c` au projet, et changez les préférences du projet pour inclure les chemins de Erlang ERTS et des fichiers d'entêtes de ICU4C.

Créez le dossier vide suivant :

{{{
C:\Program Files\erl5.6.3\lib\couchdb-0.8.0\priv
}}}

Copiez la DDL vers :

{{{
C:\Program Files\erl5.6.3\lib\couchdb-0.8.0\priv\couch_erl_driver.dll
}}}

=== couchdb/couch_js.c ===

C'est la couche qui fournit UTF-8 et les améliorations cache à !SpiderMonkey.

Remplacez js.c par couch_js.c, et changez '#include <jsapi.h>' en '#include "jsapi.h"', ensuite compilez js.exe à nouveau, renommez le en couch_js.exe et copiez le vers :

{{{
C:\Program Files\erl5.6.3\erts-5.6.2\bin
}}}

== Compilation Erlang ==

Créez le fichier suivant :

{{{
C:\Program Files\erl5.6.3\lib\couchdb-0.8.0\src\Emakefile
}}}

Ajoutez le contenu suivant :

{{{
{'./couchdb/*', [{outdir,"../ebin"}]}.
{'./mochiweb/*', [{outdir,"../../mochiweb-0.01/ebin"}]}.
}}}

Lançez `erl` (ou `werl`) et executez la commande suivante pour changer le dossier :

{{{
cd("C:/Program Files/erl5.6.3/lib/couchdb-0.8.0/src").
}}}

Exécutez cette commande pour compiler CouchDB :

{{{
make:all().
}}}

== Configuration ==
Copiez le fichier suivant :

{{{
C:\Program Files\erl5.6.3\lib\couchdb-0.8.0\etc\couchdb\couch.ini.tpl.in
}}}

ici :

{{{
C:/Program Files/erl5.6.3/bin/couch.ini
}}}

Éditez ce fichier de la façon suivante :

{{{
[Couch]

ConsoleStartupMsg=Apache CouchDB is starting.

DbRootDir=C:/Path/To/Database/Directory

Port=5984

BindAddress=127.0.0.1

DocumentRoot=C:/Program Files/erl5.6.3/lib/couchdb-0.8.0/share/www

LogFile=C:/Path/To/Log/Directory

UtilDriverDir=C:/Program Files/erl5.6.3/lib/couchdb-0.8.0/priv/couch_erl_driver.dll

LogLevel=info

[Couch Query Servers]

javascript=couch_js "C:/Program Files/erl5.6.3/lib/couchdb-0.8.0/share/server/main.js"
}}}

Make sure that the `DbRootDir` exists and that the `LogFile` can be created.

== Exécution ==

Lançez `erl` (ou `werl`) et exécutez la commande suivante :

{{{
couch_server:start().
}}}

Pour voir si tout a fonctionné à ce point de l'installation, rendez-vous avec votre navigateur sur 
[[http://localhost:5984/_utils/index.html]] et lançez `test suite`.
