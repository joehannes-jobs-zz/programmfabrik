Main Game State

	export default class Game extends Phaser.State
		init: (opts) ->

This is the obj where all the moved sprites will be stored

			@itemStack = []

Single player or multi player??

			if opts.mode is 0 then @mode = 'MULTI'
			else if opts.mode is 1
				@mode = 'SINGLE'
				@intelligence = opts.ai ? 0

The State Obj

			if opts.players then @players = opts.players
			else @players = [{ val: [], active: true, valItem: 'x' }, { val: [], active: false, valItem: 'o' }]

Push the initial State to the Browser History

			window.onpopstate = (event) =>
				if event.state is null then @state.start 'Mode'
				else
					@shutdown()
					@state.start @state.current, true, false, {
						mode: event.state.mode
						ai: event.state.intel
						players: event.state.players
					}

Listen on Mouse Pointer Event LeftClick

			@input.enabled = true
			@input.mousePointer.leftButton.onUp.add @gameMove, @

		create: () ->

Paint Game Reset Button

			@resetButton = @add.graphics()
			@resetButton.inputEnabled = true
			@paintResetButton @resetButton
			@rBT = {}
			@rBT.font = @add.retroFont 'knight3', 31, 25, Phaser.RetroFont.TEXT_SET6, 10, 1, 1
			@rBT.font.text = 'Reset Game'
			@rBT.ref = @add.image @world.centerX, 50, @rBT.font
			@rBT.ref.anchor.set 0.5, 1
			@paintResetButtonText @rBT

Just a special var for the nr of play fields

			@range = [1..9]

Create the actual gameboard

			@createBoard()

Create separate sprites for the mouseover/intersection/collision-detection

			@hitAreas = @createHitAreas()

Manual says that's a good idea if you're using a tilemap

			@physics.startSystem Phaser.Physics.ARCADE

That's the game stone for the active player

			for k, p of @players
				do (k, p) =>
					console.log p
					@attachValueItem p if p.active

Finally, repaint if history was called via back button

			for k, p of @players
				for _k, item of p.val
					temp = { valItem: p.valItem }
					@attachValueItem temp
					@paintItem item, k, temp

		update: () ->
			@paintPlayerWon()
			@paintResetButtonText @rBT
			@resetButtonHandling()
			if @atomicBusy or @gameStopped then return
			@atomicBusy = true
			for k, p of @players
				do (k, p) =>
				if p.active is true
					if +k is 1 and @mode is 'SINGLE' then @intelligentMove @intelligence
					else @makeUpdate p
			@atomicBusy = false

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

		intelligentMove: (ai) ->
			if ai > 0
				if ai == 1
					@weighedMove()
				else if ai == 2
					@perfectMove()
			else @hogusBogusMove()

		hogusBogusMove: () ->
			hb = @rnd.between(1, 9)
			if hb in @players[0].val or hb in @players[1].val
				return @hogusBogusMove()
			else
				@paintItem hb
				return @gameMoveConcrete @players[1], 1, hb

		weighedMove: () ->
			preferred = [[5],[1,3,9,7],[2,6,8,4]];
			possibleWins = [[1,2,3], [4,5,6], [7,8,9], [1,4,7], [2,5,8], [3,6,9], [1,5,9], [3,5,7]]
			winStrategy = []
			protectStrategy = []
			#proceedStrategy = []
			for k, strategy of possibleWins
				do (k, strategy) =>
					matchesP = 0
					matchesW = 0
					sP = strategy.filter (el, i, arr) => not (el in @players[0].val)
					sW = strategy.filter (el, i, arr) => not (el in @players[0].val)
					if sP.length is 1
						for _k, val of @players[1].val
							if val in sP then matchesP++
					if sW.length is 3
						for _k, val of @players[1].val
							if val in strategy then matchesW++
					if matchesP is 0 and sP.length is 1 then protectStrategy.push strategy
					if matchesW is 2 then winStrategy.push strategy
					#else if matches is 1 then proceedStrategy.push strategy
			if winStrategy.length
				console.log 'win'
				console.log winStrategy.toString()
				victory = winStrategy[@rnd.between 0, winStrategy.length - 1]
				for k, val of @players[1].val
					for _k, _val of victory
						if _val == val then victory.splice _k, 1
				@paintItem victory[0]
				return @gameMoveConcrete @players[1], 1, victory[0]
			if protectStrategy.length
				console.log 'protect'
				console.log protectStrategy.toString()
				protect = protectStrategy[@rnd.between 0, protectStrategy.length - 1]
				for k, val of @players[0].val
					for _k, _val of protect
						if _val == val then protect.splice _k, 1
				@paintItem protect[0]
				return @gameMoveConcrete @players[1], 1, protect[0]
			console.log 'smart'
			vals = [].concat @players[0].val, @players[1].val
			for k, p of preferred
				for _k, _p of p
					if not (_p in vals)
						console.log _p
						@paintItem _p
						return @gameMoveConcrete @players[1], 1, _p

		perfectMove: () ->

		paintItem: (hb, k = 1, temp) ->
			if hb % 3 is 1 then x = -80
			if hb % 3 is 2 then x = -30
			if hb % 3 is 0 then x = 40
			if hb < 4 then y = -80
			else if hb < 7 then y = -22
			else y = 42
			if temp then temp.item.alpha = 1
			(temp or @players[k]).item.position.set @world.centerX + x, @world.centerY + y

