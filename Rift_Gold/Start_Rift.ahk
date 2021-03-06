;-----------------------------------
; Start Rift if it's not Running.
;-----------------------------------
PgmName = Rift Auto-Login Script
PgmVersion = 2.0.0

; General script settings
#NoEnv
SetWorkingDir %A_ScriptDir%
#Singleinstance force
SetTitleMatchMode 2
SetKeyDelay, 50,30
CoordMode, ToolTip, Relative
CoordMode, Mouse, Relative
CoordMode, Pixel, Relative
Patcherclass = ahk_class QWidget
RiftWindowClass = ahk_class TWNClientFramework


IniFile:=A_ScriptDir "\include\rift.ini" ; Define the .ini file name and location

IfNotExist, %IniFile% ; Look for an ini file to load, and if none found, create a default one.
{
   Gosub, CreateSettings
}

Gosub, LoadSettings ; Load settings from the .ini file

; data is relative to active window, not the entire screen
; login button position
LoginButtonX=537
LoginButtonY=517
; play/upgdate button position
UpdatePlayButtonX=534
UpdatePlayButtonY=515

; gui stuff, position is relative to the entire screen
guicolor = 0xF0C040
GuiX = 100
GuiY = 50


;------------------------------------------------
; The gui is to remind you that the login is running
; this lets you see that it's still in memory. Once
; the actual login is complete the script will auto-exit.
;------------------------------------------------
Gui, +Resize
Gui, Color, %guicolor%
Gui, Add, Text,, %PgmName%
;Gui, Show
WinSet, AlwaysOnTop, On, %PgmName%
WinMove, %PgmName%,, %GuiX%, %GuiY%

RiftGameExe:=RiftPath()

gosub StartLogin
WinWaitActive, %PatcherClass%
gosub Login

;-----------------------------------
; Read Spec File
;-----------------------------------  
FileRead, LastSpec, %A_ScriptDir%\spec.tmp

;-----------------------------------
; Start AHK Script From Spec File
;-----------------------------------
if LastSpec = Tank
{
  Run %A_ScriptDir%\RSTank.ahk  
}  
else if LastSpec = Bard
{
  Run %A_ScriptDir%\Bard.ahk
} 
else if LastSpec = NB
{
  Run %A_ScriptDir%\NB.ahk
}
else if LastSpec = SoloBard
{
  Run %A_ScriptDir%\SoloBard.ahk
}
else if LastSpec = MM_PVP
{
  Run %A_ScriptDir%\MM_PVP.ahk
}
else
{
  MsgBox, No Spec file found
}

loop, ; Wait for character screen before exiting
{   
   IfWinExist, %RiftWindowClass%
   {   
   WinMove, %RiftWindowClass%,,0,0
    Break
   }
}


;------------------------------------------------
; Subroutines Section
;------------------------------------------------
GuiClose:
ExitApp

StartLogin: ; start up the game
Run, %RiftGameExe%
SplashTextOn,350,, %RiftGameExe% found.
Sleep 2000
SplashTextOff
Return

Login: ; TODO - add check to determine button image state, and then take appropriate actions. (Play/Update/Etc)
;Gosub, SendEmail
Gosub, SendPassword
Gosub, HitButton1
Gosub, HitButton2
Return

SendEmail: ; Send email address to login screen
WinActivate, %PatcherClass%
WinWaitActive, %PatcherClass%
Sleep, 1000
Send, {TAB 3}
Sleep, 100
Send, %UserEmail%
Sleep, 100
Return

SendPassword: ; Send Password to login screen
WinActivate, %PatcherClass%
WinWaitActive, %PatcherClass%
Sleep, 1000
;Send, {TAB}
Sleep, 100
Send, {DEL}
Sleep, 100
Send, {RAW}%UserPassword%
Sleep, 2000
Return

HitButton1: ; Click the Login button
WinActivate, %PatcherClass%
WinWaitActive, %PatcherClass%
MouseMove, %LoginButtonX%, %LoginButtonY% 
MouseClick
Sleep, 2000
Return

HitButton2: ; Click the Update/Play button
WinActivate, %PatcherClass%
WinWaitActive, %PatcherClass%
MouseMove, %UpdatePlayButtonX%, %UpdatePlayButtonY% 
MouseClick
Sleep, 2000
Return

CreateSettings: ; Write default settings into the default.ini file
   IniWrite, "",   %IniFile%, Login, UserEmail
   IniWrite, "",   %IniFile%, Login, UserPassword
Return

LoadSettings: ; Read settings from the default.ini file
   IniRead, UserEmail,   %IniFile%, Login, UserEmail,
   IniRead, UserPassword,   %IniFile%, Login, UserPassword,
   If (UserEmail="") ; Error checking to ensure user has edited settings in default.ini
   {
      Msgbox, 48, Error, Email address may not be blank. `n Edit it and run %PgmName% again.
      Run %inifile% ; Open the file for them to edit.
      GoSub, GuiClose
   }
   If (UserPassword="") ; Error checking to ensure user has edited settings in default.ini
   {
      Msgbox, 48, Error, Password may not be blank. `n Edit it and run %PgmName% again.
      Run %inifile%
      GoSub, GuiClose
   }
Return
   
   
;------------------------------------------------
; Functions Section
;------------------------------------------------
RiftPath()
{
   IfEqual,A_OSVersion,WIN_XP
   {   
      RiftPath:="C:\Program Files (x86)\RIFT\riftpatchlive.exe" 
   }
   Else IfEqual,A_OSVersion,WIN_2003
   {
      RiftPath:="C:\Program Files (x86)\RIFT\riftpatchlive.exe"
   }
   Else IfEqual,A_OSVersion,WIN_VISTA
   {
      RiftPath:="C:\Program Files (x86)\RIFT\riftpatchlive.exe" 
   }
   Else IfEqual,A_OSVersion,WIN_7
   {
      RiftPath:="C:\Program Files (x86)\RIFT\riftpatchlive.exe"
   }
   SplashTextOn,,, %A_OSVersion% detected.
   Sleep 2000
   SplashTextOff
   Return RiftPath
}
; END RiftPath