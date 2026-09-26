#Requires AutoHotkey v2.0
#Include ..\Lib\CloseAllTabsToTheLeft.ahk

#HotIf WinActive('ahk_class SciTEWindow')
^+x::CloseAllTabsToTheLeft()
#HotIf
