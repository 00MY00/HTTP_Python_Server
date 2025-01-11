#!/bin/bash

# Script pour gérer un serveur HTTP Python

# Définir le port utilisé pour le serveur
PORT=8000

# Créer un dossier spécifique dans /tmp comme racine du serveur
ROOT_DIR="/tmp/http_root"
Root= $PWD


echo "Voulez-vous afficher l'IP Public ? (y/N)"
read -r CHOICE


if [ ! -d "$ROOT_DIR" ]; then
    echo "Création du dossier racine du serveur : $ROOT_DIR"
    mkdir "$ROOT_DIR"
else
    echo "Le dossier racine $ROOT_DIR existe déjà."
fi

# Vérifier si Python est installé et fonctionnel
if command -v python3 &>/dev/null; then
    echo "Python3 est installé."
else
    echo "Python3 n'est pas installé. Fin du script."
    exit 1
fi

# Vérifier s'il existe déjà une instance de serveur HTTP Python
SERVER_PID=$(ps aux | grep "[p]ython3 -m http.server $PORT" | awk '{print $2}')

if [ -n "$SERVER_PID" ]; then
    echo "Un serveur HTTP Python est déjà en cours d'exécution sur le port $PORT (PID : $SERVER_PID)."
    read -p "Souhaitez-vous arrêter ce serveur ? (y/n) : " CHOICE

    if [[ "$CHOICE" == "y" || "$CHOICE" == "Y" ]]; then
        echo "Arrêt du serveur avec PID $SERVER_PID..."
        kill -9 $SERVER_PID
        echo "Le serveur a été arrêté."
        
        # Supprimer la tâche automatique associée
        TASK_PID=$(ps aux | grep "[t]ask_while_server_running" | awk '{print $2}')
        if [ -n "$TASK_PID" ]; then
            echo "Arrêt de la tâche automatique associée (PID : $TASK_PID)..."
            kill -9 "$TASK_PID"
            echo "Tâche automatique arrêtée."
        fi

        echo "Fin du script."
        exit 0
    else
        echo "Le serveur existant reste actif. Fin du script."
        exit 0
    fi
else
    echo "Aucun serveur HTTP Python n'est actuellement en cours d'exécution sur le port $PORT."
fi

# Lancer un nouveau serveur HTTP Python avec le dossier racine spécifié
echo "Démarrage du serveur HTTP Python dans le dossier $ROOT_DIR sur le port $PORT..."
python3 -m http.server $PORT --directory "$ROOT_DIR" &

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
    if [[ "$CHOICE" == "y" || "$CHOICE" == "Y" ]]; then
        PUBLIC_IP=$(curl -s ifconfig.me)
        if [ -n "$PUBLIC_IP" ]; then
            echo "Votre IP publique est : $PUBLIC_IP"
        else
            echo "Impossible de récupérer l'IP publique."
        fi
    else
        echo "Affichage de l'IP publique annulé."
    fi

    # Tâche automatique pendant que le serveur est actif
    task_while_server_running() {
        while ps -p "$NEW_SERVER_PID" > /dev/null 2>&1; do
            echo "Le serveur est toujours actif. Exécution d'une tâche automatique..."
            
            # Écrire dans le fichier journal
            echo "$(date): Le serveur est actif (PID : $NEW_SERVER_PID)" >> "$ROOT_DIR/server.log"
            
            # Exécuter le script Task.sh
            if [ -f "$Root/assets/Task.sh" ]; then
                echo "Exécution de Task.sh..."
                bash "$Root/assets/Task.sh"
            else
                echo "Le script Task.sh est introuvable dans '$Root/assets/Task.sh'."
            fi
            
            # Intervalle entre chaque exécution
            sleep 10
        done
        echo "Le serveur s'est arrêté. Fin de la tâche automatique."
    }


    # Lancer la tâche automatique en arrière-plan
    task_while_server_running &
else
    echo "Échec du démarrage du serveur HTTP Python. Fin du script."
    exit 1
fi
