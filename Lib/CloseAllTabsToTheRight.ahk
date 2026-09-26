#Requires AutoHotkey v2.0

CloseAllTabsToTheRight() {
   SciTE := ComObjActive('SciTE4AHK.Application')
   CurrentFile := SciTE.CurrentFile
   Tabs := SciTE.Tabs
   for TabPath in Tabs.Array {
      if TabPath = CurrentFile {
         SciTE.SwitchToTab(A_Index)
         Loop Tabs.Count - A_Index
            SciTE.SendDirectorMsg('close:')
         break
      }
   }
}
