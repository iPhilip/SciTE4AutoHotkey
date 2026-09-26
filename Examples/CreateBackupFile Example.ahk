#Requires AutoHotkey v2.0
#Include ..\Lib\CreateBackupFile.ahk

#HotIf WinActive('ahk_class SciTEWindow')
^+s::CreateBackupFile('Backups')
