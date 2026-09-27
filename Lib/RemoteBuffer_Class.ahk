; Updated

#Requires AutoHotkey v2.0

class RemoteBuffer
{
   __New(PID, Size) {
      static MEM_COMMIT := 0x00001000, PAGE_READWRITE := 0x04
      static DesiredAccess := (PROCESS_VM_OPERATION := 0x0008) | (PROCESS_VM_READ := 0x0010) | (PROCESS_VM_WRITE := 0x0020)
      if !this.Ptr := DllCall('Kernel32.dll\VirtualAllocEx', 'Ptr', this.Process := Process(PID, DesiredAccess), 'Ptr', 0, 'UPtr', Size, 'UInt', MEM_COMMIT, 'UInt', PAGE_READWRITE, 'Ptr')
         throw Error('VirtualAllocEx failed.', -1, this.FormatError(A_LastError))
   }
   
   __Delete() {
      static MEM_RELEASE := 0x00008000
      if !DllCall('Kernel32.dll\VirtualFreeEx', 'Ptr', this.Process, 'Ptr', this.Ptr, 'UPtr', 0, 'UInt', MEM_RELEASE, 'Int')
         throw Error('VirtualFreeEx failed.', -1, this.FormatError(A_LastError))
   }
   
   ; ----------------------------------------------------------------
   ; Read(BufferObj, Offset := 0)
   ;
   ; Reads the contents of the remote buffer into the specified buffer.
   ; The number of bytes read from the process is the size of the specified buffer.
   ; The specified Offset is applied to the remote buffer memory location.
   ; The return value is the number of bytes read, which should equal to the specified buffer size.
   ; ----------------------------------------------------------------
   
   Read(BufferObj, Offset := 0) {
      if !DllCall('Kernel32.dll\ReadProcessMemory', 'Ptr', this.Process, 'Ptr', this.Ptr + Offset, 'Ptr', BufferObj, 'UPtr', BufferObj.Size, 'UPtr*', &NumberOfBytesRead := 0, 'Int')
         throw Error('ReadProcessMemory failed.', -1, this.FormatError(A_LastError))
      return NumberOfBytesRead
   }
   
   ; ----------------------------------------------------------------
   ; Write(BufferObj, Offset := 0)
   ;
   ; Writes the contents of the specified buffer to the remote buffer.
   ; The number of bytes written to the process is the size of the specified buffer.
   ; The specified Offset is applied to the remote buffer memory location.
   ; The return value is the number of bytes written, which should equal to specified buffer size.
   ; ----------------------------------------------------------------
   
   Write(BufferObj, Offset := 0) {
      if !DllCall('Kernel32.dll\WriteProcessMemory', 'Ptr', this.Process, 'Ptr', this.Ptr + Offset, 'Ptr', BufferObj, 'UPtr', BufferObj.Size, 'UPtr*', &NumberOfBytesWritten := 0, 'Int')
         throw Error('WriteProcessMemory failed.', -1, this.FormatError(A_LastError))
      return NumberOfBytesWritten
   }
   
   ; Helper method
   
   FormatError(ErrorNo) => RegExReplace(OSError(ErrorNo).Message, '^\([x[:xdigit:]]+\) ')
}

class Process
{
   __New(PID, DesiredAccess) {
      if !this.Ptr := DllCall('Kernel32.dll\OpenProcess', 'UInt', DesiredAccess, 'Int', false, 'UInt', PID, 'Ptr')
         throw Error('OpenProcess failed.', -1, this.FormatError(A_LastError))
   }
   
   __Delete() {
      if !DllCall('Kernel32.dll\CloseHandle', 'Ptr', this.Ptr, 'Int')
         throw Error('CloseHandle failed.', -1, this.FormatError(A_LastError))
   }
   
   ; ----------------------------------------------------------------
   ; IsWow64()
   ;
   ; Determines whether the process is running under WOW64 or an Intel64 of x64 processor.
   ; The struct layout of any remote buffer must match the target process' bitness, regardless of AHK's bitness.
   ; A return value of 0 means that the process is a native 64-bit application running under 64-bit Windows. The struct layout must 64-bit aligned.
   ; A return value of 1 means that the process is running under WOW64 on a x64 processor. The struct layout must be 32-bit aligned.
   ; ----------------------------------------------------------------
   
   IsWow64() {
      if !DllCall('Kernel32.dll\IsWow64Process', 'Ptr', this.Ptr, 'Int*', &Wow64Process := 0, 'Int')
         throw Error('IsWow64Process failed.', -1, this.FormatError(A_LastError))
      return Wow64Process
   }
   
   ; Helper method
   
   FormatError(ErrorNo) => RegExReplace(OSError(ErrorNo).Message, '^\([x[:xdigit:]]+\) ')
}
