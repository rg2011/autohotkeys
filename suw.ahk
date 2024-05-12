#Requires AutoHotkey v2.0
#SingleInstance

; He tratado de activar webex y otros con DetectHiddenWindows = true,
; WinShow y WinActivate, pero no redibuja la venta. No sé si habrá que
; mandar alfuna orden de draw adicional...
; En general, lo que mejor me ha funcionado es no detectar las hidden
; windows, y si está hidden, volver a ejecutar el comando con Run.
DetectHiddenWindows false

LocalAppData := EnvGet("LocalAppData")
ProgramFiles := EnvGet(A_Is64bitOS ? "ProgramW6432" : "ProgramFiles")

ActivateSingleWindow(windowTitle, command, folder:="") {
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
  }
}

ActivateManyWindows(windowTitle, command, folder:="") {
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
  }
}

#1::{
  ActivateSingleWindow(
    "ahk_exe Skype.exe",
    "Skype"
  )
}

#2::{
  ActivateSingleWindow(
    "ahk_exe slack.exe",
    LocalAppData . "\slack\slack.exe",
    LocalAppData . "\slack"
  )
}

#3::{
  ActivateSingleWindow(
    "ahk_class TeamsWebView",
    "ms-teams"
  )
}

#4::{
  ActivateSingleWindow(
    "Webex",
    LocalAppData . "\CiscoSparkLauncher\CiscoCollabHost.exe",
    LocalAppData . "\CiscoSparkLauncher"
  )
}

#t::{
  ActivateManyWindows(
    "ahk_exe WindowsTerminal.exe",
    "wt.exe"
  )
}

#w::{
  ActivateManyWindows(
    "ahk_class MozillaWindowClass",
    ProgramFiles . "\Mozilla Firefox\firefox.exe",
    ProgramFiles . "\Mozilla Firefox"
  )
}

#c::{
  ActivateManyWindows(
    "ahk_exe Code.exe",
    LocalAppData . "\Programs\Microsoft VS Code\Code.exe",
    LocalAppData . "\Programs\Microsoft VS Code"
  )
}

#e::{
  ActivateManyWindows(
    "ahk_exe OUTLOOK.EXE",
    Run ProgramFiles . "\Microsoft Office\root\Office16\OUTLOOK.EXE"
  )
}

