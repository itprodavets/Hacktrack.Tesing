# Load configuration
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $SCRIPT_DIR "../../config.ps1")

$pathDockerComposeFile = "$SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_DEV_FILE"
$pathDockerComposeProdFile = "$SERVER_PATH_PROJECT/$DOCKER_FOLDER/$DOCKER_COMPOSE_PROD_FILE"

$dockerNetworkCreateCommand = "if [ ! `"(docker network ls | grep `"$DOCKER_NETWORK_NAME`")`" ]; then echo 'Creating Docker Network...'; sudo docker network create '$DOCKER_NETWORK_NAME'; else echo 'Docker Network already exists.'; fi"

$dockerComposeDownCommand = "sudo docker compose -f '$pathDockerComposeFile' -f '$pathDockerComposeProdFile' down"
$dockerComposeBuildCommand = "sudo docker compose -f '$pathDockerComposeFile' -f '$pathDockerComposeProdFile' build"
$dockerComposeUpCommand = "sudo docker compose -f '$pathDockerComposeFile' -f '$pathDockerComposeProdFile' up -d"

$removeProjectFolderCommand = "rm -rf '$SERVER_PATH_PROJECT'"

# Execute the command on the server (create a Docker network)
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $dockerNetworkCreateCommand

# Execute the command on the server (stop and remove containers)
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $dockerComposeDownCommand

# Execute the command on the server (build the project)
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $dockerComposeBuildCommand

# Execute the command on the server (start the project)
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $dockerComposeUpCommand

# Execute the command on the server (remove the project folder)
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $removeProjectFolderCommand
