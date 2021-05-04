
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
	Static vPosX := 0
	Static vPosY := 0
	Static vMgnX := 0
	Static vMgnY := 0
	Static vImgX := 0
	Static vImgY := 0
	Static vImgW := 0
	Static vImgH := 0
	Static oldVImgW := 0
	Static oldVImgH := 0
	Static actualVImgW := 0
	Static actualVImgH := 0

	Static ImageName := ""
	Static oldImagePath := ""
	Static imageUrl := ""
	Static oldImageUrl := ""
	Static bkgdColour := ""
	Static transCol := 0
	Static noHWndActivate := ""
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
	imagePathOut := ""
	imageUrlOut := ""
	bkgdColourOut := -1
	transColOut := ""
	vHideOut := 0
	noHWndActivateOut := ""
	vMovableOut := 0
	vBorderOut := ""
	vOnTopOut := 0
	vPosXOut := "D"
	vPosYOut := "D"
	vMgnXOut := -1
	vMgnYOut := -1
	vImgWOut := 0
	vImgHOut := 0
	mainTextOut := ""
	mainBkgdColourOut := -1
	mainFontNameOut := ""
	mainFontSizeOut := 0
	mainFontWeightOut := 0
	mainFontColourOut := -1
	mainFontQualityOut := -1
	mainFontItalicOut := 0
	mainFontStrikeOut := 0
	mainFontUnderlineOut := 0
	subTextOut := ""
	subBkgdColourOut := -1
	subFontNameOut := ""
	subFontSizeOut := 0
	subFontWeightOut := 0
	subFontColourOut := -1
	subFontQualityOut := -1
	subFontItalicOut := 0
	subFontStrikeOut := 0
	subFontUnderlineOut := 0

		if (This.hWndSaved)
		{
			if (argList.HasKey("release"))
			{
				For Key, Value in argList
				{
					if (Key == "release")
					{
						if (Value)
						{
						This.Destroy()
						return
						}
					}
				}
			}
			else
			{
				if (argList.HasKey("initSplash"))
				{
					For Key, Value in argList
					{
						if (Key == "initSplash")
						{
							if (Value)
							This.updateFlag := 0
							else
							This.updateFlag := 1
						}
					}
				}
				else
				This.updateFlag := 1
			}
		}

		For Key, Value in argList
		{

		; An alternative: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=9656
			if (Key)
			{
				Switch Key
				{
				Case "imagePath":
				{
					if (This.updateFlag)
					This.imagePath := This.ValidateText(Value)
					else
					imagePathOut := Value
				}
				Case "imageUrl":
				{
					if (This.updateFlag)
					This.imageUrl := This.ValidateText(Value)
					else
					imageUrlOut := Value
				}
				Case "bkgdColour":
				{
					if (Value != -1)
					{
						if (This.updateFlag)
						This.bkgdColour := This.ValidateColour(Value)
						else
						bkgdColourOut := Value
					}
				}
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

					if (This.updateFlag)
					This.transCol := Value
					else
					transColOut := Value
				}
				Case "vHide":
				{
					if (This.updateFlag)
					This.vHide := Value
					else
					vHideOut := Value
				}
				Case "noHWndActivate":
				{
					if (This.updateFlag)
					This.noHWndActivate := (Value)? "NoActivate ": ""
					else
					noHWndActivateOut := Value
				}
				Case "vMovable":
				{
					if (This.updateFlag)
					This.vMovable := Value
					else
					vMovableOut := Value
				}
				Case "vBorder":
				{
					if (This.updateFlag)
					This.vBorder := Value
					else
					vBorderOut := Value
				}
				Case "vOnTop":
				{
					if (This.updateFlag)
					This.vOnTop := Value
					else
					vOnTopOut := Value
				}
				Case "vPosX":
				{
					if (This.updateFlag)
					This.vPosX := (Value == "D")? Value: Floor(Value)
					else
					vPosXOut := (Value == "D")? Value: Floor(Value)
				}

				Case "vPosY":
				{
					if (This.updateFlag)
					This.vPosY := (Value == "D")? Value: Floor(Value)
					else
					vPosYOut := Value
				}

				Case "vMgnX":
				{
					if (Value >= 0)
					{
						if (This.updateFlag)
						This.vMgnX := (Value == "D")? Value: Floor(Value)
						else
						vMgnXOut := Value
					}
				}
				Case "vMgnY":
				{
					if (Value >= 0)
					{
						if (This.updateFlag)
						This.vMgnY := (Value == "D")? Value: Floor(Value)
						else
						vMgnYOut := Value
					}
				}
				Case "vImgW":
				{
					if Value is number
					{
						if (Value > 1)
						{
						This.oldVImgW := This.vImgW
							if (This.updateFlag)
							This.vImgW := Floor(Value)
							else
							vImgWOut := Value
						}
						else
						{
							if (Value > 0)
							{
							This.oldVImgW := This.vImgW
								if (This.updateFlag)
								This.vImgW := A_ScreenWidth * Value
								else
								vImgWOut := A_ScreenWidth * Value
							}
							else
							This.vImgW := 0
						}
					}
					else
					This.vImgW := 0
				}

				Case "vImgH":
				{
					if Value is number
					{
						if (Value > 1)
						{
						This.oldVImgH := This.vImgH
							if (This.updateFlag)
							This.vImgH := Floor(Value)
							else
							vImgHOut := Value
						}
						else
						{
							if (Value > 0)
							{
							This.oldVImgH := This.vImgH
								if (This.updateFlag)
								This.vImgH := A_ScreenWidth * Value
								else
								vImgHOut := A_ScreenWidth * Value
							}
							else
							This.vImgH := 0
						}
					}
					else
					This.vImgH := 0
				}



				Case "mainText":
				{
					if (This.updateFlag)
					This.mainText := This.ValidateText(Value)
					else
					mainTextOut := Value
				}
				Case "mainBkgdColour":
				{
					if (Value != -1)
					{
						if (This.updateFlag)
						This.mainBkgdColour := This.ValidateColour(Value, 1)
						else
						mainBkgdColourOut := Value
					}
				}
				Case "mainFontName":
				{
					if (Value)
					{
						if (This.updateFlag)
						This.mainFontName := This.ValidateText(Value)
						else
						mainFontNameOut := Value
					}
				}
				Case "mainFontSize":
				{
					if (200 >= Value >= 0) ; arbitrary limit
					{
						if (This.updateFlag)
						This.mainFontSize := Floor(Value)
						else
						mainFontSizeOut := Value
					}
				}
				Case "mainFontWeight":
				{
					if (1000 >= Value >= 0)
					{
						if (This.updateFlag)
						This.mainFontWeight := Floor(Value)
						else
						mainFontWeightOut := Value
					}
				}
				Case "mainFontColour":
				{
					if (Value != -1)
					{
						if (This.updateFlag)
						This.mainFontColour := This.ValidateColour(Value, 1)
						else
						mainFontColourOut := Value
					}
				}
				Case "mainFontQuality":
				{
					if (Value >= 0 && Value <= 5) ; 0 :=  DEFAULT_QUALITY
					{
						if (This.updateFlag)
						This.mainFontQuality := Floor(Value)
						else
						mainFontQualityOut := Value
					}
				}
				Case "mainFontItalic":
				{
					if (This.updateFlag)
					This.mainFontItalic := (Value)? " Italic": ""
					else
					mainFontItalicOut := Value
				}
				Case "mainFontStrike":
				{
					if (This.updateFlag)
					This.mainFontStrike := (Value)? " Strike": ""
					else
					mainFontStrikeOut := Value
				}
				Case "mainFontUnderline":
				{
					if (This.updateFlag)
					This.mainFontUnderline := (Value)? " Underline": ""
					else
					mainFontUnderlineOut := Value
				}




				Case "subText":
				{
					if (This.updateFlag)
					This.subText := This.ValidateText(Value)
					else
					subTextOut := Value
				}
				Case "subBkgdColour":
				{
					if (Value != -1)
					{
						if (This.updateFlag)
						This.subBkgdColour := This.ValidateColour(Value, 1)
						else
						subBkgdColourOut := Value
					}
				}

				Case "subFontName":
				{
					if (Value)
					{
						if (This.updateFlag)
						This.subFontName := This.ValidateText(Value)
						else
						subFontNameOut := Value
					}
				}
				Case "subFontSize":
				{
					if (200 >= Value >= 0) ; arbitrary limit
					{
						if (This.updateFlag)
						This.subFontSize := Floor(Value)
						else
						subFontSizeOut := Value
					}
				}
				Case "subFontWeight":
				{
					if (1000 >= Value >= 0)
					{
						if (This.updateFlag)
						This.subFontWeight := Floor(Value)
						else
						subFontWeightOut := Value
					}
				}
				Case "subFontColour":
				{
					if (Value != -1)
					{
						if (This.updateFlag)
						This.subFontColour := This.ValidateColour(Value, 1)
						else
						subFontColourOut := Value
					}
				}
				Case "subFontQuality":
				{
					if (Value >= 0 && Value <= 5)
					{
						if (This.updateFlag)
						This.subFontQuality := Floor(Value)
						else
						subFontQualityOut := Value
					}
				}
				Case "subFontItalic":
				{
					if (This.updateFlag)
					This.subFontItalic := (Value)? " Italic": ""
					else
					subFontItalicOut := Value
				}
				Case "subFontStrike":
				{
					if (This.updateFlag)
					This.subFontStrike := (Value)? " Strike": ""
					else
					subFontStrikeOut := Value
				}
				Case "subFontUnderline":
				{
					if (This.updateFlag)
					This.subFontUnderline := (Value)? " Underline": ""
					else
					subFontUnderlineOut := Value
				}


				}
				
			}
		}

	This.SplashImgInit(imagePathOut, imageUrlOut
	, bkgdColourOut, transColOut, vHideOut, noHWndActivateOut
	, vMovableOut, vBorderOut, vOnTopOut
	, vPosXOut, vPosYOut, vMgnXOut, vMgnYOut, vImgWOut, vImgHOut
	, mainTextOut, mainBkgdColourOut
	, mainFontNameOut, mainFontSizeOut, mainFontWeightOut, mainFontColourOut
	, mainFontQualityOut, mainFontItalicOut, mainFontStrikeOut, mainFontUnderlineOut
	, subTextOut, subBkgdColourOut
	, subFontNameOut, subFontSizeOut, subFontWeightOut, subFontColourOut
	, subFontQualityOut, subFontItalicOut, subFontStrikeOut, subFontUnderlineOut)
	
	}

	SplashImgInit(imagePathIn, imageUrlIn
	, bkgdColourIn, transColIn, vHideIn, noHWndActivateIn
	, vMovableIn, vBorderIn, vOnTopIn
	, vPosXIn, vPosYIn, vMgnXIn, vMgnYIn, vImgWIn, vImgHIn
	, mainTextIn, mainBkgdColourIn
	, mainFontNameIn, mainFontSizeIn, mainFontWeightIn, mainFontColourIn
	, mainFontQualityIn, mainFontItalicIn, mainFontStrikeIn, mainFontUnderlineIn
	, subTextIn, subBkgdColourIn
	, subFontNameIn, subFontSizeIn, subFontWeightIn, subFontColourIn
	, subFontQualityIn, subFontItalicIn, subFontStrikeIn, subFontUnderlineIn)
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

		if (This.updateFlag <= 0)
		{
		;Set defaults

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


			if (bkgdColourIn == -1)
			{
				if (This.bkgdColour == "")
				This.bkgdColour := This.GetDefaultGUIColour()
			}
			else
			This.bkgdColour := This.ValidateColour(bkgdColourIn)


		This.transCol := transColIn


			This.vHide := vHideIn

			if (noHWndActivateIn)
			This.noHWndActivate := "NoActivate "
			else
			This.noHWndActivate := ""

		This.vMovable := vMovableIn
		This.vBorder := vBorderIn

		This.vPosX := (vPosXIn == "D")? vPosXIn: Floor(vPosXIn)
		This.vPosY := (vPosYIn == "D")? vPosYIn: Floor(vPosYIn)


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

			if (vImgWIn > 0)
			This.vImgW := Floor(vImgWIn)
			else
			{
			; negative values ignored
				if (This.hWndSaved)
				This.vImgW := 0
				else
				; At startup only
				This.vImgW := A_ScreenWidth/5
			}

			if (vImgHIn > 0)
			This.vImgH := Floor(vImgHIn)
			else
			{
				if (This.hWndSaved)
				This.vImgH := 0
				else
				This.vImgH := A_ScreenHeight/3
			}







			if (StrLen(mainTextIn))
			This.mainText := This.ValidateText(mainTextIn)

			if (mainBkgdColourIn == -1)
			{
				if (This.mainBkgdColour == "")
				This.mainBkgdColour := This.GetDefaultGUIColour()
			}
			else
			This.mainBkgdColour := This.ValidateColour(mainBkgdColourIn, 1)

			if (StrLen(mainFontNameIn))
			This.mainFontName := This.ValidateText(mainFontNameIn)
			else
			{
				if (!This.mainFontName)
				This.mainFontName := "Verdana"
			}

			if (mainFontSizeIn)
			This.mainFontSize := Floor(mainFontSizeIn)
			else
			{
				if (!This.mainFontSize)
				This.mainFontSize := 12
			}

			if (mainFontWeightIn)
			This.mainFontWeight := Floor(mainFontWeightIn)
			else
			{
				if (!This.mainFontWeight)
				This.mainFontWeight := 600
			}

			if (mainFontColourIn == -1)
			{
				if (This.mainFontColour = "")
				This.mainFontColour := This.GetDefaultGUIColour(1)
			}
			else
			This.mainFontColour := This.ValidateColour(mainFontColourIn, 1)

			if (mainFontQualityIn >= 0)
			This.mainFontQuality := Floor(mainFontQualityIn)
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

			if (subBkgdColourIn == -1)
			{
				if (This.subBkgdColour == "")
				This.subBkgdColour := This.GetDefaultGUIColour()
			}
			else
			This.subBkgdColour := This.ValidateColour(subBkgdColourIn, 1)


			if (StrLen(subFontNameIn))
			This.subFontName := This.ValidateText(subFontNameIn)
			else
			{
				if (!This.subFontName)
				This.subFontName := "Verdana"
			}

			if (subFontSizeIn)
			This.subFontSize := Floor(subFontSizeIn)
			else
			{
				if (!This.subFontSize)
				This.subFontSize := 10
			}

			if (subFontWeightIn)
			This.subFontWeight := Floor(subFontWeightIn)
			else
			{
				if (!This.subFontWeight)
				This.subFontWeight := 400
			}

			if (subFontColourIn == -1)
			{
				if (This.subFontColour == "")
				This.subFontColour := This.GetDefaultGUIColour(1)
			}
			else
			This.subFontColour := This.ValidateColour(subFontColourIn, 1)

			if (subFontQualityIn >= 0)
			This.subFontQuality := Floor(subFontQualityIn)
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


		;if (!(This.vImgW && This.vImgH)) ;  get actual pic size
		This.GetPicWH()

	This.DisplayToggle()


	DetectHiddenWindows On
		if (!This.hWndSaved)
		{
			if (This.hGDIPLUS := DllCall("LoadLibrary", "Str", "GdiPlus.dll", "Ptr"))
			{
			VarSetCapacity(SI, 24, 0), Numput(1, SI, 0, "Int")
			DllCall("GdiPlus.dll\GdiplusStartup", "UPtr*", spr, "Ptr", &SI, "Ptr", 0)
			; for return value see status enumeration in  gdiplustypes.h 
			This.pToken := spr
			}
			else
			msgbox, 8208, LoadLibrary, Critical GDIPLUS error!

		;WS_DLGFRAME := 0x400000
		Gui, Splashy: New, % "+OwnDialogs +ToolWindow -Caption " . ((This.vBorder)? ((This.vBorder == "B")? "+Border ": "+0x400000 "): "")
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
		spr := " "

		if (This.vPosX == "D" && This.vPosX == "D")
		spr .= Format("W{} H{}", vWinW, vWinH)
		else
		{
			if (This.vPosX != "D" && This.vPosY == "D")
			spr .= Format(" X{} W{} H{}", This.vPosX, vWinW, vWinH)
			else
			{
				if (This.vPosX == "D")
				spr .= Format(" Y{} W{} H{}", This.vPosY, vWinW, vWinH)
				else
				spr .= Format(" X{} Y{} W{} H{}", This.vPosX, This.vPosY, vWinW, vWinH)
			}
		}


		Gui, Splashy: Show, Hide %spr%
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
	if (not This.vImgType)  ; IMAGE_BITMAP (0) or the ImageType parameter was omitted.
	DllCall("DeleteObject", "ptr", This.hBitmap)
	else if (This.vImgType = 1)  ; IMAGE_ICON
	DllCall("DestroyIcon", "ptr", This.hIcon)
	else if (This.vImgType = 2)  ; IMAGE_CURSOR
	DllCall("DestroyCursor", "ptr", This.hIcon)

	This.downloadedPathNames.SetCapacity(0)
	This.downloadedUrlNames.SetCapacity(0)
	This.hWndSaved := 0
	This.mainTextHWnd := 0
	This.subTextHWnd := 0
	This.updateFlag := 0
	Gui, Splashy: Destroy
	This.BindWndProc(1)
	This.SubClassTextCtl(0, 1)

	;This.Delete("", chr(255))
	This.SetCapacity(0)
	This.base := ""
	if (This.pToken)
	DllCall("GdiPlus.dll\GdiplusShutdown", "Ptr", This.pToken)
	if (This.hGDIPLUS)
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


		if (This.HTML.HasKey(keyOrVal))
		{
		keyOrVal := This.ToBase(This.HTML[keyOrVal], 16)
		spr1 := StrLen(keyOrVal)
		}
		else
		{
		spr := ""

		spr1 := StrLen(keyOrVal)

		; If "0X" found, remove it. Will be added later. Remove other X's
		
		if (InStr(SubStr(keyOrVal, 1, 2), "0X"))
		keyOrVal := StrReplace(SubStr(keyOrVal, 3, spr1 - 2), "X", "0")
		else
		keyOrVal := StrReplace(SubStr(keyOrVal, 1, spr1), "X", "0")			; filter out numerics 

			if keyOrVal is not xdigit
			{
				; Filter out all but numerics
				loop, Parse, keyOrVal, , %A_Space%%A_Tab% `,
				{
					if A_Loopfield is xdigit
					spr .= A_Loopfield
				}

				if (spr)
				keyOrVal := spr
				else
				keyOrVal := 0
			}

			if (spr1 != 6 && keyOrVal is digit) ;  assume decimal,
			; which may not be desired if they were digits in above loop
			keyOrVal := This.ToBase(keyOrVal, 16)

		spr1 := StrLen(keyOrVal)

			if (spr1 > 8)
			spr1 := 8
			else
			{
				if (spr1 < 3)
				return "0X0"
			}

		}

	; pad zeroes
	spr2 := ""

		loop, % (6 - spr1)
		spr2 := spr2 . "0"

	spr := "0X" . spr2 . keyOrVal


		if (toBGR) ; for the GDI functions (ColorRef)
		spr := This.ReverseColour(spr)
		else
		{
			if (InStr(spr, "0X"))
			spr := SubStr(spr, 3, 6) ; "0X" prefix not required for AHK gui functions
		}

	return spr
	}

	ReverseColour(colour)
	{

		colour := ((colour & 0x0000FF) << 16 ) | (colour & 0x00FF00) | ((colour & 0xFF0000) >> 16)

		if colour is digit
		{
		spr := This.ToBase(colour, 16)
		; possible to return spr here
		; The following just pads the zeroes.
		spr1 := StrLen(spr)

		spr2 := ""

		loop, % (6 - spr1)
		spr2 := spr2 . "0"

		colour := "0X" . spr2 . spr

		}
		return colour
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
	; returns without "0X"
	Return m
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
	static vToggle := 1

	vToggle := !vToggle
	spr := (This.vImgW)? This.vImgW: This.actualVImgW
	spr1 := (This.vImgH)? This.vImgH: This.actualVImgH

	spr1 := Format("W{} H{}", spr, spr1)
	; This function uses LoadPicture to populate hBitmap and hIcon
	; and sets the image type for the painting routines accordingly
		if (This.imagePath)
		{
			if (This.hWndSaved)
			{
			; No need to reload
				if (This.oldImagePath == This.imagePath && This.oldVImgW == This.vImgW && This.oldVImgH == This.vImgH)
				return
				else
				{
				This.oldImagePath := This.imagePath

					if (This.hBitmap)
					{
						if (!(InStr(This.imagePath, "*")))
						{
						DllCall("DeleteObject", "ptr", This.hBitmap)
						This.hBitmap := 0
						}
					}
					else
					{
						if (This.hIcon)
						{
						DllCall("DestroyIcon", "ptr", This.hIcon)
						This.hIcon := 0
						}
					}
				}
			}

		SplitPath % This.imagePath,,, spr

			if (StrLen(spr))
			This.vImgType := ((spr == "cur")? 2: (spr == "exe" || spr == "ico")? 1: 0)
			else
			This.vImgType := 0 ; assume image



			if (InStr(This.imagePath, "*"))
			{
				if (!This.hBitmap)
				{
				This.hBitmap := This.Create_Lily_jpg()
				This.vImgType := 0
				}
			return
			}
			else
			{
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
			}
		}

		SplitPath % This.imagePath, spr
		This.ImageName := spr
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
				This.oldImageUrl := This.imageUrl
				This.vImgType := 0
				spr := This.ImageName

				This.downloadedPathNames.Push(spr) 
				This.downloadedUrlNames(spr) := This.oldImageUrl
				return
				}
				else
				msgbox, 8208, LoadPicture, Format not recognized!

			}
			else
			spr := 1		

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
	} BITMAP, *PBITMAP, *NPBITMAP, *LPBITMAP; ==> Extra pointer reference
	*/
	This.ImageName := ""
	if (!(This.vImgW && This.vImgH))
	spr1 := ""
	else
	spr1 := Format("W{} H{}", This.vImgW, This.vImgH)

	if (This.imagePath)
	{
		if (This.hWndSaved)
		{
		; No need to reload
			if (This.oldImagePath == This.imagePath && This.oldVImgW == This.vImgW && This.oldVImgH == This.vImgH)
			return
			else
			{
				if (This.hBitmap)
				{
				DllCall("DeleteObject", "ptr", This.hBitmap)
				This.hBitmap := 0
				}
				else
				{
					if (This.hIcon)
					{
					DllCall("DestroyIcon", "ptr", This.hIcon)
					This.hIcon := 0
					}
				}
			}
		}

	SplitPath % This.imagePath,,, spr

		if (StrLen(spr))
		This.vImgType := ((spr == "cur")? 2: (spr == "exe" || spr == "ico")? 1: 0)
		else
		This.vImgType := 0 ; assume image



		if (InStr(This.imagePath, "*"))
		{
		This.hBitmap := This.Create_Lily_jpg()
		This.vImgType := 0
		}
		else
		{
			if (fileExist(This.imagePath))
			{
			spr := This.imagePath

				if (This.vImgType)
				{
					if (This.imagePath == A_AhkPath)
					{
						if (!(This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2": "") . spr1, spr)))
						msgbox, 8208, LoadPicture, Problem loading AHK icon!
					}
					else
					{
						if (!(This.hIcon := LoadPicture(spr, spr1, spr))) ; must use 3rd parm or bitmap handle returned!
						msgbox, 8208, LoadPicture, Problem loading icon!
					}
				}
				else
				{
					if (!(This.hBitmap := LoadPicture(spr, spr1)))
					msgbox, 8208, LoadPicture, Problem loading picture!
				}
			}
		}
	}

	if (!(This.hBitmap || This.hIcon))
	{
	SplitPath % This.imagePath, spr
	This.ImageName := spr
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
			This.DownloadFile(This.imageUrl, This.ImageName)

			if (This.hBitmap := LoadPicture(This.ImageName, spr1))
			{
			This.vImgType := 0
			spr := This.ImageName

			This.downloadedPathNames.Push(spr) 
			This.downloadedUrlNames(spr) := This.imageUrl
			}
			else
			msgbox, 8208, LoadPicture, Format not recognized!

		}
		else
		spr := 1		
	; "Neverfail" default 

		if (!This.hBitmap)
		{
		This.hIcon := LoadPicture(A_AhkPath, ((vToggle)? "Icon2 ": "") . spr1, spr)
		This.vImgType := 1
		}
	}

	Switch This.vImgType
		{
			case 0:
			{
			VarSetCapacity(bm, ((A_PtrSize == 8)? 32: 24), 0) ;tagBitmap (24: 20) PLUS pointer ref to pBitmap 
			if (!(DllCall("GetObject", "Ptr", This.hBitmap, "uInt", (A_PtrSize == 8)? 32: 24, "Ptr", &bm)))
			msgbox, 8208, GetObject hBitmap, Object could not be retrieved!

			spr := NumGet(bm, 4, "Int")
			spr1 := NumGet(bm, 8, "Int")
			VarSetCapacity(bm, 0)
			}
			case 1, 2:
			{
			; https://www.autohotkey.com/boards/viewtopic.php?t=36733
			; easier way to get icon dimensions is use default SM_CXICON, SM_CYICON
			VarSetCapacity(bm, (A_PtrSize == 8)? 104: 84, 0) ; ICONINFO Structure
				If (DllCall("GetIconInfo", "Ptr", This.hIcon, "Ptr", &bm))
				{
					ICONINFO.hbmColor := NumGet(bm, (A_PtrSize == 8)? 24: 16, "UPtr")
					ICONINFO.hbmMask := NumGet(bm, (A_PtrSize == 8)? 16: 12, "UPtr")

					if (ICONINFO.hbmColor)
					{
					DllCall("GetObject", "Ptr", ICONINFO.hbmColor, "Int", (A_PtrSize == 8)? 104: 84, "Ptr",&bm)
					spr := NumGet(bm, 4, "UInt")
					spr1 := NumGet(bm, 8, "UInt")
					This.deleteObject(ICONINFO.hbmColor)
					}
					else
					{
						if (ICONINFO.hbmMask) ; Colour plane absent
						{
						DllCall("GetObject", "Ptr", ICONINFO.hbmMask, "Int", (A_PtrSize == 8)? 104: 84, "Ptr", &bm)
						spr := NumGet(bm, 4, "UInt")
						spr1 := NumGet(bm, 8, "UInt")
						This.deleteObject(ICONINFO.hbmMask)
						}

					}
				}
				else
				; The fastest way to convert a hBITMAP to hICON is to add it to a hIML and retrieve it back as a hICON with COMCTL32\ImageList_GetIcon()
				msgbox, 8208, GetIconInfo, Icon info could not be retrieved!
			VarSetCapacity(bm, 0)

			}
		}
	This.actualVImgW := spr
	This.actualVImgH := spr1
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
				spr := (This.vImgW)? This.vImgW: This.actualVImgW
				spr1 := (This.vImgH)? This.vImgH: This.actualVImgH

					if (This.oldVImgW || This.oldVImgH)
					{
					if (!DllCall("gdi32\StretchBlt", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Int", spr, "Int", spr1, "Ptr", hDCCompat, "Int", 0, "Int", 0, "Int", This.actualVImgW, "Int", This.actualVImgH, "UInt", SRCCOPY))
					msgbox, 8208, PaintDC, BitBlt Failed!
					}
					else
					{
					if (!DllCall("gdi32\BitBlt", "Ptr", This.hDCWin, "Int", This.vImgX, "Int", This.vImgY, "Int", This.vImgW, "Int", This.vImgH, "Ptr", hDCCompat, "Int", 0, "Int", 0, "UInt", SRCCOPY))
					msgbox, 8208, PaintDC, BitBlt Failed!
					}
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
	; ##################################################################################
; # This #Include file was generated by Image2Include.ahk, you must not change it! #
; ##################################################################################
Create_Lily_jpg(NewHandle = False) {

Ptr := A_PtrSize ? "Ptr" : "UInt"
UPtr := A_PtrSize ? "UPtr" : "UInt"
If (NewHandle)
   hBitmap := 0

VarSetCapacity(B64, 63644 << !!A_IsUnicode)
B64 := "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"
B64 .= "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"
B64 .= "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"
B64 .= "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"
If !DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &B64, "UInt", 0, "UInt", 0x01, Ptr, 0, "UIntP", DecLen, Ptr, 0, Ptr, 0)
   Return False
VarSetCapacity(Dec, DecLen, 0)
If !DllCall("Crypt32.dll\CryptStringToBinary" (A_IsUnicode ? "W" : "A"), Ptr, &B64, "UInt", 0, "UInt", 0x01, Ptr, &Dec, "UIntP", DecLen, Ptr, 0, Ptr, 0)
   Return False
; Bitmap creation adopted from "How to convert Image data (JPEG/PNG/GIF) to hBITMAP?" by SKAN
; -> http://www.autohotkey.com/board/topic/21213-how-to-convert-image-data-jpegpnggif-to-hbitmap/?p=139257
hData := DllCall("Kernel32.dll\GlobalAlloc", "UInt", 2, UPtr, DecLen, UPtr)
pData := DllCall("Kernel32.dll\GlobalLock", Ptr, hData, UPtr)
DllCall("Kernel32.dll\RtlMoveMemory", Ptr, pData, Ptr, &Dec, UPtr, DecLen)
DllCall("Kernel32.dll\GlobalUnlock", Ptr, hData)
DllCall("Ole32.dll\CreateStreamOnHGlobal", Ptr, hData, "Int", True, Ptr "P", pStream)
VarSetCapacity(SI, 16, 0), NumPut(1, SI, 0, "UChar")
DllCall("Gdiplus.dll\GdipCreateBitmapFromStream",  Ptr, pStream, Ptr "P", pBitmap)
DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", Ptr, pBitmap, Ptr "P", hBitmap, "UInt", 0)
DllCall("Gdiplus.dll\GdipDisposeImage", Ptr, pBitmap)
PtrSize := A_PtrSize ? A_PtrSize : 4
DllCall(NumGet(NumGet(pStream + 0, 0, UPtr) + (PtrSize * 2), 0, UPtr), Ptr, pStream)
Return hBitmap
}
}
;=====================================================================================











;=====================================================================================
; Autoexec here:
SplashyRef := Splashy.SplashImg ; function reference


%SplashyRef%(Splashy, {vPosX: 0, imagePath: "C:\Windows\Cursors\busy_l.cur", bkgdColour: "Blue", vMovable: "", vBorder: "", vOnTop: ""
, vMgnY: 2, mainText: "ByeByeByeByeByeByeByeByeByeByeByeByeByeByeBye`nBye`nHello", mainFontSize: 24, subText: "HiHi", subFontItalic: 1, subFontStrike: 1}*)
msgbox ok

;%SplashyRef%(Splashy, {release: 1}*)
;msgbox released
;%SplashRef%(Splashy, {initSplash: 1, imagePath: "", bkgdColour: "FFFF00", mainFontUnderline: 1, transCol: "", vMovable: "movable", vBorder: "", vOnTop: ""
;, vMgnX: "D", mainText: "Yippee`n`nGreat", noHWndActivate: 1, subFontColour: "yellow", subFontSize: 24, subText: "Hi`nHi", subBkgdColour: "blue", subFontItalic: 1, subFontStrike: 1}*)

%SplashyRef%(Splashy, {initSplash: 1, vImgW: 500, vImgH: 400, imagePath: "*", bkgdColour: "green", mainFontUnderline: 1, transCol: "", vMovable: "movable", vBorder: "", vOnTop: ""
, vMgnX: 6, mainText: "Yippee`n`nGreat", noHWndActivate: 1, subFontSize: 24, subText: "Hi`nHi", subBkgdColour: "blue", subFontItalic: 1, subFontStrike: 1}*)
msgbox initSplash blue subBkgdColour
%SplashyRef%(Splashy, {bkgdColour: "green", mainFontUnderline: 1, transCol: "", vMovable: "movable", vBorder: "", vOnTop: ""
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


%SplashyRef%(Splashy, {bkgdColour: "Blue", transCol: "1", vMovable: "1", vBorder: "", vOnTop: "onTop"
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