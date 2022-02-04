#NoEnv
#MaxMem 256
#Include %A_ScriptDir%
;EnvSet, AutGUI, Some text to put in the variable.
#include Splashy.ahk
SetBatchLines, 50ms
; Splashy requires Last Found
Gui +LastFound

SplashRef := Splashy.SplashImg

SysGet, md, MonitorWorkArea, 1

scrWd := mdRight - mdleft
scrHt := mdBottom - mdTop

;image size: 220 * 71 for wikimedia image
ahkWd := 220
ahkHt := 71
ahkHtMod := 0 ; modified

spr := 0
spr1 := 0


; Compute radius: triangle, ellipse
rWd := (scrWd - ahkWd)/2 ; allow for img width
rHt := (scrHt - ahkHt)/2 ; and img Height



startPointWd := 0
startPointHt := 0


triXArg := []
triYArg := []
triVertLength := floor (sqrt((scrWd - ahkWd) * (scrWd - ahkWd)/4 + (scrHt - ahkHt) * (scrHt - ahkHt)))


pi := 4 * ATan(1)
s := round(2 * scrHt/100)
; s doesn't want to be less than 10 or it falls victim to SplaWshy's proportion rule.
; s must be even for the ellipse routine
	if (mod(s, 2))
	s += 1

; arbitrary tolerance
XY_TOL := s/(scrWd + scrHt)

minIndexTop := 0
minIndexBot := 0
ellXArg := []
ellYArg := []
ellVertInterval := []



ahkWdMod := floor((s + 1) * ahkWd/s)
ahkWdAdjust := floor(mod(scrWd, ahkWdMod)/(scrWd/ahkWdMod))
ahkHtMod := floor((s + 1) * ahkHt/s)
;ahkHtAdjust := round(mod((scrHt - 2 * ((s + 1) * ahkHt/s)), ((s + 1) * ahkHt/s))/((scrHt - 2 * ((s + 1) * ahkHt/s))/((s + 1) * ahkHt/s)))
ahkHtAdjust := floor(mod((scrHt - 2 * ahkHtMod), ahkHtMod)/((scrHt - 2 * ahkHtMod)/ahkHtMod))



; init ellipse:

	Loop, %s% ; number of steps
	{
	spr := Sin(A_Index * 2 * pi/s)

	ellYArg.Push(spr)
	ellVertInterval.Push(abs(spr))
	spr1 := Cos(A_Index * 2 * pi/s)
	ellXArg.Push(spr1)
	}

spr := 1
	Loop, % s/2
	{
		if (A_Index == 1)
		ellVertInterval[A_Index] -= ellVertInterval[s]
		else
		ellVertInterval[A_Index] -= abs(ellYArg[A_Index - 1])

		if (abs(ellVertInterval[A_Index]) <= spr)
		{
		spr := ellVertInterval[A_Index]
		minIndexBot := A_Index - 1
		}
	}

if abs((ellVertInterval[minIndexBot] - ellVertInterval[minIndexBot - 1])) < XY_TOL
twoBots := 1
else
twoBots := 0

spr := 1
	Loop, %s%
	{
		if (A_Index > s/2)
		{
		ellVertInterval[A_Index] -= abs(ellYArg[A_Index - 1])

			if (abs(ellVertInterval[A_Index]) <= spr)
			{
			spr := ellVertInterval[A_Index]
			minIndexTop := A_Index - 1
			}
		}
	}

	if abs((ellVertInterval[minIndexTop] - ellVertInterval[minIndexTop - 1])) < XY_TOL
	twoTops := 1
	else
	twoTops := 0




