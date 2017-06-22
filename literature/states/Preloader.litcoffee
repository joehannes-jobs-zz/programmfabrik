Load Assets and display a splash-screen

	import { gameAssets } from '../assets'

	export default class Preloader extends Phaser.State
		preload: () ->
			@showSplashScreen()
			@load.pack 'gameAssets', null, { gameAssets }

		create: () ->
			@state.start 'Game'

		showSplashScreen: () ->
			@add.image 0, 0, 'splash-screen'
			@load.setPreloadSprite @add.image 82, 282, 'progress-bar'
