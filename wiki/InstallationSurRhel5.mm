#language fr
## page was renamed from InstallattionSurRhel5

Installation sur RHEL5 x86_64

1. Installez les dépendances. Vous pouvez avoir besoin de EPEL/RPMFORGE

{{{
yum install ncurses-devel openssl-devel icu libicu-devel js js-devel
}}}

2. Installez Erlang
{{{
wget http://www.erlang.org/download/otp_src_R12B-2.tar.gz
tar xzvf otp_src_R12B-2.tar.gz
cd otp_src_R12B-2
./configure && make && sudo make install
cd ..
}}}

3. Installez Couchdb
{{{
svn checkout http://svn.apache.org/repos/asf/incubator/couchdb/trunk couchdb
cd couchdb
./bootstrap
./configure && make && make install
}}}

4. Editez le fichier de configuration :

{{{
vi /usr/local/etc/couchdb/couch.ini
}}}

5. Créez l'utilisateur, et appliquez les permissions sur les dossiers
{{{
adduser -r -d /usr/local/var/lib/couchdb couchdb
chown -R couchdb /usr/local/var/lib/couchdb
chown -R couchdb /usr/local/var/log/couchdb
}}}

6. Lancez! En console :
{{{
sudo -u couchdb couchdb
}}}
ou comme démon :
{{{
sudo /usr/local/etc/rc.d/couchdb start
}}}
