::****************************************
::* File:       BACKUPANDCLEANER.BAT
::* Author:     Andrew M Bates (andrewbates09)
::* Summary:    Backup MySQL database, backup webroot directory
::*	            and clean out backups older than 5 days old
::* NOTE:       Don't forget to add passwords and run as administrator - or won't work
::*             You will need to go through real quick and replace the following 
::*                 YOURMYSQLDB
::*                 YOURWEBDIR
::*                 - and probably your MySQL mysqldump.exe path below 
::****************************************

@echo off

::  get the current date as easy to use variables - ignoring first token (day of week)
set dd=%date:~-7,2%
set mm=%date:~-10,2%
set yyyy=%date:~-4,4%

::  record all the days there batch file was run - reality should be every day.
set BatchLog=batchlog.txt

::  this file will require obfuscation to allow the password to be imbedded - can use quotes
set MySQLPass=""

::  variable to know location of backups - don't use quotes it messes with the MySQL backup - so, no spaces in TARGETDIR
set TARGETDIR=C:\Backup\

::  variable to know delete webroot and MySQL backups older than 5 days
set OLDERTHAN=5

::  set =1 to run MySQL Backup, WebRoot Backup, Backups Cleanup respectively
set MYSQLBACKUP=1
set WEBROOTBACKUP=1
set BACKUPCLEANUP=1

::****************************************
::  logs what when where the backup and cleaner was run
::****************************************
:BACKUPANDCLEANERLOG
echo. >> %TARGETDIR%%BatchLog%
echo. **************************************** >> %TARGETDIR%%BatchLog%
echo. * Start BACKUPANDCLEANER.BAT >> %TARGETDIR%%BatchLog%
echo. * %date% >> %TARGETDIR%%BatchLog%
echo. * %time% >> %TARGETDIR%%BatchLog%
echo. >> %TARGETDIR%%BatchLog%


::****************************************
::  call the mysqldump command from *\MySQL\*\bin\
::****************************************	
:BACKUPMYSQL
if not %MYSQLBACKUP%==1 goto BACKUPWEBROOT

echo. BACKUPMYSQL>> %TARGETDIR%%BatchLog%

::  --user = database user to use
::  --password = database user password
::  --log-error = append warnings and errors to file
"C:\Program Files\MySQL\MySQL Server 5.5\bin\mysqldump.exe" --user root --password=%MySQLPass% --log-error=%TARGETDIR%mysqllog_%yyyy%%mm%%dd%.txt --all-databases > %TARGETDIR%YOURMYSQLDB_%yyyy%%mm%%dd%.sql


::****************************************
::  call ROBOCOPY to copy the web root to the default backup location
::****************************************
:BACKUPWEBROOT
if not %WEBROOTBACKUP%==1 goto PROCESSFILES

echo. BACKUPWEBROOT >> %TARGETDIR%%BatchLog%

::  /E = copy subdirectories, including empty ones
::  /LOG: = output status to a log file
ROBOCOPY C:\inetpub\wwwroot\YOURWEBDIR %TARGETDIR%YOURWEBDIR_%yyyy%%mm%%dd% /E /LOG:%TARGETDIR%webrootlog_%yyyy%%mm%%dd%.txt


::****************************************
::  parse MySQL/webroot backups and delete those older than OLDERTHAN date
::****************************************
:PROCESSFILES
if not %BACKUPCLEANUP%==1 goto FINISH

echo. PROCESSFILES >> %TARGETDIR%%BatchLog%
::  lists all files in the backup directory
FORFILES /P %TARGETDIR% /C "cmd /c if @isdir==FALSE echo. @path >> %TARGETDIR%%BatchLog%" /D -%OLDERTHAN%
::  deletes all files in the backup directory older than OLDERTHAN days
FORFILES /P %TARGETDIR% /C "cmd /c if @isdir==FALSE ERASE /F /Q @file" /D -%OLDERTHAN%


::****************************************
::  parse webroot backups and delete those older than olderthan date
::****************************************
:PROCESSFOLDERS

echo. PROCESSFOLDERS >> %TARGETDIR%%BatchLog%

::  lists all folders in the backup directory
FORFILES /P %TARGETDIR% /C "cmd /c if @isdir==TRUE echo. @path >> %TARGETDIR%%BatchLog%" /D -%OLDERTHAN%
::  deletes all folders in the backup directory older than OLDERTHAN days
FORFILES /P %TARGETDIR% /C "cmd /c if @isdir==TRUE RMDIR /S /Q @fname" /D -%OLDERTHAN%


::****************************************
::  clear variables used and exit
::****************************************
:FINISH

echo. >> %TARGETDIR%%BatchLog%
echo. * End BACKUPANDCLEANER.BAT >> %TARGETDIR%%BatchLog%
echo. **************************************** >> %TARGETDIR%%BatchLog%
echo. >> %TARGETDIR%%BatchLog%

::  resets all the variables
set BACKUPCLEANUP=
set WEBROOTBACKUP=
set MYSQLBACKUP=
set OLDERTHAN=
set TARGETDIR=
set MySQLPass=
set BatchLog=
set yyyy=
set mm=
set dd=


::****************************************
::  exit (yep, it is just blank)
::****************************************
:EXIT

::****************************************
::* END BACKUPANDCLEANER.BAT
::****************************************
