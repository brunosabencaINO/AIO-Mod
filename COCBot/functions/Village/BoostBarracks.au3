; #FUNCTION# ====================================================================================================================
; Name ..........: BoostBarracks.au3
; Description ...:
; Syntax ........: BoostBarracks(), BoostSpellFactory(), BoostWorkshop(), BoostTrainingPotion()
; Parameters ....:
; Return values .: None
; Author ........: MR.ViPER (9/9/2016)
; Modified ......: MR.ViPER (17/10/2016), Fliegerfaust (21/12/2017)
; Remarks .......: This file is part of MyBot, previously known as ClashGameBot. Copyright 2015-2019
;                  MyBot is distributed under the terms of the GNU GPL
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================
Func BoostBarracks()
	Return BoostTrainBuilding("Barracks", $g_iCmbBoostBarracks, $g_hCmbBoostBarracks)
EndFunc   ;==>BoostBarracks

Func BoostSpellFactory()
	Return BoostTrainBuilding("Spell Factory", $g_iCmbBoostSpellFactory, $g_hCmbBoostSpellFactory)
EndFunc   ;==>BoostSpellFactory

Func BoostWorkshop()
	Return BoostTrainBuilding("Workshop", $g_iCmbBoostWorkshop, $g_hCmbBoostWorkshop)
EndFunc   ;==>BoostWorkshop

Func BoostTrainBuilding($sName, $iCmbBoost, $iCmbBoostCtrl)
	Local $bBoosted = False

	If Not $g_bTrainEnabled Or $iCmbBoost <= 0 Then Return $bBoosted

	Local $aHours = StringSplit(_NowTime(4), ":", $STR_NOCOUNT)
	If Not $g_abBoostBarracksHours[$aHours[0]] Then
		SetLog("Boosting " & $sName & " isn't planned, skipping", $COLOR_INFO)
		Return $bBoosted
	EndIf

	Local $sIsAre = "are"
	SetLog("Boosting " & $sName, $COLOR_INFO)

	If OpenArmyOverview(True, "BoostTrainBuilding()") Then
		If $sName = "Barracks" Then
			If Not OpenTroopsTab(True, "BoostTrainBuilding()") Then Return
		ElseIf $sName = "Spell Factory" Then
			If Not OpenSpellsTab(True, "BoostTrainBuilding()") Then Return
			$sIsAre = "is"
		ElseIf $sName = "Workshop" Then
			If Not OpenSiegeMachinesTab(True, "BoostTrainBuilding()") Then Return
			$sIsAre = "is"
		Else
			SetDebugLog("BoostTrainBuilding(): $sName called with a wrong Value.", $COLOR_ERROR)
			ClickP($aAway, 1, 0, "#0161")
			_Sleep($DELAYBOOSTBARRACKS2)
			Return $bBoosted
		EndIf
		Local $aBoostBtn = findButton("BoostBarrack")
		If IsArray($aBoostBtn) Then
			ClickP($aBoostBtn)
			_Sleep($DELAYBOOSTBARRACKS1)
			Local $aGemWindowBtn = findButton("GEM")
			If IsArray($aGemWindowBtn) Then
				ClickP($aGemWindowBtn)
				_Sleep($DELAYBOOSTBARRACKS2)
				If IsArray(findButton("EnterShop")) Then
					SetLog("Not enough gems to boost " & $sName, $COLOR_ERROR)
				Else
					If $iCmbBoost >= 1 And $iCmbBoost <= 24 Then
						$iCmbBoost -= 1
						_GUICtrlComboBox_SetCurSel($iCmbBoostCtrl, $iCmbBoost)
						SetLog("Remaining " & $sName & " Boosts: " & $iCmbBoost, $COLOR_SUCCESS)
					ElseIf $iCmbBoost = 25 Then
						SetLog("Remain " & $sName & " Boosts: Unlimited", $COLOR_SUCCESS)
					EndIf
					$bBoosted = True
					; Force to get the Remain Time
					If $sName = "Barracks" Then
						$g_aiTimeTrain[0] = 0 ; reset Troop remaining time
					Else
						$g_aiTimeTrain[1] = 0 ; reset Spells remaining time
					EndIf
				EndIf
			EndIf
		Else
			If IsArray(findButton("BarrackBoosted")) Then
				SetLog($sName & " " & $sIsAre & " already boosted", $COLOR_SUCCESS)
			Else
				SetLog($sName & "boost button not found", $COLOR_ERROR)
			EndIf
		EndIf
	EndIf

	ClickP($aAway, 1, 0, "#0161")
	_Sleep($DELAYBOOSTBARRACKS2)
	Return $bBoosted
EndFunc   ;==>BoostTrainBuilding

; #FUNCTION# ====================================================================================================================
; Name ..........: -
; Description ...:
; Syntax ........: BoostTrainingPotion()
; Parameters ....:
; Return values .: None
; Author ........: Demen - 2018 - (FOR RK MOD)
; Modified ......: 
; Related .......:
; Link ..........: https://github.com/MyBotRun/MyBot/wiki
; Example .......: No
; ===============================================================================================================================

Func BoostTrainingPotion()
	; Verifying existent Variables to run this routine
	If Not AllowBoosting("Training Potion", $g_iCmbBoostTrainingPotion) Then Return

	SetLog("Boosting Training Potion", $COLOR_INFO)
	If $g_aiTownHallPos[0] = "" Or $g_aiTownHallPos[0] = -1 Then
		LocateTownHall()
		SaveConfig()
		If _Sleep($DELAYBOOSTBARRACKS2) Then Return
	EndIf

	Local Static $iLastTimeChecked[8] = [0, 0, 0, 0, 0, 0, 0, 0], $iDateCalc
	$iDateCalc = _DateDiff('n', $iLastTimeChecked[$g_iCurAccount], _NowCalc())

	If $iLastTimeChecked[$g_iCurAccount] = 0 Or $iDateCalc > 50 Then
		; Chek if the Boost is running
		If OpenArmyOverview(True, "BoostTrainingPotion()") Then
			If Not OpenTroopsTab(True, "BoostTrainingPotion()") Then Return
			Local $aBoostBtn = findButton("BoostBarrack")
			If IsArray($aBoostBtn) Then
				ClickP($aAway, 2, 0, "#0161")
				If _Sleep(1000) Then Return

				Local $bChecked = BoostPotion("Training Potion", "Town Hall", $g_aiTownHallPos, $g_iCmbBoostTrainingPotion, $g_hCmbBoostTrainingPotion) = _NowCalc()
				If Not $bChecked Then Return False
				$g_aiTimeTrain[0] = 0 ; reset Troop remaining time
				$g_aiTimeTrain[1] = 0 ; reset Spells remaining time
				$g_aiTimeTrain[2] = 0 ; reset Heroes remaining time
				$iLastTimeChecked[$g_iCurAccount] = _NowCalc() ; Reset the Check Timer
				Return True
			Else
				SetLog("Training Potion is already Boosted", $COLOR_INFO)
			EndIf
			ClickP($aAway, 2, 0, "#0161")
		EndIf
	EndIf

	If _Sleep($DELAYBOOSTBARRACKS3) Then Return
	checkMainScreen(False) ; Check for errors during function
	Return False
EndFunc   ;==>BoostTrainingPotion