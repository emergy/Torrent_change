#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=0.1.0.30
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

AutoItSetOption("TrayIconHide", 1)

#include <GuiConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <WinAPI.au3>
#include <Misc.au3>

$torrent_client_cmd_line = @AppDataDir & "\uTorrent\uTorrent.exe " & $CmdLineRaw
$ace_stream_player_cmd_line = @AppDataDir & "\ACEStream\player\ace_player.exe --play-and-exit --fullscreen " & $CmdLineRaw

; Install and configure UltraMon for use this
; functional, or erase for disable
$hotkey_for_swich_to_tv = "!#^{NUMPAD1}"
$hotkey_for_swich_to_motitor = "!#^{NUMPAD2}"

$full_screen = 1

$Gui = GUICreate("Change open as...", 395, 200, -1, -1, $WS_POPUP, $WS_EX_DLGMODALFRAME + $WS_EX_TOPMOST)
GUIRegisterMsg($WM_LBUTTONDOWN, "_WinMove")

$btnPlay = GUICtrlCreateButton("Play", 200, 5, 190, 190)
$btnDownload = GUICtrlCreateButton("Download", 5, 5, 190, 190)

Local $hDLL = DllOpen("user32.dll")

HotKeySet("!{LEFT}", "download");
HotKeySet("!{RIGHT}", "play");

GUISetState()

While 1
	$Msg = GUIGetMsg()

	Switch $Msg
		Case -3
			Exit
		Case $btnPlay
			play()
		Case $btnDownload
			download()
	EndSwitch
WEnd

Func download()
	Run($torrent_client_cmd_line)
	Exit
EndFunc   ;==>download

Func play()
	GUISetState(@SW_HIDE, $Gui)
	$monNum = _WinAPI_GetSystemMetrics(80)

	; No change display if hold ctrl
	If _IsPressed("11", $hDLL) Then $full_screen = 0

	If $full_screen = 1 Then
		If $monNum > 1 And StringLen($hotkey_for_swich_to_tv) > 0 Then
			Send($hotkey_for_swich_to_tv)
			Sleep(2000)
		EndIf
	EndIf

	$iPID = Run($ace_stream_player_cmd_line)
	Sleep(500)
	$HWnd = _GetHwndFromPID($iPID)

	If $full_screen = 1 Then
		If $monNum > 1 And StringLen($hotkey_for_swich_to_motitor) > 0 Then
			ProcessWaitClose($iPID)
			Send($hotkey_for_swich_to_motitor)
		EndIf
	EndIf

	Exit
EndFunc   ;==>play

Func _WinMove($HWnd, $Command, $wParam, $lParam)
	If BitAND(WinGetState($HWnd), 32) Then Return $GUI_RUNDEFMSG
	DllCall("user32.dll", "long", "SendMessage", "hwnd", $HWnd, "int", $WM_SYSCOMMAND, "int", 0xF009, "int", 0)
EndFunc   ;==>_WinMove

Func _GetHwndFromPID($PID)
	$HWnd = 0
	$stPID = DllStructCreate("int")
	Do
		$winlist2 = WinList()
		For $i = 1 To $winlist2[0][0]
			If $winlist2[$i][0] <> "" Then
				DllCall("user32.dll", "int", "GetWindowThreadProcessId", "hwnd", $winlist2[$i][1], "ptr", DllStructGetPtr($stPID))
				If DllStructGetData($stPID, 1) = $PID Then
					$HWnd = $winlist2[$i][1]
					ExitLoop
				EndIf
			EndIf
		Next
		Sleep(100)
	Until $HWnd <> 0
	Return $HWnd
EndFunc   ;==>_GetHwndFromPID
