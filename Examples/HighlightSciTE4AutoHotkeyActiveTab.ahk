; Highlights the active tab in the SciTE4AutoHotkey window.
; Intended to start with Windows and remain running until shutdown.
;
; Known limitations:
;
; 1. When a file is modified, SciTE appends an asterisk (*) to its tab name.
;    The asterisk is not highlighted until the tab is reselected.
;
; 2. When a file is saved under a different name using the File:Save As... menu item,
;    the highted area doesn't change. The area is adjusted as soon as the tab is reselected.
;
; Both limitations can be managed using the Shift+F5 hotkey.

#Requires AutoHotkey v2.0
#Include ..\Lib\UIA.ahk  ; https://github.com/Descolada/UIA-v2
Persistent

Color := 'Gray'      ; Color of the highlight window (https://www.autohotkey.com/docs/v2/lib/Gui.htm#BackColor)
Transparency := 100  ; A number between 0 (invisible) and 255 (opaque) indicating the degree of transparency
Period := 10         ; Time in ms that determines responsiveness of changes in the window size and location

TraySetIcon A_ProgramFiles '\AutoHotkey\SciTE\SciTE.exe'

hWin := WinWait('ahk_class SciTEWindow')
hScintilla := ControlGetHwnd('Scintilla1')
PID := WinGetPID()

; Create the highlight Gui.

WS_EX_TRANSPARENT := 0x00000020
HighlightGui := Gui('+AlwaysOnTop -Caption -DPIScale +ToolWindow +E' WS_EX_TRANSPARENT)
HighlightGui.BackColor := Color
WinSetTransparent Transparency, HighlightGui

; Highlight the active tab if the window has more than one tab.

SciTEWindow := UIA.ElementFromHandle(hWin)
TabControls := SciTEWindow.FindElements({Type:'Tab'})

if TabControls.Length > 1 {
   SelectedTab := TabControls.FindElement({Type:'TabItem', SelectionItemIsSelected:true})
   HighlightSelectedTab()
}

; Monitor changes in the active tab.

Handler := UIA.CreateAutomationEventHandler(SelectionItemEventHandler)
UIA.AddAutomationEventHandler(Handler, SciTEWindow, UIA.Event.SelectionItem_ElementSelected)

SelectionItemEventHandler(Element, EventId) {
   if WinActive(hWin) && !IsAutocompletionActive() {
      global SelectedTab := Element
      HighlightSelectedTab()
   }
}

; https://scintilla.org/ScintillaDoc.html#SCI_AUTOCACTIVE

IsAutocompletionActive() {
   static SCI_AUTOCACTIVE := 2102
   return SendMessage(SCI_AUTOCACTIVE, 0, 0, hScintilla)
}

; Monitor changes in the window size and location.

Events := []
OBJID_WINDOW := CHILDID_SELF := 0
EVENT_OBJECT_LOCATIONCHANGE := 0x800B
Events.Push(WinEvents(EVENT_OBJECT_LOCATIONCHANGE, EVENT_OBJECT_LOCATIONCHANGE, WatchWindowLocation, 'F', PID))

WatchWindowLocation(hWinEventHook, Event, hwnd, IdObject, IdChild, *) {
   if IdObject = OBJID_WINDOW && IdChild = CHILDID_SELF && hwnd = hWin
      SetTimer HighlightSelectedTab, -Period
}

; Monitor the activation of all desktop windows.

EVENT_SYSTEM_FOREGROUND := 0x0003
Events.Push(WinEvents(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, WatchActiveWindow, 'F'))

WatchActiveWindow(hWinEventHook, Event, hwnd, *) {
   if hwnd = hWin
      HighlightSelectedTab()
   else
      HighlightGui.Hide()
}

; Monitor the closing of the window.

EVENT_OBJECT_DESTROY := 0x8001
Events.Push(WinEvents(EVENT_OBJECT_DESTROY, EVENT_OBJECT_DESTROY, WatchWindowClose, 'F', PID))

WatchWindowClose(hWinEventHook, Event, hwnd, IdObject, IdChild, *) {
   if hwnd = hWin && IdObject = OBJID_WINDOW && IdChild = CHILDID_SELF {
      WinWaitClose(hwnd)
      UIA.RemoveAutomationEventHandler(Handler, SciTEWindow, UIA.Event.SelectionItem_ElementSelected)
      global Events := ''
      Reload
   }
}

; Helper function and class

HighlightSelectedTab() {
   if IsSet(SelectedTab) {
      TabRect := SelectedTab.BoundingRectangle
      HighlightGui.Show('x' TabRect.l ' y' TabRect.t ' w' (TabRect.r - TabRect.l) ' h' (TabRect.b - TabRect.t) ' NA')
   }
}

class WinEvents
{
   __New(EventMin, EventMax, Function, Options?, IdProcess?, IdThread?, Flags?) {
      static WINEVENT_OUTOFCONTEXT := 0x0000
      this.pWinEventProc := CallbackCreate(Function, Options?, 7)
      this.hWinEventHook := DllCall('User32.dll\SetWinEventHook', 'UInt', EventMin,  'UInt', EventMax, 'Ptr', 0, 'Ptr', this.pWinEventProc
                                                                , 'UInt', IdProcess ?? 0, 'UInt', IdThread ?? 0, 'UInt', Flags ?? WINEVENT_OUTOFCONTEXT, 'Ptr')
      if !this.hWinEventHook
         throw Error('SetWinEventHook failed.', -1)
   }
   
   __Delete() {
      if !DllCall('User32.dll\UnhookWinEvent', 'Ptr', this.hWinEventHook, 'Int')
         throw Error('UnhookWinEvent failed.', -1)
      CallbackFree(this.pWinEventProc)
   }
}

; Hotkey

#HotIf WinActive('ahk_class SciTEWindow')
+F5::HighlightSelectedTab()
#HotIf
