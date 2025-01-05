#!/bin/bash

# Script pour gérer un serveur HTTP Python

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

# Définir le port utilisé pour le serveur
PORT=8000

# Vérifier s'il existe déjà une instance de serveur HTTP Python
SERVER_PID=$(ps aux | grep "[p]ython3 -m http.server $PORT" | awk '{print $2}')

if [ -n "$SERVER_PID" ]; then
    echo "Un serveur HTTP Python est déjà en cours d'exécution sur le port $PORT (PID : $SERVER_PID)."
    read -p "Souhaitez-vous arrêter ce serveur ? (y/n) : " CHOICE

    if [[ "$CHOICE" == "y" || "$CHOICE" == "Y" ]]; then
        echo "Arrêt du serveur avec PID $SERVER_PID..."
        kill -9 $SERVER_PID
        echo "Le serveur a été arrêté."
        echo "Fin du script."
        exit 0
    else
        echo "Le serveur existant reste actif. Fin du script."
        exit 0
    fi
else
    echo "Aucun serveur HTTP Python n'est actuellement en cours d'exécution sur le port $PORT."
fi

# Lancer un nouveau serveur HTTP Python
echo "Démarrage du serveur HTTP Python sur le port $PORT..."
python3 -m http.server $PORT &

# Attendre un moment pour s'assurer que le serveur démarre
sleep 2

# Vérifier si le serveur a bien démarré
NEW_SERVER_PID=$(ps aux | grep "[p]ython3 -m http.server $PORT" | awk '{print $2}')

if [ -n "$NEW_SERVER_PID" ]; then
    # Obtenir l'adresse IP locale
    LOCAL_IP=$(hostname -I | awk '{print $1}')

    # Optionnel : Obtenir l'adresse IP publique
    PUBLIC_IP=$(curl -s ifconfig.me)

    echo "Le serveur HTTP Python est en cours d'exécution (PID : $NEW_SERVER_PID)."
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
