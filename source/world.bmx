
'scramble rnd world

Type TWorld

    Field rocketDistance:Int
    Field defaultSaucerDelay:Int
    Field saucerDelay:Int
    Field defaultRockDelay:Int
    Field rockDelay:Int
    Field rockSpeed:Float

	Const SCROLL_SPEED:Float = 0.50000

	'bools.
	Field scrolling:Int
	Field baseDestroyed:Int
	Field attractMode:Int

	'world object types
	Const OBJECT_ROCKET:Int = 1
	Const OBJECT_FUEL:Int = 2
	Const OBJECT_BOX:Int = 3
	Const OBJECT_SAUCER:Int = 4
	Const OBJECT_ROCK:Int = 5
	Const OBJECT_BASE:Int = 6

	'amount of tiles per area
	Const AREA_MAXTILES:Int = 4

	'areas
	Const AREA_HILLS:Int = 0
	Const AREA_SAUCERS:Int = 1
	Const AREA_ROCKS:Int= 2
	Const AREA_CITY:Int = 3
	Const AREA_MAZE:Int = 4
	Const AREA_BASE:Int = 5

	'current area
	Field area:Int
	'tiles created so far
	Field tilesCreated:Int

	Field tile1:TTile
	Field tile2:TTile
	'tile images
	Field tiles:TImage[]

	'objects on the map
	Field objectsList:TList

	'world color
	Field r:int, g:int, b:int


	Method New()
		objectsList = New TList
	
		tiles = New TImage[11]
		tiles[0] = GetResourceImage( "tile0", "tiles" )
		tiles[1] = GetResourceImage( "tile1", "tiles" )
		tiles[2] = GetResourceImage( "tile2", "tiles" )
		tiles[3] = GetResourceImage( "tile3", "tiles" )
		tiles[4] = GetResourceImage( "tile4", "tiles" )
		tiles[5] = GetResourceImage( "tile5", "tiles" )
		tiles[6] = GetResourceImage( "tile6", "tiles" )
		tiles[7] = GetResourceImage( "tile7", "tiles" )
		tiles[8] = GetResourceImage( "tile8", "tiles" )
		tiles[9] = GetResourceImage( "tile9", "tiles" )
		tiles[10] = GetResourceImage( "tile10", "tiles" )
	EndMethod


	Method StartNewGame()
		Self.area = Self.AREA_HILLS
		Self.baseDestroyed=false

		Self.defaultSaucerDelay=50
		Self.defaultRockDelay=50
		Self.rocketDistance = 40
		Self.rockSpeed = 0.6

		'select a world color
		Self.r:Int = Rand(75,200)
		Self.g:Int = Rand(75,200)
		Self.b:Int = Rand(75,200)

		Self.ResetArea()
	EndMethod


	Method ResetArea()
		Self.scrolling=true
		Self.tilesCreated = 0

		FlushKeys()

		'get rid of old map objects
		For Local e:TImageEntity = EachIn objectsList
			RemoveEntity(e)
		Next
		objectsList.Clear()

		'get rid of old tiles
		If Self.tile1 Then RemoveEntity(Self.tile1)
		if Self.tile2 then RemoveEntity(Self.tile2)

		'create first tile in this area. always index 0
		'no objects
		Self.tile1 = New TTile
		Self.tile1.SetPosition( 0, 0 )
		Self.tile1.SetImage(tiles[1])
		AddEntity(Self.tile1, LAYER_BACKDROP, "enemies" )

		Local newtile:Int = Self.SelectNewTile()
		Self.tile2 = new TTile
		Self.tile2.SetPosition( RESX, 0 )
		Self.tile2.SetImage(tiles[newtile])
		AddEntity(Self.tile2, LAYER_BACKDROP, "enemies" )
		'create objects on this tile.
		CreateMapObjects(newtile)

		objectsList.AddLast(tile1)
		objectsList.AddLast(tile2)
		Self.tile1.SetColor(Self.r, Self.g, Self.b)
		Self.tile2.SetColor(Self.r, Self.g, Self.b)
	End Method


	Method GotoNextLevel()

		PlayGameSound( "jingle", "sounds", 0.75 )

		'reset world
		self.area=Self.AREA_HILLS
		self.tilesCreated=0
		self.baseDestroyed=false

		'new color
		Self.r:Int = Rand(75,200)
		Self.g:Int = Rand(75,200)
		Self.b:Int = Rand(75,200)
		Self.tile1.SetColor(Self.r, Self.g, Self.b)
		Self.tile2.SetColor(Self.r, Self.g, Self.b)

		'get rid of already created base
		For Local e:TBase = EachIn self.objectsList
			Self.RemoveObject(e)
		Next

		'increase difficulty
		Self.rocketDistance:-5
		if Self.rocketDistance < 25 then Self.rocketDistance=25

		Self.defaultSaucerDelay:-5
		if Self.defaultSaucerDelay < 35 then Self.defaultSaucerDelay=35

		Self.rockSpeed:+0.1
		if Self.rockSpeed >1.0 then Self.rockSpeed=1.0

		G_PLAYER.fuel = G_PLAYER.MAXFUEL
		G_PLAYER.fuelTake:+0.0001
		if G_PLAYER.fuelTake > 0.0007 then G_PLAYER.fuelTake = 0.0007

	End method


	'selects and returns a tile index according to current area
	Method SelectNewTile:Int()
		Self.tilesCreated:+1

		'go to next area?
		If Self.tilesCreated > Self.AREA_MAXTILES
			Self.area:+1

			'stay in base area, unless base is destroyed
			if self.area > Self.AREA_BASE
				if not self.baseDestroyed
					self.area=Self.AREA_BASE
				Else
					Self.GotoNextLevel()
				endif
			endif

			'do not show base area when in attractmode
			If Self.attractMode = True And Self.area = Self.AREA_BASE
				Self.area = Self.AREA_HILLS
			EndIf

			Self.tilesCreated=0
		EndIf

		Select Self.area
			Case Self.AREA_HILLS	Return Rand(0,2)
			Case Self.AREA_SAUCERS	Return Rand(3,4)
			Case Self.AREA_ROCKS	Return Rand(0,2)
			Case Self.AREA_CITY		Return Rand(5,6)
			Case Self.AREA_MAZE		Return Rand(7,9)
			Case Self.AREA_BASE		Return 10
		EndSelect
	EndMethod


	Method Update()
		if not self.scrolling then return

		if self.baseDestroyed then Self.GotoNextLevel()

		'move all objects in the object list
		For Local e:TImageEntity = EachIn self.objectsList
			MoveEntity( e, -self.SCROLL_SPEED, 0 )
		Next

		'check if tile1 has moved out of the screen
		If EntityX(Self.tile1) = -RESX
			SetEntityPosition( Self.tile1, RESX, 0 )
			Local newtile1:Int = Self.SelectNewTile()
			Self.tile1.SetImage(Self.tiles[newtile1])
			Self.CreateMapObjects(newtile1)
		EndIf

		'and tile 2
		if EntityX(Self.tile2) = -RESX
			SetEntityPosition( Self.tile2, RESX, 0 )
			Local newtile2:Int = Self.SelectNewTile()
			Self.tile2.SetImage(Self.tiles[newtile2])
			Self.CreateMapObjects(newtile2)
		endif

		'generate saucers
		if self.area = Self.AREA_SAUCERS
			Self.saucerDelay:-1
			if Self.saucerDelay < 0
				Self.saucerDelay = Self.defaultSaucerDelay + Rand(-15,5)
				Self.CreateObject( Self.OBJECT_SAUCER, RESX+16, RESY/2)
			endif
		endif

		'generate rocks
		if self.area = Self.AREA_ROCKS
			Self.rockDelay:-1
			if Self.rockDelay < 0
				Self.rockDelay = Self.defaultRockDelay + rand(-30,5)
				Self.CreateObject(Self.OBJECT_ROCK, RESX+16, Rnd(8,70))
			endif
		endif

	EndMethod


	'create map objects according to tile index
	Method CreateMapObjects(index:Int)
		Select index
   			Case 0
	    	    CreateObject(Self.OBJECT_ROCKET,RESX + 124, 68)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 75, 92)
		        CreateObject(Self.OBJECT_FUEL,RESX + 59, 92)
		        CreateObject(Self.OBJECT_BOX,RESX + 12, 108)
		        CreateObject(Self.OBJECT_BOX,RESX + 28, 100)
		    Case 1
		        CreateObject(Self.OBJECT_BOX,RESX + 4, 100)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 20, 92)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 36, 100)
		        CreateObject(Self.OBJECT_FUEL,RESX + 51, 108)
		        CreateObject(Self.OBJECT_FUEL,RESX + 60, 108)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 79, 96)
		        CreateObject(Self.OBJECT_BOX,RESX + 97, 104)
		        CreateObject(Self.OBJECT_BOX,RESX + 106, 104)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 127, 92)
		        CreateObject(Self.OBJECT_BOX,RESX + 144, 100)
		        CreateObject(Self.OBJECT_FUEL,RESX + 151, 100)
			Case 2
		        CreateObject(Self.OBJECT_BOX,RESX + 20, 92)
		        CreateObject(Self.OBJECT_BOX,RESX + 36, 100)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 59, 84)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 76, 84)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 99, 68)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 107, 68)
		        CreateObject(Self.OBJECT_FUEL,RESX + 132, 84)
		        CreateObject(Self.OBJECT_FUEL,RESX + 155, 100)
		        CreateObject(Self.OBJECT_BOX,RESX + 3, 100)
		    Case 3
 		        CreateObject(Self.OBJECT_BOX,RESX + 4, 100)
		        CreateObject(Self.OBJECT_BOX,RESX + 36, 100)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 60, 84)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 75, 84)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 92, 76)
		        CreateObject(Self.OBJECT_FUEL,RESX + 19, 92)
		        CreateObject(Self.OBJECT_FUEL,RESX + 104, 76)
		        CreateObject(Self.OBJECT_FUEL,RESX + 111, 76)
		        CreateObject(Self.OBJECT_FUEL,RESX + 131, 84)
		        CreateObject(Self.OBJECT_BOX,RESX + 139, 84)
			Case 4
		        CreateObject(Self.OBJECT_BOX,RESX + 3, 100)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 19, 92)
		        CreateObject(Self.OBJECT_FUEL,RESX + 43, 108)
		        CreateObject(Self.OBJECT_FUEL,RESX + 51, 108)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 68, 100)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 92, 84)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 100, 84)
		        CreateObject(Self.OBJECT_BOX,RESX + 116, 92)
		        CreateObject(Self.OBJECT_BOX,RESX + 128, 88)
		        CreateObject(Self.OBJECT_FUEL,RESX + 143, 96)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 151, 96)
    		Case 5
		        CreateObject(Self.OBJECT_ROCKET,RESX + 4, 12)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 12, 28)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 28, 28)
		        CreateObject(Self.OBJECT_FUEL,RESX + 52, 20)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 60, 12)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 68, 28)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 76, 12)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 91, 12)
		        CreateObject(Self.OBJECT_FUEL,RESX + 100, 20)
		        CreateObject(Self.OBJECT_FUEL,RESX + 115, 20)
		        CreateObject(Self.OBJECT_FUEL,RESX + 131, 20)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 140, 28)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 148, 28)
		        CreateObject(Self.OBJECT_BOX,RESX + 156, 28)
			Case 6
		        CreateObject(Self.OBJECT_ROCKET,RESX + 4, 12)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 12, 28)
		        CreateObject(Self.OBJECT_FUEL,RESX + 28, 36)
		        CreateObject(Self.OBJECT_BOX,RESX + 36, 44)
		        CreateObject(Self.OBJECT_BOX,RESX + 44, 44)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 52, 52)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 60, 52)
		        CreateObject(Self.OBJECT_FUEL,RESX + 67, 60)
		        CreateObject(Self.OBJECT_FUEL,RESX + 84, 68)
		        CreateObject(Self.OBJECT_BOX,RESX + 91, 68)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 100, 60)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 108, 60)
		        CreateObject(Self.OBJECT_ROCKET,RESX + 124, 44)
		        CreateObject(Self.OBJECT_FUEL,RESX + 139, 36)
    		Case 7
		        CreateObject(Self.OBJECT_FUEL,RESX + 47, 44)
		        CreateObject(Self.OBJECT_FUEL,RESX + 55, 44)
		        CreateObject(Self.OBJECT_FUEL,RESX + 63, 44)
		        CreateObject(Self.OBJECT_FUEL,RESX + 87, 36)
		    Case 10
		        CreateObject(Self.OBJECT_BASE,RESX + 140,100)
	    End Select
	EndMethod


	Method CreateObject(id:Int, xpos:float, ypos:float)
		Local obj:TImageEntity
		Select id
			Case OBJECT_FUEL	obj = New TFuel
			Case OBJECT_BOX		obj = new TBox
			Case OBJECT_BASE	obj = new TBase
			case OBJECT_ROCKET	obj = new TRocket
			case OBJECT_SAUCER	obj = New TSaucer
			case OBJECT_ROCK	obj = New TRock
		EndSelect
		SetEntityPosition( obj, xpos, ypos )
		AddEntity( obj, LAYER_ENEMIES, "enemies" )
		Self.objectsList.AddLast(obj)
	EndMethod


	Method RemoveObject(e:TImageEntity)
		RemoveEntity(e)
		Self.objectsList.Remove(e)
	End method

EndType



'tile entity does not do anything by itself.
Type TTile Extends TImageEntity

	Method UpdateEntity()
	EndMethod

EndType