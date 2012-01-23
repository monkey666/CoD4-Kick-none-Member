;Example of usage
;_KickNonMember("127.0.0.1", 28960, "password", "Guid.txt")



; #FUNCTION# ====================================================================================================================
; Name ..........: _KickNonMember
; Description ...: Kicks all Players from a Call of Duty 4 Server wich are not listed in the specified .txt File
; Syntax ........: _KickNonMember($sIP, $iPort, $sRcon[, $sGuidFile = "Guid.txt"])
; Parameters ....: $sIP                 - A string value.
;                  $iPort               - An integer value.
;                  $sRcon               - A string value.
;                  $sGuidFile           - [optional] A string value. Default is "Guid.txt".
; Return values .: None
; Author ........: Monkey
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func _KickNonMember($sIP, $iPort, $sRcon, $sGuidFile = "Guid.txt")
	Local $aPlayer = __GetPlayer($sIP, $iPort, $sRcon), $iPlayerZahl, $aGUID, $fMember
	$iPlayerZahl = UBound($aPlayer)
	$aGUID = StringRegExp(FileRead($sGuidFile), "([0-9a-f]{8})\s+.+?", 3)
	Dim $iKicked = 0


	For $p = 1 To UBound($aPlayer) - 1 Step 2

		$fMember = False
		For $g = 0 To UBound($aGUID) - 1
			If $aGUID[$g] = $aPlayer[$p] Then $fMember = True
		Next
		If Not $fMember Then
			__KickPlayer($aPlayer[$p - 1], $sIP, $iPort, $sRcon)
			$iKicked += 1
		EndIf
	Next

	If $iKicked > 0 Then
		__Cod_say("Player kicked: " & $iKicked, $sIP, $iPort, $sRcon)
	EndIf
EndFunc   ;==>_KickNonMember


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __Cod_say
; Description ...: Sends message to the specifed Call of Duty 4 server, wich will be displayed ingame
; Syntax ........: __Cod_say($sText, $sIP, $iPort, $sRcon)
; Parameters ....: $sText               - A string value.
;                  $sIP                 - A string value.
;                  $iPort               - An integer value.
;                  $sRcon               - A string value.
; Return values .: None
; Author ........: Monkey
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __Cod_say($sText, $sIP, $iPort, $sRcon)
	Local $fSaid = False, $sHeader, $aSocket, $hTimer, $sRecv
	$sHeader = "ÿÿÿÿ rcon " & $sRcon & " say " & '"' & $sText & '"' & @CRLF & _
			"." & @CRLF & @CRLF
	Do
		UDPStartup()
		$aSocket = UDPOpen($sIP, $iPort)
		UDPSend($aSocket, $sHeader)
		$hTimer = TimerInit()
		Do
			$sRecv = UDPRecv($aSocket, 2048)
		Until $sRecv <> "" Or TimerDiff($hTimer) > 1000
		If $sRecv <> "" Then $fSaid = True
		UDPCloseSocket($aSocket)
		UDPShutdown()
	Until $fSaid
	ConsoleWrite("[CodSay]" & $sRecv & "[/CodSay]" & @CRLF)
EndFunc   ;==>_Cod_say


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __KickPlayer
; Description ...: Kicks a player with the specifed ID.
; Syntax ........: __KickPlayer($iID, $sIP, $iPort, $sRcon)
; Parameters ....: $iID                 - An integer value.
;                  $sIP                 - A string value.
;                  $iPort               - An integer value.
;                  $sRcon               - A string value.
; Return values .: None
; Author ........: Monkey
; Modified ......:
; Remarks .......: The ID of the current players can be received with __GetPlayer()
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __KickPlayer($iID, $sIP, $iPort, $sRcon)
	Local $fKicked = False, $sHeader, $aSocket, $hTimer, $sRecv
	$sHeader = "ÿÿÿÿ rcon " & $sRcon & " clientkick " & $iID & @CRLF & _
			"." & @CRLF & @CRLF
	Do
		UDPStartup()
		$aSocket = UDPOpen($sIP, $iPort)
		UDPSend($aSocket, $sHeader)
		$hTimer = TimerInit()
		Do
			$sRecv = UDPRecv($aSocket, 2048)
		Until $sRecv <> "" Or TimerDiff($hTimer) > 1000
		If $sRecv <> "" Then $fKicked = True
		UDPCloseSocket($aSocket)
		UDPShutdown()
	Until $fKicked
	ConsoleWrite("[Kick]" & $sRecv & "[/Kick]" & @CRLF)
EndFunc   ;==>_KickPlayer


; #INTERNAL_USE_ONLY# ===========================================================================================================
; Name ..........: __GetPlayer
; Description ...: Recieves the player information from a Call of Duty 4 server
; Syntax ........: __GetPlayer($sIP, $iPort, $sRcon)
; Parameters ....: $sIP                 - A string value.
;                  $iPort               - An integer value.
;                  $sRcon               - A string value.
; Return values .: This Function will return an Array wich includes the GUID's and the player ID's
; Author ........: Monkey
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: No
; ===============================================================================================================================
Func __GetPlayer($sIP, $iPort, $sRcon)
	Local $aPlayer, $fData = False, $sHeader, $aSocket, $hTimer, $sRecv
	$sHeader = "ÿÿÿÿ rcon " & $sRcon & " status" & @CRLF & _
			"." & @CRLF & @CRLF
	Do
		UDPStartup()
		$aSocket = UDPOpen($sIP, $iPort)
		UDPSend($aSocket, $sHeader)
		$hTimer = TimerInit()
		Do
			$sRecv = UDPRecv($aSocket, 2048)
		Until $sRecv <> "" Or TimerDiff($hTimer) > 1000
		If $sRecv <> "" Then $fData = True
		UDPCloseSocket($aSocket)
		UDPShutdown()
	Until $fData
	ConsoleWrite("[GetPlayer]" & $sRecv & "[/GetPlayer]")
	$aPlayer = StringRegExp($sRecv, '\s(\d+).+?([0-9a-f]{8})\s', 3)
	Return $aPlayer
EndFunc   ;==>_getplayer
