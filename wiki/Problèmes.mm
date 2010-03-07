== Mise à jour ==

Avez-vous compilé CouchDB à partir du dépot Subversion?

Avez vous exécuté un `svn up` qui semble tout casser ?

Après chaque mise à jour, vous devez lancer la commande suivante :

{{{
./bootstrap -C
}}}

Si vous avez encore des problèmes, essayez le point suivant.

== Premier lancement ==

Avez-vous des problèmes au lancement de CouchDB la première fois ?

Suivez cette simple procédure et reportez le résultat de chaque étape sur la liste de diffusion (ou IRC).

 1. Indiquez le nom de votre système d'exploitation et de votre architecture procésseur.

 2. Indiquez les versions des dépendances de CouchDB installées.

 3. Suivez [[http://incubator.apache.org/couchdb/community/code.html|les instructions de checkout]] pour obtenir une copîe récente du trunk.

 4. Bootstrap à partir du dossier `couchdb` :

  {{{
./bootstrap -C
}}}
  
 5. Compilez dans un dossier temporaire :
  {{{
./configure --prefix=/tmp/couchdb && make && make install
}}}

 6. Exécutez la commande couchdb et enregistrez le résultat :
  
  {{{
/tmp/couchdb/bin/couchdb
}}}
 
 7. Utilisez votre outil de traçage et enregistrez le résultat de la commande précedente.

  1. Sur les systèmes Linux utilisez de préférence strace:

    {{{
strace /tmp/couchdb/bin/couchdb 2> strace.out
}}}

  2. Merci d'ajouter la documentation pour votre système...

 8. Reportez le résultat de chaque étape sur la liste de diffusion (ou IRC).
