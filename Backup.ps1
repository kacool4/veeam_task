
<#

 Author: Dimitrios Kakoulidis
 Date Create : 27-03-2024
 Last Update : 27-03-2024
 Version: 1.0

 .Description 
   Script is making exact copy of a source location to destination.
   - If file or fodler exists on destination folder but not on source then it will be removed
   - If file exists on source and not on destination then it will be copied in the destination folder
   - If file exists on both folders and it is  exactly the same then it will be skipped 
   - If file on source folder is newer the script will replace the old file on destination with the new updated version
  
 .Output
   - In the end you will have an export BCKLogs_Currentdate.csv file that shows all the actions (copied, skipped, create, delete) of each file and folder
  
 .Format
   - Backup.ps1 -Source <foldername> - Destination <fodlername> -logpath <logpathlocation> 
#> 



### Parameters that are needed when you run the script
param (
    [string]$source,
    [string]$destination,
    [string]$logpath,
    [switch]$help,
    [switch]$version,
    [switch]$about
)


### Variables for source and destination folders and variables for log files and location to be saved.

$sourceFolder = $source
$destinationFolder = $destination
$logpathFolder = $logpath
$logs = @()


### Triggered with the argument -version

If ($version){
  Write-output 'Backup Tool Version 1.0'
  Exit
}


### Triggered with the argument -Help

If ($help){  
  Write-Host " This script will make exact copy of a source folder to a destination folder`n", 
             "  You can run it with the following format `n"
  Write-Host  "Backup.ps1 -source " -ForegroundColor Green -NoNewline;
  Write-Host "<put source folder>" -ForegroundColor Yellow -NoNewline; 
  Write-Host " -destination" -ForegroundColor Green -NoNewline;
  Write-Host " <put destination folder>" -ForegroundColor Yellow -NoNewline;
  Write-Host " -logpath" -ForegroundColor Green -NoNewline;
  Write-Host " <put log file folder>" -ForegroundColor Yellow
  Exit
}


### Triggered with the argument -about

If ($about){
  Write-output "Author: Dimitrios Kakoulidis
 Date Create : 27-03-2024
 Last Update : 27-03-2024
 Version: 1.0

 .Description 
   Script is making exact copy of a source location to destination.
   - If file or fodler exists on destination folder but not on source then it will be removed
   - If file exists on source and not on destination then it will be copied in the destination folder
   - If file exists on both folders and it is  exactly the same then it will be skipped 
   - If file on source folder is newer the script will replace the old file on destination with the new updated version
  
 .Output
   - In the end you will have an export BCKLogs_Currentdate.csv file that shows all the actions (copied, skipped, create, delete) of each file and folder
   
 .Format
   - Backup.ps1 -Source <foldername> - Destination <fodlername> -logpath <logpathlocation>"
  Exit
}

### Check if the argument source is given. If not it will prompt for to input the path.

if ($sourceFolder.Length -eq 0 -or $sourceFolder -eq $null -or $sourceFolder -eq '') {
    Write-host "You haven't provide the source folder."
    $sourceFolder = Read-Host "Please enter the Source Path "
}
 

### Check if the argument destination is given. If not it will prompt for to input the path.

if ($destinationFolder.Length -eq 0 -or $destinationFolder -eq $null -or $destinationFolder -eq '') {
    Write-host "You haven't provide the destination folder."
    $destinationFolder = Read-Host "Please enter the Destination Path "
  
}

### Check if argument Log path is given. If not it will prompt for to input the path.

if ($logpathFolder.Length -eq 0 -or $logpathFolder -eq $null -or $logpathFolder -eq '') {
   Write-host "You haven't provide the  folder." 
   $logpathFolder = Read-Host "Please enter the Log Path "
}


### Check if the give log path exists. If not then it will create it.

if (-not (Test-Path -Path $logpathFolder)) {
  New-Item -ItemType Directory -Path $logpathFolder | Out-Null
  Write-Host "Folder $logpathFolder for storing log file is created as it does not exist."
}

### Check if the give source exists. If not then it throws an error message

if (-not (Test-Path -Path $sourceFolder)) {
    Write-output "Source folder does not exist, Please check and run again the script"
    Exit
}


<# Check the destination folder if exists. If not then it will create it and skip the comparison with 
   the source folder as it is not needed. If the destination folder exists then start the comparison and remove 
   whatever file or folder exists only in destintion folder