; Init image
%SplashRef%(Splashy, {vHide: 1, imageUrl: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/AutoHotkey_logo.png/220px-AutoHotkey_logo.png"}*)




%SplashRef%(Splashy, {vHide: 1, mainText: "", subText: "", noHWndActivate: 1, vOnTop: 1, vImgW: 0, vImgH: 0}*)


/*
	SplashImgInit(parent, imagePath, imageUrl
	, bkgdColour, transCol, vHide, noHWndActivate
	, vOnTop, vMovable, vBorder, vImgTxtSize
	, vPosX, vPosY, vMgnX, vMgnY, vImgW, vImgH
	, mainText, mainBkgdColour
	, mainFontName, mainFontSize, mainFontWeight, mainFontColour
	, mainFontQuality, mainFontItalic, mainFontStrike, mainFontUnderline
	, subText, subBkgdColour
	, subFontName, subFontSize, subFontWeight, subFontColour
	, subFontQuality, subFontItalic, subFontStrike, subFontUnderline)
*/

msgbox, 8196 , Splashy AHK Road Test, Ready for the Road Test?
	IfMsgBox, No
	gosub Quit

;
; begin subBkgdColour, effects
%SplashRef%(Splashy, {subText: "Testing text colours", vHide: 1, vImgTxtSize: 1, vImgH: 2}*)
AIndex := 1
Loop
{
	Loop %s%
	{
		if (!(mod(A_Index, 3)))
		spr := "purple"
		else
		{
			if (!(mod(A_Index, 2)))
			spr := "cyan"
			else
			spr := "orange"
		}
	Switch (AIndex)
	{
	Case 1:
	%SplashRef%(Splashy, {subText: "Testing text colours", subFontName: "Courier New", vMgnY: A_Index, vHide: 0, subBkgdColour: spr}*)
	Case 2:
	{
		if (A_Index > s/2)
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subText: "Testing FontName: Default", subFontName: "", vMgnY: A_Index}*)
		}
		else
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subText: "Testing FontName: Courier New", subFontName: "Courier New", vMgnY: A_Index, subBkgdColour: ""}*)
		}
	}
	Case 3:
	{
		if (A_Index > s/2)
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subFontSize: 20, subFontWeight: 700, vMgnY: A_Index}*)
		}
		else
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subText: "Testing FontSize and FontWeight", subFontSize: 15, subFontWeight: 500, vMgnY: A_Index}*)
		}
	}
	Case 4:
	{
		if (!(mod(A_Index, 3)))
		spr1 := "gold"
		else
		{
			if (!(mod(A_Index, 2)))
			spr1 := "plum"
			else
			spr1 := "khakigrau"
		}
	%SplashRef%(Splashy, {subText: "Testing text colours", subFontName: "", subFontColour: spr1, subFontSize: "", subFontWeight: "", vImgTxtSize: 0, vMgnY: A_Index}*)
	}
	Case 5:
	{
		if (A_Index > s/2)
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subFontQuality: 5, vMgnY: A_Index}*)
		}
		else
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subText: "Testing FontQuality and FontItalic", subFontQuality: mod(A_Index, 5), subFontItalic: 1, subFontColour: "", vMgnY: A_Index}*)
		}
	}
	Case 6:
	{
		if (A_Index > s/2)
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subFontUnderline: 1, vMgnY: A_Index}*)
		}
		else
		{
			if (!mod(A_Index, 3))
			%SplashRef%(Splashy, {subText: "Testing FontStrike and FontUnderline", subFontQuality: "", subFontItalic: 0, subFontStrike: 1, vMgnY: A_Index}*)
		}
	}
	}
	sleep 100
	}
AIndex++
} Until (AIndex == 7)

%SplashRef%(Splashy, {vHide: 1, subText: "", vMgnY: 0, vImgTxtSize: 1, vImgH: 0, subFontStrike: 0, subFontUnderline: 0}*)





%SplashRef%(Splashy, {vHide: 1, subText: "Testing Margins and Colours"}*)

;Begin Test Margins
Loop %s%
{
	if (!(mod(A_Index, 3)))
	spr := "red"
	else
	{
		if (!(mod(A_Index, 2)))
		spr := "blue"
		else
		spr := "yellow"
	}

%SplashRef%(Splashy, {vHide: 0, bkgdColour: spr, vMgnX : A_Index, vMgnY: A_Index}*)
sleep 100
}

