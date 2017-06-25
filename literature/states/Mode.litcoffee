The Mode state displays and makes available the possibility of
* single player Mode (vs. AI/Computer)
* 2 player Mode

	import { gameAssets } from '../assets'

	export default class Mode extends Phaser.State
		preload: ->
			@load.pack 'gameAssets', null, { gameAssets }
		create: ->
			@players = [{
				title: 'Player 1 VS Player 2'
				y: 150
				offset: 65
				active: true
			}, {
				title: 'Player 1 VS Computer'
				y: 350
				offset: 65
				active: false
			}]

			for k, p of @players
				do (k, p) =>
					p.button = @add.graphics()
					p.button.inputEnabled = true
					@paintButton p.button, p.y
					p.font = @add.retroFont 'knight3', 31, 25, Phaser.RetroFont.TEXT_SET6, 10, 1, 1
					p.font.text = p.title
					p.ref = @add.image @world.centerX, p.y + p.offset, p.font
					p.ref.tint = Math.random() * 0xFFFFFF
					p.ref.anchor.set 0.5, 1

			@cursors = @input.keyboard.createCursorKeys()

			window.history.pushState null, '', 'index.html'

		update: () ->
			if @cursors.up.isDown and @players[1].active then @toggleActive()
			else if @cursors.down.isDown and @players[0].active then @toggleActive()

			for k, p of @players
				if (not p.active) and p.button.input.justOver()
					@toggleActive()

			for k, p of @players
				do (k, p) =>
					p.ref.tint = Math.random() * 0xFFFFFF
					if p.active then @paintButton p.button, p.y, Math.random() * 0xFFFFFF, 0.5
					else @paintButton p.button, p.y
			if @players[0].button.input.justReleased() then @select()
			else if @players[1].button.input.justReleased() then @select 1
			else if @input.keyboard.isDown(Phaser.KeyCode.SPACEBAR) or @input.keyboard.isDown Phaser.KeyCode.ENTER
				@select k if p.active for k, p of @players

		toggleActive: () ->
			for key, player of @players
				player.active = !player.active

		paintButton: (button, y, color = 0xFFFFFF, opacity = 0.1) ->
			button.clear()
			button.beginFill color, opacity
			button.drawRect 0, y, @world.width, 100

		select: (which = 0) ->
			p.button.inputEnabled = false for k, p of @players
			@state.start 'Game', true, false, { mode: which }
