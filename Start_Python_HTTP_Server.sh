#!/bin/bash

# Script to reat a python HTTP server to help files transfèr to the victim

# Vérifier si /tmp existe
if [ -d "/tmp" ]; then
    echo "Le répertoire /tmp existe."
    cd /tmp
else
    echo "Le répertoire /tmp n'existe pas. Fin du script."
    exit 1
fi

# Vérifier si Python est installé et fonctionnel
if command -v python3 &>/dev/null; then
    echo "Python3 est installé."
else
    echo "Python3 n'est pas installé. Fin du script."
    exit 1
fi

# Vérifier si le port 8000 est disponible
PORT=8000
if lsof -i:$PORT &>/dev/null; then
    echo "Le port $PORT est déjà utilisé. Fin du script."
    exit 1
else
    echo "Le port $PORT est disponible."
fi

# Lancer le serveur HTTP Python
echo "Démarrage du serveur HTTP Python sur le port $PORT..."
python3 -m http.server $PORT &
echo "Le serveur HTTP Python est en cours d'exécution."