Loop %s%
{

AIndex := s - A_Index + 1

if (!(mod(AIndex, 3)))
spr := "red"
else
{
	if (!(mod(AIndex, 2)))
	spr := "blue"
	else
	spr := "yellow"
}
%SplashRef%(Splashy, {bkgdColour: spr, vMgnX : AIndex, vMgnY: AIndex}*)
sleep 100
}

%SplashRef%(Splashy, {vHide: 1, subText: "", bkgdColour: "", vImgW: 0, vMgnX : 0, vMgnY: 0}*)




; Begin vImgTxtSize

ASpace := ""
Loop % 3 * s
{
ASpace .= A_Space
spr := "Text to " . ASpace . "fit "
%SplashRef%(Splashy, {vHide: 0, mainText: spr, vImgTxtSize: 1}*)
sleep 10
}
Loop % 3 * s
{
ASpace := subStr(ASpace, 2)
spr := "Text to " . ASpace . "fit "
%SplashRef%(Splashy, {mainText: spr, vImgTxtSize: 1}*)
sleep 10
}

; end vImgTxtSize


%SplashRef%(Splashy, {vHide: 1, mainText: "", subText: "", vImgTxtSize: 0}*)





; begin size
spr := 0


Loop %s%
{
spr := (A_Index - 1)/s
%SplashRef%(Splashy, {vHide: 0, vImgW: s + spr * ahkWd, vImgH: s + spr * ahkHt}*)
sleep 5
}

Loop %s%
{
spr := (s - A_Index)/s
%SplashRef%(Splashy, {vImgW: s + spr * ahkWd, vImgH: s + spr * ahkHt}*)
sleep 5
}

Loop %s%
{
spr := (A_Index - 1)/s
%SplashRef%(Splashy, {vImgW: s + spr * ahkWd, vImgH: s + spr * ahkHt}*)
sleep 5
}

Loop
{
spr := ahkWd + s * A_Index
spr1 := ahkHt + s * A_Index
%SplashRef%(Splashy, {vImgW: spr, vImgH: spr1}*)
sleep 5
} Until (spr > scrWd || spr1 > scrHt)

%SplashRef%(Splashy, {vHide: 1, vImgW: 0, vImgH: 0}*)












;Begin Square
msgbox Begin Square


;Dry run to check endpoints

	Loop
	{
	spr := A_Index * ahkWdAdjust + ((A_Index - 1) * ahkWdMod)
	} Until (spr > 20 * scrWd/21)

	if (spr := scrWd - spr)
	startPointWd := floor(spr/2)

spr := 0

	Loop
	{
	spr := A_Index * ahkHtAdjust + (A_Index * ahkHtMod)
	} Until (spr > (20 * scrHt/21) - 2 * ahkHt)

	if (spr := scrHt - spr - 2 * ahkHtMod - ahkHtAdjust)
	startPointHt := floor(spr/2)



spr := 0
Loop
{
spr := startPointHt + A_Index * ahkHtAdjust + (A_Index * ahkHtMod)
AIndex := A_Index
%SplashRef%(Splashy, {vHide: 0, mainText: "", subText: "", instance: A_Index, vPosX: 0, vPosY: spr}*)
} Until (spr > (20 * scrHt/21) - 2 * ahkHt)

Loop
{
spr := startPointWd + A_Index * ahkWdAdjust + ((A_Index - 1) * ahkWdMod)
AIndex1 := AIndex + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex1, vPosX: spr, vPosY: scrHt - ahkHt}*)
} Until (spr > 20 * scrWd/21)


spr1 := scrWd - ahkWdMod
Loop
{
spr := startPointHt + A_Index * ahkHtAdjust + ((A_Index + 1) * ahkHtMod)
AIndex := AIndex1 + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex, vPosX: spr1, vPosY: scrHt - spr}*)
} Until (spr > (20 * scrHt/21) - ahkHt)

Loop
{
spr := startPointWd + A_Index * ahkWdAdjust + (A_Index * ahkWdMod)

AIndex1 := AIndex + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex1, vPosX: scrWd - spr, vPosY: 0}*)
} Until (spr > 20 * scrWd/21)


Loop %AIndex1%
{
sleep, 50
%SplashRef%(Splashy, {instance: -A_Index}*)
}









