Boot State, responsible for settin up some Phaser features

	import { preloaderAssets } from '../assets'

	export default class Boot extends Phaser.State
		preload: () ->

Path to the Assets ...

			@load.path = 'assets/';

Adjust how many pointers are checked for input events

			@input.maxPointers = 1

			@scale.pageAlignHorizontally = true
			@scale.pageAlignVertically = true
			@scale.scaleMode = Phaser.ScaleManager.NO_SCALE

If the game canvas loses focus, keep the game loop running

			@stage.disableVisibilityChange = true
			@tweens.frameBased = false

Load the graphical assets required to show the splash-screen

			@load.pack 'preloaderAssets', null, { preloaderAssets }

		create: () ->
			@state.start 'Preloader'
