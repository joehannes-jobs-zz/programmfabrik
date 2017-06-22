#Game Entry Point

This is the game initialization routine ...

### Imports

We'll need to import the babel-polyfill

	import 'babel-polyfill'

Now let's import our configuration and game states

	import * as config from './config.litcoffee'
	import * as states from './states.litcoffee'

Kickoff!

	init = () ->
		game = new Phaser.Game config
		game.state.add key, stat for key, state of Object.entries states
		game.state.start 'Boot'

		game

Module Export ...

	export init
