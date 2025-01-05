#!/bin/bash

# Script pour créer un serveur HTTP Python pour le transfert de fichiers
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

# Obtenir l'adresse IP locale
LOCAL_IP=$(hostname -I | awk '{print $1}')

# Optionnel : Obtenir l'adresse IP publique
PUBLIC_IP=$(curl -s ifconfig.me)

# Lancer le serveur HTTP Python
echo "Démarrage du serveur HTTP Python sur le port $PORT..."
python3 -m http.server $PORT &

# Attendre un moment pour s'assurer que le serveur démarre
sleep 2

# Vérifier si le serveur est bien lancé
if lsof -i:$PORT &>/dev/null; then
    echo "Le serveur HTTP Python est en cours d'exécution."
    echo "URL locale : http://$LOCAL_IP:$PORT"
    if [ -n "$PUBLIC_IP" ]; then
        echo "URL publique : http://$PUBLIC_IP:$PORT"
    else
        echo "Impossible de déterminer l'adresse IP publique."
    fi
else
    echo "Échec du démarrage du serveur HTTP Python. Fin du script."
    exit 1
fi
