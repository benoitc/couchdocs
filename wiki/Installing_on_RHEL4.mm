## page was renamed from InstallingOnRHEL4
Installing on RHEL4 x86_64

1. install erlang
{{{
wget http://www.erlang.org/download/otp_src_R12B-5.tar.gz
tar xzvf otp_src_R12B-5.tar.gz
cd otp_src_R12B-5
./configure && make && sudo make install
cd ..
}}}
2. install other dependencies. you'll need EPEL and/or RPMForge
{{{
yum install icu libicu-devel js js-devel
}}}
3. install spidermonkey ( step may be optional if you can get js/js-devel as above)

Also see [[InstallingSpiderMonkey]]
{{{
wget http://ftp.mozilla.org/pub/mozilla.org/js/js-1.7.0.tar.gz
tar xvzf js-1.7.0.tar.gz
cd js/src/
make -f Makefile.ref # (add BUILD_OPT=1 for non-debug build?)
JS_DIST=/usr/local/spidermonkey make -f Makefile.ref export
cd ..
cd ..
}}}
4. install couchdb
{{{
svn checkout http://svn.apache.org/repos/asf/couchdb/trunk couchdb
cd couchdb
./bootstrap
./configure --with-js-lib=/usr/local/spidermonkey/lib64 --with-js-include=/usr/local/spidermonkey/include
make && make install
}}}
