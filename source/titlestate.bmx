

Type TTitleState Extends TState

	'for flashy text
	Field colorFlash:Int
	field colorHighLight:Int
	CONST COLORFLASH_DELAY:Int = 20

	Method Enter()
		G_WORLD = New TWorld
		G_WORLD.StartNewGame()
		G_WORLD.attractMode = True
	End Method


	Method Leave()
		FlushKeys()
		G_WORLD = Null
		ClearEntities()
	End Method


	Method Update(delta:Double)

		'update color flash toggle
		colorFlash:+1
		if colorFlash Mod COLORFLASH_DELAY = 0
			colorHighLight = not colorHighLight
			colorFlash = 0
		endif

		If KeyHit(KEY_ENTER)
			EnterGameState( STATE_PLAY, New TTransitionFadeIn, New TTransitionFadeOut)
		Endif

		G_WORLD.Update()
	End Method


	Method PreRender(tween:Double)
		SetColor 30, 30, 30
		SetRotation(0)
		SetScale(1,1)
		SetAlpha(1.0)
		DrawImage( GetResourceImage("backdrop", "tiles"), 0, 0 )
	End Method


	Method Render(tween:Double)

		'take care of side borders in fullscreen mode.
		SetOrigin(TVirtualGfx.VG.vxoff, TVirtualGfx.VG.vyoff)

	    SetRotation(-10)
    	SetColor(50,100,200)
	    SetScale(2,2)
	    SetAlpha(1.0)
		DrawImage( GetResourceImage("logo", "images"),RESX/2,33 )

	    SetRotation(0)
	    SetGameColor( RED )
	   	RenderText("RND!", 118 ,33, False, False)
	   	SetGameColor( WHITE )
	    RenderText("HISCORE: "+ G_HISCORE,0,2,True,True)
	    RenderText("BY WDW 2013", 0,50,True,True)

		SetGameColor( RED )
		if colorHighLight then SetGameColor( WHITE )
		RenderText("PRESS [ENTER] TO PLAY", 0, RESY - 30, True, True)

		SetGameColor( GREEN )
		RenderText("[ESCAPE] game config menu", 0, RESY - 15, True, True)
	End Method

End Type