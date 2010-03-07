== Dépendances de CouchDB ==

Dans un premier temps, il vous faut récupérer les slackbuilds suivants :

 * [[http://slackbuilds.org/repository/13.0/network/js/|js]]
 * [[http://slackbuilds.org/repository/13.0/libraries/icu4c/|icu4c]]
 * [[http://slackbuilds.org/repository/13.0/development/erlang-otp/|erlang-otp]]

Les [[http://books.couchdb.org/relax/appendix/installing-from-source|autres dépendances]] sont normalement satisfaites :
 * curl : à vérifier en utilisant un :
{{{#!bash
curl-config --version
}}}
 * make & gcc

Créer les packages des slackbuids (les slackbuils sont prévus pour i486 ; si vous êtes en 64 bits, éditer le fichier `<package>.Slackbuild` pour modifier la valeur de `ARCH`.

Pour que le SlackBuild fonctionne, il vous faut mettre l'archive des sources du package à créer dans le répertoire créé en décompressant le fichier slackbuild.

{{{#!bash
tar xzf js.tar.gz
cd js
./js.SlackBuild
=> Slackware package /tmp/js-1.8.0_rc1-x86_64-1_SBo.tgz created.

tar xzf icu4c.tar.gz
cd ../icu4c
./icu4c.SlackBuild
=> Slackware package /tmp/icu4c-4.2.1-x86_64-1_SBo.tgz created

tar xzf erlang-otp.tar.gz
cd erlang-otp
./erlang-otp.SlackBuild
=> Slackware package /tmp/erlang-otp-13B03-x86_64-1_SBo.tgz created.
}}}

Installer ensuite les packages créés :

{{{#!bash
nicolas@cassis:/tmp$ sudo installpkg icu4c-4.2.1-x86_64-1_SBo.tgz 
Verifying package icu4c-4.2.1-x86_64-1_SBo.tgz.                   
Installing package icu4c-4.2.1-x86_64-1_SBo.tgz:                  
PACKAGE DESCRIPTION:                                              
# icu4c (International Components for Unicode)                    
#                                                                 
# The International Components for Unicode (ICU) libraries provide
# robust and full-featured Unicode services on a wide variety of  
# platforms.                                                      
#                                                                 
# Homepage: http://www.icu-project.org/                           
#                                                                 
Executing install script for icu4c-4.2.1-x86_64-1_SBo.tgz.        
Package icu4c-4.2.1-x86_64-1_SBo.tgz installed.                   

nicolas@cassis:/tmp$ sudo installpkg js-1.8.0_rc1-x86_64-1_SBo.tgz
Verifying package js-1.8.0_rc1-x86_64-1_SBo.tgz.
Installing package js-1.8.0_rc1-x86_64-1_SBo.tgz:
PACKAGE DESCRIPTION:
# SpiderMonkey (Mozilla's JavaScript Engine)
#
# SpiderMonkey is the code-name for the Mozilla's C implementation of
# JavaScript. It can be used by applications such as elinks and others.
#
# This is the standalone version of the engine used by Firefox and other
# Mozilla applications.
#
# Homepage: http://www.mozilla.org/js/spidermonkey
#
Package js-1.8.0_rc1-x86_64-1_SBo.tgz installed.

nicolas@cassis:/tmp$ sudo installpkg erlang-otp-13B03-x86_64-1_SBo.tgz
Verifying package erlang-otp-13B03-x86_64-1_SBo.tgz.
Installing package erlang-otp-13B03-x86_64-1_SBo.tgz:
PACKAGE DESCRIPTION:
# Erlang (programming language)
#
# Erlang is a general-purpose concurrent programming language and
# runtime system.
# The sequential subset of Erlang is a functional language,
# with strict evaluation, single assignment, and dynamic typing.
# It was designed by Ericsson to support distributed,
# fault-tolerant, soft-real-time, non-stop applications.
#
# http://www.erlang.org/
#
Executing install script for erlang-otp-13B03-x86_64-1_SBo.tgz.
Package erlang-otp-13B03-x86_64-1_SBo.tgz installed.
}}}

== Installation de CouchDB ==

Il vous faut au préalable créer un utilisateur et un groupe couchdb :

{{{#!bash
groupadd -g 231 couchdb
useradd -u 231 -g couchdb -d /var/lib/couchdb -s /bin/sh couchdb
}}}

Récupérer le [[http://slackbuilds.org/repository/13.0/development/couchdb/|slackbuild de CouchDB]]

il vous faut alors procéder de la façon suivante :

{{{#!bash
tar xzf couchdb.tar.gz
cd couchdb
# récupérer les sources de couchdb 0.10.1 et metter les dans votre répertoire couchdb
# éditer si besoin le SlackBuild
# créer votre package :
./couchdb.Slackbuild
=> Slackware package /tmp/SBo/couchdb-0.10.1-x86_64-1_SBo.tgz created.
}}}

Il ne reste plus qu'à installer le paquet :

{{{#!bash
installpkg /tmp/SBo/couchdb-0.10.1-x86_64-1_SBo.tgz
}}}

== Démarrage / Arrêt automatique de CouchDB ==

Editer /etc/rc.d/rc.local pour y ajouter :

{{{#!bash
if [ -x /etc/rc.d/rc.couchdb ]; then
	. /etc/rc.d/rc.couchdb start
fi
}}}

et dans /etc/rc.d/rc.local_shutdown :

{{{#!bash
if [ -x /etc/rc.d/rc.couchdb ]; then
	. /etc/rc.d/rc.couchdb stop
fi
}}}

Ouvrez http://localhost:5984/_utils/

Et voilà... il est maintenant temps de vous relaxer ;-)
