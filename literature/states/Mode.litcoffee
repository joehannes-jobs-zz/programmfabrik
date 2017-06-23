The Mode state displays and makes available the possibility of
* single player Mode (vs. AI/Computer)
* 2 player Mode

	import { gameAssets } from '../assets'

	export default class Mode extends Phaser.State
		preload: ->
			@load.pack 'gameAssets', null, { gameAssets }
		create: ->
			for key, item of [150, 350]
				bar = @add.graphics()
				bar.beginFill 0xFFFFFF, .1
				bar.drawRect 0, item, 650, 100

Without using the retroFont we could have used CSS Styling

style = {
	font: "bold 32px Syncopate"
	fill: "#fff"
	boundsAlignH: "center"
	boundsAlignV: "middle"
}

			@players = [{
				title: 'Player 1 VS Player 2'
				y: 215
			}, {
				title: 'Player 1 VS Computer'
				y: 415
			}]

			for key, item of @players
				do (key, item) =>
					item.font = @add.retroFont 'knight3', 31, 25, Phaser.RetroFont.TEXT_SET6, 10, 1, 1
					item.font.text = item.title
					item.ref = @add.image @world.centerX, item.y, item.font
					item.ref.tint = Math.random() * 0xFFFFFF
					item.ref.anchor.set 0.5, 1

Using the webfont instead we could have written

text = @add.text 0, 0, item.title, style
text.setShadow 3, 3, 'rgba(0, 0, 0, .7)', 2
text.setTextBounds 0, item.y, 650, 100

		update: () ->
			for key, item of @players
				item.ref.tint = Math.random() * 0xFFFFFF
