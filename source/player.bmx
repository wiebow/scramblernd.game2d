
Type TPlayer Extends TImageEntity

	Field dead:Int
	Field deadPause:Int
	Field bombs:Int
	Field bombChannel:TChannel

	Const MAXFUEL:Float= 1.0
	Field fuelTake:Float = 0.0004
	Field fuel:Float
	Field score:Int

	Field lives:Int
	Field extraLifeGranted:Int
	Field timeFlown:Int

	Field state:TPlayState

	Method New()

		Self.SetImage( GetResourceImage( "objects", "images" ) )
		Self.SetFrame(0)
		Self.SetColor(255,255,50)
		Self.SetVisible(True)
		Self.SetPosition(10, 40)

		Self.dead=False
		Self.bombs=0
		Self.score = 0
		Self.lives = 3
		Self.fuel = Self.MAXFUEL
		Self.timeFlown = 0
		self.extraLifeGranted=False
	EndMethod


	Method UpdateEntity()
		If Self.dead = True
			Self.deadPause:-1
			if Self.deadPause <0
				If Self.lives > 0
					Self.dead=false
					Self.SetPosition(10, 40)
					Self.SetVisible(True)
					Self.fuel = Self.MAXFUEL
					Self.bombs=0
					G_WORLD.ResetArea()
				EndIf
			Endif
			Return
		EndIf

		Self.fuel:- Self.fuelTake
		If Self.fuel <=0.0
			Self.fuel = 0.0
			MoveEntity( Self, 0, TWorld.SCROLL_SPEED )
		EndIf

		If Self.fuel > 0.0
			If KeyControlDown("LEFT") Then MoveEntity( Self, -TWorld.SCROLL_SPEED, 0 )
			If KeyControlDown("RIGHT") Then MoveEntity( Self, TWorld.SCROLL_SPEED, 0 )
			If KeyControlDown("UP") Then MoveEntity( Self, 0, -TWorld.SCROLL_SPEED )
			If KeyControlDown("DOWN") Then MoveEntity( Self, 0, TWorld.SCROLL_SPEED )

			If EntityX( Self ) < 5 Then SetEntityX( Self, 5 )
			If EntityX( Self ) > RESX-5 Then SetEntityX( Self, RESX-5 )
			If EntityY( Self ) < 12 Then SetEntityY( Self, 12 )
			If EntityY( Self ) > RESY-10 Then SetEntityY( Self, RESY-10 )
		EndIf

		If KeyControlHit("BULLET")
			G_GAME.CreateBullet( Self.GetPosition() )
			PlayGameSound( "bullet", "sounds", 0.2 )
		Endif

		'keep playing the bomb sound on the same channel
		'to avoid multiple sounds.
		If KeyControlHit("BOMB") = 1
			If Self.bombs < 2
				Self.bombs:+1
				G_GAME.CreateBomb( Self.GetPosition() )
				Self.bombChannel = PlayGameSound( "bomb", "sounds" , 0.1, 1.0, Self.bombChannel)

			EndIf
		EndIf

		'ship collide with enemy? (and tiles)
		local enemy:TImageEntity = EntityGroupCollide( Self, "enemies" )
		If enemy
			Self.dead = True
			Self.lives:-1
			Self.deadPause = 250
			Self.SetVisible(False)
			G_WORLD.scrolling=false
			G_GAME.CreateExplosion( Self.GetPosition(), 15 )
			PlayGameSound( "explosion", "sounds" )
		EndIf

		'extra life?
		If Self.extraLifeGranted = false
			If score > 10000
				self.lives:+1
				Self.extraLifeGranted=True
				PlayGameSound( "extra", "sounds" )
			EndIf
		EndIf

		'earn points by flying, every 60 updates.
		Self.timeFlown:+1
		if Self.timeFlown Mod 60 = 0
			Self.score:+10
		EndIf

		'update hiscore
		G_HISCORE = max( Self.score, G_HISCORE )
	EndMethod

EndType