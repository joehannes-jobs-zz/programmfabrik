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
				title: 'Player 1 VS Randummy'
				y: 300
				offset: 65
				active: false
			}, {
				title: 'Player 1 VS DeepThought'
				y: 450
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

			window.history.pushState null, '', 'index.html'

		update: () ->
			for k, p of @players
				do (k, p) =>
					if (not p.active) and p.button.input.justOver()
						@toggleActive +k

			for k, p of @players
				do (k, p) =>
					p.ref.tint = Math.random() * 0xFFFFFF
					if p.active then @paintButton p.button, p.y, Math.random() * 0xFFFFFF, 0.5
					else @paintButton p.button, p.y

			for k, p of @players
				if p.button.input.justReleased() then @select +k
				else if  p.active and (@input.keyboard.isDown(Phaser.KeyCode.SPACEBAR) or @input.keyboard.isDown(Phaser.KeyCode.ENTER))
					@select +k

		toggleActive: (k) ->
			for key, player of @players
				if k is +key then player.active = true
				else player.active = false

		paintButton: (button, y, color = 0xFFFFFF, opacity = 0.1) ->
			button.clear()
			button.beginFill color, opacity
			button.drawRect 0, y, @world.width, 100

		select: (which = 0) ->
			if which isnt 0
				ai = which - 1
				which = 1
			p.button.inputEnabled = false for k, p of @players
			@state.start 'Game', true, false, { mode: which, ai: ai }
