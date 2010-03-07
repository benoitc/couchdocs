There are three types of variable data files to backup:

   * Database files
      
   * Configuration files
   
   * Log files

[[http://mail-archives.apache.org/mod_mbox/incubator-couchdb-user/200808.mbox/%3c32800028-9286-47C8-82A5-1ECC25667FDA@apache.org%3e|Couch-users discussion from Damien Katz - August 2008]]:

{{{
Actually, you can copy a live database file from the OS at anytime without problem. Doesn't matter if its being updated, or even if its being compacted, the CouchDB never-overwrite storage format ensures it should just work without issue.
}}}

For all platforms, locate your database, configuration, and log files and perform a filesystem copy. Be careful to preserve file permissions, too. Archive these files to wherever you want-- ideally on a different machine in a different physical location -- with appropriate security limiting access.   

For example, here are the directories to backup for a [[http://wiki.apache.org/couchdb/InstallingOnUbuntu|CouchDB install on Ubuntu]]:

  * Configuration: /usr/local/etc/couchdb/

  * Database files: /usr/local/var/lib/couchdb/    

  * Logs: /usr/local/var/log/couchdb/

'''Note:''' Before CouchDB 1.0 intermediate releases can have incompatible database file formats. For details on migrating those, see BreakingChanges.
