#!/bin/bash

## ------------------------------------------------------------------
## CONFIGURATION ET GESTION DES ARGUMENTS
## ------------------------------------------------------------------

# V2.1 : Script avec ville par défaut si aucun argument n'est fourni
# TÂCHE V2.2 : Rendre le script "Cron-Safe"
# Détermine le chemin absolu où se trouve le script.
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Si aucun argument n'est fourni on utilise la ville de "Toulouse" par défaut
VILLE=${1:-"Toulouse"}

# Fichier local où sauvegarder les données brutes
FICHIER_BRUT="$SCRIPT_DIR/meteo_brute.txt"

## ------------------------------------------------------------------
## ÉTAPE 1 : RÉCUPÉRATION DES DONNÉES
## ------------------------------------------------------------------

# Utilise curl pour récupérer les données météorologiques
# -s : Mode silencieux (pas de barre de progression)
# "wttr.in/$VILLE" : L'URL du service, avec la variable VILLE
# > "$FICHIER_BRUT" : Redirige la sortie de curl vers le fichier local
curl -s "wttr.in/${VILLE}?2&T&lang=fr" > "$FICHIER_BRUT"

## ------------------------------------------------------------------
## ÉTAPE 2 : EXTRACTION DES DONNÉES
## ------------------------------------------------------------------

# --- Température actuelle ---
# Récupération des températures via wttr.in en format simple
# %t -> température actuelle
TEMP_ACTUELLE=$(curl -s "wttr.in/$VILLE?format=%t")

# --- Prévision du lendemain ---
PREVISION_DEMAIN=$(awk '
BEGIN {
    tab_count=0
    in_second=0
    max=""
}
/^┌/ && /┤/ {
    tab_count++
    if(tab_count==2) in_second=1
}
in_second {
    # ignorer les lignes sans °C ou contenant km/h, mm, km
    if($0 !~ /°C/ || $0 ~ /km\/h/ || $0 ~ /mm/ || $0 ~ / km/) next
    ligne=$0
    while(match(ligne, /[+-]?[0-9]+(\([0-9]+\))? ?°C/)) {
  	  temp=substr(ligne,RSTART,RLENGTH)
  	  gsub(/ ?°C/,"",temp)
  	  gsub(/\(.*\)/,"",temp)
  	  if(max=="" || temp>max) max=temp
  	  ligne=substr(ligne,RSTART+RLENGTH)
  	}
}
END {
    if(max!="") {
  	  printf "%+.0f°C\n", max
    } else {
  	  print "N/A"
    }
}
' "$FICHIER_BRUT")

## ------------------------------------------------------------------
## ÉTAPE 3 : FORMATAGE ET SAUVEGARDE (V3)
## ------------------------------------------------------------------

# --- Formatage ---
# Objectif: Rendre les infos lisibles

# Déclaration des variables DATE et HEURE
DATE=$(date +"%Y-%m-%d")
HEURE=$(date +"%H:%M")

# Format demandé : [Date] - [Heure] - Ville : [Temp] - [Prévision]
LIGNE_FORMATTEE="${DATE} - ${HEURE} - ${VILLE} : ${TEMP_ACTUELLE} - ${PREVISION_DEMAIN}"

# --- Gestion de l'historique (V3) ---

# 1. Définir le nom du fichier d'historique basé sur la date du jour (YYYYMMDD)
FICHIER_HISTORIQUE="$SCRIPT_DIR/meteo_$DATE.txt"

# 2. Enregistre les données dans le fichier du jour (en ajoutant >>)
echo "$LIGNE_FORMATTEE" >> "$FICHIER_HISTORIQUE"
    
# 3. Mettre à jour le message de confirmation
echo "Les données météo de la ville de $VILLE ont été enregistrées dans le fichier $FICHIER_HISTORIQUE."
