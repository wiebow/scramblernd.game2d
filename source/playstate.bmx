

Type TPlayState Extends TState

	Method Enter()
		G_PLAYER = New TPlayer
		G_PLAYER.state = Self
		AddEntity(G_PLAYER, LAYER_PLAYER, "player" )

		G_WORLD = New TWorld
		G_WORLD.StartNewGame()
		G_WORLD.attractMode = False

		PlayGameSound( "jingle", "sounds", 0.75 )
	EndMethod


	Method Update(delta:Double)
		G_WORLD.Update()

		If G_PLAYER.lives = 0 And KeyHit(KEY_ENTER) = 1
			EnterGameState( STATE_TITLE, New TTransitionFadeIn, New TTransitionFadeOut )
		End If
	EndMethod


	Method Leave()
		FlushKeys()
		G_WORLD = Null
		G_PLAYER = Null
		ClearEntities()
		StopAllSound()
	EndMethod


	Method PreRender(tween:Double)
		SetColor 50, 50, 50
		SetRotation(0)
		SetScale(1,1)
		SetAlpha(1.0)
		DrawImage(GetResourceImage("backdrop", "tiles"), 0, 0)
	End Method


	Method Render(tween:Double)
		TRenderState.Push()
		TRenderState.Reset()

		RenderText( "SCORE: "+ G_PLAYER.score, 2, 1, False, True )
		RenderText( "HI: " + G_HISCORE, 120, 1, False, True )

		SetColor 0, 0, 0
		DrawRect(30, 116, G_PLAYER.fuel * 150, 1)
		SetColor 255, 255, 255
		DrawRect(30, 115.5, G_PLAYER.fuel * 150, 1)

		'display extra lives
		If G_PLAYER.lives > 1
			SetScale 0.5, 0.5
			Local xpos:Int = 4
			SetRotation(-90)
			For Local i:Int = 1 To G_PLAYER.lives - 1
				SetColor 0, 0, 0
				DrawImage( GetResourceImage("objects", "images"), xpos, 116.5, 0)
				SetColor 255, 255, 255
				DrawImage( GetResourceImage("objects", "images"), xpos, 116, 0)
				xpos:+4
			Next
			SetRotation(0)
			SetScale 1, 1
		EndIf

		If G_PLAYER.lives = 0
			SetColor Rnd(100, 200), Rnd(0, 100), Rnd(100, 255)
			RenderText( "GAME OVER", 0, 50, True, True )
			SetGameColor( WHITE )
			RenderText( "PRESS ENTER TO CONTINUE", 0, 65, True, True )
		End If

		TRenderState.Pop()
	EndMethod

EndType