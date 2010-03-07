CouchDb requires many bits to be installed.

Building an all in one , embeddable, no external dependencies packaging of CouchDB for each major desktop OS (Windows, MacOSX and Linux) would help make it easy for new users to get started. Installers would be a bonus.

Pioneering work has already been done with CouchDbx : a self-contained MacOSX application with all the required bits..

The goal here is to document:
 * the minimal bits that are required to install a self-contained, all-in-one, embeddable CouchDb
 * the step-by-step instructions to build those packages
 * installers creation

Some sources of inspiration:
 * the Erlang NSIS installer for windows
 * ejabberd: http://www.ejabberd.im/
 
Installer technologies:
 * package builder on macos
 * nsis on windows
 * shell archives on linux

IP and licensing issues
 * since there are 3rd party dependencies that may be problematic, installers will fetch at install time the 3rd party dependencies.
 * see that page for ASF policies: http://www.apache.org/legal/3party.html 
 * and that email thread for specific incubator PMC comments: 
  * http://mail-archives.apache.org/mod_mbox/incubator-general/200807.mbox/%3c003801c8e1e2$0c98fb30$0dfbfdc0@computer%3e , 
  * http://mail-archives.apache.org/mod_mbox/incubator-general/200807.mbox/%3c3EF9FB5A-D441-4E67-BE2A-B23984A7F856@SUN.com%3e
  * http://mail-archives.apache.org/mod_mbox/incubator-general/200807.mbox/%3cf2e8eedf0807091057q77737020s8007e255eb255837@mail.gmail.com%3e
