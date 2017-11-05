#include <Misc.au3>
$dll = DllOpen('user32.dll')

While True
    For $x = 0 To 255
        If _IsPressed(Hex($x, 2), $dll) Then
            ConsoleWrite(Hex($x, 2))
            While _IsPressed(Hex($x, 2), $dll)
                Sleep(1)
            WEnd
        EndIf
    Next
    Sleep(1)
WEnd

Func OnAutoItExit()
    DllClose($dll)
    Exit
EndFunc  ;==>OnAutoItExit