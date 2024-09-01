$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
# Create archive to copy to the server
. (Join-Path $SCRIPT_DIR "/deploy/server/create-archive-to-copy-server.ps1")

# Deploy the project to the server (copy the archive to the server and extract it) (docker-compose)
. (Join-Path $SCRIPT_DIR "/deploy/server/project-docker-compose.ps1")
