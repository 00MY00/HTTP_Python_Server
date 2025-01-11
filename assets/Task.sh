#!/bin/bash

# Définir le répertoire racine
ROOT_DIR="/tmp/http_root"
LOG_FILE="$ROOT_DIR/server.log"

# Vérifier si le répertoire existe
if [ ! -d "$ROOT_DIR" ]; then
    echo "$(date): Le répertoire $ROOT_DIR n'existe pas. Fin du script." >> "$LOG_FILE"
    exit 1
fi

# Initialiser le fichier de log
echo "$(date): Début de la vérification des fichiers dans $ROOT_DIR." >> "$LOG_FILE"

# Vérifier les fichiers dans le répertoire
for FILE in "$ROOT_DIR"/*; do
    # Ignorer si ce n'est pas un fichier
    if [ ! -f "$FILE" ]; then
        continue
    fi

    # Extraire le nom de fichier
    FILENAME=$(basename "$FILE")

    # Vérifier si le nom contient déjà 'MD5='
    if [[ "$FILENAME" == *MD5=* ]]; then
        echo "$(date): Le fichier \"$FILENAME\" contient déjà un hash MD5. Ignoré." >> "$LOG_FILE"
        continue
    fi

    # Calculer le hash MD5 du fichier
    MD5_HASH=$(md5sum "$FILE" | awk '{print $1}')

    # Renommer le fichier en ajoutant 'MD5=<hash>'
    NEW_FILENAME="${FILENAME}_MD5=${MD5_HASH}"
    mv "$FILE" "$ROOT_DIR/$NEW_FILENAME"
    echo "$(date): Le fichier \"$FILENAME\" a été renommé en \"$NEW_FILENAME\"." >> "$LOG_FILE"
done

echo "$(date): Fin de la vérification des fichiers dans $ROOT_DIR." >> "$LOG_FILE"
