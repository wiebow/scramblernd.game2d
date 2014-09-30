
Type TParticle Extends TImageEntity

	Field speed:Float
	Field angle:Float
	Field alphaChange:Float


	Method New()
		Self.SetImage(GetResourceImage( "bullet", "images" ))
		Self.SetColor(Rnd(100, 255), Rnd(100, 255), Rnd(100, 255))
		Self.alphaChange = 1.0 / Rnd(30,50)
		Self.SetCollision(false)
	End Method


	Method UpdateEntity()
		'move
		Self.Move( Sin(angle)* Self.speed, -cos(angle)*Self.speed )

		'scroll with world
		if G_WORLD.scrolling then Self.Move( -TWorld.SCROLL_SPEED, 0 )

		'burn!
		Self.SetColor(Rnd(100, 255), Rnd(100, 255), Rnd(100, 255))

		Self.SetAlpha( Self.GetAlpha()- Self.alphaChange)
		If Self.GetAlpha() <= 0.0 Then
			RemoveEntity(Self)
		Endif
	End Method
EndType
