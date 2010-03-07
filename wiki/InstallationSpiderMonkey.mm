#language fr
{{{
make -f Makefile.ref
JS_DIST=/usr/local/spidermonkey make -f Makefile.ref export
}}}

== Notes lors de l'installation sur OS X ==

 * Le export doit être executé en tant que root utilisez donc $ sudo sh
 * Lors du lancement de./configure pour couchdb vous devrez utiliser les paramètres --with-js-include et --with-js-lib
 * Assurez vous que /usr/local/spidermonkey/lib est dans DYLD_LIBRARY_PATH : {{{export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/spidermonkey/lib}}}
 * Si malgrez tous vous obtenez l'erreur {{{dyld: Library not loaded: Darwin_OPT.OBJ/libjs.dylib}}} lors du lancement de couchdb, essayez d'ajoutez le chemin js/src du code source. Il a le dossier Darwin_OPT.OBJ à l'intérieur.  {{{export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/usr/local/spidermonkey/lib:/path/to/src/js/src}}}

== Notes lors de l'installation sur Linux ==

Il est préférable d'installer la bibliothèque de SpiderMonkey à partir de votre système de gestion de paquet, ex. :

{{{
apt-get libmozjs-dev
}}}

Ou:

{{{
yum install js-devel
}}}

Cependant, si vvous avez besoin de l'installer à partir du source, assurez vous que le chemin de la bibiliothèque de SpiderMonkey est dans LD_LIBRARY_PATH :

{{{
export LD_LIBRARY_PATH=/usr/local/spidermonkey/lib
}}}