spr := 0
Loop
{
spr := startPointWd + A_Index * ahkWdAdjust + ((A_Index - 1) * ahkWdMod)

%SplashRef%(Splashy, {mainText: "", subText: "", instance: A_Index, vPosX: spr, vPosY: 0}*)
AIndex := A_Index
} Until (spr > 20 * scrWd/21)

spr1 := scrWd - ahkWdMod
Loop
{
spr := startPointHt + A_Index * ahkHtAdjust + (A_Index * ahkHtMod)
AIndex1 := AIndex + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex1, vPosX: spr1, vPosY: spr}*)
} Until (spr > (20 * scrHt/21) - 2 * ahkHt)

Loop
{
spr := startPointWd + A_Index * ahkWdAdjust + (A_Index * ahkWdMod)
AIndex := AIndex1 + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex, vPosX: scrWd - spr, vPosY: scrHt - ahkHt}*)
} Until (spr > 20 * scrWd/21)

Loop
{
spr := startPointHt + A_Index * ahkHtAdjust + ((A_Index + 1) * ahkHtMod)
AIndex1 := AIndex + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex1, vPosX: 0, vPosY: scrHt - spr}*)
} Until (spr > (20 * scrHt/21) - ahkHt)

Loop %AIndex1%
{
sleep, 50
%SplashRef%(Splashy, {instance: -A_Index}*)
}


spr := 0


Loop
{
spr := startPointHt + A_Index * ahkHtAdjust + (A_Index * ahkHtMod)
AIndex := A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: A_Index, vPosX: 0, vPosY: spr}*)
} Until (spr > (20 * scrHt/21) - 2 * ahkHt)

Loop
{
spr := startPointWd + A_Index * ahkWdAdjust + ((A_Index - 1) * ahkWdMod)
AIndex1 := AIndex + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex1, vPosX: spr, vPosY: scrHt - ahkHt}*)
} Until (spr > 20 * scrWd/21)

spr1 := scrWd - ahkWdMod
Loop
{
spr := startPointHt + A_Index * ahkHtAdjust + ((A_Index + 1) * ahkHtMod)
AIndex := AIndex1 + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex, vPosX: spr1, vPosY: scrHt - spr}*)
} Until (spr > (20 * scrHt/21) - ahkHt)
Loop
{
spr := startPointWd + A_Index * ahkWdAdjust + (A_Index * ahkWdMod)

AIndex1 := AIndex + A_Index
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex1, vPosX: scrWd - spr, vPosY: 0}*)
} Until (spr > 20 * scrWd/21)


Loop %AIndex1%
{
sleep, 50
%SplashRef%(Splashy, {instance: -A_Index}*)
}








msgbox Begin Triangle
;Begin Triangle
;ahkWdMod := scrWd/scrHt/2 * (ahkHt) + floor((mod(scrWd/2, ahkHt)/(s/2)))
spr := floor(scrHt/ahkHt)
ahkHtMod := ahkHt + floor(mod(scrHt, ahkHt)/spr)
	if (rWd < scrHt)
	ahkWdMod := rWd/(spr - 1) + floor((mod(rWd, spr)/spr))
	else
	ahkWdMod := rWd/s + floor((mod(rWd, s/2)/(s/2)))

Loop
{
spr := (A_Index - 1) * ahkWdMod
spr1 := (A_Index - 1) * ahkHtMod
;scaleHt := scrWd/scrHt * 

AIndex := A_Index
;msgbox % "rWd " rWd "s " s " spr " spr " triVertLength " triVertLength "`nscrHt - ahkHt " scrHt - ahkHt " spr1 " spr1
%SplashRef%(Splashy, {mainText: "", subText: "", instance: A_Index, vPosX: spr, vPosY: 2 * rHt - spr1}*)
} Until (spr1 > scrHt - 5*ahkHt/4)  ;(spr * spr + spr1 * spr1 > triVertLength * triVertLength)

