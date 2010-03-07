= Update views on document save =

CouchDB defaults to regenerating views the first time they are accessed. This behavior is preferable in most cases as it optimizes the resource utilization on the database server. 
On the other hand, in some situations the benefit of always having fast and updated views far outweigh the cost of regenerating them every time the database server receives updates. This can be achieved by supplying an updater script that calls the views when needed.

== Example using ruby ==

=== couch.ini ===
(0.8) Add the following line to the couch.ini file {{{
	DbUpdateNotificationProcess=/PATH/TO/view_updater.rb
}}}

(0.9) Add the following section to the local.ini file: {{{
[update_notification]
view_updater=/PATH/TO/view_updater.rb
}}}  

=== view_updater.rb ===
The following script updates the views for each tenth update made to the database or at most once every second when a lot of saves are performed 

{{{

#!/usr/bin/ruby

###################
# CONF            #
###################

# The smallest amount of changed documents before the views are updated
MIN_NUM_OF_CHANGED_DOCS = 10

# URL to the DB on the CouchDB server
URL = "http://localhost:5984"

# Set the minimum pause between calls to the database
PAUSE = 1 # seconds

# One entry for each design document 
# in each database
VIEWS = {"my_db"  => {"design_doc" => "view_name"}}

###################
# RUNTIME         #
###################

run = true
number_of_changed_docs = {}

threads = []

# Updates the views
threads << Thread.new do

  while run do

    number_of_changed_docs.each_pair do |db_name, number_of_docs|
      if number_of_docs >= MIN_NUM_OF_CHANGED_DOCS
        
        # Reset the value
        number_of_changed_docs[db_name] = 0
        
        # If there are views in the database, get them
        if VIEWS[db_name]
          VIEWS[db_name].each do |design, view|
            `curl #{URL}/#{db_name}/_design/#{design}/_view/#{view}?limit=0`
          end  
        end
                
      end
    end

    # Pause before starting over again
    sleep PAUSE
    
  end
  
end

# Receives the update notification from CouchDB
threads << Thread.new do

  while run do

    STDERR << "Waiting for input\n"
    update_call = gets
    
    # When CouchDB exits the script gets called with
    # a never ending series of nil
    if update_call == nil
      run = false
    else
      
      # Get the database name out of the call data
      # The data looks somethind like this:
      # {"type":"updated","db":"DB_NAME"}\n
      update_call =~ /\"db\":\"(\w+)\"/
      database_name = $1
      
      # Set to 0 if it hasn't been initialized before
      number_of_changed_docs[$1] ||= 0
      
      # Add one pending changed document to the list of documents
      # in the DB
      number_of_changed_docs[$1] += 1
      
    end
    
  end

end

# Good bye
threads.each {|thr| thr.join}

}}}

The view_updater.rb itself has to be made executable by CouchDB (chmod 0700?).

== Example using Python ==

{{{

#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Updater script to regenerate couchdb views on update.
"""

import logging
logging.basicConfig(level=logging.INFO)

import os
import re
import signal
import sys
import time
import urllib2

from threading import Thread

flags = {
    'is_running': True
}

changed_docs = {}

class ViewUpdater(object):
    """Updates the views.
    """
    
    # The smallest amount of changed documents before the views are updated
    MIN_NUM_OF_CHANGED_DOCS = 50
    
    # Set the minimum pause between calls to the database
    PAUSE = 5 # seconds
    
    # URL to the DB on the CouchDB server
    URL = "http://localhost:5984"
    
    # One entry for each design document 
    # in each database
    VIEWS = {
        'my_db': {
            'design_doc': [
                'view_name',
                # ...
            ]
        }
    }
    
    def start(self):
        Thread(target=self._run).start()
    
    
    def _run(self):
        """Loop, checking for enough ``changed_docs`` to trigger a
          request to couchdb to re-index.
        """
        
        while flags['is_running']:
            try:
                for db_name, number_of_docs in changed_docs.items():
                    if number_of_docs >= self.MIN_NUM_OF_CHANGED_DOCS:
                        # Reset the value
                        del changed_docs[db_name]
                        # If there are views in the database, get them
                        if db_name in self.VIEWS:
                            logging.info('regenerating %s' % db_name)
                            db_views = self.VIEWS[db_name]
                            for design, views in db_views.iteritems():
                                for view in views:
                                    url = '%s/%s/_design/%s/_view/%s?limit=0' % (
                                        self.URL, db_name, design, view
                                    )
                                    urllib2.urlopen(url)
                time.sleep(self.PAUSE)
            except Exception:
                flags['is_running'] = False
                raise
            
        
        
    
    


class NotificationConsumer(object):
    """Receives the update notification from CouchDB.
    """
    
    DB_NAME_EXPRESSION = re.compile(r'\"db\":\"(\w+)\"')
    
    def _run(self):
        """Consume update notifications from stdin.
        """
        
        while flags['is_running']:
            try:
                data = sys.stdin.readline()
            except:
                continue
            else:
                if not data: # exit
                    flags['is_running'] = False
                    break
                result = self.DB_NAME_EXPRESSION.search(data)
                if result:
                    db_name = result.groups()[0]
                    # Set to 0 if it hasn't been initialized before
                    if db_name not in changed_docs:
                        changed_docs[db_name] = 0
                    # Add one pending changed document to the list
                    # of documents in the DB
                    changed_docs[db_name] += 1
                
            
        
        
    
    
    def start(self):
        t = Thread(target=self._run)
        t.start()
        return t
        
    
    


def main():
    logging.info('update_notification handler (re)starting')
    consumer = NotificationConsumer()
    updater = ViewUpdater()
    updater.start()
    t = consumer.start()
    try:
        while flags['is_running']:
            t.join(10)
    except KeyboardInterrupt, err:
        flags['is_running'] = False
        
    


if __name__ == '__main__':
    main()

}}}
