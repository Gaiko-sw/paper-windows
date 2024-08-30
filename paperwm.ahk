#Requires AutoHotkey v2.0
#include WinEvent.ahk

; #ErrorStdOut
; #Warn All, Off
Persistent
#SingleInstance Force
ProcessSetPriority "High", WinGetPID("A")

OnError E
E(err, mode) {
	OutputDebug err.message " " err.extra " " err.file " line: " err.line
	return 1
}

DllCall('RegisterShellHookWindow', 'UInt', A_ScriptHwnd)
OnMessage DllCall('RegisterWindowMessage', 'Str', 'SHELLHOOK'), shellMessage
OnExit((*) => DllCall("DeregisterShellHookWindow", "UInt", A_ScriptHwnd))
; WinEvent.Show(NewWindow)

WM_NULL := 0
WM_CREATE := 1
WM_DESTROY := 2
WM_MOVE := 3
WM_SIZE := 5
WM_ACTIVATE := 6
WM_SETFOCUS := 7
WM_KILLFOCUS := 8

StartX := 0
CurrentX := 0
Windows := Array()
FocusedWindowIndex := 0

; wm := WindowManager()
; OnMessage DllCall('RegisterWindowMessage', 'Str', 'SHELLHOOK'), shellMessage

class WindowManager {
	SomeFunc() {
		msgbox class func
	}
}

!Delete::FocusPrev()
!PgDn::FocusNext()

!Home::Scroll(-300)
!End::Scroll(300)

!Insert::CentreCurrentWindow()
!PgUp::NewWindow()

Return

ShellMessage(msg_type, lparam, msg, hwnd) {
	if msg_type = WM_CREATE {
		OutputDebug "create"
		NewWindow(lparam)
	} else if msg_type = WM_DESTROY {
		OutputDebug "destroy"
		RemoveWindow(lparam)
	} else if msg_type = WM_ACTIVATE {
		OutputDebug "activate"
		FocusWindow(lparam)
	} else if msg_type = WM_MOVE {
		; un manage window, reflow
	} else if msg_type = WM_SIZE {
		; set width, reflow
	} else if msg_type = WM_SETFOCUS {
		; focus window, scroll on screen
	}
}

IsWindowManaged(window_id) {
	for window in Windows {
		if window = window_id {
			return true
		}
	}
}

NewWindow(window_id?) { ;, hook, dwmsEventTime) {
	OutputDebug "in NewWindow"

	If not IsSet(window_id) {
		window_id := WinGetID("A")
	}

	global Windows

	if FocusedWindowIndex = 0 {
		index := Windows.Length + 1
	} else {
		index := FocusedWindowIndex + 1
	}

	OutputDebug "Inserting at " index
	Windows.InsertAt(index, window_id)

	FocusWindowAtIndex(index)
	ReflowWindows()
}

RemoveWindow(window_id) {
	global FocusedWindowIndex

	for i, window in Windows {
		if window = window_id {
			if i = FocusedWindowIndex {
				FocusedWindowIndex -= 1
			}
			Windows.RemoveAt(i)
			OutputDebug "Remove found window. Reflowing"
			ReflowWindows()
			break
		}
	}
}

OnWindowActivated(window_id) {
	if IsWindowManaged(window_id) {
		OutputDebug "Window activate"
	}
}

FocusWindow(window_id) {
	global FocusedWindowIndex
	for i, window in Windows {
		if window = window_id {
			FocusWindowAtIndex(i)
		}
	}
	FocussedWindowIndex := 0
}

FocusWindowAtIndex(index) {
	global FocusedWindowIndex

	WinActivate "ahk_id" Windows[index]
	FocusedWindowIndex := index
}

FocusNext() {
	OutputDebug "In FocusNext"
	global FocusedWindowIndex

	if FocusedWindowIndex = 0 {
		if Windows.Length > 0 {
			FocusWindowAtIndex(0)
		}
	} else if FocusedWindowIndex < Windows.Length {
		FocusWindowAtIndex(FocusedWindowIndex + 1)
	} else {
		FocusWindowAtIndex(FocusedWindowIndex)
	}
}

FocusPrev() {
	OutputDebug "In FocusPrev"
	global FocusedWindowIndex
	
	if FocusedWindowIndex = 0 {
		if Windows.Length > 0 {
			FocusWindowAtIndex(Windows.Length)
		}
	} else if FocusedWindowIndex > 1 {
		FocusWindowAtIndex(FocusedWindowIndex - 1)
	} else {
		FocusWindowAtIndex(FocusedWindowIndex)
	}
}

ReflowWindows(NewStartX?) {
	global StartX
	global CurrentX

	if IsSet(NewStartX) {
		StartX := NewStartX
	}

	CurrentX := StartX
	for window in Windows {
		W := 0
		try {
			WinGetPos &X, &Y, &W, &H, "ahk_id" window
			WinMove(CurrentX, 0, W, A_ScreenHeight, "ahk_id" window)
			CurrentX += W
		} catch {
			; remove this window
		}
	}
}

Scroll(amount) {
	OutputDebug "In scroll"
	global StartX := StartX + amount
	ReflowWindows()
}

CentreCurrentWindow() {
	prior_width := 0
	current_window := Windows[FocusedWindowIndex]
	for i, window in Windows {
		if i = FocusedWindowIndex {
			break
		}
		W := 0
		WinGetPos &X, &Y, &W, &H, "ahk_id" window
		prior_width += W
	}
	WinGetPos &X, &Y, &W, &H, "ahk_id" current_window
	centring_width := A_ScreenWidth / 2
	centring_width -= W / 2

	ReflowWindows(centring_width - prior_width)
}