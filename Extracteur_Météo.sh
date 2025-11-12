#!/bin/bash

# V1.3: Script de base - Formater les informations + correction extraction température prévue pour le lendemain

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
curl -s "wttr.in/${VILLE}?2&T&lang=fr" > "$FICHIER_BRUT"

# Récupération des températures via wttr.in en format simple
# %t -> température actuelle
TEMP_ACTUELLE=$(curl -s "wttr.in/$VILLE?format=%t")
# 3. Extraction Prévision (partie corrigée)
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


# --- Formatage ---
# Objectif: Rendre les infos lisibles

DATE=$(date +"%Y-%m-%d")
HEURE=$(date +"%H:%M")

# Format demandé : [Date] - [Heure] - Ville : [Temp] - [Prévision]
LIGNE_FORMATTEE="${DATE} - ${HEURE} - ${VILLE} : ${TEMP_ACTUELLE} - ${PREVISION_DEMAIN}"