Stick the gamestone to the mouse --
or drop it in place and switch players

		makeUpdate: (p) ->
			x = @input.x - 32
			y = @input.y - 32
			p.item.position.set x, y
			field = @detectValidField p.item
			if field > 0 then p.item.alpha = 1
			else p.item.alpha = 0.5

		toggleActive: () ->
			for k, p of @players
				do (k, p) =>
					if p.active is false
						@attachValueItem p
						p.active = true
					else
						p.active = false

		gameMove: () ->
			for k, p of @players
				do (k, p) =>
					if p.active and (validField = @detectValidField p.item) > 0
						@gameMoveConcrete p, k, validField

		gameMoveConcrete: (p, k, validField) ->
			p.val.push validField
			p.item.alpha = 1
			if @gameHasWinner k
				@resetPlayer k
				@gameWon k
			else if @gameIsDraw()
				@resetPlayer k
				@gameWon -1
			else
				@resetPlayer k
				@toggleActive()
			if (@mode is 'MULTI') or (+k is 0)
				console.log 'pushHistory'
				@pushHistory()

		gameHasWinner: (k) ->
			p = @players[k]
			if p.active and
			(1 in p.val and 2 in p.val and 3 in p.val) or
			(4 in p.val and 5 in p.val and 6 in p.val) or
			(7 in p.val and 8 in p.val and 9 in p.val) or
			(1 in p.val and 5 in p.val and 9 in p.val) or
			(3 in p.val and 5 in p.val and 7 in p.val) or
			(1 in p.val and 4 in p.val and 7 in p.val) or
			(2 in p.val and 5 in p.val and 8 in p.val) or
			(3 in p.val and 6 in p.val and 9 in p.val)
				true
			else false

		gameIsDraw: () ->
			moves = 0
			(moves += p.val.length) for k, p of @players
			if moves > 8 then true
			else false

		gameWon: (k) ->
			@gameStopped = true
			@input.mousePointer.leftButton.onUp.removeAll @

			@w = {}
			@w.font = @add.retroFont 'knight3', 31, 25, Phaser.RetroFont.TEXT_SET6, 10, 1, 1
			if k > -1
				@w.font.text = 'Player ' + @players[k].valItem + ' won!!!'
			else @w.font.text = 'DRAW!!!'
			@w.ref = @add.image @world.centerX, 700, @w.font
			@w.ref.tint = Math.random() * 0xFFFFFF
			@w.ref.anchor.set 0.5, 1

			true

		paintPlayerWon: () ->
			@w?.ref.tint = Math.random() * 0xFFFFFF

Attach a new gamestone to the mouse

		attachValueItem: (p) ->
			x = -32 + (@input.x ? 32)
			y = -32 + (@input.y ? 32)
			p.item = @add.sprite x, y, p.valItem
			p.item.alpha = .5

Collision detection - is the gamestone over a valid field --
can we drop it if the user clicks?

		detectValidField: (spriteA) ->
			boundsA = spriteA.getBounds()

			for k, sprite of @hitAreas
				boundsB = sprite.getBounds()
				if Phaser.Rectangle.intersects(boundsA, boundsB)
					vals = @players[0].val.concat @players[1].val
					for _k, p of @players
						return +k + 1 unless (+k + 1) in vals
			0

		resetPlayer: (k) ->
			@itemStack.push @players[k].item
			@players[k] =
				val: @players[k].val
				active: @players[k].active
				valItem: @players[k].valItem

		paintResetButton: (button, y = 0, color = 0xFFFFFF, opacity = 0.3) ->
			button.clear()
			button.beginFill color, opacity
			button.drawRect 0, y, @world.width, 70

		paintResetButtonText: (rBT) ->
			rBT.ref.tint = Math.random() * 0xFFFFFF

		resetGame: () ->
			@state.start 'Mode'

		resetButtonHandling: () ->
			@resetGame() if @resetButton.input.justReleased()

		shutdown: () ->
			@resetPlayer i for i, p of @players
			for k, sprite of @itemStack
				sprite?.destroy()

			@resetButton = null
			@rBT = null
			@w = null
			@input.mousePointer.leftButton.onUp.removeAll @
			@atomicBusy = false
			@gameStopped = false

		pushHistory: () ->
			players = for k, p of @players
				val: p.val
				active: p.active
				valItem: p.valItem
			window.history.pushState { players: players, mode: @mode, intel: @intelligence }, '', 'index.html'
