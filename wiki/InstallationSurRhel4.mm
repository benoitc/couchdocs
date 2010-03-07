#language fr

Installation sur RHEL4 x86_64

1. Installez Erlang
{{{
wget http://www.erlang.org/download/otp_src_R12B-2.tar.gz
tar xzvf otp_src_R12B-2.tar.gz
cd otp_src_R12B-2
./configure && make && sudo make install
cd ..
}}}
2. Installez les autres dépendances. Vous aurez besoin de EPEL et/ou RPMForge
{{{
yum install icu libicu-devel js js-devel
}}}
3. Installez SpiderMonkey ( optionnel si vous avez récupéré js/js-devel au-dessus)

Voir aussi [[InstallationSpiderMonkey]]
{{{
wget http://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz
tar xvzf js-1.7.0.tar.gz
cd js/src/
make -f Makefile.ref # (add BUILD_OPT=1 for non-debug build?)
JS_DIST=/usr/local/spidermonkey make -f Makefile.ref export
cd ..
cd ..
}}}
4. Installez couchdb
{{{
svn checkout http://svn.apache.org/repos/asf/incubator/couchdb/trunk couchdb
cd couchdb
./bootstrap -C
./configure --with-js-lib=/usr/local/spidermonkey/lib64 --with-js-include=/usr/local/spidermonkey/include
make && make install
}}}
