## Retaliate 64 Changelog

##### v0.3 - 03-Feb-2018 - Final Beta - SID Music
- Updated Splash bitmap to show 3 of the ship models
- Added SID music support (using [Dion Olsthoorn library](http://www.dionoidgames.com))
- Added SID music during game play ([Scout by Jeroen Tel](http://csdb.dk/sid/?id=28205))
- Implemented support for NTSC on PAL music playback
- Implemented new screen with Score Points and Game Control information
- Implemented Game Pause (using space bar)
- Added new Hangar title using sprites
- Implemented support to select ship model with joystick on Hangar
- Implemented shield activation (with joystick) on Hangar
- Added option to disable music on Hangar
- Added option to disable sfx and music during the game
- Moved difficulty level selection to Hangar and added to saved data
- Reduced number of stars to improve game performance
- Improved performance of shield gauge display routing
- Fixed shooter aliens "double round" issue on Hard mode at the end of waves
- Reorganized game memory map (see [repo Wiki](https://github.com/lvcabral/retaliate64/wiki))

##### v0.2.1 - 21-Jan-2018 - Freeze Hotfix

- Fixed bug #1 - Hangar save option (F7) freezing the game
- Fixed bug #2 - Key combination shift+C= scrambling the screen
- Compressed prg with exomizer to speedup load time

##### v0.2 - 18-Jan-2018 - Hangar Screen and Skill levels

- Added 3 Difficulty Levels (Easy, Normal, Hard)
- Added 4 new ship sprites (based on the original game)
- Implemented Hangar Screen to select ship model, ship and shield colors
- Added option to save high scores and hangar settings to disk
- Added Game Over screen with mission statistics
- Added more aliens wave configurations

##### v0.1 - 30-Dez-2017 - Initial Version

The main additions/changes to the code from the book were:

- Added a splash screen for the game
- Added the Retaliate logo (as sprites) on the Menu
- Added a intro screen with game story/instructions
- Added a credits screen
- Changed sprites of the ships to reproduce Retaliate design
- Changed aliens movement from swinging horizontally to moving down vertically
- Implemented ship-to-ship collision logic
- Limited the vertical movement of the player ship
- Implemented the shield (activated with joystick down)
- Implemented the shield energy gauge on the bottom line
- Implemented limited bullets for player, and added an Ammo counter on screen
- Implemented bullet collection feature (using the energy shield)
- Reduced to a single life for the player
- Changed score system to: 5 points killed by shield, 10 points killed by bullet

---
Original repository <https://github.com/lvcabral/retaliate64>
Copyright (C) 2017,2018 Marcelo Lv Cabral - <https://lvcabral.com>