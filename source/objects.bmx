

Type TFuel Extends TImageEntity

	Method New()
		Self.SetImage(GetResourceImage("objects","images"))
		Self.SetFrame(TWorld.OBJECT_FUEL)
		Self.SetColor(100,255,100)
	EndMethod


	Method UpdateEntity()
		if EntityX(Self) < -8 then G_WORLD.RemoveObject(self)
	End Method


	Method Score()
		G_PLAYER.score:+ 25
		G_PLAYER.fuel:+ 0.125
		G_PLAYER.fuel = Min(G_PLAYER.fuel, G_PLAYER.MAXFUEL)
	End Method
EndType


Type TBox Extends TImageEntity

	Method New()
		Self.SetImage(GetResourceImage("objects","images"))
		Self.SetFrame(TWorld.OBJECT_BOX)
		Self.SetColor(100,100, 255)
	EndMethod


	Method UpdateEntity()
		if EntityX(Self) < -8 then G_WORLD.RemoveObject(self)
	End Method


	Method Score()
		G_PLAYER.score:+25
	End Method
EndType


Type TBase Extends TImageEntity

	Method New()
		Self.SetImage(GetResourceImage("objects","images"))
		Self.SetFrame(TWorld.OBJECT_BASE)
		Self.SetColor(255,100,100)
	EndMethod


	Method UpdateEntity()
		if EntityX(Self) < -8 then G_WORLD.RemoveObject(self)
	End Method


	method Score()
		G_PLAYER.score:+1000
	End Method
EndType


Type TRocket Extends TImageEntity

	Field active:Int
	Field flying:Int

	Method New()
		Self.SetImage(GetResourceImage("objects","images"))
		Self.SetFrame(TWorld.OBJECT_ROCKET)
		Self.SetColor(Rand(100, 255), Rand(100, 255), Rand(100, 255))

		active = rand(1,4)
  		if G_WORLD.area = G_WORLD.AREA_ROCKS then active = 1
  		flying = False
	EndMethod


	Method UpdateEntity()

		if EntityX(Self) < -8
			G_WORLD.RemoveObject(self)
			Return
		endif

		if self.flying = False
			if self.active > 2
				Local xpos:Int = RESX/2
				if G_PLAYER then xpos = EntityX( G_PLAYER )

				if xpos > Self.GetPositionX()-G_WORLD.rocketDistance
					Self.flying= True
					G_GAME.CreateExplosion( Self.GetPosition(), 5, 0.05 )
				endif
			endif
		Else
			Self.Move( 0, -TWorld.SCROLL_SPEED )
			if EntityY(Self) < -8
				G_WORLD.RemoveObject(self)
				return
			endif
		Endif

		'collison with tile or rock?
		Local collidedWith:TImageEntity = EntityGroupCollide( Self, "enemies" )
		If collidedWith
			if TTile(collidedWith) or TRock(collidedWith)
				G_WORLD.RemoveObject(self)
				g_game.CreateExplosion(Self._position, 9,0.04)
				PlayGameSound( "explosion", "sounds", 0.5 )
			Endif
		EndIf
	EndMethod


	Method Score()
		G_PLAYER.score:+50
	End Method

EndType


Type TRock Extends TImageEntity

	Field rotationSpeed:Float


	Method New()
		Self.SetImage(GetResourceImage("objects","images"))
		Self.SetFrame(TWorld.OBJECT_ROCK)
		Self.SetColor(Rand(100, 255), Rand(100, 255), Rand(100, 255))
		Self.rotationSpeed = rnd(-4,4)
	End Method


	Method UpdateEntity()
		Self.Move( -0.5, 0 )
		if EntityX(Self) < -16
			G_WORLD.RemoveObject(self)
			Return
		endif

		Self.AddRotation( Self.rotationSpeed )

		'only tiles stop rocks
		Local collidedWith:TImageEntity = TTile(EntityGroupCollide( Self, "enemies" ))
		If collidedWith
			G_WORLD.RemoveObject(self)
			G_GAME.CreateExplosion(Self.GetPosition(), 9, 0.04)
			PlayGameSound( "explosion", "sounds", 0.5 )
			Return
		EndIf

	EndMethod

EndType


Type TSaucer Extends TImageEntity

	'saucer travels between these y positions
	Const MIN_YPOS:Int = 25
	Const MAX_YPOS:Int = 75
	'in this amount of steps
	Const STEPS_TOTAL:Int = 60
	'saucer current step
	Field currentStep:float
	'the direction saucer is moving in
	Field stepDirection:int


	Method New()
		Self.SetImage(GetResourceImage("objects","images"))
		Self.SetFrame(TWorld.OBJECT_SAUCER)
		Self.SetColor(Rand(100, 255), Rand(100, 255), Rand(100, 255))

		'start at random place in movement path
		Self.currentStep = rand(10,50)
		self.stepDirection=1
	End Method


	Method UpdateEntity()
		Self.Move( -0.25, 0 )

		if EntityX(Self) < -16
			G_WORLD.RemoveObject(self)
			Return
		endif

		'caclulate new y pos using interpolation
		'http://sol.gfxile.net/interpolation/
	 	local v:float = currentStep / STEPS_TOTAL
		v = SmoothStep(v)
		local ypos:Float = (MIN_YPOS * v) + (MAX_YPOS * (1.0-v))
		SetEntityY( Self, ypos )

		'calculate next step, ping pong style.
		Self.currentStep:+ Self.stepDirection
		if Self.currentStep = Self.STEPS_TOTAL then Self.stepDirection = -1
		if Self.currentStep = 0 then Self.stepDirection = 1

		'only tiles stop saucers
		Local collidedWith:TImageEntity = TTile(EntityGroupCollide( Self, "enemies" ))
		If collidedWith
			G_WORLD.RemoveObject(self)
			G_GAME.CreateExplosion(Self._position, 9, 0.04)
			PlayGameSound( "explosion", "sounds", 0.5 )
			Return
		EndIf

	EndMethod

EndType


Function SmoothStep:Float(x:float)
	Return x*x* (3-2*x)
End Function
