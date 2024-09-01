# Load configuration
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $SCRIPT_DIR "../../config.ps1")

# Create archive
Write-Output "Creating archive..."
$archiveCommand = "tar -czvf `"$PROJECT_SOURCE\$ARCHIVE_NAME`" -C `"$PROJECT_SOURCE`" --exclude=`"node_modules`" --exclude=`".git`" --exclude=`".idea`" --exclude=`".next`" --exclude=`".env`" --exclude=`".env.local`" --exclude=`".env.development`" . --verbose ."
Invoke-Expression $archiveCommand

# Removing the project folder on the server
Write-Output "Removing the project folder on the server..."

$sshCommandRemove = "if [ -d `"$SERVER_PATH_PROJECT`" ]; then echo `"`"Directory exists. Removing...`"`"; rm -rf `"$SERVER_PATH_PROJECT`"; fi"
$sshCommandCreate = "echo `"`"Creating new directory...`"`"; mkdir -p `"$SERVER_PATH_PROJECT`""

ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $sshCommandRemove
ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $sshCommandCreate

# Copy the archive to the server
Write-Output "Copying the archive to the server..."
scp -P $SSH_PORT "${PROJECT_SOURCE}\${ARCHIVE_NAME}" "$( $SSH_USER )@$( $SSH_SERVER ):$SERVER_TMP_PATH"

# Unpack archive on server and remove it
Write-Output "Unpacking archive on the server..."

$sshCommandUnpack = "echo `"`"Unpacking archive...`"`"; tar -xzvf `"$SERVER_TMP_PATH/$ARCHIVE_NAME`" -C `"$SERVER_PATH_PROJECT`"; echo `"`"Removing archive...`"`"; rm -rf `"$SERVER_TMP_PATH/$ARCHIVE_NAME`""

ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $sshCommandUnpack

# Remove local archive
Write-Output "Removing local archive..."
Remove-Item "$PROJECT_SOURCE\$ARCHIVE_NAME"