Loop
{
spr := (AIndex + A_Index - 1) * ahkWdMod
spr1 := (AIndex - A_Index - 1) * ahkHtMod
;msgbox % "spr " spr " spr1 " spr1 " triVertLength " triVertLength
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex + A_Index, vPosX: spr, vPosY: 2 * rHt - spr1}*)		
} Until (spr1 <= 0)


Loop %AIndex1%
{
sleep, 50
%SplashRef%(Splashy, {instance: -A_Index}*)
}

Loop
{
spr := (A_Index - 1) * ahkWdMod
spr1 := (A_Index - 1) * ahkHtMod
;scaleHt := scrWd/scrHt * 

AIndex := A_Index
;msgbox % "rWd " rWd "s " s " spr " spr " spr1 " spr1 " triVertLength " triVertLength
%SplashRef%(Splashy, {mainText: "", subText: "", instance: A_Index, vPosX: spr, vPosY: spr1}*)
} Until (spr1 > scrHt - 5*ahkHt/4)

Loop
{
spr := (AIndex + A_Index - 1) * ahkWdMod
spr1 := (AIndex - A_Index - 1) * ahkHtMod
;msgbox % "spr " spr " spr1 " spr1 " triVertLength " triVertLength
%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex + A_Index, vPosX: spr, vPosY: spr1}*)		
} Until (spr1 <= 0)


Loop %AIndex1%
{
sleep, 50
%SplashRef%(Splashy, {instance: -A_Index}*)
}








Ellipse:

msgbox Begin Ellipse
;Begin Ellipse

	Loop, %s%
	{
	sleep 100
		if (A_Index == minIndexBot || (twoBots && A_Index == minIndexBot - 1))
		%SplashRef%(Splashy, {mainText: "bot", instance: A_Index, vPosX: (rWd + rWd * ellXArg[A_Index]), vPosY: (rHt + rHt * ellYArg[A_Index])}*)	
		else
		{
			if (A_Index == minIndexTop || (twoTops && A_Index == minIndexTop - 1))
			%SplashRef%(Splashy, {subText: "top", instance: A_Index, vPosX: (rWd + rWd * ellXArg[A_Index]), vPosY: (rHt + rHt * ellYArg[A_Index])}*)
			else
			%SplashRef%(Splashy, {mainText: "", subText: "", instance: A_Index, vPosX: (rWd + rWd * ellXArg[A_Index]), vPosY: (rHt + rHt * ellYArg[A_Index])}*)		
		}
	}



	Loop, %s%
	{
	sleep 100
		if (A_Index == minIndexBot || (twoBots && A_Index == minIndexBot - 1))
		{
		%SplashRef%(Splashy, {mainText: "bot", subText: "", instance: A_Index}*)
		;msgbox % "minIndexBot " minIndexBot " minIndexTop " minIndexTop " A_Index " A_Index
		}
		else
		{
			if (A_Index == minIndexTop || (twoTops && A_Index == minIndexTop - 1))
			%SplashRef%(Splashy, {mainText: "", subText: "top", instance: A_Index, vPosX: (rWd + rWd * ellXArg[A_Index]), vPosY: (rHt + rHt * ellYArg[A_Index])}*)
			else
			{
			if Mod(A_Index, 2) is digit
			{
			%SplashRef%(Splashy, {instance: -A_Index}*)
			;msgbox % "minIndexBot " minIndexBot " minIndexTop " minIndexTop " A_Index " A_Index
			}
			}
		}
	}


; Ellipse reverse
AIndex := s
While AIndex > 0
{
sleep, 50
%SplashRef%(Splashy, {instance: -AIndex}*)
--AIndex
}

