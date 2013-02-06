; Live/Offline Host
; Author: Anthony Kosednar 2013

#cs

Basic Includes

#ce

#RequireAdmin
#NoTrayIcon
#include <Constants.au3>

#cs

Functions & Variables

#ce 

; Operating Variables
Global $Host_File = @SystemDir & "\drivers\etc\hosts"
Global $Working_Dir =  @MyDocumentsDir & "\LiveOfflineHost\"
Global $Primary_Host_File = $Working_Dir & "primary_hosts.txt"
Global $Secondary_Host_File = $Working_Dir & "secondary_hosts.txt"
Global $Backup_Host_File = $Working_Dir & "Backup\hosts"
Global $Current_Host_File = "primary" ; default

; Hot Keys for Host Toggle (Defualt to Alt+1 & Alt +2)
HotKeySet("!1", "TogglePrimary")
HotKeySet("!2", "ToggleSecondary")

Func StartUp()
   ; Setup Global Variables
   Global $Host_File, $Working_Dir, $Primary_Host_File, $Secondary_Host_File, $Backup_Host_File, $Current_Host_File
   
   ; Check if Our Files & Directories Exist
   If DirGetSize($Working_Dir) = -1 Then
	  DirCreate($Working_Dir)
   EndIf
   
   If FileExists(@StartupDir & "\LiveOfflineHost.exe") == 0 Then
	  FileCopy(@ScriptFullPath,@StartupDir & "\LiveOfflineHost.exe")
	  ConsoleWrite("Installed as startup" & @CRLF)  
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
	  $var = IniReadSection($Working_Dir & "conf.ini", "run")
	  For $i = 1 To $var[0][0]
			if($var[$i][0] == "host_current") Then
			   $Current_Host_File = $var[$i][1]
			   ConsoleWrite("Current Host File Set to: " & $Current_Host_File & @CRLF)
			EndIf
	  Next
   EndIf
EndFunc

Func set_current_host($change)
    ; Setup Global Variables
   Global $Host_File, $Working_Dir, $Primary_Host_File, $Secondary_Host_File, $Backup_Host_File, $Current_Host_File, $primary_item, $secondary_item
   If $change == "primary" Then
	  FileCopy($Primary_Host_File, $Host_File, 9)
	  $Current_Host_File = "primary"
	  TrayItemSetState($primary_item, $TRAY_CHECKED)
	  TrayItemSetState($secondary_item, $TRAY_UNCHECKED)
   Else
	  FileCopy($Secondary_Host_File, $Host_File, 9)
	  $Current_Host_File = "secondary"
	  TrayItemSetState($primary_item, $TRAY_UNCHECKED)
	  TrayItemSetState($secondary_item, $TRAY_CHECKED)
   EndIf
   
   IniWrite($Working_Dir & "conf.ini", "run", "host_current", $Current_Host_File)
   RunWait("ipconfig /flushdns","C:\",@SW_HIDE)
   ConsoleWrite("Set actual host file to " & $Current_Host_File & @CRLF)
EndFunc

Func TogglePrimary()
   set_current_host("primary")
   ToolTip('Host set to Primary', 0, 0)
   Sleep(2000)
   ToolTip("")
 EndFunc
 
 Func ToggleSecondary()
   set_current_host("secondary")
   ToolTip('Host set to Secondary', 0, 0)
   Sleep(2000)
   ToolTip("")
EndFunc

#cs

Main Program Body

#ce

StartUp()
set_current_host($Current_Host_File) ; Setup host file just in case it changed
Opt("TrayMenuMode", 1) ; Default tray menu items (Script Paused/Exit) will not be shown.
; Let's create 2 radio menuitem groups

; Create Our Radio Items
Global $primary_item = TrayCreateItem("Primary", -1, -1, 1)

If $Current_Host_File == "primary" Then
   TrayItemSetState(-1, $TRAY_CHECKED)
EndIf

Global $secondary_item = TrayCreateItem("Secondary", -1, -1, 1)

If $Current_Host_File == "secondary" Then
   TrayItemSetState(-1, $TRAY_CHECKED)
EndIf

TrayCreateItem("")
Global $exit_item = TrayCreateItem("Exit")

TraySetState()

While 1
    Local $msg = TrayGetMsg()
    Select
        Case $msg = 0
            ContinueLoop
		 Case $msg = $primary_item
			; Switch Host to Primary
			TogglePrimary()
		 Case $msg = $secondary_item
			; Switch Host to Secondary
			ToggleSecondary()
		 Case $msg = $exit_item
            ExitLoop
    EndSelect
WEnd

Exit