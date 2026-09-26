#Requires AutoHotkey v2.0
#Include ..\Lib\CloseAllTabsToTheRight.ahk

#HotIf WinActive('ahk_class SciTEWindow')
^+x::CloseAllTabsToTheRight()
#HotIf
