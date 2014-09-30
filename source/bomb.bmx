

Type TBomb Extends TImageEntity

	Field fallSpeed:Float=0.0

	Method New()
		Self.SetImage( GetResourceImage("bullet", "images") )
		Self.SetColor(255,255,255)
		Self.SetScaleY(2.0)
	End Method


	Method UpdateEntity()
		'move
		Self.Move( 0, Self.fallSpeed )

		'speed up
		Self.fallSpeed:+0.025
		Self.fallSpeed = Min(Self.fallSpeed, TWorld.SCROLL_SPEED )

		'colliding with anything?
		Local collidedWith:TImageEntity = EntityGroupCollide( Self, "enemies" )
		If collidedWith
'			if TPlayer(collidedWith) or TBullet(collidedWith) or TBomb(collidedWith) then return

			RemoveEntity(Self)
			G_PLAYER.bombs:-1
			if G_PLAYER.bombs = 0 then PauseChannel(G_PLAYER.bombchannel)

			if TTile(collidedWith) or TRock(collidedWith)
				G_GAME.CreateExplosion(Self.GetPosition(), 3, 0.02 )
				PlayGameSound( "explosion", "sounds", 0.1 )
				return
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
				G_WORLD.baseDestroyed=true
			Endif

			G_GAME.CreateExplosion(collidedWith.GetPosition(), 9, 0.05 )
			PlayGameSound( "explosion", "sounds", 0.5 )
			RemoveEntity(collidedWith)
		EndIf
	End Method

EndType
