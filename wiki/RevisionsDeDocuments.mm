#language fr

Plutôt que d'écraser pas les documents mis à jour, CouchDB crée un nouveau document à la fin du fichier de base de données, avec la même  `_id` et un nouvel identifiant `_rev`. Ce type de stockage est gourmand, aussi un [[Compactage]] régulier est nécessaire pour libérer de l'espace disque. Les anciennes révisions ne sont pas disponibles pour les [[Vues]].

Les révisions de documents sont utilisées pour un controle optimisé de la concurrence. Si vous tentez de mettre à jour un document en utilisant une ancienne révision, un conflit sera levée. Ces conflits doivent être résolus par votre client, géneralement en demandant une nouvelle version du document, la modifiant et en tentant une nouvelle mise à jour.


@@ En quoi est-ce lié aux conflits lors d'une réplicaton ?

=== Historique des révisions ===

'''Vous ne pouvez pas vous appuyer sur les révisions de documents pour autre chose que le controle de la concurrence.'''

En effet, avec la compation les révisions peuvent disparaître à tous moments. Vous ne pouvez donc les utiliser pour un système de révisions client.

Si vous souhaitez implémenter un système de révision client, différentes méthodes ont été suggérées :

 * Utiliser les attachements pour stocker les anciennes révisions.
 * UUtiliser différents documents pour stocker les anciennes révisions.

@@ Merci d'ajouter à cette liste les solutions qui pourraient convenir selon vous
