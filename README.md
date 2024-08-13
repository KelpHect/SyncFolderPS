# Continuous Folder Synchronization Script

This repository contains a PowerShell script designed to continuously synchronize a source folder with a replica folder. The script ensures that the replica folder maintains a full, identical copy of the source folder. It supports logging operations and handles scenarios where folders are added, updated, or removed.

## Features

- **Continuous Synchronization**: Keeps the replica folder in sync with the source folder in real time.
- **Logging**: Logs all file creation, copying, removal, and folder operations to a specified log file and the console.
- **Folder Existence Checks**: Recreates the replica folder if it is removed during execution and exits if the source folder is removed.
- **Parameter Validation**: Ensures that all required paths are provided and valid.

## Script Overview

The script performs the following tasks:

1. **Initialization**:
   - Checks if the provided `SourceFolder`, `ReplicaFolder`, and `LogFile` paths are valid.
   - Creates the `ReplicaFolder` if it does not exist.

2. **Continuous Synchronization Loop**:
   - Periodically checks for changes in the `SourceFolder` and updates the `ReplicaFolder` accordingly.
   - Handles scenarios where the `SourceFolder` or `ReplicaFolder` might be removed or recreated during execution.

3. **Logging**:
   - Logs all operations to the specified log file and the console.

## Usage

To use the script, follow these steps:

1. **Run the Script**:
   Open a PowerShell prompt and navigate to the script directory. Execute the script with the required parameters:

   ```powershell
   .\ContinuousSyncFolders.ps1 -SourceFolder "C:\Path\To\Source" -ReplicaFolder "C:\Path\To\Replica" -LogFile "C:\Path\To\LogFile.log" -IntervalSeconds 10
   ```

   - `-SourceFolder` (string): Path to the source folder to be synchronized.
   - `-ReplicaFolder` (string): Path to the replica folder where the source folder will be synchronized.
   - `-LogFile` (string): Path to the log file where synchronization operations will be logged. If not provided, the script logs to a default file named `SyncLog.log` in the script directory.
   - `-IntervalSeconds` (int): Time interval (in seconds) between synchronization cycles. Default is 10 seconds.

## Example

```powershell
.\ContinuousSyncFolders.ps1 -SourceFolder "C:\Source" -ReplicaFolder "D:\Replica" -LogFile "C:\Logs\SyncLog.log" -IntervalSeconds 30
```

This command will synchronize the `C:\Source` folder with the `D:\Replica` folder every 30 seconds and log the operations to `C:\Logs\SyncLog.log`.

## Error Handling

- **Missing Source Folder**: If the `SourceFolder` is removed, the script will log a warning message and exit.
- **Missing Replica Folder**: If the `ReplicaFolder` is removed during execution, the script will recreate it and log the event.

## Contribution

Feel free to submit issues or pull requests if you encounter any problems or have suggestions for improvements.

## License

This script is released under the MIT License. See the [LICENSE](LICENSE) file for more details.
