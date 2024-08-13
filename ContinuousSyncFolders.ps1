param (
    [string]$SourceFolder,
    [string]$ReplicaFolder,
    [string]$LogFile,
    [int]$IntervalSeconds = 10
)

function Log-Message {
    param (
        [string]$Message
    )
    # Log the message to the console
    Write-Output $Message
    # Log the message to the log file with a timestamp
    Add-Content -Path $LogFile -Value ("[$(Get-Date)] $Message")
}

function Sync-Folders {
    param (
        [string]$Source,
        [string]$Replica
    )
    
    # Get all files and folders from the source and replica folders
    $sourceItems = Get-ChildItem -Path $Source -Recurse
    $replicaItems = Get-ChildItem -Path $Replica -Recurse

    # Create a hash table for quick lookup of replica items
    $replicaHashTable = @{}
    foreach ($item in $replicaItems) {
        $relativePath = $item.FullName.Substring($Replica.Length + 1)
        $replicaHashTable[$relativePath] = $item
    }

    # Synchronize files and folders from source to replica
    foreach ($item in $sourceItems) {
        $relativePath = $item.FullName.Substring($Source.Length + 1)
        $targetPath = Join-Path $Replica $relativePath

        if (-not (Test-Path -Path $targetPath)) {
            # Copy new files and folders from source to replica
            if ($item.PSIsContainer) {
                # Create the folder in replica
                New-Item -ItemType Directory -Path $targetPath
                Log-Message "Created folder: $relativePath"
            } else {
                # Copy the file to replica
                Copy-Item -Path $item.FullName -Destination $targetPath
                Log-Message "Created file: $relativePath"
            }
        } else {
            # If the file exists, check if it needs to be updated
            if (-not $item.PSIsContainer) {
                $sourceFileHash = Get-FileHash -Path $item.FullName -Algorithm SHA256
                $replicaFileHash = Get-FileHash -Path $targetPath -Algorithm SHA256

                if ($sourceFileHash.Hash -ne $replicaFileHash.Hash) {
                    Copy-Item -Path $item.FullName -Destination $targetPath -Force
                    Log-Message "Updated file: $relativePath"
                }
            }
        }

        # Remove the item from the replica hash table
        $replicaHashTable.Remove($relativePath)
    }

    # Remove files and folders that are in the replica but not in the source
    foreach ($key in $replicaHashTable.Keys) {
        $replicaItem = $replicaHashTable[$key]

        if ($replicaItem.PSIsContainer) {
            Remove-Item -Path $replicaItem.FullName -Recurse -Force
            Log-Message "Removed folder: $key"
        } else {
            Remove-Item -Path $replicaItem.FullName -Force
            Log-Message "Removed file: $key"
        }
    }
}

# Validate the provided paths
if (-not $SourceFolder) {
    Write-Warning "Source folder path is not provided. Exiting script."
    exit 1
}

if (-not (Test-Path -Path $SourceFolder)) {
    Write-Error "Source folder '$SourceFolder' does not exist. Exiting script."
    exit 1
}

if (-not $ReplicaFolder) {
    Write-Warning "Replica folder path is not provided. Exiting script."
    exit 1
}

if (-not $LogFile) {
    $scriptPath = $PSScriptRoot
    $LogFile = Join-Path -Path $scriptPath -ChildPath "SyncLog.log"
    Write-Warning "Log file path is not provided. Logging to default location: $LogFile"
}

# Ensure Replica folder exists, create it if not
if (-not (Test-Path -Path $ReplicaFolder)) {
    New-Item -ItemType Directory -Path $ReplicaFolder
    Log-Message "Replica folder '$ReplicaFolder' did not exist and was created."
}

# Start the continuous synchronization loop
Log-Message "Starting continuous synchronization from '$SourceFolder' to '$ReplicaFolder' with an interval of $IntervalSeconds seconds."

while ($true) {
    try {
        # Check if the Source folder is missing and exit if necessary
        if (-not (Test-Path -Path $SourceFolder)) {
            Log-Message "Source folder '$SourceFolder' was not found, it was either moved or deleted. Exiting script."
            exit 1
        }

        # Check if the Replica folder is missing and recreate if necessary
        if (-not (Test-Path -Path $ReplicaFolder)) {
            New-Item -ItemType Directory -Path $ReplicaFolder
            Log-Message "Replica folder '$ReplicaFolder' was not found and has been recreated."
        }

        # Perform synchronization
        Sync-Folders -Source $SourceFolder -Replica $ReplicaFolder
        Log-Message "Synchronization cycle completed."
    } catch {
        Log-Message "Error during synchronization: $_"
    }

    Start-Sleep -Seconds $IntervalSeconds
}
