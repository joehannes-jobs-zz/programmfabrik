Main Game State

	export default class Game extends Phaser.State
		init: (mode) ->
			if mode is 0 then @mode = 'MULTI'
			else if mode is 1 then @mode = 'SINGLE'
			@players = [{val: [], active: true, valItem: 'x' }, {val: [], active: false, valItem: 'o' }]

		create: () ->

Just a special var for the nr of play fields

			@range = [1..9]

Create the actual gameboard

			@createBoard()

Create separate sprites for the mouseover/intersection/collision-detection

			@hitAreas = @createHitAreas()

Manual says that's a good idea if you're using a tilemap

			@physics.startSystem Phaser.Physics.ARCADE

That's the game stone for the active player

			@attachValueItem @players[0]
			@input.enabled = true

		update: () ->
			for k, p of @players
				if p.active is true
					if k is 1 and @mode = 'SINGLE' then @intelligentMove()
					else @makeUpdate p

		createBoard: () ->
			field = 0
			data = for hogus of @range
				for bogus of @range

Since we boast of a crowd of icons watching the game (tilemap = 9x9, not the bare necessary 3x3)
We also need to double check if a tile is an actual gamefield or just an icon

					if 2 < hogus < 6 and 2 < bogus < 6 then field++

it's just an icon, a random one

					else @rnd.between(9, 35).toString()

Prepare the expected CSV format

			data.map (el) => el.join ','
			data = data.join '\n'

Create the Tilemap in the cache

			@cache.addTilemap 'dynamicMap', null, data, Phaser.Tilemap.CSV

Add the created Tilemap to our Game(-State)

			@t3Board = @add.tilemap 'dynamicMap', 64, 64
			@t3Board.addTilesetImage 'tilemap', 'tilemap', 64, 64

Create a Tile Layer and position it

			@boardLayer = @t3Board.createLayer 0, 64 * 9, 64 * 9
			@boardLayer.fixedToCamera = false
			@boardLayer.position.set @world.centerX - @boardLayer.width / 2, @world.centerY - @boardLayer.height / 2

		createHitAreas: () ->
			offsetX = @world.centerX - @boardLayer.width / 6
			offsetY = @world.centerY - @boardLayer.height / 6

			for k, r of @range
				x = y = 0
				if 3 < r < 7 then y = 1
				else if r > 6 then y = 2
				if r % 3 is 2 then x = 1
				else if r % 3 is 0 then x = 2
				@add.sprite (offsetX + x * 64 + 28), (offsetY + y * 64 + 28), 'hitarea'

The AI Algorithm

		intelligentMove: () ->
			console.log 'algorithm'
			@toggleActive()

Stick the gamestone to the mouse --
or drop it in place and switch players

		makeUpdate: (p) ->
			x = @input.x - 32
			y = @input.y - 32
			p.item.position.set x, y
			if @detectValidField(p.item) > 0
				p.item.alpha = 1
				#if @input.
			else p.item.alpha = 0.5

		toggleActive: () ->
			for k, p of @players
				p.active = !p.active
				@attachValueItem p if p.active and (k is 0 or @mode is 'MULTI')

Attach a new gamestone to the mouse

		attachValueItem: (p) ->
			p.item = @add.sprite @input.x - 32, @input.y - 32, p.valItem
			p.item.alpha = .5

Collision detection - is the gamestone over a valid field --
can we drop it if the user clicks?

		detectValidField: (spriteA) ->
			truthy = 0
			boundsA = spriteA.getBounds()

			for k, sprite of @hitAreas
				boundsB = sprite.getBounds()
				if Phaser.Rectangle.intersects boundsA, boundsB
					truthy = k + 1
					return truthy
			truthy
