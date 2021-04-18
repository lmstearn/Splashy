
#SingleInstance, force
#NoEnv  ; Performance and compatibility with future AHK releases.
;#Warn, All, OutputDebug ; Enable warnings for a debugger to display to assist with detecting common errors.
;#Warn UseUnsetLocal, OutputDebug  ; Warn when a local variable is used before it's set; send to OutputDebug
#MaxMem 256
#MaxThreads 3
#Persistent
#Include %A_ScriptDir%


AutoTrim, Off ; traditional assignments off
ListLines Off ;A_ListLines default is on: history of lines most recently executed 
SendMode Input  ; Recommended for new scripts due to superior speed & reliability.
SetWinDelay, 40
; ListVars for debugging
SetBatchLines, 25ms ; too fast? A_BatchLines is 10ms

Class Splashy
{

	spr := 0
	spr1 := 0
	spr2 := 0

	; HTML Colours (RGB- no particular order)
	STATIC HTML := {CYAN: "0X00FFFF", AQUAMARINE : "0X7FFFD4", BLACK: "0X000000", BLUE: "0X0000FF", FUCHSIA: "0XFF00FF", GRAY: "0X808080", AUBURN: "0X2A2AA5"
	 , LIME: "0X00FF00", MAROON: "0X800000", NAVY: "0X000080", OLIVE: "0X808000", PURPLE: "0X800080", INDIGO: "0X4B0082", LAVENDER: "0XE6E6FA", DKSALMON: "0X7A96E9"
	 , SILVER: "0XC0C0C0", TEAL: "0X008080", WHITE: "0XFFFFFF", YELLOW: "0XFFFF00", WHEAT: "0xF5DEB3", ORANGE: "0XFFA500", BEIGE: "0XF5F5DC", CELADON: "0XACE1AF"
	 , CHESTNUT: "0X954535", TAN: "0xD2B48C", CHOCOLATE: "0X7B3F00", TAUPE: "0X483C32", SALMON: "0XFA8072", VIOLET: "0X7F00FF", GRAPE: "0X6F2DA8", STEINGRAU: "0X485555"
	 , PEACH: "0XFFE5B4", CORAL: "0XFF7F50", CRIMSON: "0XDC143C", VERMILION: "0XE34234", CERULEAN: "0X007BA7", TURQUOISE: "0X40E0D0", VIRIDIAN: "0X40826D", RED: "0XFF0000"
	 , PLUM: "0X8E4585", MAGENTA: "0XF653A6", GOLD: "0XFFD700", GOLDENROD: "0XDAA520", GREEN: "0X008000", ONYX: "0X353839", KHAKIGRAU: "0X746643", FELDGRAU: "0X3D5D5D"}

	Static WM_PAINT := 0x000F
	Static WM_NCHITTEST := 0x84
	Static WM_ERASEBKGND := 0x0014
	Static WM_CTLCOLORSTATIC := 0x0138

	Static updateFlag := -1
	Static procEnd := 0
	Static pToken := 0
	Static hGDIPLUS := 0
	Static WndProcOld := 0


	Static ImageName := ""
	Static userWorkingDir := ""
	Static downloadedPathNames := []
	Static downloadedUrlNames := []
	Static vImgType := 0
	Static hWndSaved := 0
	Static release := 0
	Static hDCWin := 0
	Static hBitmap := 0
	Static hIcon := 0
	Static vHide := 0
	Static vMgnX := 0
	Static vMgnY := 0
	Static vImgX := 0
	Static vImgY := 0
	Static vImgW := 0
	Static vImgH := 0


	Static imagePath := ""
	Static imageUrl := ""
	Static bkgdColour := ""
	Static transCol := 0
	Static noHWndActivate := 0
	Static vBorder := 0
	Static vOnTop := 0


	Static mainTextHWnd := 0
	Static mainText := ""
	Static mainTextSize := [0, 0]
	Static mainBkgdColour := ""
	Static mainFontName := ""
	Static mainFontSize := 0
	Static mainFontWeight := 0
	Static mainFontColour := ""
	Static mainFontQuality := 0
	Static mainFontItalic := ""
	Static mainFontStrike := ""
	Static mainFontUnderline := ""
	Static mainMarquee := 0

	Static subTextHWnd := 0
	Static subText := ""
	Static subTextSize := [0, 0]
	Static subBkgdColour := ""
	Static subFontName := ""
	Static subFontSize := 0
	Static subFontWeight := 0
	Static subFontColour := ""
	Static subFontQuality := 0
	Static subFontItalic := ""
	Static subFontStrike := ""
	Static subFontUnderline := ""
	Static subMarquee := 0


	class BoundFuncCallback
	{
	; https://www.autohotkey.com/boards/viewtopic.php?f=76&t=88704&p=390706
		__New(BoundFuncObj, paramCount, options := "")
		{
		This.pInfo := Object( {BoundObj: BoundFuncObj, paramCount: paramCount} )
		This.addr := RegisterCallback(This.__Class . "._Callback", options, paramCount, This.pInfo)
		}
		__Delete()
		{
		ObjRelease(This.pInfo)
		DllCall("GlobalFree", "Ptr", This.addr, "Ptr")
		}
		_Callback(Params*)
		{
		Info := Object(A_EventInfo), Args := []
		Loop % Info.paramCount
		Args.Push( NumGet(Params + A_PtrSize*(A_Index - 2)) )
		Return Info.BoundObj.Call(Args*)
		}
	}

	SplashImg(argList*)
	{

		For Key, Value in argList
		{
		; arguments not in the current argList are set to zero.
		; An alternative: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=9656
			Switch Key
			{
			Case "release":
			{
				if (Value)
				{
				This.Destroy()
				return
				}
			}
			Case "imagePath":
			This.imagePath := This.ValidateText(Value)
			Case "imageUrl":
			This.imageUrl := This.ValidateText(Value)

			Case "bkgdColour":
			This.bkgdColour := This.ValidateColour(Value)
			Case "transCol":
			{
				if (This.transCol)
				{
					if (!Value && This.hWndSaved)
					{
					WinSet, TransColor, Off, % "ahk_id" . This.hWndSaved
						if (This.subTextHWnd)
						WinSet, TransColor, Off, % "ahk_id" . This.subTextHWnd
						if (This.mainTextHWnd)
						WinSet, TransColor, Off, % "ahk_id" . This.mainTextHWnd
					}
				}
			This.transCol := Value
			}
			Case "vHide":
			This.vHide := Value

			Case "noHWndActivate":
			{
				if (Value)
				This.noHWndActivate := "NoActivate "
			}
			Case "vMovable":
			This.vMovable := Value
			Case "vBorder":
			This.vBorder := Value
			Case "vOnTop":
			This.vOnTop := Value
			Case "vMgnX":
			{
				if (Value >= 0)
				This.vMgnX := (Value == "D")? Value: Floor(Value)
			}
			Case "vMgnY":
			{
				if (Value >= 0)
				This.vMgnY := (Value == "D")? Value: Floor(Value)
			}
			Case "vImgW":
			{
				if (Value > 1)
				This.vImgW := Floor(Value)
				else
				{
					if (Value > 0)
					This.vImgW := A_ScreenWidth * Value
				}
			}
			Case "vImgH":
			{
				if (Value >= 1)
				This.vImgH := Floor(Value)
				else
				{
					if (Value > 0)
					This.vImgH := A_ScreenHeight * Value
				}
			}



			Case "mainText":
			This.mainText := This.ValidateText(Value)
			Case "mainBkgdColour":
			This.mainBkgdColour := This.ValidateColour(Value, 1)
			Case "mainFontName":
			{
				if (Value)
				This.mainFontName := This.ValidateText(Value)
			}
			Case "mainFontSize":
			{
				if (200 >= Value >= 0) ; arbitrary limit
				This.mainFontSize := Floor(Value)
			}
			Case "mainFontWeight":
			{
				if (1000 >= Value >= 0)
				This.mainFontWeight := Floor(Value)
			}
			Case "mainFontColour":
			This.mainFontColour := This.ValidateColour(Value, 1)
			Case "mainFontQuality":
			{
				if (Value >= 0 && Value <= 5)
				This.mainFontQuality := Floor(Value)
			}
			Case "mainFontItalic":
			{
				This.mainFontItalic := (Value)? " Italic": ""
			}
			Case "mainFontStrike":
			{
				This.mainFontStrike := (Value)? " Strike": ""
			}
			Case "mainFontUnderline":
			{
				This.mainFontUnderline := (Value)? " Underline": ""
			}




			Case "subText":
			This.subText := This.ValidateText(Value)
			Case "subBkgdColour":
			This.subBkgdColour := This.ValidateColour(Value, 1)
			Case "subFontName":
			{
				if (Value)
				This.subFontName := This.ValidateText(Value)
			}
			Case "subFontSize":
			{
				if (200 >= Value >= 0) ; arbitrary limit
				This.subFontSize := Floor(Value)
			}
			Case "subFontWeight":
			{
				if (1000 >= Value >= 0)
				This.subFontWeight := Floor(Value)
			}
			Case "subFontColour":
			This.subFontColour := This.ValidateColour(Value, 1)
			Case "subFontQuality":
			{
				if (Value >= 0 && Value <= 5)
				This.subFontQuality := Floor(Value)
			}
			Case "subFontItalic":
			{
				This.subFontItalic := (Value)? " Italic": ""
			}
			Case "subFontStrike":
			{
				This.subFontStrike := (Value)? " Strike": ""
			}
			Case "subFontUnderline":
			{
				This.subFontUnderline := (Value)? " Underline": ""
			}


			Case "initSplash":
			{
				if (Value)
				This.updateFlag := 0
			}
			
			}
		}

	This.SplashImgInit(This.imagePath, This.imageUrl
	, This.bkgdColour, This.transCol, This.vHide, This.noHWndActivate
	, This.vMovable, This.vBorder, This.vOnTop
	, This.vMgnX, This.vMgnY, This.vImgW, This.vImgH
	, This.mainText, mainBkgdColour
	, This.mainFontName, This.mainFontSize, This.mainFontWeight, This.mainFontColour
	, This.mainFontQuality, This.mainFontItalic, This.mainFontStrike, This.mainFontUnderline
	, This.subText, subBkgdColour
	, This.subFontName, This.subFontSize, This.subFontWeight, This.subFontColour
	, This.subFontQuality, This.subFontItalic, This.subFontStrike, This.subFontUnderline)
	
	}

	SplashImgInit(imagePathIn := "", imageUrlIn := ""
	, bkgdColourIn := -1, transColIn := "", vHideIn := -1, noHWndActivateIn := ""
	, vMovableIn := 0, vBorderIn := "", vOnTopIn := 0
	, vMgnXIn := -1, vMgnYIn := -1, vImgWIn := 0, vImgHIn := 0
	, mainTextIn := "", mainBkgdColourIn := -1
	, mainFontNameIn := "", mainFontSizeIn := 0, mainFontWeightIn := 0, mainFontColourIn := -1
	, mainFontQualityIn := -1, mainFontItalicIn := 0, mainFontStrikeIn := 0, mainFontUnderlineIn := 0
	, subTextIn := "", subBkgdColourIn := -1
	, subFontNameIn := "", subFontSizeIn := 0, subFontWeightIn := 0, subFontColourIn := -1
	, subFontQualityIn := -1, subFontItalicIn := "", subFontStrikeIn := "", subFontUnderlineIn := "")
	/*
	; Future expansion:
	, rightText := "", rightFontNameIn := "", rightFontSizeIn := 0, rightFontWeightIn := 0, rightFontColourIn := -1
	, leftText := "", leftFontNameIn := "", leftFontSizeIn := 0, leftFontWeightIn := 0, leftFontColourIn := -1
	; also consider transparency
	*/
	{
	vWinW := 0, vWinH := 0
	This.userWorkingDir := A_WorkingDir
	SetWorkingDir %A_ScriptDir% ; else use full path for 

	This.procEnd := 0

		if (This.updateFlag > 0)
		This.updateFlag := 0
		else
		{
		;Set defaults

			if (!This.hWndSaved)
			{
			; default of -1 never set, unfortunately
				if (bkgdColourIn == "")
				bkgdColourIn := -1
				if (mainBkgdColourIn == "")
				mainBkgdColourIn := -1
				if (subBkgdColourIn == "")
				subBkgdColourIn := -1
				if (mainFontColourIn == "")
				mainFontColourIn := -1
				if (subFontColourIn == "")
				subFontColourIn := -1
			}


			if (StrLen(imagePathIn))
			This.imagePath := imagePathIn
			else
			{
				if (!This.imagePath)
				This.imagePath := A_AhkPath ; default icon. Ist of 5
			}
			if (StrLen(imageUrlIn))
			This.imageUrl := imageUrlIn
			else
			{
				if (!This.imageUrl)
				This.imageUrl := "https://www.autohotkey.com/assets/images/ahk_wallpaper_reduced.jpg"
			}


			if (bkgdColourIn >= 0)
			This.bkgdColour := This.ValidateColour(bkgdColourIn)
			else
			{
				if (This.bkgdColour == "")
				This.bkgdColour := This.GetDefaultGUIColour()
			}


		This.transCol := transColIn


			if (vHideIn >= 0)
			This.vHide := vHideIn
			else
			This.vHide := 0

			if (noHWndActivateIn)
			This.noHWndActivate := "NoActivate "
			else
			This.noHWndActivate := ""

		This.vMovable := vMovableIn
		This.vBorder := vBorderIn

			if (vMgnXIn == "D")
			{
			SM_CXEDGE := 45
			sysget, spr, %SM_CXEDGE%
			This.vMgnX := spr
			}
			else
			This.vMgnX := Floor(vMgnXIn)

			if (vMgnYIn == "D")
			{
			SM_CYEDGE := 46
			sysget, spr, %SM_CYEDGE%
			This.vMgnY := spr
			}
			else
			This.vMgnY := Floor(vMgnYIn)

			if (vImgWIn)
			This.vImgW := Floor(vImgWIn)
			else
			{
				if (!This.hWndSaved) ; At startup only
				This.vImgW := A_ScreenWidth/5
			}

			if (vImgHIn)
			This.vImgH := Floor(vImgHIn)
			else
			{
				if (!This.hWndSaved) ; At startup only
				This.vImgH := A_ScreenHeight/3
			}







			if (StrLen(mainTextIn))
			This.mainText := This.ValidateText(mainTextIn)

			if (mainBkgdColourIn >= 0)
			This.mainBkgdColour := This.ValidateColour(mainBkgdColourIn, 1)
			else
			{
				if (This.mainBkgdColour == "")
				This.mainBkgdColour := This.GetDefaultGUIColour()
			}

			if (StrLen(mainFontNameIn))
			This.mainFontName := mainFontNameIn
			else
			{
				if (!This.mainFontName)
				This.mainFontName := "Verdana"
			}

			if (mainFontSizeIn)
			This.mainFontSize := mainFontSizeIn
			else
			{
				if (!This.mainFontSize)
				This.mainFontSize := 12
			}

			if (mainFontWeightIn)
			This.mainFontWeight := mainFontWeightIn
			else
			{
				if (!This.mainFontWeight)
				This.mainFontWeight := 600
			}

			if (mainFontColourIn >= 0)
			This.mainFontColour := This.ValidateColour(mainFontColourIn, 1)
			else
			{
				if (This.mainFontColour = "")
				This.mainFontColour := This.GetDefaultGUIColour(1)
			}


			if (mainFontQualityIn >= 0)
			This.mainFontQuality := mainFontQualityIn
			else
			{
				; NONANTIALIASED_QUALITY for better performance
				; https://stackoverflow.com/questions/8283631/graphics-drawstring-vs-textrenderer-drawtextwhich-can-deliver-better-quality/23230570#23230570
				if (!This.mainFontQuality)
				This.mainFontQuality := 1
			}

		This.mainFontItalic := (mainFontItalicIn)? " Italic": ""

		This.mainFontStrike := (mainFontStrikeIn)? " Strike": ""

		This.mainFontUnderline := (mainFontUnderlineIn)? " Underline": ""



			if (StrLen(subTextIn))
			This.subText :=  This.ValidateText(subTextIn)
			if (subBkgdColourIn >= 0)
			This.subBkgdColour := This.ValidateColour(subBkgdColourIn, 1)
			else
			{
				if (This.subBkgdColour == "")
				This.subBkgdColour := This.GetDefaultGUIColour()
			}

			if (StrLen(subFontNameIn))
			This.subFontName := subFontNameIn
			else
			{
				if (!This.subFontName)
				This.subFontName := "Verdana"
			}

			if (subFontSizeIn)
			This.subFontSize := subFontSizeIn
			else
			{
				if (!This.subFontSize)
				This.subFontSize := 10
			}

			if (subFontWeightIn)
			This.subFontWeight := subFontWeightIn
			else
			{
				if (!This.subFontWeight)
				This.subFontWeight := 400
			}

			if (subFontColourIn >= 0)
			This.subFontColour := This.ValidateColour(subFontColourIn, 1)
			else
			{
				if (This.subFontColour == "")
				This.subFontColour := This.GetDefaultGUIColour(1)
			}

			if (subFontQualityIn >= 0)
			This.subFontQuality := subFontQualityIn
			else
			{
				if (!This.subFontQuality)
				This.subFontQuality := 1
			}


		This.subFontItalic := (subFontItalicIn)? " Italic": ""

		This.subFontStrike := (subFontStrikeIn)? " Strike": ""

		This.subFontUnderline := (subFontUnderlineIn)? " Underline": ""

		This.updateFlag := 1 ; in case -1 at start
		}



	This.DisplayToggle()
		if (!(This.vImgW && This.vImgH)) ; actual pic size
		This.GetPicWH()

	DetectHiddenWindows On
		if (!This.hWndSaved)
		{
		This.hGDIPLUS := DllCall("LoadLibrary", "Str", "GdiPlus.dll", "Ptr")
		VarSetCapacity(SI, 24, 0), Numput(1, SI, 0, "Int")
		DllCall("GdiPlus.dll\GdiplusStartup", "UPtr*", spr, "Ptr", &SI, "Ptr", 0)
		This.pToken := spr		
		;WS_DLGFRAME := 0x400000
		Gui, Splashy: New, % "+ToolWindow -Caption " . ((This.vBorder)? ((This.vBorder == "B")? "+Border ": "+0x400000 "): "")
		This.BindWndProc()
		}

	Gui, Splashy: Color, % This.bkgdColour

	This.vImgX := This.vMgnX, This.vImgY := This.vMgnY
	vWinW := This.vImgW + 2 * This.vMgnX
	vWinH := This.vImgH + 2 * This.vMgnY



		if (StrLen(This.mainText))
		{
		Gui, Splashy: Font, % "norm s" . This.mainFontSize . " w" . This.mainFontWeight . " q" . This.mainFontQuality . This.mainFontItalic . This.mainFontStrike . This.mainFontUnderline, % This.mainFontName

		if (This.mainTextHWnd)
			{
			GuiControl, Splashy: Text, % This.mainTextHWnd, % This.mainText
			GuiControl, Splashy: Font, % This.mainTextHWnd
			This.mainTextSize := This.Text_height(This.mainText, This.mainTextHWnd)
			GuiControl, Splashy: Move, % This.mainTextHWnd, % "X" . This.vMgnX . " Y" . This.vMgnY . " W" . This.vImgW . " H" . This.mainTextSize[2]
			This.vImgY += This.mainTextSize[2]
			;ControlSetText, , %mainText%, % "ahk_id" . This.mainTextHWnd
			; This sends more paint messages to parent
			;ControlMove, , % This.vMgnX, % This.vMgnY, This.vImgW , Text_height(mainText, This.mainTextHWnd), % "ahk_id" . This.mainTextHWnd
			}
			else
			{
			Gui, Splashy: Add, Text, % "Center W" . This.vImgW . " Y" . This.vMgnY . " HWND" . "spr", % This.mainText
			This.mainTextHWnd := spr
			; initial pos can be a bit off 
			ControlGetPos, , , spr, , , % "ahk_id" . This.mainTextHWnd
			spr := This.vImgX + This.vImgW/2 - spr/2
			GuiControl, Splashy: Move, % This.mainTextHWnd, x%spr%
			GuiControl, Splashy: Font, % This.mainTextHWnd
			This.mainTextSize := This.Text_height(This.mainText, This.mainTextHWnd)
			This.vImgY += This.mainTextSize[2]
			}

			if (This.transCol)
			This.mainBkgdColour := This.ValidateColour(This.bkgdColour, 1)
		This.SubClassTextCtl(This.mainTextHWnd)

		vWinH += This.vImgY

		}
		else
		{
			if (This.mainTextHWnd)
			GuiControl, Splashy: Hide, % This.mainTextHWnd
		}

		if (StrLen(This.subText))
		{
		Gui, Splashy: Font, % "norm s" . This.subFontSize . " w" . This.subFontWeight . " q" . This.mainFontQuality . This.subFontItalic . This.subFontStrike . This.subFontUnderline, % This.subFontName


		spr := This.vImgH + This.vImgY + This.vMgnY


			if (This.subTextHWnd)
			{
			GuiControl, Splashy: Text, % This.subTextHWnd, % This.subText

			This.subTextSize := This.Text_height(This.subText, This.subTextHWnd)
			vWinH += This.subTextSize[2]
			
			GuiControl, Splashy: Font, % This.subTextHWnd
			GuiControl, Splashy: Move, % This.subTextHWnd, % "X" . This.vMgnX . " Y" . spr . " W" . This.vImgW . " H" . This.subTextSize[2]
			
			}
			else
			{
			Gui, Splashy: Add, Text, % "xp Center W" . This.vImgW . " Y" . spr . " HWND" . "spr1", % This.subText
			This.subTextHWnd := spr1
			This.subTextSize := This.Text_height(This.subText, This.subTextHWnd)
			ControlGetPos, , , spr1, , , % "ahk_id" . This.subTextHWnd
			spr1 := This.vImgX + This.vImgW/2 - spr1/2
			GuiControl, Splashy: Move, % This.subTextHWnd, % "X" . spr1 . " H" . This.subTextSize[2]
			GuiControl, Splashy: Font, % This.subTextHWnd
			vWinH += This.subTextSize[2]
			}

			if (This.transCol)
			This.subBkgdColour := This.ValidateColour(This.bkgdColour, 1)
		This.SubClassTextCtl(This.subTextHWnd)
		}
		else
		{
			if (This.subTextHWnd)
			GuiControl, Splashy: Hide, % This.subTextHWnd
		}

	Gui, Splashy: Font


		if (This.vOnTop)
		WinSet, AlwaysOnTop, On, % "ahk_id" . This.hWnd()




		if (!This.vHide)
		{
		Gui, Splashy: Show, % "Hide " . Format("W{} H{}", vWinW, vWinH)
		VarSetCapacity(rect, 16, 0)
		DllCall("GetWindowRect", "Ptr", This.hWnd(), "Ptr", &rect)
		;WinGetPos, spr, spr1,,, % "ahk_id" . This.hWnd() ; fail

		; Supposed to prevent form visibility without picture while loading. Want another approach?
		Gui, Splashy: Show, % Format("X{} Y{}", -30000, -30000)
		sleep 20

		spr := NumGet(rect, 0, "int")
		spr1 := NumGet(rect, 4, "int")

		;WinMove, % "ahk_id" . This.hWnd(),, %spr%, %spr1% ; fails here whether 30000 or 0, as well as SetWindowPos. SetWindowPlacement?


		Gui, Splashy: Show, % This.noHWndActivate . Format("X{} Y{}", spr, spr1)
			if (This.transCol && !This.vBorder)
			WinSet, TransColor, % This.bkgdColour, % "ahk_id" . This.hWnd()
		This.PaintProc(This.hWndSaved)
		}


	This.procEnd := 1

	SetWorkingDir % This.userWorkingDir ; else use full path for 
	DetectHiddenWindows Off

	}
	;==========================================================================================================
	;==========================================================================================================


	hWnd()
	{
		if (!This.hWndSaved)
		{
		DetectHiddenWindows, On
		Gui, Splashy: +HWNDspr
		This.hWndSaved := spr
		DetectHiddenWindows, Off
		}
	Return This.hWndSaved
	}

	vMovable
	{
		set
		{
		This._vMovable := value
		}
		get
		{
		return This._vMovable
		}
	}

	Destroy()
	{
	SetWorkingDir %A_ScriptDir%
		for key, value in % This.downloadedPathNames
		{
			if (FileExist(value))
			FileDelete, % value
		}
	This.downloadedPathNames.SetCapacity(0)
	This.downloadedUrlNames.SetCapacity(0)
	This.hWndSaved := 0
	This.mainTextHWnd := 0
	This.subTextHWnd := 0
	This.updateFlag := 0
	Gui, Splashy: Destroy
	This.BindWndProc(1)
	This.SubClassTextCtl(0, 1)
	; AHK takes care of Splashy.hBitmap deletion
	;Splashy.Delete("", chr(255))
	;This.SetCapacity(0)
	;This.base := ""
	DllCall("GdiPlus.dll\GdiplusShutdown", "Ptr", This.pToken)
	DllCall("FreeLibrary", "Ptr", This.hGDIPLUS)
	}

	ValidateText(string)
	{
		if (StrLen(string))
		{
			if (StrLen(string) > 20000) ;length?
			string := SubStr(string, 1, 20000)
		}
		else ; "0", or some irregularity in string.
		{
		string =
		}
		return string
	}

	ValidateColour(keyOrVal, toBGR := 0)
	{
	spr := ""

		if (This.HTML.HasKey(keyOrVal))
		spr := This.ToBase(This.HTML[keyOrVal], 16)
		else
		{
			if keyOrVal is xdigit
			{
				if (StrLen(keyOrVal) > 8)
				{
					if keyOrVal is digit ;  assume decimal
					spr := This.ToBase(keyOrVal, 16)
					else
					spr := SubStr(keyOrVal, 1, 8)
				}
				else
				spr := keyOrVal
			}
			else
			{
				loop, % StrLen(keyOrVal)
				{
					if A_Loopfield is xdigit
					{
						if A_Loopfield != "X"
						spr .= A_Loopfield
					}
				}

				if (!spr)
				spr := 0
			}
		}

	spr1 := strLen(spr)
		if (spr1 < 8)
		{
			if (spr1 == 6 && !InStr(spr, "0X")) ; valid RGB
			spr := "0X" . spr
			else
			{
			spr2 := subStr(spr, 3)
			spr := "0X"
			;spr := Format("{:0x}", Number)
				loop, % (8 - spr1)
				{
				spr := spr . 0
				}

			spr .= spr2
			}
		}

		if (toBGR) ; for the GDI functions (ColorRef)
		spr := This.ReverseColour(spr)
		else
		{
			if (InStr(spr, "0X"))
			spr := SubStr(spr, 3) ; "0X" prefix not required for AHK gui functions
		}

	return spr
	}

	ReverseColour(colour)
	{
		colour := ((colour & 0x0000FF) << 16 ) | (colour & 0x00FF00) | ((colour & 0xFF0000) >> 16)
		return This.ToBase(colour, 16)
	}

	ToBase(n, b)
	{

		if (b != 16 && SubStr(n, 1, 2) == "0x")
		{
		n := SubStr(n, 3)
		; In This case the mod function will fail for letters in any case
		}

		Loop
		{
		r := mod(n, b)
		d := floor(n/b)

			if (b == 16)
			r := (r > 9)? chr(0x37 + r) : r

		m := r . m
		n := d
			if (n < 1)
			Break
		}
	Return % (b == 16)? "0X" . m: m
	}

	GetDefaultGUIColour(font := 0)
	{
		static COLOR_WINDOWTEXT := 8, COLOR_3DFACE := 15 ;(more white than grey these days)

		spr := DllCall("User32.dll\GetSysColor", "Int", (font)? 8: 15, "UInt")
		;BGR +> RGB
		spr := This.ReverseColour(spr)

		return spr
	}
	DownloadFile(URL, fName)
	{
			try
			{
				UrlDownloadToFile, %URL%, %fName%
			}
			catch spr
			{
			msgbox, 8208, FileDownload, Error with the bitmap download!`nSpecifically: %spr%
			}		
		FileGetSize, spr , % A_ScriptDir . "`\" . fName
			if spr < 50 ; some very small image
			{
			msgbox, 8208, FileDownload, File size is incorrect!
			return 0
			}
			sleep 50
			return 1


			return fName

	}

	BindWndProc(release := 0)
	{
	Static WndProcNew := 0
	static SetWindowLong := A_PtrSize == 8 ? "SetWindowLongPtr" : "SetWindowLong"
		if (release)
		{
		;This.clbk.__Delete()
		This.clbk := ""
		WndProcNew := 0
		}
		else
		{
			if (!WndProcNew) ; called once only from the caller- this is extra security
			{
			This.clbk := new This.BoundFuncCallback( ObjBindMethod(This, "WndProc"), 4 )
			WndProcNew := This.clbk.addr
				if (WndProcNew)
				{
					if (!(This.WndProcOld := DllCall(SetWindowLong, "Ptr", This.hWnd(), "Int", GWL_WNDPROC := -4, "Ptr", WndProcNew, "Ptr")))
					msgbox, 8208, WndProc, Bad return!		
				}
				else
				msgbox, 8208, WndProc, No address!
			}
		}
	}

	WndProc(hwnd, uMsg, wParam, lParam)
	{
	Critical 
		Switch uMsg
		{
			case % This.WM_CTLCOLORSTATIC:
			{
			return This.CtlColorStaticProc(wParam, lParam)
			}
			case % This.WM_PAINT:
			{
			This.PaintProc()
			return 0
			}
			case % This.WM_NCHITTEST:
			{
			return This.NcHitTestProc(hWnd, uMsg, wParam, lParam)
			}
			Default:
			return DllCall("CallWindowProc", "Ptr", This.WndProcOld, "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)		
		}
		
	}

	NcHitTestProc(hWnd, uMsg, wParam, lParam)
	{
		Static HTCLIENT := 1, HTCAPTION := 2
		; Makes form movable

		if (This.vMovable)
		{

		lResult := DllCall("DefWindowProc", "Ptr", hWnd, "UInt", uMsg, "UPtr", wParam, "Ptr", lParam)

			if (lResult == HTCLIENT)
			lResult := HTCAPTION
		return % lResult
		}
		else
		return % HTCLIENT
	}

	CtlColorStaticProc(wParam, lParam)
	{
	static DC_BRUSH := 0x12

		if (lparam == This.subTextHWnd) ; && This.hDCWin == wParam)
		This.SetColour(wParam, This.subBkgdColour, This.subFontColour)
		else
		{
			if (lParam == This.mainTextHWnd)
			This.SetColour(wParam, This.mainBkgdColour, This.mainFontColour)
		}
	return DllCall("Gdi32.dll\GetStockObject", "UInt", DC_BRUSH, "UPtr")
	}

	SetColour(textDC, bkgdColour, fontColour)
	{
		static NULL_BRUSH := 0x5, TRANSPARENT := 0X1, OPAQUE := 0X2, CLR_INVALID := 0xFFFFFFFF
		DllCall("Gdi32.dll\SetBkMode", "Ptr", textDC, "UInt", (This.transCol)? TRANSPARENT: OPAQUE)
		if (DllCall("Gdi32.dll\SetBkColor", "Ptr", textDC, "UInt", bkgdColour) == CLR_INVALID)
		msgbox, 8208, SetBkColor, Cannot set background colour for text!
		if (DllCall("Gdi32.dll\SetTextColor", "Ptr", textDC, "UInt", fontColour) == CLR_INVALID)
		msgbox, 8208, SetTextColor, Cannot set colour for text!

		DllCall("SetDCBrushColor", "Ptr", textDC, "UInt", bkgdColour)
	}


	PaintProc(hWnd := 0)
	{
	spr1 := 0	
		if (VarSetCapacity(PAINTSTRUCT, 60 + A_PtrSize, 0))
		{
				if (!hWnd)
				{
				hWnd := This.hWnd()
					if (!This.procEnd)
					spr1 := 1
				}
			; DC validated
				if (DllCall("User32.dll\BeginPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr"))
				{
					if (!spr1)
					{
					static vDoDrawImg := 1 ;set This to 0 and the image won't be redrawn
					static vDoDrawBgd := 1 ;set This to 0 and the background won't be redrawn
					;return ;uncomment This line and the window will be blank

						if (vDoDrawImg)
						This.PaintDC()
						else
						Sleep, -1

						if (vDoDrawBgd)
						This.DrawBackground()
					}
				}
			DllCall("User32.dll\EndPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr")
		}
		else
		msgbox, 8208, PAINSTRUCT, Cannot paint!

	}

	SubClassTextCtl(ctlHWnd, release := 0)
	{
	Static SubProcFunc := 0
		if (release)
		{
		;This.subClbk.__Delete()
		This.subClbk := ""
		SubProcFunc := 0
		}
		else
		{
			if (!ctlHWnd)
			return
			if (!SubProcFunc)
			{
			This.subClbk := new This.BoundFuncCallback( ObjBindMethod(This, "SubClassTextProc"), 6 )
			SubProcFunc := This.subClbk.addr
			}

			if !DllCall("Comctl32.dll\SetWindowSubclass", "Ptr", ctlHWnd, "Ptr", SubProcFunc, "Ptr", ctlHWnd, "Ptr", 0)
			msgbox, 8208, Text Control, SubClassing failed!

		}
	}
	SubClassTextProc(hWnd, uMsg, wParam, lParam, IdSubclass, RefData)
	{
	;THis subclass for marquee code
	; WM_PAINT is required to paint the scrolled text.
	; BeginPaint in WM_PAINT will erase the content already set in the DC of the control.
	;
	;To prevent, temporarily modify AHK's own hbrBackground in its WNDCLASSEX
	; hbrBackground := DllCall(GetStockObject(NULL_BRUSH))
	;
	;Which means we have to create our own class and window for the control anyway,
	; Then use Pens & Brushes & DrawTextEx et al.

	/*
	static DC_BRUSH := 0x12
	Critical


		if (uMsg == This.WM_ERASEBKGND)
		{
		return 1
		}
		if (uMsg == This.WM_PAINT)
		{
		VarSetCapacity(PAINTSTRUCT, 60 + A_PtrSize, 0)
		hDC := DllCall("User32.dll\BeginPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr")

			spr := This.ToBase(hWnd, 16)
			spr1 := InStr(spr, This.mainTextHWnd)
			spr2 := InStr(spr, This.subTextHWnd)


			if (spr1 || spr2)
			{

			if (This.mainMarquee && spr1)
			{
			}
			else
				{
					if (This.mainMarquee && spr1)
					{
					}
					else
					{
						if (spr1)
						This.SetColour(This.mainBkgdColour, hDC)
						else
						This.SetColour(This.subBkgdColour, hDC)
					}
				}
			}
		DllCall("User32.dll\EndPaint", "Ptr", hWnd, "Ptr", &PAINTSTRUCT, "UPtr")
		Return 0
		}

;Marquee code in an outside function
            RECT rectControls = {wd + xCurrentScroll, yCurrentScroll, xNewSize + xCurrentScroll, yNewSize + yCurrentScroll};
            if (!ScrollDC(hdcWinCl, -xDelta, 0, (CONST RECT*) &rectControls, (CONST RECT*) &rectControls, (HRGN)NULL, (RECT*) &rectControls))
                ReportErr(L"HORZ_SCROLL: ScrollD Failed!");

*/

	Return DllCall("Comctl32.dll\DefSubclassProc", "Ptr", hWnd, "UInt", uMsg, "Ptr", wParam, "Ptr", lParam)
	}


	DisplayToggle()
	{
	static vToggle := 1, oldImageUrl := ""
	This.ImageName := ""
	vToggle := !vToggle

		if (!(This.vImgW && This.vImgH))
		spr1 := ""
		else
		spr1 := Format("W{} H{}", This.vImgW, This.vImgH)
	; This function uses LoadPicture to populate hBitmap and hIcon
	; and sets the image type for the painting routines accordingly

		if (This.imagePath)
		{
		SplitPath % This.imagePath,,, spr

			if (StrLen(spr))
			{
			This.vImgType := ((spr == "cur")? 2: (spr == "exe" || spr == "ico")? 1: 0)

				if (fileExist(This.imagePath))
				{
				spr := This.imagePath

					if (This.vImgType)
					{
						if (This.imagePath == A_AhkPath)
						{
						This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2": "") . spr1, spr)
						return
						}
						else
						{
							if (This.hIcon := LoadPicture(spr, spr1, spr)) ; must use 3rd parm or bitmap handle returned!
							return
						}
					}
					else
					{
						if (This.hBitmap := LoadPicture(spr, spr1))
						return
					}
				}

			SplitPath % This.imagePath, spr
			This.ImageName := spr
			}

			; Fail, so download

			if (This.imageUrl && RegExMatch(This.imageUrl, "^(https?://|www\.)[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(/\S*)?$"))
			{
				if (!(This.ImageName))
				{
				SplitPath % This.imageUrl, spr
				This.ImageName := spr
				}
				;  check if file D/L'd previously
				for key, value in % This.downloadedUrlNames
				{
					if (This.imageUrl == value)
					{
						if (fileExist(key))
						{
							Try
							{
								if (key != This.ImageName)
								FileCopy, %key%, % This.ImageName
							Break
							}
							Catch e
							{
							msgbox, 8208, FileCopy, % key . " could not be copied with error: " . e
							}
						}
					}
				}


				if (!fileExist(This.ImageName))
				{
					if (!(This.DownloadFile(This.imageUrl, This.ImageName)))
					return
				}

				if (This.hBitmap := LoadPicture(This.ImageName, spr1))
				{
				oldImageUrl := This.imageUrl
				This.vImgType := 0
				spr := This.ImageName

				This.downloadedPathNames.Push(spr) 
				This.downloadedUrlNames(spr) := oldImageUrl
				return
				}
				else
				msgbox, 8208, LoadPicture, Format not recognized!

			}
			else
			spr := 1		
		}

		; "Neverfail" default 
		This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2 ": "") . spr1, spr)
		This.vImgType := 1

		
	}

	GetPicWH()
	{
	Static ICONINFO := []
	/*
	typedef struct tagBITMAP {
	  LONG   bmType;
	  LONG   bmWidth;
	  LONG   bmHeight;
	  LONG   bmWidthBytes;
	  WORD   bmPlanes; // Short
	  WORD   bmBitsPixel; // Short
	  LPVOID bmBits; // FAR ptr to void
	} BITMAP, *PBITMAP, *NPBITMAP, *LPBITMAP;
	*/



	Switch This.vImgType
		{
			case 0:
			{
			;VarSetCapacity(bm, (A_PtrSize == 8)? 32 : 24, 0)
	;		if (!(spr := DllCall("GetCurrentObject", "Ptr", This.hDCWin, "uint", OBJ_BITMAP, "Ptr")))
	;		msgbox, 8208, GetCurrentObject hDCWin, Object could not be retrieved!
			;if (This.hBitmap != spr)
	;		msgbox, 8208, hBitmap, hBitmap is not current!


			VarSetCapacity(bm, ((A_PtrSize == 8)? 24: 20), 0)
			if (!(DllCall("GetObject", "Ptr", This.hBitmap, "uInt", ((A_PtrSize == 8)? 24 : 20), "Ptr", &bm)))
			msgbox, 8208, GetObject hBitmap, Object could not be retrieved!

			This.vImgW := NumGet(bm, 4, "Int")
			This.vImgH := NumGet(bm, 8, "Int")

			}
			case 1, 2:
			{
			; https://www.autohotkey.com/boards/viewtopic.php?t=36733
			; easier way to get icon dimensions is use default SM_CXICON, SM_CYICON
			VarSetCapacity(spr1, (A_PtrSize == 8)? 104: 84, 0) ; ICONINFO Structure
				If (DllCall("GetIconInfo", "Ptr", This.hIcon, "Ptr", &spr1))
				{
					ICONINFO.hbmColor := NumGet(spr1, (A_PtrSize == 8)? 24: 16, "UPtr")
					ICONINFO.hbmMask := NumGet(spr1, (A_PtrSize == 8)? 16: 12, "UPtr")

					if (ICONINFO.hbmColor)
					{
					DllCall("GetObject", "Ptr", ICONINFO.hbmColor, "Int", (A_PtrSize == 8)? 104: 84, "Ptr",&spr1)
					This.vImgW := NumGet(spr1, 4, "UInt")
					This.vImgH := NumGet(spr1, 8, "UInt")
					This.deleteObject(ICONINFO.hbmColor)
					}
					else
					{
						if (ICONINFO.hbmMask) ; Colour plane absent
						{
						DllCall("GetObject", "Ptr", ICONINFO.hbmMask, "Int", (A_PtrSize == 8)? 104: 84, "Ptr", &spr1)
						This.vImgW := NumGet(spr1, 4, "UInt")
						This.vImgH := NumGet(spr1, 8, "UInt")
						This.deleteObject(ICONINFO.hbmMask)
						}

					}
				}
				else
				; The fastest way to convert a hBITMAP to hICON is to add it to a hIML and retrieve it back as a hICON with COMCTL32\ImageList_GetIcon()
				msgbox, 8208, GetIconInfo, Icon info could not be retrieved!
			VarSetCapacity(spr1, 0)  

			}
		}


	}


	PaintDC()
	{
	;===============
	static IMAGE_BITMAP := 0, SRCCOPY = 0x00CC0020
	static hBitmapOld := 0
	;draw bitmap/icon onto GUI & call GetDC every paint

	This.hDCWin := DllCall("user32\GetDC", "Ptr", This.hWndSaved, "Ptr")
		Switch This.vImgType
		{
			case 0:
			{
				if (!(hDCCompat := DllCall("gdi32\CreateCompatibleDC", "Ptr", This.hDCWin, "Ptr")))
				msgbox, 8208, Compat DC, DC could not be created!
				if (hBitmapOld := This.selectObject(hDCCompat, This.hBitmap))
				{
					if (!DllCall("gdi32\BitBlt", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Int", This.vImgW, "Int", This.vImgH, "Ptr", hDCCompat, "Int", 0, "Int", 0, "UInt", SRCCOPY))
					msgbox, 8208, PaintDC, BitBlt Failed!
				This.selectObject(hDCCompat, hBitmapOld)

				}
				if (!(DllCall("gdi32\DeleteDC", "Ptr", hDCCompat)))
				msgbox, 8208, Compat DC, DC could not be deleted!

			}
			case 1, 2: ;IMAGE_ICON := 1, IMAGE_CURSOR := 1
			{
			DllCall("user32\DrawIconEx", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Ptr", This.hIcon, "Int", This.vImgW, "Int", This.vImgH, "UInt",0, "Ptr",0, "UInt",0x3) ;DI_NORMAL := 0x3
				/*
				; DllCall("gdi32\DestroyIcon", "Ptr", This.hIcon) fails for AHK executable
				; AHK LoadImage does not use LR_SHARED
				; Consider above only if creating or copying an icon- whereas the following is ignored
				if (!(DllCall("gdi32\DeleteObject", "Ptr", This.hIcon)))
				msgbox, 8208, Icon Handle, Handle could not be deleted!
				*/
			}
		}
		This.releaseDC(This.hWndSaved, This.hDCWin)
	}

	DrawBackground()
	{
		; for custom see  https://docs.microsoft.com/en-us/windows/win32/gdi/drawing-a-custom-window-background
		DllCall("gdi32\ExcludeClipRect", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Int", This.vImgX+This.vImgW, "Int", This.vImgY+This.vImgH)

		;SelectClipRgn not required
		; one pixel region
		hRgn := DllCall("gdi32\CreateRectRgn", "Int", 0, "Int", 0, "Int", 1, "Int", 1, "Ptr")
		; Updates hRgn to define the clipping region in This.hDCWin: turns out to be everything except the margins.
		DllCall("gdi32\GetClipRgn", "Ptr", This.hDCWin, "Ptr", hRgn)
		hBrush := DllCall("user32\GetSysColorBrush", "Int", 15, "Ptr") ;COLOR_BTNFACE := 15
		DllCall("gdi32\FillRgn", "Ptr", This.hDCWin, "Ptr", hRgn, "Ptr", hBrush)
		This.deleteObject(hRgn)
	}	

	Text_height(Text, hWnd)
	{
	FontSize := 0, hDCScreen := 0, outSize := [0, 0]
	;https://www.autohotkey.com/boards/viewtopic.php?f=76&t=9130&p=50713#p50713

	StrReplace(Text, "`r`n", "`r`n", spr1)
	StrReplace(Text, "`n", "`n", spr2)
	spr1 += spr2 + 1

	spr2 := "" ; get longest of multiline
		loop, Parse, Text, `n, `r
		{
		if (StrLen(A_Loopfield)) > StrLen(spr2)
		spr2 := A_Loopfield
		}

	HFONT := DllCall("User32.dll\SendMessage", "Ptr", hWnd, "Int", 0x31, "Ptr", 0, "Ptr", 0) ; WM_GETFONT := 0x31
	hDCScreen := DllCall("user32\GetDC", "Ptr", 0, "Ptr")
		if (HFONT_OLD := This.selectObject(hDCScreen, HFONT))
		{

		VarSetCapacity(FontSize, 8)
		DllCall("GetTextExtentPoint32", "UPtr", hDCScreen, "Str", spr2, "Int", StrLen(spr2), "UPtr", &FontSize)
		outSize[1] := NumGet(FontSize, 0, "UInt")
		DllCall("GetTextExtentPoint32", "UPtr", hDCScreen, "Str", Text, "Int", StrLen(Text), "UPtr", &FontSize)
		outSize[2] := NumGet(FontSize, 4, "UInt") * spr1

		; clean up

		This.selectObject(hDCScreen, HFONT_OLD)
		; If not created, DeleteObject NOT required for This HFONT

		This.releaseDC(0, hDCScreen)
		return outSize
		}
		else
		{
		This.releaseDC(0, hDCScreen)
		return 0
		}
	}


	selectObject(hDC, hgdiobj)
	{
	static HGDI_ERROR := 0xFFFFFFFF

	hRet := DllCall("Gdi32.dll\SelectObject", "Ptr", hDC, "Ptr", hgdiobj, "Ptr")

		if (!hRet || hRet == HGDI_ERROR)
		{
		msgbox, 8208, GDI Object, % "Selection failed `nError code is: " . ((hRet == HGDI_ERROR)? "HGDI_ERROR: ": "Unknown: ") . "The errorLevel is " ErrorLevel ": " . A_LastError
		return 0
		}
		else
		return hRet
	}
	deleteObject(hDC, hgdiobj)
	{
		if !DllCall("Gdi32.dll\DeleteObject", "Ptr", hObject)
		msgbox, 8208, GDI Object, % "Deletion failed `nError code is: " . "ErrorLevel " ErrorLevel ": " . A_LastError
	}
		releaseDC(hWnd, hDC)
	{
		if !DllCall("ReleaseDC", "UPtr", hWnd, "UPtr", hDC)
		msgbox, 8208, Device Context, % "Release failed `nError code is: " . "ErrorLevel " ErrorLevel ": " . A_LastError
	}
}
;=====================================================================================











;=====================================================================================
; Autoexec here:
SplashRef := Splashy.SplashImg ; function reference


%SplashRef%(Splashy, {imagePath: "C:\Windows\Cursors\busy_l.cur", bkgdColour: "Blue", vMovable: "", vBorder: "", vOnTop: ""
, vMgnY: 2, mainText: "ByeByeByeByeByeByeByeByeByeByeByeByeByeByeBye`nBye`nHello", mainFontSize: 24, subText: "HiHi", subFontItalic: 1, subFontStrike: 1}*)
msgbox ok

%SplashRef%(Splashy, {release: 1}*)
msgbox released
;%SplashRef%(Splashy, {initSplash: 1, imagePath: "", bkgdColour: "FFFF00", mainFontUnderline: 1, transCol: "", vMovable: "movable", vBorder: "", vOnTop: ""
;, vMgnX: "D", mainText: "Yippee`n`nGreat", noHWndActivate: 1, subFontColour: "yellow", subFontSize: 24, subText: "Hi`nHi", subBkgdColour: "blue", subFontItalic: 1, subFontStrike: 1}*)

%SplashRef%(Splashy, {initSplash: 1, imagePath: "1", bkgdColour: "green", mainFontUnderline: 1, transCol: "", vMovable: "movable", vBorder: "", vOnTop: ""
, vMgnX: 6, mainText: "Yippee`n`nGreat", noHWndActivate: 1, subFontSize: 24, subText: "Hi`nHi", subBkgdColour: "blue", subFontItalic: 1, subFontStrike: 1}*)
return
%SplashRef%(Splashy, {bkgdColour: "green", mainFontUnderline: 1, transCol: "", vMovable: "movable", vBorder: "", vOnTop: ""
, vMgnX: 6, mainText: "Yippee`n`nGreat", noHWndActivate: 1, subFontSize: 24, subText: "Hi`nHi", subBkgdColour: "blue", subFontItalic: 1, subFontStrike: 1}*)

Return



q::
	if (Splashy.vHide)
	DetectHiddenWindows, On
	else
	{
		if InStr(A_ThisHotkey, "q")
		{
		WinGet, spr, ID, A
		WinGetClass, vWinClass, % "ahk_id " spr
			if (vWinClass != "AutoHotkeyGUI")
			return
		}
	}

Process, Priority,, High
Thread, Priority, 2000000000

/*
%SplashRef%(Splashy, {initSplash: value, release: boolValue, imagePath: pathString, imageUrl: urlString

, bkgdColour: colourStringorVal, transCol: boolValue, vHide: boolValue, noHWndActivate: boolValue

, vMovable: boolValue, vBorder: borderString, vOnTop: boolValue

, vMgnX: value, vMgnY: value, vImgW: value, vImgH: value

, mainText: string, mainBkgdColour: colourStringorVal

, mainFontName: string, mainFontSize: value, mainFontWeight: value, mainFontColour: colourStringorVal

, mainFontQuality: value, mainFontItalic: boolValue, mainFontStrike: boolValue, mainFontUnderline: boolValue

, subText: string, subBkgdColour: colourStringorVal

, subFontName: string, subFontSize: value, subFontWeight: value, subFontColour: colourStringorVal

, subFontQuality: value, subFontItalic: boolValue, subFontStrike: boolValue, subFontUnderline: boolValue})

*/

;%spr%(Splashy, {imagePath: "C:\Windows\Cursors\busy_l.cur", bkgdColour: "Blue", vMovable: "", vBorder: "", vOnTop: ""
;, vMgnY: 2, mainText: "ByeByeByeByeByeByeByeByeByeByeByeByeByeByeBye`nBye`nHello", mainFontSize: 24, subText: "HiHi", subFontItalic: 1, subFontStrike: 1}*)


%SplashRef%(Splashy, {bkgdColour: "Blue", transCol: "1", vMovable: "1", vBorder: "", vOnTop: "onTop"
, vMgnY: 6, mainText: "", subText: "AHK RULES!", subFontColour: "Green", subFontSize: 24, subFontStrike: 0, subFontQuality: 5, subFontUnderline: 1}*)


;Critical, Off
Process, Priority,, Normal

	if (Splashy.vHide)
	DetectHiddenWindows, Off

return

w::
	if (Splashy.vHide)
	DetectHiddenWindows, On
	if InStr(A_ThisHotkey, "w")
	{
	WinGet, spr, ID, A
	WinGetClass, vWinClass, % "ahk_id " spr
		if (vWinClass != "AutoHotkeyGUI")
		return
	}
;test code to redraw the image
Splashy.PaintProc()
	if (Splashy.vHide)
	DetectHiddenWindows, Off

;DllCall("InvalidateRect", "Ptr", Splashy.hWnd(), "Ptr", 0, "Uint", 1, "Int")
return


Esc::
Splashy.Destroy()
ExitApp