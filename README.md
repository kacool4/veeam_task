# Backup Tool ver 1.0

 Author: Dimitrios Kakoulidis
 Date Create : 27-03-2024
 Last Update : 27-03-2024
 Version: 1.0

 ## Description 
   Script is making exact copy of a source location to destination.
   - If file or fodler exists on destination folder but not on source then it will be removed
   - If file exists on source and not on destination then it will be copied in the destination folder
   - If file exists on both folders and it is  exactly the same then it will be skipped 
   - If file on source folder is newer the script will replace the old file on destination with the new updated version
  
 ## Output
   - In the end you will have an export BCKLogs_Currentdate.csv file that shows all the actions (copied, skipped, create, delete) of each file and folder
  
 ## Format
   - Backup.ps1 -Source <Source Folder> - Destination <Destination Folder> -logpath <Log Folder>  


 ![Alt text](/screenshots/report.png?raw=true "CSV Export")


 ## Run the script
 
   Use the following command to run the script and replace the <Source_Folder> and <Destination_folder> with your preferred folders
```powershell
PS> Backup.ps1 -Source <Source Folder> - Destination <Destination Folder> -logpath <Log Folder> 
```
   ![Alt text](/screenshots/Output.png?raw=true "Console Output")

## Arguments
Apart from the -source and -destination arguments you can use also the following :
```
- -version --> Shows the latest version of the script
- -Help --> Gives you the syntax of the command
- -About --> Gives a description of the script
- -Logpath --> Give the path that the log file will be stored
```

 ![Alt text](/screenshots/triggers.png?raw=true "Arguments")

# Checks


The script is written in a way that can predict missing arguments. For Example in case you add only source folder it will throw an error that you forgot the destination folder

 ![Alt text](/screenshots/no_dest_folder.png?raw=true "Error")

 Other checks that the script does are :
  -  If the source folder does not exist
  -  If you put destination folder only\
  -  If you don't put any argument

