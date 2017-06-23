Main Game State

	export default class Game extends Phaser.State
		create: () ->
			range = [1..9]
			field = 0
			data = for hogus of range
				for bogus of range
					if 2 < hogus < 6 and 2 < bogus < 6 then field++
					else @rnd.between(9, 35).toString()
			data.map (el, i, arr) => el.join ','
			data = data.join '\n'

			@cache.addTilemap 'dynamicMap', null, data, Phaser.Tilemap.CSV

			@t3Board = @add.tilemap 'dynamicMap', 64, 64
			@t3Board.addTilesetImage 'tilemap', 'tilemap', 64, 64

			@boardLayer = @t3Board.createLayer 0
			#@boardLayer.resizeWorld()
			@physics.startSystem Phaser.Physics.ARCADE

			@cursors = @input.keyboard.createCursorKeys()

		update: () ->
			if @cursors.left.isDown then game.camera.x--
			if @cursors.right.isDown then game.camera.x++
			if @cursors.up.isDown then game.camera.y--
			if @cursors.down.isDown then game.camer.y++
