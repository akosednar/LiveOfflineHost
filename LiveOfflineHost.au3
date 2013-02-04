; Live/Offline Host
; Author: Anthony Kosednar 2013

#RequireAdmin

; Operating Variables
$Host_File = @SystemDir & "\drivers\etc\hosts"
$Working_Dir =  @MyDocumentsDir & "\LiveOfflineHost\"

$Primary_Host_File = $Working_Dir & "primary_hosts.txt"
$Secondary_Host_File = $Working_Dir & "secondary_hosts.txt"

$Backup_Host_File = $Working_Dir & "Backup\hosts"

$Current_Host_File = "primary"
$Working_Dir & "conf.ini"

; Check if Our Files & Directories Exist
If DirGetSize($Working_Dir) = -1 Then
   DirCreate($Working_Dir)
EndIf

If FileExists($Backup_Host_File) == 0  Then
   FileCopy($Host_File,$Backup_Host_File, 8)
EndIf

If FileExists($Primary_Host_File) == 0 Then
   FileCopy($Host_File,$Primary_Host_File, 8)
EndIf

If FileExists($Secondary_Host_File) == 0  Then
   FileCopy($Host_File,$Secondary_Host_File, 8)
EndIf

; Check for hosts current state
If FileExists($Working_Dir & "conf.ini") == 0  Then
   IniWrite($Working_Dir & "conf.ini", "run", "host_current", "primary")
   ConsoleWrite("Created Conf Ini" & @CRLF)
Else
   ConsoleWrite("Conf Ini Exists" & @CRLF)
   Local $var = IniReadSection($Working_Dir & "conf.ini", "run")
    For $i = 1 To $var[0][0]
		 if($var[$i][0] == "host_current") Then
			$Current_Host_File = $var[$i][1]
			ConsoleWrite("Current Host File Set to: " & $Current_Host_File & @CRLF)
		 EndIf
	 Next
EndIf
