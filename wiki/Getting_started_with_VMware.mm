Getting started with CouchDB and VMware Appliance.

== Quickstart ==

  * [[http://s3.amazonaws.com/vmware_appliances/Jeos%20Elastic%20Drive%20and%20CouchDB-0.7.3a.rar|Download the appliance]]. Size of the file is around 250Mb.
  * Unpack it into proper directory (On my Windows workstation I have ''C:\Virtual Machines'' directory).
  * In VMware Player use ''Commands > Open''.
  * In VMware Server use ''File > Open > Browse'' and select your unpacked image
  * In terminal use username ''khaz'' and password ''khaz''. For elevated privileges use ''sudo command''.
  * At this point you should have all ready to go. To verify that service is running, you can run command inside terminal session ''wget http://localhost:5984/''. It should return document that looks like:
  {{{
{"couchdb": "Welcome", "version": "0.7.3a"}
}}}

== Detailed Description ==

This appliance release has with CouchDB version 0.7.3a (rev. 649). It runs as a service under Ubuntu 7.10 Jeos and has a bonus addon - free version of Elastic Drive, that helps to establish persistence to remote storage services like Amazon S3 or Nirvanix, thus preserving the data that is stored in your CouchDB.

  * [[http://s3.amazonaws.com/vmware_appliances/Jeos%20Elastic%20Drive%20and%20CouchDB-0.7.3a.rar|Download the appliance]]. Size of the file is around 250Mb.
  * Unpack it into proper directory (On my Windows workstation I have ''C:\Virtual Machines'' directory). You need to have some utility to decompress an archive, I use trial version of [[http://www.rarlab.com/download.htm|WinRAR]]. Same utility had limitations on zip archive size, so this is why you have .rar
  * In VMware Player use ''Commands > Open''.
  * In VMware Server use ''File > Open > Browse'' and select your unpacked image.
  * In terminal use username  ''khaz'' and password ''khaz''. For elevated privileges use ''sudo command''.
  * At this point you should have all ready to go. To verify that service is running, you can run command inside terminal session ''wget http://localhost:5984/''. It should return document that looks like:
  {{{
{"couchdb": "Welcome", "version": "0.7.3a"}
}}}
  If you are running Server Edition, and bridged Ethernet connection (so it uses external DHCP to obtain IP address), you can run ifconfig inside terminal session and see what IP address is assigned to this virtual instance. At this point it is easy to open new browser window and type in something like http://192.168.1.111:5984/. If you see the response like above it means all works as expected.
