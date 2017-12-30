# Retaliate for the Commodore 64
Project to remake, using 6502/6510 Assembly, the space shooter game Retaliate (available on Roku & Android)

![Retaliate Screens](http://lvcabral.com/images/C64/RetaliateScreens.png)

## Introduction
After developing remakes of classic 8bit games (Prince of Persia, Lode Runner, Donkey Kong) to the Roku platform (streaming box/TV OS)
I decided to work the other way around, this time creating a version of one of the most successful games for Roku, the arcade-style 
space shooter game [Retaliate](https://channelstore.roku.com/details/53540/retaliate) to the [Commodore 64 computer](https://en.wikipedia.org/wiki/Commodore_64).

### Game Concept
Originally created by [Romans I XVI](https://www.romansixvigaming.com/) Retaliate has a unique concept, unlike the classic shooters (Space Invaders, Galaxian, Galaga)
where you have infinity ammunition, here you start with no bullets at all! However you have energy stored for a shield that, 
when is activated, not only can destroy the aliens but most importantly collect their bullets so you are able to RETALIATE!

### About the Project
I started studying 6502 assembly to work on [my port of Prince of Persia](https://github.com/lvcabral/Prince-of-Persia-Roku), but at that time, the focus was just to understand 
pieces of the logic. As I own a Commodore 64 since 2015, I wanted to start a project for it, but always found too complex to start 
from scratch.

This changed when I came across the book called "[Retro Game Dev - C64 Edition](http://amzn.to/2Dbftp7)" by Derek Morris, with his simple approach, I got the motivation 
and some code to start with, along with the right tools to simplify the work (a development IDE and ready made libraries).

The game code on this project is a learning exercise, that was implemented upon Derek's mini-shooter-game example from 
the book (shared with no licensing restrictions). So be aware that this is my first attempt on creating a game 
for the Commodore 64, and is still an ongoing project, this way, as I learn more, new features will be implemented.
If you found bugs or have any suggestions please go on and report those at the [Issues Backlog](https://github.com/lvcabral/retaliate64/issues), 
and If you also want to collaborate with the game, fork the project and send your pull requests!

### Features
With this initial release my main goal was to implement the basic funcitionality to reproduce (as much as possible) the original game mechanics and graphics.

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

### ToDo List
The current planned improvements are listed below:

- Multiplex sprites to have bigger alien waves
- 3 Difficulty Levels (Easy, Normal, Hard)
- Hangar Screen to select ship model and shield color
- Add Gameplay Background Music (any SID expert to help?)
- Improve sound effects
- Multiple high scores table with names
- Save high scores to disk

## How to Play the Game
You can run the game on a real Commodore 64/128 or using an emulator, below the two methods:

### Using a Commodore 64/128 with Floppy Disk or SD Card

1.	Download the latest D64 file from the [release page](https://github.com/lvcabral/retaliate64/releases)
2.	Save it into the media you need (floppy disk or SD Card) 
3.	Mount the media and turn on your computer
4.  Execute: LOAD "RETALIATE",8,1
5.	Execute: RUN

### Using a Commodore 64 Emulator

1.	Download the latest D64 file from the [release page](https://github.com/lvcabral/retaliate64/releases)
2.	Open VICE x64 emulator
3.	Click on menu option File->Autostart disk/tape image... 
4.  Select the D64 file

## Build and Test

1.	Download the repository
2.	Download and install VICE Emulator
3.	Download and install CBM Prg Studio
4.	Open CBM Prg Studio and configure VICE location
5.	Open project file retaliate.cbmprj
6.	Press CTRL+F5 (build project and execute)

## Resources Used
These are the books, tools and websites that are helping me developing this project:

- [Retro Game Dev: Book by Derek Morris](https://www.retrogamedev.com/)
- [Romans I XVI Gaming: Original game developer](https://www.romansixvigaming.com/)
- [Retaliate for Roku: Open Source Repo](https://github.com/Romans-I-XVI/Roku-Retaliate-Channel-Open-Source)
- [VICE: Versatile Commodore Emulator](http://vice-emu.sourceforge.net/)
- [CBM Prg Studio: IDE by  Arthur Jordison](http://www.ajordison.co.uk/)
- [Project One: Graphic editor by Resource](http://p1.untergrund.net/)
- [Codebase64: C64 Programming Wiki](http://codebase64.org/)
- [6502.org: The microprocessor resource](http://www.6502.org)
- [Dustlayer: Blog with C64 Tutorials by @actraiser](http://dustlayer.com/)
- [Commodore 64 Resources by Peter Kofler](http://kofler.dot.at/c64/)

## My Other Ports/Remakes

- Prince of Persia for Roku: [Video](https://www.youtube.com/watch?v=gFOKxBuw66o&t=1s) - [Repo](https://github.com/lvcabral/Prince-of-Persia-Roku)
- Lode Runner for Roku: [Video](https://www.youtube.com/watch?v=PizGMcdjIqQ&t=17s) - [Repo](https://github.com/lvcabral/Lode-Runner-Roku)
- Donkey Kong for Roku: [Video](https://www.youtube.com/watch?v=NA59qZk7fQU) - Repo was taken down by Nintendo
- Moon Patrol for Roku: [Video](https://www.youtube.com/watch?v=JNLBkOXiTQU) - Repo not available yet
