#Requires AutoHotkey v2.0
#Include SciFindText.ahk

; Search all SciTE4AutoHotkey tabs for the specified text.
; The SearchFlags parameter specifies the type of search. If omitted, the search will be case-insensitive.
; See the SciFindText function documentation for other values for the SearchFlags parameter.
; Reference: https://scintilla.org/ScintillaDoc.html

SearchAllSciTE4AutoHotkeyTabs(Text, SearchFlags?) {
   static SCI_GETSELECTIONSTART := 2143
   static SCI_GETSELECTIONEND   := 2145
   static SCI_SETSEL            := 2160
   
   SciTE := ComObjActive('SciTE4AHK.Application')
   hCtrl := ControlGetHwnd('Scintilla1', 'ahk_id' SciTE.SciTEHandle)
   
   Current := {}
   ;
   ; Determine the current selection.
   ;
   Current.StartPos := SendMessage(SCI_GETSELECTIONSTART, 0, 0, hCtrl)
   Current.EndPos := SendMessage(SCI_GETSELECTIONEND, 0, 0, hCtrl)
   ;
   ; Determine the current tab number.
   ;
   Current.FilePath := SciTE.CurrentFile
   Tabs := SciTE.Tabs
   for TabPath in Tabs.Array {
      if TabPath = Current.FilePath {
         Current.TabNo := A_Index - 1
         break
      }
   }
   ;
   ; Look for the text in each tab. If found, highlight it and display the results before continuing.
   ;
   TotalOccurrences := 0
   for TabPath in Tabs.Array {
      TabNo := A_Index
      SciTE.SwitchToTab(TabNo - 1)
      Sleep 100
      StartPos := 0
      EndPos := UnSet
      TabOccurrences := 0
      while SearchResult := SciFindText(hCtrl, Text, SearchFlags?, StartPos, &EndPos?) {
         TabOccurrences++, TotalOccurrences++
         SendMessage(SCI_SETSEL, SearchResult.StartPos, SearchResult.EndPos, hCtrl)
         Result := MsgBox('Found: ' Text '`n`nTab: ' TabNo '`nPos: ' SearchResult.Value '`nOccurrence: ' TabOccurrences '`nPath: ' TabPath '`n`n'
                        . 'Do you want to continue?`nNo stops searching the current tab.`nCancel stops searching the remaining tabs.', , 'YesNoCancel')
         if Result != 'Yes'
            if Result = 'No'
               break 1
            else
               break 2
         StartPos := SearchResult.EndPos
      }
   }
   MsgBox 'Found a total of ' TotalOccurrences ' occurrences.'
   ;
   ; Restore the original tab and selection.
   ;
   ControlFocus hCtrl
   SciTE.SwitchToTab(Current.TabNo)
   SendMessage(SCI_SETSEL, Current.StartPos, Current.EndPos, hCtrl)
}
