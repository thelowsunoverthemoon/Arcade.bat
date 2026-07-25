<h1 align="center">Arcade.bat</h1>

<p align="center">A Collection of Arcade Games using Batch and VT100 escape sequences</p>
<p align="center">⚠️ Windows 10 only ⚠️</p>

## 🌱 Plants Vs Zombies 🌱
This one is written much better than the other ones (written over 5 years later). Was planning on doing a full fledged game, but as of right now the main system is there. However, only 1 level. See [Momodora: Lunar Glow](https://github.com/thelowsunoverthemoon/MomodoraLunarGlow) for another example of similar games. Some interesting things I did:

* Have the renderer be a separate process than the game logic. Not sure if it makes it faster but the main loop is a lot smaller. Now there are 3 processes running at once : ```RENDERER```, ```CONTROLLER```, and ```GAME```.
* I thought of a fun way to do projectile collision when you need to know who got hit (in this case, zombies) without needing a projectile loop. Assuming each zombie has an ```id```. We go thru the loop to move the zombies, and we set this variable:
```Batch
FOR %%G in (!zombies!) DO (
    // move them
    SET "zombie.hit=!zombie.hit!+%%G*[!zombie.%%G.y!;!zombie.%%G.x!]"
```
Now when we do projectile collision 
```Batch
FOR %%R in (!proj!) DO (
    // assume %%X and %%Y are projectile X and Y
    IF not "!zombie.hit!" == "!zombie.hit:[%%Y;%%X]=!" (
        SET /A hit=!zombie.hit:[%%1;%%X]=1,!
```
"Hit" will contain the id of the zombie of who got hit. So instead of having to do an additional loop making it ```O(n^2)```, this is just ```O(n)```. How it works is that an undefined variable like [2,3] becomes 0. Also, the reason I replace with "," is for the case when 2 zombies are in the same place. This way only the first zombie gets hit, since after ```,``` itll be treated as a separate expression 


## 🐍 Snake 🐍
There's been Snake done in pure Batch already [here](https://www.dostips.com/forum/viewtopic.php?t=4741) by dbenham, but I wanted to make a version that was as simple and minimal as possible. I also wanted to make a version that relied solely on VT100 escape sequences for display.

The following version of Snake in Batch is very simple, and it has non-blocking controls, pellets, ect, everything in a classic Snake game. Also, I made it so that moving in the opposite direction results in a collision, just for that extra challenge. It also has 3 "skins" you can choose from just for fun. To play, just save it in a .bat file and run. You MUST save it in UTF-8 format, or else the Unicode characters show. You can also change up the Snake Speed, but editing the ```snake[speed]``` variable. (lower number -> faster)

Original post [here](https://www.reddit.com/r/Batch/comments/k9hnxv/snake_in_pure_batch/)

## 🟡 Pacman 🟡
I did simplify a lot of the rules, but the basic game is there. Here are the major changes:

* No "ghost house"; eaten ghosts reset all at once after the powerup wears off
* Ghosts turn white after eating powerup, and turn dark blue to signal the powerup is wearing off
* Ghosts all have the same basic behavior
* No fruits

Due to the method of input used, the controls lag/miss keys sometimes. As well, it's pretty much impossible to win unless you manually adjust the speed variable to a really high number, so I didn't bother implementing a win detection. It's more of a proof of concept than anything.

The script also adjusts reg keys to use Lucida Console font instead of the default Consolas, to give it a more retro feel. If you don't want that, then just replace the first IF with

```Batch
IF not "%1" == "" (
    GOTO :%1
)
```
You MUST save it in UTF-8 encoding for the characters to display properly, and also have Windows 10 for VT100 sequences. Use WASD to move.

Original post [here](https://www.reddit.com/r/Batch/comments/lyj3i0/pacman_in_pure_batch/)

## 🐦 Flappy Bird 🐦
Depending on your computer, it may be faster or slower, but you can always change the values in the %every% macro to make it faster or slower ("every" N frame do this, so every 2 frames is faster than every 3 frames). I was too lazy to do any frame capping, but I did add some clouds and randomized bird colours just to keep it faithful to the original.

Original post [here](https://www.reddit.com/r/Batch/comments/pj3z18/flappy_bird_in_pure_batch/)

## 🦖 Google Dinosaur Game 🦖
The script has randomized cactus and the day & night mode shift from the original game. And when you're saving it into a script, save it in ANSI encoding, or the Unicode characters won't display right. Here are some screenshots of the game.

Original post [here](https://www.reddit.com/r/Batch/comments/g7hvng/google_dinosaur_game_in_batch/)
