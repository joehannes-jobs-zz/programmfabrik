#Game Entry Point

This is the game initialization routine ...

### Imports

We'll need to import the babel-polyfill

	import 'babel-polyfill'

Now let's import our configuration and game states

	import * as config from './config'
	import * as states from './states'

Kickoff!

	init = () ->
		game = new Phaser.Game config
		game.state.add state, states[state] for state of states
		game.state.start 'Boot'

		game

Module Export ...

	export { init }
