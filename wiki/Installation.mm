= Installation of CouchDB and Dependencies =
<<TableOfContents(2)>>

== Dependencies ==

 ||<|2>'''CouchDB''' ||<-4> ''Runtime''||<-2> ''Build''||
 ||'''Spidermonkey'''||'''Erlang'''||'''ICU'''||'''cURL'''||'''Automake'''||'''Autoconf'''||
 ||0.9.x||==1.7||>=5.6.0||>= 3.0||>= 7.15.5||>= 1.6.3||>= 2.59||
 ||0.10.x||>=1.7 && <=1.8.0||>=5.6.5||>= 3.0||>= 7.18.0||>= 1.6.3||>= 2.59||
 ||0.11.x||>=1.7||>=5.6.5||>= 3.0||>= 7.18.0||>= 1.6.3||>= 2.59||

== Troubleshooting ==

=== Installing from source ===
'''Tips/Hints'''

If you have trouble/wired errors building from source, it is always good starting point to reset the repository to a clean state and retry:
{{{
make clean && make distclean && ./bootstrap && ./configure && make check && make
}}}


== System specific installation guides ==

'''Linux and Solaris'''
  * [[Installing_on_RHEL4]]
  * [[Installing_on_RHEL5]]
  * [[Installing_on_Fedora7]]
  * [[Installing_on_Fedora10]]
  * [[Installing_on_Gentoo]]
  * [[Installing_on_Ubuntu]]
  * [[Installing_on_Open_Solaris_and_Joynet_Accellerator]]
  * [[Installing_on_Slackware]]

'''Apple Mac'''
  * [[Installing_on_OSX]]

'''Windows'''
  * [[Installing_on_Windows]]

'''BSD Unix'''
  * [[Installing_on_FreeBSD]]
  * [[Installing_on_NetBSD]]
  * [[Installing_on_OpenBSD]]

'''Installing from Source'''
  * [[Installing_SpiderMonkey]]
  * [[Installing_from_source]]

'''Verifying the Installation'''
  * [[Verify_and_Test_Your_Installation]]

'''Third Party Tool Configuration'''
  * [[Apache_As_a_Reverse_Proxy]]
