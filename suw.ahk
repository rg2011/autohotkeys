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
ProgramX86 := EnvGet(A_Is64bitOS ? "ProgramFiles(x86)" : "ProgramFiles")

; Grupos de aplicaciones entre los que tabular
Groups := Map(
    "Skype", "ahk_exe Skype.exe",
    "Slack", "ahk_exe slack.exe",
    "Teams", "ahk_class TeamsWebView",
    "Webex", "ahk_exe CiscoCollabHost.exe",
    "Terminal", "ahk_exe WindowsTerminal.exe",
    "Web", "ahk_class MozillaWindowClass",
    "Code", "ahk_exe Code.exe",
    "Email", "ahk_exe OUTLOOK.EXE"
)

for groupName, windowTitle in Groups {
  GroupAdd(groupName, windowTitle)
}

; El único grupo con más de un tipo de ventana que tengo de momento
GroupAdd("Social", Groups["Skype"])
GroupAdd("Social", Groups["Slack"])
GroupAdd("Social", Groups["Teams"])
GroupAdd("Social", Groups["Webex"])

XButton1 & º::
#º::{
  GroupActivate("Social")
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

XButton1 & 1::
XButton2 & 1::
#1::{
  ActivateGroupOrRun(
    "Skype",
    ProgramX86 . "\Microsoft\Skype for Desktop\Skype.exe",
    ProgramX86 . "\Microsoft\Skype for Desktop"
  )
}

XButton1 & 2::
#2::{
  ActivateGroupOrRun(
    "Slack",
    LocalAppData . "\slack\slack.exe",
    LocalAppData . "\slack"
  )
}

XButton1 & 3::
#3::{
  ActivateGroupOrRun(
    "Teams",
    "ms-teams"
  )
}

XButton1 & 4::
#4::{
  ActivateGroupOrRun(
    "Webex",
    LocalAppData . "\CiscoSparkLauncher\CiscoCollabHost.exe",
    LocalAppData . "\CiscoSparkLauncher"
  )
}

XButton1 & t::
#t::{
  ActivateGroupOrRun(
    "Terminal",
    "wt.exe"
  )
}

XButton1 & w::
#w::{
  ActivateGroupOrRun(
    "Web",
    ProgramFiles . "\Mozilla Firefox\firefox.exe",
    ProgramFiles . "\Mozilla Firefox"
  )
}

XButton1 & c::
#c::{
  ActivateGroupOrRun(
    "Code",
    LocalAppData . "\Programs\Microsoft VS Code\Code.exe",
    LocalAppData . "\Programs\Microsoft VS Code"
  )
}

XButton1 & e::
#e::{
  ActivateGroupOrRun(
    "Email",
    ProgramFiles . "\Microsoft Office\root\Office16\OUTLOOK.EXE"
  )
}
