#!/bin/bash

# Configuration
source project-config.sh

# Function to remove all stopped containers
remove_stopped_containers() {
  echo "Removing stopped containers..."
  docker container prune -f
}

# Function to remove all unused images
remove_unused_images() {
  echo "Removing unused images..."
  docker image prune -a -f
}

# Function to remove all unused volumes
remove_unused_volumes() {
  echo "Removing unused volumes..."
  docker volume prune -f
}

# Function to remove all unused networks
remove_unused_networks() {
  echo "Removing unused networks..."
  docker network prune -f
}

# Function to remove dangling images
remove_dangling_images() {
  echo "Removing dangling images..."
  docker images -f "dangling=true" -q | xargs -r docker rmi
}

# Function to remove all containers, images, networks, and volumes
remove_all() {
  echo "Removing all containers, images, networks, and volumes..."
  docker system prune -a -f --volumes
}

# Function to execute the chosen option locally
execute_locally() {
  case $1 in
    1)
      remove_stopped_containers
      ;;
    2)
      remove_unused_images
      ;;
    3)
      remove_unused_volumes
      ;;
    4)
      remove_unused_networks
      ;;
    5)
      remove_dangling_images
      ;;
    6)
      remove_all
      ;;
    7)
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option. Exiting..."
      exit 1
      ;;
  esac
}

# Function to execute the chosen option on the remote server via SSH
execute_remotely() {
  ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER << EOF
    case $1 in
      1)
        $(typeset -f remove_stopped_containers)
        remove_stopped_containers
        ;;
      2)
        $(typeset -f remove_unused_images)
        remove_unused_images
        ;;
      3)
        $(typeset -f remove_unused_volumes)
        remove_unused_volumes
        ;;
      4)
        $(typeset -f remove_unused_networks)
        remove_unused_networks
        ;;
      5)
        $(typeset -f remove_dangling_images)
        remove_dangling_images
        ;;
      6)
        $(typeset -f remove_all)
        remove_all
        ;;
      7)
        echo "Exiting..."
        exit 0
        ;;
      *)
        echo "Invalid option. Exiting..."
        exit 1
        ;;
    esac
EOF
}

# Display a menu to the user
echo "Docker Cleanup Script"
echo "======================"
echo "1. Remove stopped containers"
echo "2. Remove unused images"
echo "3. Remove unused volumes"
echo "4. Remove unused networks"
echo "5. Remove dangling images"
echo "6. Remove all containers, images, networks, and volumes"
echo "7. Exit"
echo -n "Choose an option [1-7]: "

read option

echo "Execution Mode"
echo "==============="
echo "1. Local"
echo "2. Remote"
echo -n "Choose execution mode [1-2]: "

read mode

case $mode in
  1)
    execute_locally $option
    ;;
  2)
    execute_remotely $option
    ;;
  *)
    echo "Invalid execution mode. Exiting..."
    exit 1
    ;;
esac

echo "Cleanup completed."
