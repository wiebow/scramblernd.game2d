
'ScrambleRND, with Game2D
'(c) 2013/14 wiebo de wit

SuperStrict
Framework wdw.game2d

Include "source/scramblegame.bmx"
Include "source/titlestate.bmx"
Include "source/playstate.bmx"
Include "source/world.bmx"
Include "source/player.bmx"
Include "source/particle.bmx"
Include "source/bullet.bmx"
Include "source/bomb.bmx"
Include "source/objects.bmx"

Const RESX:Int = 160
Const RESY:Int = 120

Const LAYER_BACKDROP:Int = 0 
Const LAYER_ENEMIES:Int = 1
Const LAYER_PLAYER:Int = 2
Const LAYER_PARTICLES:Int = 3

Const STATE_TITLE:Int = 0
Const STATE_PLAY:Int = 1

Global G_WORLD:TWorld
Global G_PLAYER:TPlayer
Global G_HISCORE:Int
Global G_GAME:TScrambleGame


G_GAME = New TScrambleGame
G_GAME.Start()
