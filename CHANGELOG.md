## Retaliate 64 - Changelog

##### v1.00 - Dec-2021 - Community Edition Release

- Mines starts to appear later in the game, however on each level it shows one stage earlier
- Reduced # of Mines per wave and on the stages with Mines these will appear only 25% of the time
- Increased the number of Full Ammo Waves on some Ship models
- Reduced the speed of Ruthless Retaliator
- Balanced the Number of times each bomb type shows up
- Reduced the number of waves per stage going from 4(Easy) to 7(Extreme)
- Reduced the speed of each stage
- Reduced overall Shield Speed on consumption and made recovery constant
- Improved Orbs boucing array to make it swing around the start position
- Shield speed changed to be based on ship model
- Renamed Bullets to Phasers on screen and made each bomb type a different color
- Changed M key to only turn the music on/off during the game not the SFX
- Final Stage now shows on Mission Stats screen and on Menu High Score Panel
- Final Stage now saved with High Score to the data file
- Fixed: Asteroids wave was randomly not moving on the X axis
- Fixed: Disabling Shift+C= keys code
- Fixed: UNLOCKALL debug switch now works when RETDATA does not exist and only unlock ships
- Fixed: Full Bullets debug switch to not be disabled when Full Ammo bomb is collected
- Updated credits screen with 2021 as release year
- Moved music and splash files to assets folder
- Several small code optimizations

##### v0.99 - Feb-2020 - New Loader DX screen

- Update version text on credits screen
- Changed alient types of "Left Stair" wave
- On disk loader menu: Added DX features screen
- On Disk Loader menu: Moved load error message one line up to avoid erasing the tip of joystick icon

##### v0.96-v0.98 - Jan-2019 to Jun-2019 - DX Improvements Merge

- Added move left and right animation frames to all player ship models
- Added animation frames to probe, shooter and asteroid sprites
- Added new Orb Probes that swings horizontally as it moves down the screen
- Added Mine Probes than needs 2 hits to be destroyed (or a missile)
- Alien Mines only starts to appear from the 5th wave of first stage
- Added new Sonar bomber that passes 3 times and launches a sonic bomb that can only be bounced by player shield
- New randomized bomb type is: 60% Missiles, 25% Sonic, 15% Full Ammo pulsar
- Bombs launched by Destroyer and Sonar now follows the player ship, as in original game
- Bombs launched by player can be guided by the ship position
- Every stage the probes changes color
- Each player ship model now has different features:
    - Lateral Speed: First two ships are normal, the other three are fast
    - Stable Shield: Sturdy Striker and Ruthless Retaliator are stable, shield don't increase speed during the game
    - # of Waves in Full Ammo: First three ships it lasts only 2 waves, the other two models the shield lasts 3 waves
- Reduced player ship hitbox for sprites and bullets when shield is down
- Shield recovery speed is now faster than consumption (similar to original game)
- Player ship fly from below the screen on start of stage
- Multiple explosions when player dies
- Implemented warp star speed on end of each stage
- Randomized the start wave to a subset of waves, instead of the constant wave zero.
- Changed the final stage to only one wave and no asteroid field
- Adjusted difficulty of the asteroid field formations
- After Game Over by winning a medal the game switches to the medal panel screen
- Added support to record several hi-scores, one per skill level
- Updated medals screen to also show the new high-scores board
- Added new screen with all alien sprites and ammo types information
- Changed one of the multicolor generic colors from LightBlue to Blue
- Removed "blue" and "brown" from the Hangar color picker and added two tones of gray
- Changed game over message to show "Good Job" only after 60 targets destroyed (minimum of 300 points)
- Moved the splash bitmap screen from the main prg to the loader menu
- Added switches for trainers and debug
- Refactored to add support to up 85 waves (but total defined waves remains 18)
- Refactored to use the new macro "mva" to directly assign values to variables
- Several optimizations and bug fixes

##### v0.90-v0.95 - Aug-2018 to Dec-2018 - Community Edition Fork

- Implemented new menu/hangar screens with joystick support (instead of keyboard)
- Changed speed of player ship, and added small intertia
- Added horizontal movement for Alien Shooters (similar to Android version)
- Besides the regular ships (probes and shooters) in some waves a Destroyer will cross the screen and launch a missile towards the player
- Missles can be collected the same way as bullets, however are launched using the Joystick up
- There are two types of missiles:
	- Regular missiles: Can destroy aliens but also asteroids with a single shot. The hit score is 15 for missiles.
	- "Full ammo" missiles: These will be launched around 20% of the times by the destroyer. It gives unlimited bullets for two waves.
- Implemented asteroid field with animation (both X & Y movement)
- 3 bullet shots are needed to destroy an asteroid but only 1 missile
- Added new menu screen with information about missiles, asteroids and the medal panel
- Updated credits screen to show additional code developers
- Implemented Stages
	- 7 stages per skill level
	- 10 alien waves randomly selected from 18 available
	- An asteroid field closes each stage. There are 2 options randomly selected.
	- Speed increases every 3 stages
- Added medal award on Game Over screen when player finishes 7 stages on every skill level
- The same way as the original game, 1000 points on each skill level are needed to unlock the other player ship models
- Added support for Localization
- Changed the normal and hard levels shield speed to better balance the game difficulty
- Removed usage of kernal keyboard routines, that caused slow down on the game with any key press
- Changed in-game sound switches to a single "mute" option
- Added "Paused Game" message on screen
- Aliens speed adjusted when PAL computer is detected
- Adjusted collision area for player ship, and now the Shield collision is a little wider
- Reorganized memory to support new sprites and screens

##### v0.4-v0.8 - Mar-2018 to Jul-2018 - Internal research and development

- Integrated sprite multiplexer (by [Cadaver](https://cadaver.github.io/)), to increase the number of sprites on screen
- Adapted new [star field routine (by Jay Aldred)](https://github.com/JasonAldred/C64-Starfield) to reduce CPU usage
- Integrated exclusive SID music (by [Richard Bayliss](http://tnd64.unikat.sk/)) based on the original game theme
- Added the Extreme skill level to match the original game
- Several performance improvements

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
Copyright (C) 2017-2022 Marcelo Lv Cabral - <https://lvcabral.com>