AIndex := s

	While AIndex > 0
	{
	sleep 100

		if (AIndex == minIndexTop || (twoTops && AIndex == minIndexTop - 1))
		%SplashRef%(Splashy, {subText: "top", instance: AIndex, vPosX: (rWd + rWd * ellXArg[AIndex]), vPosY: (rHt + rHt * ellYArg[AIndex])}*)	
		else
		{
			if (AIndex == minIndexBot || (twoBots && AIndex == minIndexBot - 1))
			%SplashRef%(Splashy, {mainText: "bot", instance: AIndex, vPosX: (rWd + rWd * ellXArg[AIndex]), vPosY: (rHt + rHt * ellYArg[AIndex])}*)
			else
			%SplashRef%(Splashy, {mainText: "", subText: "", instance: AIndex, vPosX: (rWd + rWd * ellXArg[AIndex]), vPosY: (rHt + rHt * ellYArg[AIndex])}*)		
		}
;msgbox % "minIndexBot " minIndexBot " minIndexTop " minIndexTop "`nAIndex " AIndex "`nrWd + rWd * ellXArg[AIndex] " rWd + rWd * ellXArg[AIndex]
	--AIndex
	}

AIndex := s

	While AIndex > 0
	{
	sleep 100

		if (AIndex == minIndexTop || (twoTops && AIndex == minIndexTop - 1))
		{
		minIndexTop := AIndex
		%SplashRef%(Splashy, {subText: "top", mainText: "", instance: AIndex}*)
		}
		else
		{
			if (AIndex == minIndexBot || (twoBots && AIndex == minIndexBot - 1))
			{
			%SplashRef%(Splashy, {mainText: "bot", subText: "", instance: AIndex, vPosX: (rWd + rWd * ellXArg[AIndex]), vPosY: (rHt + rHt * ellYArg[AIndex])}*)
			minIndexBot := AIndex
			}
			else
			{
			if Mod(AIndex, 2) is digit
			%SplashRef%(Splashy, {instance: -AIndex}*)		
			}
		}
	--AIndex
	}


AIndex := s
	While AIndex > 0
	{
	sleep 100

		if (AIndex == minIndexTop)
		%SplashRef%(Splashy, {subText: "top", mainText: "", instance: AIndex}*)	
		else
		{
			if (AIndex == minIndexBot)
			%SplashRef%(Splashy, {mainText: "bot", subText: "", instance: AIndex, vPosX: (rWd + rWd * ellXArg[AIndex]), vPosY: (rHt + rHt * ellYArg[AIndex])}*)
			else
			%SplashRef%(Splashy, {instance: -AIndex}*)		
		}
	--AIndex
	}

Sleep 200
rWd := (scrWd - ahkWd)/2 ; allow for img width
rHt := (scrHt - ahkHt)/2 ; and img Height

Sleep 200
%SplashRef%(Splashy, {subText: "A", mainText: "A", vPosX: rWd - ahkWd, vPosY: ahkHt, instance: minIndexTop}*)
%SplashRef%(Splashy, {subText: "K", mainText: "K", vPosX: rWd + ahkWd, vPosY: rHt - ahkHt, instance: minIndexBot}*)

Sleep 200
%SplashRef%(Splashy, {subText: "A", mainText: "A", vPosX: rWd - ahkWd, vPosY: 2 * ahkHt, instance: minIndexTop}*)
%SplashRef%(Splashy, {subText: "K", mainText: "K", vPosX: rWd + ahkWd, vPosY: rHt - 2 * ahkHt, instance: minIndexBot}*)

%SplashRef%(Splashy, {subText: "H", mainText: "H", vPosX: rWd, vPosY: rHt, instance: 1}*)

Sleep 200

loop %s%
{
spr := (A_Index <= s/2)?"b":"wscd"
spr1 := (A_Index <= s/2)?"Thin Border":"Borders Combo"

%SplashRef%(Splashy, {vBorder: spr, subText: spr1, mainText: "A", vPosX: rWd - ahkWd, vPosY: rHt, instance: minIndexTop}*)
%SplashRef%(Splashy, {vBorder: spr, subText: spr1, mainText: "H", vPosX: rWd, vPosY: rHt, instance: 1}*)
%SplashRef%(Splashy, {vBorder: spr, subText: spr1, mainText: "K", vPosX: rWd + ahkWd, vPosY: rHt, instance: minIndexBot}*)
Sleep 100
}

Sleep 200

msgbox Road Test complete!

gosub Quit


return
Quit:
Esc::
%SplashRef%(Splashy, {release: 1}*)
ExitApp