#>
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
    Write-host "Folder $destinationFolder Created" -ForegroundColor Green
}
else{


### Checks to compare and REMOVES files/folders from destination folder starts #############

  ### Get a list of all files in the folder and all subfolders
  $allDestinationFiles = Get-ChildItem -Path $destinationFolder -File -Recurse
     
  ### Remove files in the destination that do not exist in the source folder
  foreach ($destinationFile in $allDestinationFiles) {
    $AuditLogDF = New-Object System.Object
    $sourcePath = Join-Path $sourceFolder $destinationFile.FullName.Substring($destinationFolder.Length + 1)
    $FullFileDest = $destinationFile.FullName


    ### Check if the file doesn't exist in the source folder
    if (-not (Test-Path -Path $sourcePath)) {
      ### Remove the file from the destination
      Remove-Item -Path $destinationFile.FullName -Force -ErrorAction SilentlyContinue
      Write-host "File $FullFileDest Removed" -ForegroundColor Red
      ### Create a log record that the file was removed
      $AuditLogDF| Add-Member -MemberType NoteProperty -Name "Type" -Value "File"
      $AuditLogDF| Add-Member -MemberType NoteProperty -Name "Name" -Value $destinationFile.FullName
      $AuditLogDF| Add-Member -MemberType NoteProperty -Name "Status" -Value "Removed"
      $logs += $AuditLogDF
    }
  }


  ### Get a list of all directories in the destination folder and its subfolders
  $destinationDirectories = Get-ChildItem -Path $destinationFolder -Directory -Recurse

  ### Remove directories in the destination that don't exist in the source
  foreach ($destinationDirectory in $destinationDirectories) {
    $AuditLogD = New-Object System.Object
    $relativePath = $destinationDirectory.FullName.Substring($destinationFolder.Length + 1)
    $sourcePath = Join-Path $sourceFolder $relativePath

    ### Check if the directory doesn't exist in the source
    if (-not (Test-Path -Path $sourcePath -PathType Container)) {
        ### Remove the directory from the destination
        Remove-Item -Path $destinationDirectory.FullName -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "Folder $destinationDirectory Removed" -ForegroundColor Red
        ### Create a log record that the folder was removed
        $AuditLogD| Add-Member -MemberType NoteProperty -Name "Type" -Value "Folder"
        $AuditLogD| Add-Member -MemberType NoteProperty -Name "Name" -Value $destinationDirectory
        $AuditLogD| Add-Member -MemberType NoteProperty -Name "Status" -Value "Removed"
        $logs += $AuditLogD
    }
   }

}

### Checks to compare and REMOVE files/folders from destination folder ends #############


### Checks to compare and COPY files/folders to destination folder starts #############


### Create the destination folder if it doesn't exist
if (-not (Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
    Write-Host "Folder $destinationFolder Created" -ForegroundColor Green
}


### Create each folder to the destination 

### Get a list of all directories in the source folder and subfolders
$sourceDirectories = Get-ChildItem -Path $sourceFolder -Directory -Recurse

### Create related directories in the destination folder
foreach ($sourceDirectory in $sourceDirectories) {

    $AuditLogFolder = New-Object System.Object
    $relativePath = $sourceDirectory.FullName.Substring($sourceFolder.Length + 1)
    $destinationPath = Join-Path $destinationFolder $relativePath

    # Create a log record for folders
    $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Type' -Value 'Folder'
    $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Name' -Value $destinationPath


    # Check if the directory exists in the destination
    if (-not (Test-Path -Path $destinationPath -PathType Container)) {

        # Create the directory if it doesn't exist
        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
        Write-Host "Folder $destinationPath Created" -ForegroundColor Green

        # Create a log record that folder was created
        $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Created'

    } else {
        # Create a log record that folder was skipped as already exists
        $AuditLogFolder| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Skipped'
        Write-Host "Folder $destinationPath was Skipped" -ForegroundColor Yellow
    }
    $logs+= $AuditLogFolder
}


### Copy each file to the destination 

$allFiles = Get-ChildItem -Path $sourceFolder -File -Recurse

foreach ($file in $allFiles) {

    $AuditLog = New-Object System.Object
    $destinationPath = Join-Path $destinationFolder $file.FullName.Substring($sourceFolder.Length + 1)

    # Create a log record for the file
    $AuditLog| Add-Member -MemberType NoteProperty -Name 'Type' -Value 'File'
    $AuditLog| Add-Member -MemberType NoteProperty -Name 'Name' -Value $file.FullName
    $FullFilename = $file.FullName
    # Check if the file exists in the destination and if it is newer
    if (!(Test-Path -Path $destinationPath) -or ($file.LastWriteTime -gt (Get-Item -Path $destinationPath).LastWriteTime)) {

        # Copy the file to the destination
        Copy-Item -Path $file.FullName -Destination $destinationPath -Force

        # Create a log record for the file that is copied
        $AuditLog| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'Copied'
        Write-Host "File $FullFilename was Copied" -ForegroundColor Green

    } else {
        # Create a log record for the file that it is skipped as it is already exists and it is the same
        $AuditLog| Add-Member -MemberType NoteProperty -Name 'Status' -Value 'SKipped'
        Write-Host "File $FullFilename was Skipped" -ForegroundColor Yellow
    }
    $logs+= $AuditLog
}

### Checks to compare and COPY files/folders to destination folder ends #############


### Export log files to csv 
$loglocation = $logpathFolder+"\BCKLogs_$(Get-Date -Format 'dd-MM-yyyy').csv" 
$logs| Export-Csv $loglocation -NoTypeInformation -Encoding UTF8

## Output final message

Write-Output "Log file from the tasks is stored on "$loglocation


### End of script. ###