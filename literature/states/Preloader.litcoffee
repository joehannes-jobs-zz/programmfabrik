Load Assets and display a splash-screen

	import { gameAssets } from '../assets'

	export default class Preloader extends Phaser.State
		preload: () ->
			@showSplashScreen()
			@load.pack 'gameAssets', null, { gameAssets }

		create: () ->
			setTimeout @state.start.bind(@state, 'Game'), 3000

		showSplashScreen: () ->
			@add.image 0, 0, 'splash-screen'

			loaderani = @add.tileSprite 275, 300, 100, 100, 'progress-bar'
			loaderani.animations.add 'spin'
			loaderani.animations.play 'spin', 32, true
