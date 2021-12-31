# Project Timeline

## Project Release: December 2017
I started studying 6502 assembly to work on [my port of Prince of Persia](https://github.com/lvcabral/Prince-of-Persia-Roku), but at that time, the focus was just to understand pieces of the logic. As I own a Commodore 64 since 2015, I wanted to start a project for it, but always found too complex to start from scratch.

This changed when I came across the book called "[Retro Game Dev - C64 Edition](http://amzn.to/2Dbftp7)" by Derek Morris, with his simple approach, I got the motivation and some code to start with, along with the right tools to simplify the work (a development IDE and ready made libraries).

The game code on this project is a learning exercise, that was implemented upon Derek's mini-shooter-game example from the book (shared with no licensing restrictions). So, be aware that this is my first attempt on creating a game for the Commodore 64, this way, as I learned more, new features were implemented. If you found bugs or have any suggestions please go on and report those at the [Issues Backlog](https://github.com/lvcabral/retaliate64/issues), 
and If you also want to collaborate with the game, fork the project and send your pull requests!

![Retaliate Screens](https://lvcabral.com/images/C64/retaliate03-500x420.gif)

My main goal was to implement the functionality to reproduce (as much as possible) the original game mechanics and graphics. 
You can see below a comparison of the ship sprites I created, based on the original Roku game.

![Player Ship Models](https://lvcabral.com/images/C64/retaliate-ships-comparison.png)

The release v0.3 (early 2018) was the last public Beta version and it introduced a SID music during the game play, bug fixes, additional screen and settings.

## Project Update: December-2018

As I predicted, it took me a few months (nights and weekends) to study and be able to implement the new features I planned for the game. I managed to incorporate a multiplex/sort routine that allowed increase the number of sprites on the screen, increasing the number of alien enemies and making the usability closer to the original game. I also added the destroyer alien (from the Android version) and a new concept of an Asteroid Field, as a tribute to the classic Arcade game, in order to explode an asteroid you need to hit it 3 times with a bullet (and it decreases in size) or hit with a missle collected from the destroyer. The game now is also translated to Portuguese (my native language) and Spanish.

Exactly one year after this repository was launched, I was able to announce that I partnered with [RGCD](http://www.rgcd.co.uk) to make a physical release of Retaliate for Commodore 64! We managed to have great people involved including [Richard Bayliss](http://tnd64.unikat.sk/) (music) and [Trevor Storey](https://twitter.com/smila007) (graphics).

## Project Update: May-2019

[RGCD](http://www.rgcd.co.uk) officially announced on their website the physical release of **Retaliate DX** in cartridge! 

[![Retaliate DX](https://4.bp.blogspot.com/-iy5HdunYrIY/XN223l6rTnI/AAAAAAAANVM/r6uqa9rPjUUV6snKgu9eWMAPw7vZkhgIACLcBGAs/s480/retal1.png)](https://www.rgcd.co.uk/2019/05/retaliate-dx-commodore-64.html)

## Project Update: April-2021

After a long period of inactivity, the project was revived early in 2021. During that time, I managed to migrate the DX edition code to use [KickAssembler](http://theweb.dk/KickAssembler/) and started another wave of Beta testing, that brought several improvements to the game balance and performance. At that time the box of the game was printed and the release of the cartridge was again [teased by RGCD website](https://www.rgcd.co.uk/2021/04/coming-soon-retaliate-dx-endless-forms.html).

![RGCD Cartridge Box](https://lvcabral.com/images/C64/retaliate-dx-box-rgcd-white.png)

## Project Update: December-2021

To celebrate for years of the launch of this project, I decided to release the digital version of Retaliate DX and the full version of Retaliate CE on this repository, the cartridge and disk release will come later in 2022.

Get the DX version on the game in my itchi.io store:

[![Retaliate DX](https://lvcabral.com/images/C64/retaliate-dx-itchio-page.png)](https://lvcabral.itch.io/retaliate-dx)

