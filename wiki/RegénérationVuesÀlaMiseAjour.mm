#language fr

= Mettre à jour les vues lors de l'enregistrement d'un document =

Par défaut CouchDB regénère les vues la première fois qu'elles sont appelées. Ce comportement est adéquat pour la plupart des cas dans la mesure où il optimise l'utilisation des resources sur le serveur de base de données.

Mais  dans certains cas, il est préférables d'avoir rapidement des vues à jour malgré le coût créée par une mise à jour systématique à chaque fois que le serveur reçoit une mise à jour. On peut réaliser cela en fournissant un script de mise à jour qui appelle les vues lorsque cela est nécessaire.

== Exemple utilisant ruby ==

=== couch.ini ===
Ajoutez la lignes suivante au fichier couch.ini {{{
	DbUpdateNotificationProcess=/PATH/TO/view_updater.rb
}}}

=== view_updater.rb ===
Le script suivant met à jour les vues toutes les 10 mises à jour reçues  par la base de données ou une fois / secondes lorsque le nombre d'enregistrement est important {{{
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
VIEWS = {"DATABASE_NAME"  => ["list_of/design_documents",
                              "another/design_document"],
         "recipes"        => ["category/most_popular"],
         "ingredients"    => ["by/price"]}        
        

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
          VIEWS[db_name].each do |view|
            `curl #{URL}/#{db_name}/_view/#{view}?count=0`
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

    puts "Waiting for input:"
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

view_updater.rb doit être exécutable par CouchDB .
