HotKeySet("{ESC}", "_Toggle")

Global $aSuspend[2] = [False, False] ; Should Suspend, Is Suspended

Main()

Func _Toggle()
	$aSuspend[0] = Not $aSuspend[0]
EndFunc

Func _ProcessSuspend($sProcess)
	$iPID = ProcessExists($sProcess)
	If $iPID Then
		$ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $iPID)
		$i_success = DllCall("ntdll.dll","int","NtSuspendProcess","int",$ai_Handle[0])
		DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $ai_Handle)
		If IsArray($i_success) Then
			Return 1
		Else
			SetError(1)
			Return 0
		Endif
	Else
		SetError(2)
		Return 0
	EndIf
EndFunc

Func _ProcessResume($sProcess)
	$iPID = ProcessExists($sProcess)
	If $iPID Then
		$ai_Handle = DllCall("kernel32.dll", 'int', 'OpenProcess', 'int', 0x1f0fff, 'int', False, 'int', $iPID)
		$i_success = DllCall("ntdll.dll","int","NtResumeProcess","int",$ai_Handle[0])
		DllCall('kernel32.dll', 'ptr', 'CloseHandle', 'ptr', $ai_Handle)
		If IsArray($i_success) Then
			Return 1
		Else
			SetError(1)
			Return 0
		Endif
	Else
		SetError(2)
		Return 0
	EndIf
EndFunc

Func Main()
	; Resume on Launch in case anything broke previously
	_ProcessResume("OculusDash.exe")
	_ProcessResume("VRDashboard.exe")
	While True
		If $aSuspend[0] Then
			If Not $aSuspend[1] Then
				_ProcessSuspend("OculusDash.exe")
				_ProcessSuspend("VRDashboard.exe")
				$aSuspend[1] = True
			EndIf
		Else
			If $aSuspend[1] Then
				_ProcessResume("OculusDash.exe")
				_ProcessResume("VRDashboard.exe")
				$aSuspend[1] = False
			EndIf
		EndIf
	WEnd
EndFunc