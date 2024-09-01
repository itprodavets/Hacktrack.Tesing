#!/bin/bash

# Configuration
source project-config.sh

# Check if the network exists
if [ ! "$(docker network ls | grep $DOCKER_NETWORK_NAME)" ]; then
  echo "Creating Docker Network..."
  sudo docker network create $DOCKER_NETWORK_NAME
else
  echo "Docker Network already exists."
fi

# Docker compose Down
echo "Stopping Docker Compose..."
docker compose -f $PROJECT_SOURCE/$DOCKER_FOLDER/$DOCKER_COMPOSE_DEV_FILE -f $PROJECT_SOURCE/$DOCKER_FOLDER/$DOCKER_COMPOSE_PROD_FILE down

# Docker compose Build
echo "Building Docker Compose..."
docker compose -f $PROJECT_SOURCE/$DOCKER_FOLDER/$DOCKER_COMPOSE_DEV_FILE -f $PROJECT_SOURCE/$DOCKER_FOLDER/$DOCKER_COMPOSE_PROD_FILE build

# Docker compose Up
echo "Starting Docker Compose..."
docker compose -f $PROJECT_SOURCE/$DOCKER_FOLDER/$DOCKER_COMPOSE_DEV_FILE -f $PROJECT_SOURCE/$DOCKER_FOLDER/$DOCKER_COMPOSE_PROD_FILE up -d
