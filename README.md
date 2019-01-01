# Retaliate for the Commodore 64
Project to remake, using 6502/6510 Assembly, the space shooter game Retaliate (available on Roku & Android)

### New Year's Update: 31-December-2018
As I predicted, it took me a few months (nights and weekends) to study and be able to implement the new features I planned for the game. I managed to incorporate a multiplex/sort routine that allowed increase the number of sprites on the screen, increasing the number of alien enemies and making the usability closer to the original game. I also added the destroyer alien (from the Android version) and a new concept of an Asteroid Field, as a tribute to the classic Arcade game, in order to explode an asteroid you need to hit it 3 times with a bullet (and it decreases in size) or hit with a missle collected from the destroyer. The game now is also translated to Portuguese (my native language) and Spanish.

Now, exactly one year after this repository was launched, I'm happy to announce that I partnered with [RGCD](http://www.rgcd.co.uk) to make a physical release of Retaliate for Commodore 64!

We managed to have great people involved including [Richard Bayliss](http://tnd64.unikat.sk/) (music) and [Trevor Storey](http://smilastorey.wixsite.com/trevor-storey) (graphics). The "community edition" source-code will be released here, the same day the physical release, the only difference will be the graphics, for the community edition I will keep my own sprites.

Check the teaser video below for a quick preview!

[![Release Teaser](https://lvcabral.com/images/c64/youtube-player.jpg)](https://www.youtube.com/watch?v=rxUQ07g1_1w)

## Introduction
After developing remakes of classic 8bit games (Prince of Persia, Lode Runner, Donkey Kong, Moon Patrol) to the Roku platform (streaming box/TV OS)
I decided to work the other way around, this time, developing for the [Commodore 64 computer](https://en.wikipedia.org/wiki/Commodore_64) a version of one of the most successful games for Roku, the arcade-style 
space shooter [Retaliate](https://channelstore.roku.com/details/53540/retaliate).

![Retaliate Screens](http://lvcabral.com/images/C64/retaliate03-500x420.gif)

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
the book (shared with no licensing restrictions). So, be aware that this is my first attempt on creating a game 
for the Commodore 64, and still is an ongoing project, this way, as I learn more, new features will be implemented.
If you found bugs or have any suggestions please go on and report those at the [Issues Backlog](https://github.com/lvcabral/retaliate64/issues), 
and If you also want to collaborate with the game, fork the project and send your pull requests!

I'm also adding techincal documentation (memory map etc.) on the [Wiki page of the project](https://github.com/lvcabral/retaliate64/wiki).

### Features
My main goal is to implement the functionality to reproduce (as much as possible) the original game mechanics and graphics. 
You can see below a comparison of the ship sprites I created, based on the original Roku game.

![Player Ship Models](http://lvcabral.com/images/C64/retaliate-ships-comparison.png)

The current release (v0.3) is the last public Beta version and it brings a SID music during the game play, bug fixes, additional screen and settings.

Open the [Changelog](https://github.com/lvcabral/retaliate64/blob/master/CHANGELOG.md) to check all the currently implemented features.

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
3.	Download and install CBM .prg Studio (v3.12 or newer)
4.	Open CBM .prg Studio and configure VICE location
5.	Open project file retaliate.cbmprj
6.	Press CTRL+F5 (build project and execute)

![Retaliate Gameplay](http://lvcabral.com/images/C64/retaliate64-beta-gameplay-300px.gif)

## Resources Used
These are the books, music, tools and websites that are helping me to develop this project:

- [Retro Game Dev: Book by Derek Morris](https://www.retrogamedev.com/)
- [Romans I XVI Gaming: Original game developer](https://www.romansixvigaming.com/)
- [Retaliate for Roku: Open Source Repo](https://github.com/Romans-I-XVI/Roku-Retaliate-Channel-Open-Source)
- [Music "Scout" by Jeroen Tel](http://csdb.dk/sid/?id=28205)
- [VICE: Versatile Commodore Emulator](http://vice-emu.sourceforge.net/)
- [CBM .prg Studio: IDE by Arthur Jordison](http://www.ajordison.co.uk/)
- [Project One: Graphic editor by Resource](http://p1.untergrund.net/)
- [Codebase64: C64 Programming Wiki](http://codebase64.org/)
- [6502.org: The microprocessor resource](http://www.6502.org)
- [Dustlayer: Blog with C64 Tutorials by @actraiser](http://dustlayer.com/)
- [Commodore 64 Resources by Peter Kofler](http://kofler.dot.at/c64/)

## My Other Ports/Remakes

- Prince of Persia for Roku: [Video](https://www.youtube.com/watch?v=gFOKxBuw66o&t=1s) - [Repo](https://github.com/lvcabral/Prince-of-Persia-Roku)
- Lode Runner for Roku: [Video](https://www.youtube.com/watch?v=PizGMcdjIqQ&t=17s) - [Repo](https://github.com/lvcabral/Lode-Runner-Roku)
- Donkey Kong for Roku: [Video](https://www.youtube.com/watch?v=NA59qZk7fQU) - Repo was taken down by Nintendo
- Moon Patrol for Roku: [Video](https://www.youtube.com/watch?v=JNLBkOXiTQU) - [Repo](https://github.com/lvcabral/Moon-Patrol-Roku)
