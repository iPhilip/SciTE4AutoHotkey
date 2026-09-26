#Requires AutoHotkey v2.0

CloseAllTabsToTheLeft() {
   SciTE := ComObjActive('SciTE4AHK.Application')
   CurrentFile := SciTE.CurrentFile
   SciTE.SwitchToTab(0)
   Sleep 100
   for TabPath in SciTE.Tabs.Array {
      if TabPath = CurrentFile
         break
      SciTE.SendDirectorMsg('close:')
   }
}
