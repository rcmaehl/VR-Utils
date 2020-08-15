HotKeySet("{ESC}", "_Toggle")

#include <TabConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>


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

	Local $hMsg

	Local $hGUI = GUICreate("VR Utils", 320, 240, -1, -1, BitOr($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU))

	Local $hTabs = GUICtrlCreateTab(0, 0, 320, 240, $TCS_VERTICAL+$TCS_BUTTONS)

		GUICtrlCreateTabItem("Dashboards")
			$hDashboards = GUICreate("", 300, 240, 20, 0, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
			GUICtrlCreateTab(0, 0, 300, 240)
				GUICtrlCreateTabItem("HTC")
				GUICtrlCreateTabItem("Oculus")
					$hOculusLockout = GUICtrlCreateCheckbox("Lockout Dashboard", 10, 25, 140, 20)
				GUICtrlCreateTabItem("Steam")
					$hSteamLockout = GUICtrlCreateCheckbox("Lockout Dashboard", 10, 25, 140, 20)
				GUICtrlCreateTabItem("WMR")
			GUICtrlCreateTabItem("")
		GUISwitch($hGUI)

		GUICtrlCreateTabItem("Headsets")
			GUICtrlSetState(-1, $GUI_SHOW)
			$hHeadSets = GUICreate("", 300, 240, 20, 0, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
			GUICtrlCreateTab(0, 0, 300, 240)
				GUICtrlCreateTabItem("Index")
				GUICtrlCreateTabItem("Rift")
				GUICtrlCreateTabItem("Rift S")
					$hRiftSFixDP = GUICtrlCreateCheckbox('Automatically Fix "No DisplayPort Connection"', 10, 25, 280, 20)
				GUICtrlCreateTabItem("Vive")
				GUICtrlCreateTabItem("WMR")
			GUICtrlCreateTabItem("")
		GUISetState(@SW_SHOW, $hHeadSets)
		GUISwitch($hGUI)

		GUICtrlCreateTabItem("VR Utils Settings")
			$hStartUp = GUICtrlCreateCheckbox("Start With Windows", 30, 5, 145, 20)
			$hUpdates = GUICtrlCreateCheckbox("Automatically Check for Updates", 30, 25, 180, 20)
				$hCheckNow = GUICtrlCreateButton("Check Now", 240, 25, 70, 20)
		GUISwitch($hGUI)

	GUICtrlCreateTabItem("")

	GUISetState(@SW_SHOW, $hGUI)

	While True

		$hMsg = GUIGetMsg()

		Select

			Case $hMsg = $GUI_EVENT_CLOSE
				GUIDelete($hGUI)
				Exit

			Case $hMsg = $hTabs
				Switch GUICtrlRead($hTabs)
					Case 0
						GUISetState(@SW_HIDE, $hHeadSets)
						GUISetState(@SW_SHOW, $hDashboards)
					Case 1
						GUISetState(@SW_HIDE, $hDashboards)
						GUISetState(@SW_SHOW, $hHeadSets)
					Case 2
						GUISetState(@SW_HIDE, $hDashboards)
						GUISetState(@SW_HIDE, $hHeadSets)

				EndSwitch
		EndSelect

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