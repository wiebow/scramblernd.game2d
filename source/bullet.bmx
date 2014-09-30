

Type TBullet Extends TImageEntity


	Method New()
		Self.SetImage( GetResourceImage("bullet", "images") )
		Self.SetColor(255,255,255)
	End Method


	Method UpdateEntity()
		'move
		Self.Move( TWorld.SCROLL_SPEED*2, 0 )

		If _position.GetX() > RESX Then 
			RemoveEntity(Self)
			Return
		Endif


		'collision with enemy or tiles?
		Local collidedWith:TImageEntity = EntityGroupCollide( Self, "enemies" )
		If collidedWith
			RemoveEntity(Self)
			if TTile(collidedWith) or TRock(collidedWith)
				G_GAME.CreateExplosion(Self._position, 3, 0.02)
				PlayGameSound( "explosion", "sounds", 0.1 )
				Return
			Endif

			'score
			if TRocket(collidedWith)
				TRocket(collidedWith).Score()
			elseif TBox(collidedWith)
				TBox(collidedWith).Score()
			elseif TFuel(collidedWith)
				TFuel(collidedWith).Score()
			elseif TBase(collidedWith)
				TBase(collidedWith).Score()
			Endif

			G_GAME.CreateExplosion( collidedWith.GetPosition(), 9, 0.05 )
			PlayGameSound( "explosion", "sounds", 0.5 )
			RemoveEntity(collidedWith)
		EndIf
	End Method

EndType
