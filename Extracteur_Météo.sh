#!/bin/bash

# V1.2 : Extraction des températures actuelles et prévisions de demain
# Version simplifiée et fiable avec wttr.in ?format=

# Vérifie si l'utilisateur a fourni un nom de ville en argument
if [ -z "$1" ]; then
  echo "Erreur : Veuillez fournir un nom de ville en argument."
  echo "Exemple : ./Extracteur_Meteo.sh Toulouse"
  exit 1
fi

# Stocke l'argument (la ville)
VILLE=$1

# Récupération des températures via wttr.in en format simple
# %t -> température actuelle
# %T -> prévision pour demain
TEMP_ACTUELLE=$(curl -s "wttr.in/$VILLE?format=%t")
PREVISION_DEMAIN=$(curl -s "wttr.in/$VILLE?format=%T")

# Affiche les résultats
echo "Ville : $VILLE"
echo "Température actuelle : $TEMP_ACTUELLE"
echo "Prévision demain : $PREVISION_DEMAIN"

# Enregistre les résultats dans meteo.txt sur une seule ligne
DATE=$(date '+%Y-%m-%d')
HEURE=$(date '+%H:%M')
echo "$DATE - $HEURE - $VILLE : $TEMP_ACTUELLE - $PREVISION_DEMAIN" >> meteo.txt

echo "Données ajoutées dans meteo.txt."

