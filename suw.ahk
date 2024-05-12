#Requires AutoHotkey v2.0
#SingleInstance

; He tratado de activar webex y otros con DetectHiddenWindows = true,
; WinShow y WinActivate, pero no redibuja la venta. Es posible que
; esté detectando y activando alguna ventana oculta que usa la app
; por debajo, al ser una aplicación basada en webview.
; En general, lo que mejor me ha funcionado es no detectar las hidden
; windows, y si está hidden, volver a ejecutar el comando con Run.
;
; Nota: El problema de no detectar hidden windows, es que tampoco detecta
; las cloacked, que son las que están en otro escritorio. Así que no
; puedo conmutar ventanas entre escritorios.
DetectHiddenWindows false

LocalAppData := EnvGet("LocalAppData")
ProgramFiles := EnvGet(A_Is64bitOS ? "ProgramW6432" : "ProgramFiles")

; Activar ventana si existe, o ejecutar app en otro caso.
ActivateSingleOrRun(windowTitle, command, folder:="") {
  if WinExist(windowTitle) {
    minimized := WinGetMinMax()
    if minimized == -1 {
      WinRestore
    }
    WinActivate
  } else {
    if folder != "" {
      Run command, folder
    } else {
      Run command
    }
    handle := WinWait(windowTitle, , 3)
    if handle != 0 {
      WinActivate
    }
  }
}

#1::{
  ActivateSingleOrRun(
    "ahk_exe Skype.exe",
    "Skype"
  )
}

#2::{
  ActivateSingleOrRun(
    "ahk_exe slack.exe",
    LocalAppData . "\slack\slack.exe",
    LocalAppData . "\slack"
  )
}

#3::{
  ActivateSingleOrRun(
    "ahk_class TeamsWebView",
    "ms-teams"
  )
}

#4::{
  ActivateSingleOrRun(
    "Webex",
    LocalAppData . "\CiscoSparkLauncher\CiscoCollabHost.exe",
    LocalAppData . "\CiscoSparkLauncher"
  )
}

; Grupos de aplicaciones entre los que tabular
Groups := Map(
    "Terminal", "ahk_exe WindowsTerminal.exe",
    "Web", "ahk_class MozillaWindowClass",
    "Code", "ahk_exe Code.exe",
    "Email", "ahk_exe OUTLOOK.EXE"
)

for groupName, windowTitle in Groups {
  GroupAdd(groupName, windowTitle)
}

; Segunda versión de "ActivateGroupOrRun". La primera (más abajo)
; localizaba todas las ventanas del grupo y las activaba a la vez.
; Esta versión utiliza "GroupActivate" para activarlas alternativamente.
ActivateGroupOrRun(windowGroup, command, folder:="") {
  windowTitle := Groups[windowGroup]
  if WinExist(windowTitle) {
    handle := GroupActivate(windowGroup, "R")
    if handle == 0 { ; The only window in group is the already active one
      if WinGetMinMax() == -1 {
        WinRestore()
      }      
    } else { ; We activated a different window in the group
      ahk_id := "ahk_id " . handle
      if WinGetMinMax(ahk_id) == -1 {
        WinRestore(ahk_id)
      }
    }
  } else {
    if folder == "" {
      Run command
    } else {
      Run command, folder
    }
    handle := WinWait(windowTitle, , 3)
    if handle != 0 {
      WinActivate
    }
  }
}

; Versión antigua, que no gestionaba la alternancia
; entre ventanas de un mismo grupo
DeprecatedActivateGroupOrRun(windowGroup, command, folder:="") {
  windowTitle := Groups[windowGroup]
  count := 0
  for , wnd in WinGetList(windowTitle) {
    ahk_id := "ahk_id " . wnd
    minimized := WinGetMinMax(ahk_id)
    if minimized == -1 {
      WinRestore(ahk_id)
    }
    WinActivate(ahk_id)
    count += 1
  }
  if count == 0 {
    if folder == "" {
      Run command
    } else {
      Run command, folder
    }
    handle := WinWait(windowTitle, , 3)
    if handle != 0 {
      WinActivate
    }
  }
}
    
#t::{
  ActivateGroupOrRun(
    "Terminal",
    "wt.exe"
  )
}

#w::{
  ActivateGroupOrRun(
    "Web",
    ProgramFiles . "\Mozilla Firefox\firefox.exe",
    ProgramFiles . "\Mozilla Firefox"
  )
}

#c::{
  ActivateGroupOrRun(
    "Code",
    LocalAppData . "\Programs\Microsoft VS Code\Code.exe",
    LocalAppData . "\Programs\Microsoft VS Code"
  )
}

#e::{
  ActivateGroupOrRun(
    "Email",
    ProgramFiles . "\Microsoft Office\root\Office16\OUTLOOK.EXE"
  )
}
