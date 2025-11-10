#!/bin/bash

# V1.1: Script de base - Récupération des données brutes

# Vérifie si l'utilisateur a fourni un nom de ville en argument
if [ -z "$1" ]; then
  # Si $1 (le premier argument) est vide, affiche un message d'erreur
  echo "Erreur : Veuillez fournir un nom de ville en argument."
  echo "Exemple : ./Extracteur_Météo.sh Toulouse"
  # Quitte le script avec un code d'erreur
  exit 1
fi

# Stocke l'argument (la ville) dans une variable pour plus de clarté
VILLE=$1

# Fichier local où sauvegarder les données brutes
FICHIER_BRUT="meteo_brute.txt"

# Utilise curl pour récupérer les données météorologiques
# -s : Mode silencieux (pas de barre de progression)
# "wttr.in/$VILLE" : L'URL du service, avec la variable VILLE
# > "$FICHIER_BRUT" : Redirige la sortie de curl vers le fichier local
curl -s "wttr.in/$VILLE" > "$FICHIER_BRUT"

echo "Données brutes pour $VILLE sauvegardées dans $FICHIER_BRUT."
