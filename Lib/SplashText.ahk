#Requires AutoHotkey v2.0

; -------------------------------------------------------------------------------------------------------------------------------
; SplashText(Text?, Title?, Options?, Timeout?)
; Function:       Creates a customizable GUI window with text in it. Use SplashText() to destroy the window. Calling the function
;                 with any text while a SplashText window is being displayed, destroys the previous window and creates a new one.
;                 The window is 'always on top', meaning that it stays above all other normal windows. To change this, use
;                 WinSetAlwaysOnTop(false, SplashGui). The window and the text in it can be customized through the
;                 Options parameter (see below).
; Parameters:     Text    - (Optional) The text to be displayed. If omitted, any existing SplashText window will be destroyed.
;                 Title   - (Optional) The title of the GUI window. If omitted, the file name of the script will be used.
;                 Options - (Optional) An object literal with any of the following properties:
;                    Font - Font options separated by spaces (https://www.autohotkey.com/docs/v2/lib/GuiObj.htm#SetFont)
;                    FontName - The name of the font (https://www.autohotkey.com/docs/v2/misc/FontsStandard.htm)
;                    Text - Text options separated by spaces (https://www.autohotkey.com/docs/v2/lib/GuiObj.htm#Add)
;                    BackColor - The background color of the window (https://www.autohotkey.com/docs/v2/lib/GuiObj.htm#BackColor)
;                    Show - Gui.Show options separated by spaces (https://www.autohotkey.com/docs/v2/lib/GuiObj.htm#Show)
;                    Note: If any of the properties are omitted, the value associated with that same property in the
;                          DefaultOptions object will be used. If Options is omitted, the function generates a window
;                          similar to the window created with the AutoHotkey v1 SplashTextOn command.
;                 Timeout - (Optional) The time in seconds after which the window is automatically destroyed. If this parameter
;                           is omitted, the window will continue to be shown until it is destroyed using SplashText().
; Return values:  The Gui object if a GUI window was created or a blank, otherwise.
; Global vars:    None
; Depenencies:    None
; Requirements:   AHK v2.0
; Tested with:    AHK v2.0.11 (U32/U64)
; Tested on:      Win 10 Pro (x64)
; Written by:     iPhilip
; Forum link:     https://www.autohotkey.com/boards/viewtopic.php?f=6&t=48681
; -------------------------------------------------------------------------------------------------------------------------------

SplashText(Text?, Title?, Options?, Timeout?)
{
   static SplashGui, DefaultOptions := {Font:'s11', FontName:'Segoe UI', Text:'Center', BackColor:'', Show:''}
   
   if IsSet(SplashGui)
   {
      SetTimer SplashText, 0
      SplashGui.Destroy()
      SplashGui := UnSet
   }
   
   if IsSet(Text)
   {
      Options := Options ?? {}
      SplashGui := Gui('+AlwaysOnTop +Owner -SysMenu', Title?)
      SplashGui.SetFont(Options.HasOwnProp('Font') ? Options.Font : DefaultOptions.Font
                      , Options.HasOwnProp('FontName') ? Options.FontName : DefaultOptions.FontName)
      SplashGui.Add('Text', Options.HasOwnProp('Text') ? Options.Text : DefaultOptions.Text, Text)
      SplashGui.BackColor := Options.HasOwnProp('BackColor') ? Options.BackColor : DefaultOptions.BackColor
      SplashGui.Show(Options.HasOwnProp('Show') ? Options.Show : DefaultOptions.Show)
      
      if IsSet(Timeout) && Timeout > 0
         SetTimer SplashText, -Timeout * 1000
      
      return SplashGui
   }
}
