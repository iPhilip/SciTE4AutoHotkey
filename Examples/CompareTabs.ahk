#Requires AutoHotkey v2.0
#Include <SplashText>

#HotIf WinActive('ahk_class SciTEWindow')

; --------------------
; Compare two files opened in Scite4AutoHotkey.
; Requires kdiff3.exe to be installed in the C:\Program Files\KDiff3 folder.
; Homepage: http://kdiff3.sourceforge.net/

^+c::
{
   static Key := 'F11'  ; Don't use Esc
   SciTE := ComObjActive('SciTE4AHK.Application')
   SplashText('Select the first tab and press ' Key '...')
   Hook := InputHook('L0', '{' Key '}{Esc}')
   Hook.Start(), Hook.Wait(), SplashText()
   if Hook.EndKey = 'Escape'
      return
   Path1 := SciTE.CurrentFile
   if !FileExist(Path1)
      return MsgBox("File doesn't exist.`n`n" Path1, , 'Iconx')
   SplashText('Select the second tab and press ' Key '...')
   Hook.Start(), Hook.Wait(), SplashText()
   if Hook.EndKey = 'Escape'
      return
   Path2 := SciTE.CurrentFile
   if !FileExist(Path2)
      return MsgBox("File doesn't exist.`n`n" Path2, , 'Iconx')
   Run 'C:\Program Files\KDiff3\kdiff3.exe "' Path1 '" "' Path2 '"'
}
