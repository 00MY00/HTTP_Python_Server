#!/bin/bash

# Définir le port utilisé pour le serveur
PORT=8000

# Vérifier si le serveur Python est en cours d'exécution sur le port spécifié
SERVER_PID=$(ps aux | grep "[p]ython3 -m http.server $PORT" | awk '{print $2}')

if [ -n "$SERVER_PID" ]; then
    echo "Le serveur HTTP Python est en cours d'exécution sur le port $PORT (PID : $SERVER_PID)."
    echo "Fermeture du serveur..."
    kill -9 "$SERVER_PID"
    echo "Le serveur a été arrêté."
else
    echo "Aucun serveur HTTP Python n'est en cours d'exécution sur le port $PORT."
fi
