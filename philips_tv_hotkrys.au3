#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Res_Fileversion=0.0.0.1
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include "WinHttp.au3"
#include <Misc.au3>
#include <Array.au3>


$tv = "http://192.168.1.18:1925"


Local $sIP = "192.168.1.11" ; ip address as defined by AutoIt
;Local $sIP = @IPAddress1 ; ip address as defined by AutoIt
Local $iPort = 8888;
Local $sServerAddress = "http://" & $sIP & ":" & $iPort & "/"
Local $iMaxUsers = 15 ; Maximum number of users who can simultaneously get/post
Local $sServerName = "MediaboX/1.1 (" & @OSVersion & ") AutoIt " & @AutoItVersion

TCPStartup()

Local $aSocket[$iMaxUsers] ; Creates an array to store all the possible users
Local $sBuffer[$iMaxUsers] ; All these users have buffers when sending/receiving, so we need a place to store those

For $x = 0 to UBound($aSocket)-1
    $aSocket[$x] = -1
Next

$iMainSocket = TCPListen($sIP,$iPort) ;create main listening socket
If @error Then ; if you fail creating a socket, exit the application
    MsgBox(0x20, "AutoIt Webserver", "Unable to create a socket on port " & $iPort & ".") ; notifies the user that the HTTP server will not run
    Exit ; if your server is part of a GUI that has nothing to do with the server, you'll need to remove the Exit keyword and notify the user that the HTTP server will not work.
EndIf

ConsoleWrite( "Server created on " & $sServerAddress & @CRLF) ; If you're in SciTE,

