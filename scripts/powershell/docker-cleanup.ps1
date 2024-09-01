# Загрузка конфигурации
. ./config.ps1

# Функция для удаления всех остановленных контейнеров
function Remove-StoppedContainers {
    Write-Output "Removing stopped containers..."
    docker container prune -f
}

# Функция для удаления всех неиспользуемых образов
function Remove-UnusedImages {
    Write-Output "Removing unused images..."
    docker image prune -a -f
}

# Функция для удаления всех неиспользуемых томов
function Remove-UnusedVolumes {
    Write-Output "Removing unused volumes..."
    docker volume prune -f
}

# Функция для удаления всех неиспользуемых сетей
function Remove-UnusedNetworks {
    Write-Output "Removing unused networks..."
    docker network prune -f
}

# Функция для удаления висячих образов
function Remove-DanglingImages {
    Write-Output "Removing dangling images..."
    docker images --filter "dangling=true" --quiet | ForEach-Object { docker rmi $_ }
}

# Функция для удаления всех контейнеров, образов, сетей и томов
function Remove-All {
    Write-Output "Removing all containers, images, networks, and volumes..."
    docker system prune -a -f --volumes
}

# Функция для выполнения выбранной опции локально
function Execute-Locally {
    param (
        [int]$option
    )

    switch ($option) {
        1 { Remove-StoppedContainers }
        2 { Remove-UnusedImages }
        3 { Remove-UnusedVolumes }
        4 { Remove-UnusedNetworks }
        5 { Remove-DanglingImages }
        6 { Remove-All }
        7 {
            Write-Output "Exiting..."
            exit
        }
        default {
            Write-Output "Invalid option. Exiting..."
            exit 1
        }
    }
}

# Функция для выполнения выбранной опции на удаленном сервере через SSH
function Execute-Remotely {
    param (
        [int]$option
    )

    $bashCommand = @"
case $option in
    1)
        docker container prune -f
        ;;
    2)
        docker image prune -a -f
        ;;
    3)
        docker volume prune -f
        ;;
    4)
        docker network prune -f
        ;;
    5)
        docker images -f "dangling=true" -q | xargs -r docker rmi
        ;;
    6)
        docker system prune -a -f --volumes
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
"@

    # Удаление возвратов каретки
    $bashCommand = $bashCommand -replace "`r", ""

    ssh -p $SSH_PORT $SSH_USER@$SSH_SERVER $bashCommand
}

# Отображение меню для пользователя
Write-Output "Docker Cleanup Script"
Write-Output "======================"
Write-Output "1. Remove stopped containers"
Write-Output "2. Remove unused images"
Write-Output "3. Remove unused volumes"
Write-Output "4. Remove unused networks"
Write-Output "5. Remove dangling images"
Write-Output "6. Remove all containers, images, networks, and volumes"
Write-Output "7. Exit"
$option = Read-Host "Choose an option [1-7]"

Write-Output "Execution Mode"
Write-Output "==============="
Write-Output "1. Local"
Write-Output "2. Remote"
$mode = Read-Host "Choose execution mode [1-2]"

switch ($mode) {
    1 { Execute-Locally $option }
    2 { Execute-Remotely $option }
    default {
        Write-Output "Invalid execution mode. Exiting..."
        exit 1
    }
}

Write-Output "Cleanup completed."
