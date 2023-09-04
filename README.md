# Retaliate for the Commodore 64 (Community Edition)
Project to remake, in 6502 Assembly, the space shooter game Retaliate (Roku & Android) for the Commodore 64

## Introduction

After developing remakes of classic 8-bit games (see links below on this document) to the [Roku platform](https://developer.roku.com/docs/features/features-overview.md) (streaming box/TV OS) I decided to work the other way around, this time, developing for the [Commodore 64 computer](https://en.wikipedia.org/wiki/Commodore_64) a version of one of the most successful games for Roku, the arcade-style space shooter [Retaliate](https://channelstore.roku.com/details/53540/retaliate). Originally created by [Romans I XVI Gaming](https://www.romansixvigaming.com/), **Retaliate** has a unique concept, unlike the classic shooters (Space Invaders, Galaxian, Galaga) where you have infinity shooting power, here you start with no ammunition at all! However you have energy stored for a shield that, when is activated, not only can destroy the enemies but most importantly collect their ammo so you are able to RETALIATE!

## Project Information

- If you want to know more about the development of this game please take a look at the [project timeline](./docs/project.md) page.
- To see the memory map of the game check the [repository wiki](https://github.com/lvcabral/retaliate64/wiki/Memory-Map) page.
- Open the [Changelog](./CHANGELOG.md) to check the history of the source code implementation.

## Game Editions Comparison

The source code on this repository contains the **Community Edition** of the game, that has the same game engine code as the [DX edition of the game](https://lvcabral.itch.io/retaliate-dx), but with some limitations, take a look on the table below to see what are the main differences between the two editions.

<a href="https://www.youtube.com/watch?feature=player_embedded&v=Jgf1SbaIOfw" target="_blank"><img src="https://img.youtube.com/vi/Jgf1SbaIOfw/0.jpg"
alt="Retaliate DX" width="240" height="180" border="2" align="right" /></a>

| Feature            | Retaliate CE    | Retaliate DX         |
| -------------------|:---------------:|:--------------------:|
| Skill Levels       | 4               | 4                    |
| Stages per Level   | 7               | 7 + Ending Scene     |
| Player Ship Models | 1 + 4 to unlock | 1 + 4 to unlock      |
| Double cannons     | N/A             | 2 models             |         
| Enemy Ship Models  | 6               | 10                   |
| Enemy Formations   | 18              | 36                   |
| Intro Screen       | Simple          | Enhanced by Jon Eggleton |
| UI and Sprites     | Simple          | Enhanced by [@smilastorey](https://twitter.com/smila007) |
| Sound Effects      | Simple          | Enhanced by [TND](http://www.tnd64.unikat.sk/)|
| Game Music         | Main Theme      | Menu and Main Theme by [TND](http://www.tnd64.unikat.sk/)|
| Sound Effects      | Simple          | Enhanced by [TND](http://www.tnd64.unikat.sk/)|
| Localization       | en-us           | en-us, pt-br, es-es  |
| Game Control       | Joystick        | Joystick and [SNES Controller](https://texelec.com/product/snes-adapter-commodore/)|
| Easter Egg Mode    | N/A             | Unlock with joystick |
| Assembly code      | CBM .prg Studio | KickAssembler        |

If you learned from this project and want to motivate me to develop more cool stuf, head to my store and purchase [Retaliate DX](https://lvcabral.itch.io/retaliate-dx). I can guarantee you will enjoy a lot the additional features!

## How to Play the Game

You can run the game on a real Commodore 64/128 or using an emulator, below the two methods:

### Using a Commodore 64/128 with Floppy Disk or SD Card

1.	Download the latest **D64 file** from the [release page](https://github.com/lvcabral/retaliate64/releases)
2.	Save it into the media you normally use (floppy disk or SD Card) 
3.	Mount the media and turn on your computer
4.  Execute: LOAD "RETALIATE",8,1
5.	Execute: RUN

### Using a Commodore 64 Emulator

1.	Download the latest **D64 file** from the [release page](https://github.com/lvcabral/retaliate64/releases)
2.	Open [VICE x64 emulator (3.1 or newer)](http://vice-emu.sourceforge.net/)
3.	Click on menu option File->Autostart disk/tape image... 
4.  Select the D64 file

## How to Build and Run the Code (Windows only)

1.	Clone or download this Git repository
2.	Download and install [VICE Emulator](http://vice-emu.sourceforge.net/)
3.	Download and install CBM .prg Studio (v3.14 or newer)
4.	Open [CBM .prg Studio](http://www.ajordison.co.uk/) and configure VICE location
5.	Open project file retaliate.cbmprj
6.	Press CTRL+F5 (build project and execute)

## How to Build a Disk Image (Windows only)

Using [CBM .prg Studio](http://www.ajordison.co.uk/) execute the tasks:
1.	Open buildGame.asm
2.  Press CTRL+F6 (builds retaliate-ce.prg to "out" folder)
3.  Open buildLoader.asm
4.  Press F6 (builds retaliate.prg to "out" folder)
5.  Open buildDataFile.asm
6.  Press F6 (builds retdata.prg to "out" folder)
7.  Select "Open Command Line" from the Project menu
8.  Type "cd .." and ENTER to go to repository's root
9.  Execute "diskbuild.bat" (builds retaliate-ce.d64 to "release" folder)

## Resources Used

These are some of the books, tools and websites that helped me to develop this project:

- [Retro Game Dev: Book by Derek Morris](https://www.retrogamedev.com/)
- [Romans I XVI Gaming: Original game developer](https://www.romansixvigaming.com/)
- [Retaliate for Roku: Open Source Repo](https://github.com/Romans-I-XVI/Roku-Retaliate-Channel-Open-Source)
- [CBM .prg Studio: IDE by Arthur Jordison](http://www.ajordison.co.uk/)
- [VICE: Versatile Commodore Emulator](http://vice-emu.sourceforge.net/)
- [exomizer 3 by Magnus Lind](https://bitbucket.org/magli143/exomizer/wiki/Home)
- [mkd64 by Zirias](https://github.com/Zirias/c64_tool_mkd64)
- [Pixcen by John Hammarberg](https://github.com/Hammarberg/pixcen)
- [Project One: Graphic editor by Resource](http://p1.untergrund.net/)
- [The New Dimention by Richard Bayliss](http://tnd64.unikat.sk/)
- [Codebase64: C64 Programming Wiki](http://codebase64.org/)
- [6502.org: The microprocessor resource](http://www.6502.org)
- [Dustlayer: Blog with C64 Tutorials by @actraiser](http://dustlayer.com/)
- [Commodore 64 Resources by Peter Kofler](http://kofler.dot.at/c64/)
- [Mapping the Commodore 64](https://archive.org/stream/Compute_s_Mapping_the_Commodore_64)
- [Machine Language for the C64 by Jim Butterfield](https://archive.org/details/Machine_Language_for_the_Commodore_Revised_and_Expanded_Edition)

## My Other Retro Game Ports/Remakes

- Prince of Persia for Roku: [Video](https://www.youtube.com/watch?v=gFOKxBuw66o&t=1s) - [Repo](https://github.com/lvcabral/Prince-of-Persia-Roku)
- Lode Runner for Roku: [Video](https://www.youtube.com/watch?v=PizGMcdjIqQ&t=17s) - [Repo](https://github.com/lvcabral/Lode-Runner-Roku)
- Donkey Kong for Roku: [Video](https://www.youtube.com/watch?v=NA59qZk7fQU) - Repo was taken down by Nintendo
- Moon Patrol for Roku: [Video](https://www.youtube.com/watch?v=JNLBkOXiTQU) - [Repo](https://github.com/lvcabral/Moon-Patrol-Roku)

## My Other Links

- My website is [https://lvcabral.com](https://lvcabral.com)
- My twitter is [@lvcabral](https://twitter.com/lvcabral)
- My podcast is [PODebug Podcast](http://podebug.com)
- Check my other [GitHub repositories ](https://github.com/lvcabral)

## Project License

Copyright (C) 2017-2022 Marcelo Lv Cabral. All rights reserved.

Licensed under [MIT](https://github.com/lvcabral/retaliate64/blob/master/LICENSE) License.