HotKeySet("^#!{BS}", "key_press");
HotKeySet("^#!\", "key_press");
HotKeySet("^#!{LEFT}", "key_press");
HotKeySet("^#!{RIGHT}", "key_press");
HotKeySet("^#!{UP}", "key_press");
HotKeySet("^#!{DOWN}", "key_press");
HotKeySet("^#!{ENTER}", "key_press");
HotKeySet("^#!{ESC}", "key_press");
HotKeySet("^#!{h}", "key_press");
HotKeySet("^#!{g}", "key_press");
HotKeySet("^#!{o}", "key_press");
HotKeySet("^#!{VOLUME_UP}", "key_press");
HotKeySet("^#!{VOLUME_DOWN}", "key_press");
HotKeySet("^#!{VOLUME_MUTE}", "key_press");
HotKeySet("^#!{f}", "key_press");
HotKeySet("^#!{s}", "key_press");
HotKeySet("^#!{a}", "key_press");
HotKeySet("^#!{r}", "key_press");


While 1
    $iNewSocket = TCPAccept($iMainSocket)

    If $iNewSocket >= 0 Then ; Verifies that there actually is an incoming connection
        For $x = 0 to UBound($aSocket)-1 ; Attempts to store the incoming connection
            If $aSocket[$x] = -1 Then
                $aSocket[$x] = $iNewSocket ;store the new socket
                ExitLoop
            EndIf
        Next
    EndIf


    For $x = 0 to UBound($aSocket)-1 ; A big loop to receive data from everyone connected
        If $aSocket[$x] = -1 Then ContinueLoop ; if the socket is empty, it will continue to the next iteration, doing nothing
        $sNewData = TCPRecv($aSocket[$x],1024) ; Receives a whole lot of data if possible
        If @error Then ; Client has disconnected
            $aSocket[$x] = -1 ; Socket is freed so that a new user may join
            ContinueLoop ; Go to the next iteration of the loop, not really needed but looks oh so good
        ElseIf $sNewData Then ; data received
            $sBuffer[$x] &= $sNewData ;store it in the buffer
            If StringInStr(StringStripCR($sBuffer[$x]),@LF&@LF) Then ; if the request has ended ..
                $sFirstLine = StringLeft($sBuffer[$x],StringInStr($sBuffer[$x],@LF)) ; helps to get the type of the request
                $sRequestType = StringLeft($sFirstLine,StringInStr($sFirstLine," ")-1) ; gets the type of the request
                ;If $sRequestType = "GET" Then ; user wants to download a file or whatever ..
                    $sRequest = StringTrimRight(StringTrimLeft($sFirstLine,4),11) ; let's see what file he actually wants
                    Switch $sRequest
                        Case "/media_next"
                            Send("{MEDIA_NEXT}")
                        Case "/media_previous"
                            Send("{MEDIA_PREV}")
                        Case "/media_stop"
                            Send("{MEDIA_STOP}")
                        Case "/media_playpause"
                            Send("{MEDIA_PLAY_PAUSE}")
                        Case "/mute"
                            Send("{VOLUME_MUTE}")
                    EndSwitch
                    _HTTP_SendHTML($aSocket, "200 OK")
                ;EndIf
            EndIf
        EndIf
    Next

    Sleep(10)
WEnd


Func key_press()
	Switch @HotKeyPressed
		Case "^#!{BS}"
			tv_api("/1/input/key", '{"key":"Back"}')
		Case "^#!\"
			tv_api("/1/input/key", '{"key":"Options"}')
		Case "^#!{LEFT}"
			tv_api("/1/input/key", '{"key":"CursorLeft"}')
		Case "^#!{RIGHT}"
			tv_api("/1/input/key", '{"key":"CursorRight"}')
		Case "^#!{UP}"
			tv_api("/1/input/key", '{"key":"CursorUp"}')
		Case "^#!{DOWN}"
			tv_api("/1/input/key", '{"key":"CursorDown"}')
		Case "^#!{ENTER}"
			tv_api("/1/input/key", '{"key":"Confirm"}')
		Case "^#!{ESC}"
			tv_api("/1/input/key", '{"key":"Standby"}')
		Case "^#!{h}"
			tv_api("/1/input/key", '{"key":"Home"}')
		Case "^#!{g}"
			tv_api("/1/input/key", '{"key":"GreenColour"}')
		Case "^#!{o}"
			tv_api("/1/input/key", '{"key":"GreenColour"}')
			Sleep(2500)
			tv_api("/1/input/key", '{"key":"CursorUp"}')
			Sleep(200)
			tv_api("/1/input/key", '{"key":"CursorUp"}')
			Sleep(200)
			tv_api("/1/input/key", '{"key":"CursorUp"}')
			Sleep(200)
			tv_api("/1/input/key", '{"key":"CursorUp"}')
			Sleep(200)
			tv_api("/1/input/key", '{"key":"CursorDown"}')
			Sleep(1000)
			tv_api("/1/input/key", '{"key":"Confirm"}')
		Case "^#!{VOLUME_MUTE}"
			tv_api("/1/input/key", '{"key":"Mute"}')
		Case "^#!{VOLUME_UP}"
			tv_api("/1/input/key", '{"key":"VolumeUp"}')
		Case "^#!{VOLUME_DOWN}"
			tv_api("/1/input/key", '{"key":"VolumeDown"}')
		Case "^#!{f}"
			tv_api("/1/input/key", '{"key":"Viewmode"}')
		Case "^#!{s}"
			tv_api("/1/input/key", '{"key":"Source"}')

		Case "^#!{a}"
			tv_api("/1/input/key", '{"key":"AmbilightOnOff"}')
		Case "^#!{r}"
			tv_api("/1/input/key", '{"key":"Rewind"}')
	EndSwitch
EndFunc




Func tv_api($uri, $post_data)
	if StringLen($post_data) = 0 Then
		$r = HttpGet($tv & $uri, $post_data)
	Else
		$r = HttpPost($tv & $uri, $post_data)
	EndIf
EndFunc

Func OnAutoItExit()
    TCPCloseSocket($iMainSocket)
    TCPShutdown() ; Close the TCP service.
EndFunc   ;==>OnAutoItExit

Func _HTTP_SendHTML($hSocket, $sHTML, $sReply = "200 OK") ; sends HTML data on X socket
    _HTTP_SendData($hSocket, Binary($sHTML), "text/html", $sReply)
EndFunc

Func _HTTP_SendData($hSocket, $bData, $sMimeType, $sReply = "200 OK")
    $sPacket = Binary("HTTP/1.1 " & $sReply & @CRLF & _
    "Server: " & $sServerName & @CRLF & _
    "Connection: close" & @CRLF & _
    "Content-Lenght: " & BinaryLen($bData) & @CRLF & _
    "Content-Type: " & $sMimeType & @CRLF & _
    @CRLF)
    TCPSend($hSocket,$sPacket) ; Send start of packet

    While BinaryLen($bData) ; Send data in chunks (most code by Larry)
        $a = TCPSend($hSocket, $bData) ; TCPSend returns the number of bytes sent
        $bData = BinaryMid($bData, $a+1, BinaryLen($bData)-$a)
    WEnd

    $sPacket = Binary(@CRLF & @CRLF) ; Finish the packet
    TCPSend($hSocket,$sPacket)

    ;TCPCloseSocket($hSocket)
EndFunc
