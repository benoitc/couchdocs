#language fr

Une liste concise des [[http://bitworking.org/projects/URI-Templates/|modèles d'URI]] clés de CouchDB.

Pour voir la liste des bases de données :

  http://localhost:5984/_all_dbs

Pour obtenir des informations de bases sur une base de données :

  http://localhost:5984/nombd/

Pour obtenir une liste de tous les documents d'une base de données:

  http://localhost:5984/nombd/_all_docs

Pour obtenir un document :

  http://localhost:5984/nombd/docid

Pour télécharger un fichier attaché :

  http://localhost:5984/nombd/docid/_bin/filename

Pour voir tous les documents design d'une base de données :

  http://localhost:5984/nombd/_design

Pour obtenir un document design :

  http://localhost:5984/nombd/_design/designdocid

Pour obtenir une vue :

  http://server/nombd/_design/designdocid/viewname
