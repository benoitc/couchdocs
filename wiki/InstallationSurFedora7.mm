#language fr
Installation sur Fedora Core 7 i386

1. Installez Erlang
{{{
yum install erlang
}}}
2. Installez les autres dépendances (aucune source de paquet indépendante requise)
{{{
yum install icu libicu-devel js js-devel
}}}
3. Installez Couchdb
{{{
svn checkout http://svn.apache.org/repos/asf/incubator/couchdb/trunk couchdb
cd couchdb
./bootstrap -C
./configure
make && make install
}}}
4. Créez l'utilisateur couchdb
{{{
sudo adduser -r -d /usr/local/var/lib/couchdb couchdb
sudo chown -R couchdb /usr/local/var/lib/couchdb
sudo chown -R couchdb /usr/local/var/log/couchdb
}}}
5. (optionnel) éditez les préférences Port et !BindAddress
{{{
vim /usr/local/etc/couchdb/couch.ini
}}}
6. Démarrez le serveur CouchDB dans votre terminal
{{{
sudo -u couchdb couchdb
}}}
ou comme démon
{{{
sudo /usr/local/etc/rc.d/couchdb start
}}}

Allez sur http://localhost:5984/_utils/index.html
ou http://hostname:5984/_utils/index.html si vous avez modifié !BindAddress
