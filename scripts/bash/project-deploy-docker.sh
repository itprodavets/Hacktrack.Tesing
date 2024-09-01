#!/bin/bash

# Configuration
source project-config.sh

# Create archive
tar -czvf "$PROJECT_SOURCE/$ARCHIVE_NAME" -C $PROJECT_SOURCE --exclude='node_modules' --exclude='.git' --exclude='.idea' --exclude='.next' --exclude='.env' --exclude='.env.local'  --exclude='.env.development' . --verbose .

# Removing the project folder on the server
echo "Removing the project folder on the server..."
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER << EOF

if [ -d "$SERVER_PATH_PROJECT" ]; then
    echo "Directory exists. Removing..."
    rm -rf $SERVER_PATH_PROJECT
fi
  echo "Creating new directory..."
  mkdir -p $SERVER_PATH_PROJECT

EOF

# Copy the archive to the server
echo "Copying the archive to the server..."
scp -P $SSH_PORT "$PROJECT_SOURCE/$ARCHIVE_NAME" $SSH_USER@$SSH_SERVER:$SERVER_TMP_PATH

# Unpack archive on server and remove it
echo "Unpacking archive on the server..."
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER << EOF

  echo "Unpacking archive..."
  tar -xzvf $SERVER_TMP_PATH/$ARCHIVE_NAME -C $SERVER_PATH_PROJECT

  echo "Removing archive..."
  rm -rf $SERVER_TMP_PATH/$ARCHIVE_NAME

EOF

# Docker compose
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER << EOF

# check if the network exists
if [ ! "$(docker network ls | grep $DOCKER_NETWORK_NAME)" ]; then
  echo "Creating Docker Network..."
  sudo docker network create $DOCKER_NETWORK_NAME
else
  echo "Docker Network already exists."
fi

# Docker compose Down
echo "Stopping Docker Compose..."
sudo docker compose -f $SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_DEV_FILE -f $SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_PROD_FILE down

# Docker compose Build
echo "Building Docker Compose..."
sudo docker compose -f $SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_DEV_FILE -f $SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_PROD_FILE build

# Docker compose Up
echo "Starting Docker Compose..."
sudo docker compose -f $SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_DEV_FILE -f $SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_PROD_FILE up -d

# Removing the project folder on the server
echo "Removing the project folder on the server..."
rm -rf $SERVER_PATH_PROJECT

EOF

echo "Removing archive..."
rm $PROJECT_SOURCE/$ARCHIVE_NAME
