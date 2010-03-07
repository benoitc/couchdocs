#language fr

Explications et solutions aux messages d'erreurs qui peuvent survenir lors de la compilation ou de l'exécution de CouchDB.


== icu-config manquant ==

=== Problème ===

{{{
*** The icu-config script could not be found. Make sure it is
*** in your path, and that taglib is properly installed.
*** Or see http://ibm.com/software/globalization/icu/
}}}

=== Solution ===

Installez ICU et utilisez `locate` pour localiser la commande `icu-config` :

{{{
locate icu-config
}}}

Ajoutez le dossier indiqué par cette commande à votre `PATH`:

{{{
export PATH="$PATH:/usr/local/bin"
}}}


== LD_LIBRARY_PATH incorrect ==

=== Problème ===

{{{
$ couchdb      
Apache CouchDB 0.8.0-incubating (LogLevel=info)
Apache CouchDB is starting.

{"init terminating in do_boot",{error,{open_error,-10}}​}

Crash dump was written to: erl_crash.dump
init terminating in do_boot ()
}}}

=== Solution ===

Vous devez fixer correctement la variable d'environnement  `LD_LIBRARY_PATH` afin qu'elle pointe bien vers les bibliothèques installées. Dans Mac OS X, l'équivalent est `DYLD_LIBRARY_PATH`.

Exemple pour un utilisateur normal :

{{{
LD_LIBRARY_PATH=/usr/local/lib:/usr/local/js/lib couchdb
}}}

Exemple pour l'utilisateur `couchdb` :

{{{
echo LD_LIBRARY_PATH=/usr/local/lib:/usr/local/js/lib couchdb | sudo -u couchdb sh
}}}


== Architecture Binaire Incompatible ==

Sur Mac OS X, les bibliothèques et exécutables peuvent être des ''fat binaries'' qui supportent plusieurs architectures processeur (PPC and x86, 32 and 64 bit).  Mais cela signifie aussi que vous pouvez avoir des problèmes lors du chargement de bibliothèque qui ne supporte pas l'archictecture sur laquelle l'application est exécutée. 

=== Problème ===

{{{
$ couchdb      
Apache CouchDB 0.8.0-incubating (LogLevel=info)
Apache CouchDB is starting.

{"init terminating in do_boot",{error,{open_error,-12}}​}

Crash dump was written to: erl_crash.dump
init terminating in do_boot ()
}}}

=== Solution ===

Vous avez probablement compilé Erlang avec l'option 64 bits. Le problème est que ICU, que CouchDB tente de charger au démarrage, n'a pas été compilé avec le support 64 bits, et donc ne peut être chargé dans le processus 64 bits d'Erlang.

Recompilez Erlang et résistez à la tentation de construire un binaire 64 bits (omettez juste l'option `--enable-darwin-64bit` ). L'option `--enable-darwin-universal` fonctionne correctement mais notez que pour l'instant il n'existe pas de binaire universel d'ICU.

== Port non disponible ==

=== Problème ===

{{{
$ couchdb      
Apache CouchDB 0.8.0-incubating (LogLevel=info)
Apache CouchDB is starting.

...
[error] [<0.46.0>] {error_report,<0.21.0>,
...
               {couch_httpd,start_link,
                   ["127.0.0.1","5984","/tmp/couchdb-a/share/couchdb/www"]}},
           {restart_type,permanent},
           {shutdown,1000},
           {child_type,supervisor}]}]}}
...
}}}

=== Solution ===

Editez le fichier `/etc/couchdb/couch.ini` et modifiez `Port`pour un port disponible.
