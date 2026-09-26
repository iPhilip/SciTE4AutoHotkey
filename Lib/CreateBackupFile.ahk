#Requires AutoHotkey v2.0

; Creates a backup file containing the contents of the current file.
; Outputs a notification to the SciTE output pane, opening it if closed.
; Returns the name of the backup file.

CreateBackupFile(BackupDir := '', Encoding := 'UTF-8') {
   static WinTitle := 'ahk_class SciTEWindow'
   
   SciTE := ComObjActive('SciTE4AHK.Application')
   SplitPath SciTE.CurrentFile, &FileName, &Dir, &Extension, &NameNoExt
   if FileName && Instr(WinGetTitle(WinTitle), FileName) {
      BackupDir := BackupDir = '' ? Dir : Dir '\' BackupDir
      if !DirExist(BackupDir)
         DirCreate BackupDir
      
      BackupPath := BackupDir '\' NameNoExt '_' A_Now '.' Extension
      FileObj := FileOpen(BackupPath, 'w', Encoding)
      FileObj.Write(SciTE.Document)
      FileObj.Close()
      
      OpenSciTEOutputPane(true)
      ControlSend '^{End}', 'Scintilla2', WinTitle
      SciTE.Output('>"' BackupPath '" was successfully created.`n')
      
      return BackupPath
   }
}

; Opens/closes the SciTE output pane.

OpenSciTEOutputPane(Flag, MaxTries := 10) {
   static WinTitle         := 'ahk_class SciTEWindow'
   static WM_COMMAND       := 0x0111
   static IDM_TOGGLEOUTPUT := 409
   
   ControlGetPos , , , &Height, 'Scintilla2', WinTitle
   
   if !height = !Flag
      return
   
   SendMessage WM_COMMAND, IDM_TOGGLEOUTPUT, 0, , WinTitle
   
   Loop MaxTries {
      Sleep 100
      ControlGetPos , , , &Height, 'Scintilla2', WinTitle
      
      if !Height = !Flag
         return
   }
   
   throw Error("Unable to toggle SciTE's output pane.", -1)
}
