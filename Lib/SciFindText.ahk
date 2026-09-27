#Requires AutoHotkey v2.0
#Include <RemoteBuffer_Class>  ; https://github.com/iPhilip/RemoteBuffer

; ----------------------------------------------------------------------------------------------------------------
; SciFindText(hCtrl, SearchText, SearchFlags?, StartPos?, &EndPos?)
;
; Find the specified text in the Scintilla control of the SciTE4AutoHotkey window.
;
; Parameters:
;
; hCtrl - the handle of the Scintila control, e.g. ControlGetHwnd('Scintilla1', 'ahk_id' oSciTE.SciTEHandle)
;
; SearchText - The text to be searched.
;
; Search flags - Flags that determine the type of search. This value can be a combination of the following values:
;
;    SCFIND_NONE       := 0x0
;    SCFIND_WHOLEWORD  := 0x2
;    SCFIND_MATCHCASE  := 0x4
;    SCFIND_WORDSTART  := 0x00100000
;    SCFIND_REGEXP     := 0x00200000
;    SCFIND_POSIX      := 0x00400000
;    SCFIND_CXX11REGEX := 0x00800000
;
; See https://scintilla.org/ScintillaDoc.html#searchFlags for more details.
;
; StartPos and EndPos - The starting and ending byte positions, not necessarily character positions.
; If omitted the starting byte position will be 0.
; If omitted the ending byte position will be the last position in the document.
; Note that EndPos is a ByRef parameter so that the SCI_GETLENGTH message doesn't have to be called each time the function is called for the same document.
;
; Notes:
; The function uses the SCI_FINDTEXT message to find the text in the control.
; https://scintilla.org/ScintillaDoc.html#SCI_FINDTEXT
; On 64-bit Win32, SCI_FINDTEXT is limited to the first 2G of text.
; The SCI_FINDTEXTFULL message removes this limitation.
; SCI_FINDTEXTFULL requires Scintilla 5.2.3 (see https://www.scintilla.org/ScintillaHistory.html).
; Version 3.1.0 of SciTE4AutoHotkey uses SciTE/Scintilla 5.2.2.
;
; Requires the RemoteBuffer class
; ----------------------------------------------------------------------------------------------------------------

SciFindText(hCtrl, SearchText, SearchFlags?, StartPos?, &EndPos?) {
   static SCFIND_NONE   := 0
   static SCI_GETLENGTH := 2006
   static SCI_FINDTEXT  := 2150
   
   PID := WinGetPID(hCtrl)
   SearchTextBuffer := Buffer(StrPut(SearchText, 'UTF-8'))
   StrPut SearchText, SearchTextBuffer, 'UTF-8'
   RemoteSearchTextBuffer := RemoteBuffer(PID, SearchTextBuffer.Size)
   RemoteSearchTextBuffer.Write(SearchTextBuffer)
   
   Sci_TextToFind := Buffer(24, 0)
   EndPos := EndPos ?? SendMessage(SCI_GETLENGTH, 0, 0, hCtrl)
   NumPut 'Int', StartPos ?? 0, 'Int', EndPos, 'Ptr', RemoteSearchTextBuffer.Ptr, Sci_TextToFind, 0
   RemoteTextToFindBuffer := RemoteBuffer(PID, Sci_TextToFind.Size)
   RemoteTextToFindBuffer.Write(Sci_TextToFind)
   
   Result := {}
   Result.Value := SendMessage(SCI_FINDTEXT, SearchFlags ?? SCFIND_NONE, RemoteTextToFindBuffer, hCtrl) << 32 >> 32
   if Result.Value = -1
      return
   RemoteTextToFindBuffer.Read(Sci_TextToFind)
   
   Result.StartPos := NumGet(Sci_TextToFind, 16, 'Int')
   Result.EndPos   := NumGet(Sci_TextToFind, 20, 'Int')
   
   return Result
}

/*
struct Sci_TextToFind {
    struct Sci_CharacterRange chrg;     // range to search - 8 bytes
    const char *lpstrText;              // the search pattern (zero terminated) - 8 bytes (for 64-bit SciTE4AutoHotkey)
    struct Sci_CharacterRange chrgText; // returned as position of matching text - 8 bytes
};

struct Sci_CharacterRange {
    Sci_PositionCR cpMin; - 4 bytes
    Sci_PositionCR cpMax; - 4 bytes
};
