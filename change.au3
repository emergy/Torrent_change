#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=0.1.0.17
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <WinAPI.au3>

$torrent_client_cmd_line = @AppDataDir & "\uTorrent\uTorrent.exe " & $CmdLineRaw
$ace_stream_player_cmd_line = @AppDataDir & "\ACEStream\player\ace_player.exe --play-and-exit --fullscreen " & $CmdLineRaw

; Install and configure UltraMon for use this
; functional, or erase for disable
$hotkey_for_swich_to_tv="!#^{NUMPAD1}"
$hotkey_for_swich_to_motitor="!#^{NUMPAD2}"

$Gui = GuiCreate("Change open as...", 395, 200, -1, -1, $WS_POPUP, $WS_EX_DLGMODALFRAME + $WS_EX_TOPMOST)
GuiRegisterMsg($WM_LBUTTONDOWN, "_WinMove")

$btnPlay = GUICtrlCreateButton("Play", 5, 5, 190, 190)
$btnDownload = GUICtrlCreateButton("Download", 200, 5, 190, 190)

GUISetState()

While 1
    $Msg = GUIGetMsg()

    Switch $Msg
        Case -3
            Exit
		Case $btnPlay
			GUISetState(@SW_HIDE, $Gui)
			$monNum = _WinAPI_GetSystemMetrics(80)

			If $monNum > 1 And StringLen($hotkey_for_swich_to_tv) > 0 Then
				Send($hotkey_for_swich_to_tv)
				Sleep(2000)
			EndIf

			$iPID = Run($ace_stream_player_cmd_line)
			Sleep(500)
			$hWnd = _GetHwndFromPID($iPID)

			If $monNum > 1 And StringLen($hotkey_for_swich_to_motitor) > 0 Then
				ProcessWaitClose($iPID)
				Send($hotkey_for_swich_to_motitor)
			EndIf

			Exit
		Case $btnDownload
			Run($torrent_client_cmd_line)
			Exit
    EndSwitch
WEnd

Func _WinMove($HWnd, $Command, $wParam, $lParam)
    If BitAND(WinGetState($HWnd), 32) Then Return $GUI_RUNDEFMSG
    DllCall("user32.dll", "long", "SendMessage", "hwnd", $HWnd, "int", $WM_SYSCOMMAND, "int", 0xF009, "int", 0)
EndFunc

Func _GetHwndFromPID($PID)
    $hWnd = 0
    $stPID = DllStructCreate("int")
    Do
        $winlist2 = WinList()
        For $i = 1 To $winlist2[0][0]
            If $winlist2[$i][0] <> "" Then
                DllCall("user32.dll", "int", "GetWindowThreadProcessId", "hwnd", $winlist2[$i][1], "ptr", DllStructGetPtr($stPID))
                If DllStructGetData($stPID, 1) = $PID Then
                    $hWnd = $winlist2[$i][1]
                    ExitLoop
                EndIf
            EndIf
        Next
        Sleep(100)
    Until $hWnd <> 0
    Return $hWnd
EndFunc ;==>_GetHwndFromPID