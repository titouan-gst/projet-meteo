# Projet d'extraction Météo

Ceci est un script Shell pour extraire les données météo de wttr.in.

## Objectif
L'objectif est d'extraire la température actuelle et les prévisions du lendemain pour une ville donnée.

## Membres de l'équipe
* Membre 1
* Membre 2
* Membre 3
* Membre 4

## Configuration d'une tâche cron
Pour automatiser l’exécution de notre script, nous utilisons cron, l’outil de planification des tâches sous Linux. 
La première étape consiste à ouvrir la table de planification de l’utilisateur avec la commande crontab -e. Une fois l’éditeur ouvert, il suffit d’ajouter une ligne indiquant quand et comment le script doit être exécuté. Par exemple, pour lancer automatiquement le script chaque heure, il est nécessaire d’utiliser le chemin absolu vers le script, car en effet, cron ne s’exécute pas depuis le dossier du projet.
Il est important de remplacer le chemin absolu par le chemin réel du dossier contenant le script (que l’on peut obtenir avec la commande pwd). L’utilisation d’un chemin complet garantit que cron retrouve correctement le script, même lorsqu’il s’exécute sans environnement utilisateur habituel.
La redirection >> cron.log 2>&1 permet d’enregistrer à la fois la sortie standard et les éventuelles erreurs dans un fichier de log. Il est également possible d’indiquer une ville en argument, par exemple : 0 * * * * /chemin/vers/Extracteur_Meteo.sh Paris
sans quoi la ville par défaut (Toulouse) sera utilisée.
Enfin, pour vérifier que la tâche a bien été enregistrée, il suffit d’utiliser la commande crontab -l, qui affiche l’ensemble des tâches planifiées pour l’utilisateur. Cette configuration permet donc d’automatiser entièrement la collecte des données météorologiques.
