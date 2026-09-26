#Requires AutoHotkey v2.0
#Include ..\Lib\SearchAllSciTE4AutoHotkeyTabs.ahk

#HotIf WinActive('ahk_class SciTEWindow')

; --------------------
; Search all tabs for the specified text.
; If text is selected, it is used as the default value for the InputBox.
; Overrides the Find in Files... built-in hotkey (Ctrl+Shift+F).
; Restores the original clipboard when done.
;
; If the specified text is preceeded with a '<Options>' string (optionally followed by spaces or tabs),
; the search can be made case-sensitive and/or follow a regular expression, e.g. '<Case,RegEx> SearchString'.
; If Options includes the string 'Case', the search is case-sensitive.
; If Options includes the string 'RegEx', the search string is a regular expression.
; The regular expression uses Scintilla's based implementation.
; The Options string is case-insensitive.
; If the Options string is not included, the search is case-insensitive.
; The '<Options>' string will be stripped before the search is executed.
; See https://scintilla.org/ScintillaDoc.html#searchFlags for more details.

^+f::
{
   static SCFIND_NONE      := 0x0
   static SCFIND_MATCHCASE := 0x4
   static SCFIND_REGEXP    := 0x00200000
   
   CopyTextToClipboard(&C_Clipboard)
   InputBoxObj := InputBox('Enter the search text:', , 'w300 h100', Trim(A_Clipboard))
   if InputBoxObj.Result = 'OK' && (Text := Trim(InputBoxObj.Value)) != '' {
      Flags := SCFIND_NONE
      IsCaseSense := IsRegEx := 'No'
      if RegExMatch(Text, 'i)<.*?Case.*?>')
         Flags |= SCFIND_MATCHCASE, IsCaseSense := 'Yes'
      if RegExMatch(Text, 'i)<.*?RegEx.*?>')
         Flags |= SCFIND_REGEXP, IsRegEx := 'Yes'
      if RegExMatch(Text, '^\s*<.*?>\s*(.*?)\s*$', &Match)
         Text := Match[1]
      if Text != ''
      && MsgBox('Searching "' Text '"`n`nCase-sensitive? ' IsCaseSense '`nRegEx? ' IsRegEx, , 'OKCancel') = 'OK'
         SearchAllSciTE4AutoHotkeyTabs(Text, Flags)
   }
   A_Clipboard := C_Clipboard
}
