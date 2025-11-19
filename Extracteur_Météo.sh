#!/bin/bash

# ====================================================================
# CONFIGURATION DU PROJET (V2.0 / VARIANTE 3)
# ====================================================================

# Détermine le chemin absolu du script pour un usage sûr avec cron. (V2.2)
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Si aucun argument n'est fourni on utilise la ville de "Toulouse" par défaut. (V2.1)
VILLE=${1:-"Toulouse"} 

# Fichier de log et fichier brut temporaire (VARIANTE 3 / V1.1)
LOG_ERROR="$SCRIPT_DIR/meteo_error.log"
FICHIER_BRUT="$SCRIPT_DIR/meteo_brute.txt"

# Fonction pour enregistrer les erreurs avec timestamp (VARIANTE 3)
log_error() {
  local message="$1"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  echo "[$timestamp] - ERREUR: $message" >> "$LOG_ERROR"
}

# ====================================================================
# V1.1 : RÉCUPÉRATION DES DONNÉES BRUTES ET VÉRIFICATION DE L'ERREUR
# ====================================================================

# Utilise curl pour récupérer les données météorologiques brutes.
curl -s "wttr.in/${VILLE}?2&T&lang=fr" > "$FICHIER_BRUT"

# --- VARIANTE 3 : VÉRIFICATION DE LA CONNEXION ---
if [ $? -ne 0 ]; then
  # $? stocke le code de retour de la dernière commande (curl).
  log_error "Échec de la connexion à wttr.in ou données non reçues pour $VILLE."
  exit 1 # Quitter le script pour éviter de traiter des données vides
fi
# --- FIN VÉRIFICATION CONNEXION ---

# ====================================================================
# V1.2 / V1.3 / VARIANTE 1 : EXTRACTION DES MÉTRIQUES
# ====================================================================

# --- Température actuelle ---
# Récupération des températures via wttr.in en format simple
# %t -> température actuelle
TEMP_ACTUELLE=$(curl -s "wttr.in/$VILLE?format=%t")

# Extraction de la température actuelle (V1.2)
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

# --- CORRECTION VARIANTE 1 : EXTRACTION ROBUSTE (Fix N/A) ---

# 1. Extraction du Vent et de l'Humidité via l'API directe (plus fiable)
VENT=$(curl -s "wttr.in/$VILLE?format=%w&lang=fr" | xargs)
HUMIDITE=$(curl -s "wttr.in/$VILLE?format=%h&lang=fr" | xargs)

# 2. Extraction de la Visibilité depuis le fichier brut
# L'option -a force grep à lire le fichier comme du texte (évite les erreurs binaires)
VISIBILITE=$(grep -a "Visibilité" "$FICHIER_BRUT" | head -1 | sed 's/[^0-9]*\([0-9]* *km\).*/\1/' | xargs)

# Sécurisation des variables si non trouvées
VENT=${VENT:-"N/A"}
HUMIDITE=${HUMIDITE:-"N/A"}
VISIBILITE=${VISIBILITE:-"N/A"}

# ====================================================================
# V1.4 / V3.0 / VARIANTE 2 : FORMATAGE ET ARCHIVAGE TEXTE/JSON
# ====================================================================

# Déclaration des variables DATE et HEURE (V1.3)
DATE=$(date +"%Y-%m-%d")
HEURE=$(date +"%H:%M")

# Définition de la ligne formatée (V1.4 / VARIANTE 1)
LIGNE_FORMATTEE="${DATE} - ${HEURE} - ${VILLE} : ${TEMP_ACTUELLE} - ${PREVISION_DEMAIN} - Vent : ${VENT} - Humidité : ${HUMIDITE} - Visibilité : ${VISIBILITE}"

# Définition du nom de base du fichier d'historique (V3.0)
FICHIER_HISTORIQUE="$SCRIPT_DIR/meteo_$DATE.txt"

# Enregistre les données au format texte (append)
echo "$LIGNE_FORMATTEE" >> "$FICHIER_HISTORIQUE"
    
# Affichage du message de confirmation
echo "Les données météo de la ville de $VILLE ont été enregistrées dans le fichier $FICHIER_HISTORIQUE."

# Fichier météo JSON (VARIANTE 2)
FICHIER_METEO_JSON="meteo_$DATE.json"

# Si le fichier n'existe pas, on crée un fichier JSON vide (VARIANTE 2)
if [ ! -f "$FICHIER_METEO_JSON" ]; then
    echo "{}" > "$FICHIER_METEO_JSON"
fi

# On ajoute ou met à jour les données météo d'une ville passée en argument dans le fichier JSON (VARIANTE 2)
jq \
  --arg ville "$VILLE" \
  --arg date "$DATE" \
  --arg heure "$HEURE" \
  --arg temp_actuelle "$TEMP_ACTUELLE" \
  --arg prevision_demain "$PREVISION_DEMAIN" \
  --arg vent "$VENT" \
  --arg humidite "$HUMIDITE" \
  --arg visibilite "$VISIBILITE" \
  '.[$ville] = { 
      "date": $date,
      "heure": $heure,
      "temperature": $temp_actuelle,
      "prevision_demain": $prevision_demain,
      "vent": $vent,
      "humidite": $humidite,
      "visibilite": $visibilite
  }' "$FICHIER_METEO_JSON" > tmp.json && mv tmp.json "$FICHIER_METEO_JSON"

echo  "Les données météo de la ville de $VILLE ont été enregistrées dans le fichier météo JSON créé : $FICHIER_METEO_JSON."
