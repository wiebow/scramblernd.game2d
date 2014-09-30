
Type TScrambleGame Extends TGame

	Const VERSION:String = "1.1"


	Method New()
		SetGameTitle("ScrambleRND! v" + Self.VERSION)
	EndMethod


	Method Startup()
		HideMouse()
		SeedRnd(MilliSecs())		

		InitializeGraphics( 800, 600, RESX, RESY )

		'add entity collision groups
		AddEntityGroup( "player" )
		AddEntityGroup( "particles" )
		AddEntityGroup( "bullets")
		AddEntityGroup( "bombs" )
		AddEntityGroup( "enemies" )			' backdrop, ships, objects etc..

		'add resource groups
		AddResourceGroup( "tiles" )
		AddResourceGroup( "images" )
		AddResourceGroup( "sounds" )

		'load images
		SetMaskColor(255, 0, 255)
		AutoImageFlags(MASKEDIMAGE)
		AddResourceImage(LoadImage("media/backdrop.png"), "backdrop", "tiles")
		AddResourceImage(LoadImage("media/tile0.png"), "tile0", "tiles")
		AddResourceImage(LoadImage("media/tile1.png"), "tile1", "tiles")
		AddResourceImage(LoadImage("media/tile2.png"), "tile2", "tiles")
		AddResourceImage(LoadImage("media/tile3.png"), "tile3", "tiles")
		AddResourceImage(LoadImage("media/tile4.png"), "tile4", "tiles")
		AddResourceImage(LoadImage("media/tile5.png"), "tile5", "tiles")
		AddResourceImage(LoadImage("media/tile6.png"), "tile6", "tiles")
		AddResourceImage(LoadImage("media/tile7.png"), "tile7", "tiles")
		AddResourceImage(LoadImage("media/tile8.png"), "tile8", "tiles")
		AddResourceImage(LoadImage("media/tile9.png"), "tile9", "tiles")
		AddResourceImage(LoadImage("media/tile10.png"), "tile10", "tiles")

		AutoMidHandle(True)
		AddResourceImage(LoadImage("media/logo.png"), "logo", "images")
		AddResourceImage(LoadAnimImage("media/objects.png", 16, 16, 0, 7), "objects", "images")
		AddResourceImage(LoadImage("media/bullet.png"), "bullet", "images")

		'load sounds
		AddResourceSound( LoadSound("media/jingle.wav"), "jingle", "sounds" )
		AddResourceSound( LoadSound("media/bullet.wav"), "bullet", "sounds" )
		AddResourceSound( LoadSound("media/explosion.wav"), "explosion", "sounds" )
		AddResourceSound( LoadSound("media/bomb.wav"), "bomb", "sounds" )
		AddResourceSound( LoadSound("media/extralife.wav"), "extra", "sounds" )

		'load and set font
		Self.SetGameFont( LoadImageFont("media/cbm64.ttf", 11, 0) )
		Self.SetFontScale(0.6)

		'create game controls
		AddKeyControl( TKeyControl.Create("UP", KEY_UP) )
		AddKeyControl( TKeyControl.Create("DOWN", KEY_DOWN) )
		AddKeyControl( TKeyControl.Create("LEFT", KEY_LEFT) )
		AddKeyControl( TKeyControl.Create("RIGHT", KEY_RIGHT) )
		AddKeyControl( TKeyControl.Create("BOMB", KEY_X) )
		AddKeyControl( TKeyControl.Create("BULLET", KEY_Z) )

		'add states
		AddGameState( New TTitleState, STATE_TITLE )
		AddGameState( New TPlayState, STATE_PLAY )

		G_HISCORE = 1206

		'force a fade in
		_enterTransition = New TTransitionFadeIn
	End Method


	Method CleanUp()
	EndMethod


	Method CreateExplosion(position:TPosition, amount:Int, speed:Float=0.7)
		Local particle:TParticle
		For local i:Int = 0 to amount
			particle = New TParticle
			particle.speed = Rnd(0.2, speed)
			particle.angle = Rnd(360)
			SetEntityPosition( particle, position.GetX(), position.GetY() )
			AddEntity( particle, LAYER_PARTICLES, "particles" )
		Next
	EndMethod


	Method CreateBullet(position:TPosition)
		Local bullet:TBullet = New TBullet
		SetEntityPosition( bullet, position.GetX()+4, position.GetY() )
		AddEntity( bullet, LAYER_PLAYER, "bullets" )
	EndMethod


	Method CreateBomb(position:TPosition)
		Local bomb:TBomb = New TBomb
		SetEntityPosition( bomb, position.GetX()+4, position.GetY() )
		AddEntity( bomb, LAYER_PLAYER, "bombs" )
	EndMethod

End Type
