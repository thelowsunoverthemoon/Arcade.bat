<!-- : Begin batch script
:: create files beforehand so no cant find file bug
:: multiline SET /A
:: make sure function paramters if have

:: normal, conehead, buckethead
:: 3 levels
:: music
:: end and victory screens
:: menu

@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
IF not "%1" == "" (
    GOTO :%1
)

CALL :PRELUDE

(START /B "" %0 RENDERER) < "%TEMP%\%~n0_sig_render.txt"
"%~F0" CONTROL > "%TEMP%\%~n0_sig.txt" | "%~F0" GAME < "%TEMP%\%~n0_sig.txt" > "%TEMP%\%~n0_sig_render.txt"

EXIT /B

:GAME
FOR /F %%A in ('ECHO PROMPT $E ^| CMD') DO SET "\e=%%A"

CALL :CREATE_TILE_MAPPING

CALL :SET_WAVES 1

SET "peashoot.every=50"
SET /A "zombie.every.0=38", "zombie.eat.0=50", "zombie.hp.0=7"
SET /A "zombie.every.1=30", "zombie.eat.1=50", "zombie.hp.1=9"
SET /A "zombie.every.2=15", "zombie.eat.2=25", "zombie.hp.2=6"
SET /A "zombie.every.3=30", "zombie.eat.3=50", "zombie.hp.3=12"

SET /A "plant.cost.0=100", "plant.cost.1=50", "plant.cost.2=50"
SET /A "plant.hp.0=5", "plant.hp.1=10", "plant.hp.2=5"

SET "plants= "
SET "zombies= "
SET "plant.hit= "
SET "zombies.hit= "
SET /A "sun=50", "sun.flowers=0", "sun.every=350", "plant.select=0", "wave.cur=wave.timer=0"

FOR /F "tokens=1-4 delims=:.," %%A in ("!TIME: =0!") DO SET /A "t1=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100"

FOR /L %%? in () DO (
    SET /P "input="
    
    FOR /F "tokens=1-4 delims=:.," %%A in ("!TIME: =0!") DO SET /A "t2=(((1%%A*60)+1%%B)*60+1%%C)*100+1%%D-36610100", "dt=t2-t1"
    IF !dt! GTR 1 (
        SET /A "t1=t2", "frame=(frame + 1) %% 0x7FFFFFFF"

        FOR %%G in (!input!) DO (
            IF 1%%G EQU +1%%G (
                SET "plant.select=!input!"
                SET "plant.msg=,plant.select=!input!"
            ) else (
                FOR %%P in (!plant.select!) DO (
                    IF !sun! GEQ !plant.cost.%%P! (
                        IF "!occ.%%G!" == "0" (
                            SET /A "sun-=plant.cost.%%P","plant.num+=1",!tile.%%G!,"occ.%%G=1"
                            SET "sun.msg=,sun=!sun!"
                            SET "plant.!plant.num!.occ=%%G"
                            SET /A "plant.!plant.num!.cur=0","plant.!plant.num!.hp=plant.hp.%%P","plant.!plant.num!.type=plant.select","plant.!plant.num!.x=!tile.x!","plant.!plant.num!.y=!tile.y!"
                            SET "plants=!plants! !plant.num! "
                            SET "plant.msg=,plant.new=!plant.num!,plant.type=%%P,plant.x=!tile.x!,plant.y=!tile.y!"
                            IF "%%P" == "2" (
                                SET /A "sun.flowers+=1"
                            )
                        )
                    )
                )

            )
            SET "input="
        )
        SET /A "sun.cur=(sun.cur + 1) %% sun.every"
        IF "!sun.cur!" == "0" (
            SET /A "sun+=25+sun.flowers*25"
            SET "sun.msg=!sun.msg!,sun=!sun!"
        )
        IF not defined wave.pending IF defined wave (
            SET /A "wave.timer+=1"
            FOR /F "tokens=1,*" %%W in ("!wave!") DO (
                FOR /F "tokens=1,* delims=;" %%D in ("%%W") DO (
                    IF !wave.timer! GEQ %%D (
                        SET "wave.timer=0"
                        SET "wave.pending=%%E"
                        SET "wave=%%X"
                    )
                )
            )
        )
        IF defined wave.pending (
            FOR /F "tokens=1,* delims=;" %%D in ("!wave.pending!") DO (
                SET "wave.pending=%%E"
                SET /A "zombie.num+=1", "zombie.y=8+(!RANDOM! %% 4)*5"
                SET /A "zombie.!zombie.num!.type=%%D","zombie.!zombie.num!.x=40","zombie.!zombie.num!.y=zombie.y","zombie.!zombie.num!.hp=zombie.hp.%%D"
                SET "zombies=!zombies! !zombie.num! "
                SET "zombie.msg=!zombie.msg!,zombie.new=!zombie.num!,zombie.type=%%D,zombie.x=40,zombie.y=!zombie.y!"
            )
        )
        IF not defined wave IF not defined wave.pending IF "!zombies!" == " " (
            SET /A "wave.cur+=1"
            IF "!wave.cur!" == "!wave.max!" (
                TITLE FINAL WAVE
            ) else (
                TITLE WAVE !wave.cur!
            )
            FOR %%Q in (!wave.cur!) DO (
                SET "wave=!wave.%%Q!"
            )
        )
        FOR %%G in (!plants!) DO (
            SET /A "plant.ext.x=plant.%%G.x+2"
            IF "!plant.%%G.type!" == "0" (
                SET /A "plant.%%G.cur=(plant.%%G.cur + 1) %% peashoot.every"
                IF "!plant.%%G.cur!" == "0" (
                    SET "proj=!proj! "!plant.%%G.y! !plant.%%G.x! #. 0 5""
                )
            )
            SET "plant.hit=!plant.hit!+[!plant.%%G.y!;!plant.%%G.x!]*%%G+[!plant.%%G.y!;!plant.ext.x!]*%%G"
        )
        
        FOR %%G in (!zombies!) DO (
            FOR /F "tokens=1-2" %%X in ("!zombie.%%G.x! !zombie.%%G.y!") DO (
                IF "!plant.hit!" == "!plant.hit:[%%Y;%%X]=!" (
                    SET /A "zombie.%%G.cur=(zombie.%%G.cur + 1) %% zombie.every.!zombie.%%G.type!","zombie.ext.x=zombie.%%G.x+1"
                    IF "!zombie.%%G.cur!" == "0" (
                        SET /A "zombie.%%G.x-=1"
                        SET "zombie.msg=!zombie.msg!,zombie.%%G.x-=1"
                    )
                    SET "zombie.msg=!zombie.msg!,zombie.%%G.mode=0"
                ) else (
                    SET /A "hit=!plant.hit:[%%Y;%%X]=1!", "zombie.%%G.eat.cur=(zombie.%%G.eat.cur + 1) %% zombie.eat.!zombie.%%G.type!"
                    SET "zombie.msg=!zombie.msg!,zombie.%%G.mode=1"
                    IF "!zombie.%%G.eat.cur!" == "0" (
                        FOR %%H in (!hit!) DO (
                            SET /A "plant.%%H.hp-=1"
                            IF !plant.%%H.hp! LEQ 0 (
                                SET "plants=!plants: %%H =!"
                                SET "occ.!plant.%%H.occ!=0"
                                SET "plant.hit=!plant.hit:[%%Y;%%X]=!"
                                SET "zombie.msg=!zombie.msg!,zombie.%%G.mode=0"
                                SET "plant.msg=!plant.msg!,plant.%%H.die=1"
                                IF "!plant.%%H.type!" == "2" (
                                    SET /A "sun.flowers-=1"
                                )
                            )
                        )
                    )
                )
            )
            SET "zombie.hit=!zombie.hit!+%%G*[!zombie.%%G.y!;!zombie.%%G.x!]+%%G*[!zombie.%%G.y!;!zombie.ext.x!]"
        )
        SET "proj.cpy=!proj!"
        SET "proj="
        SET "proj.disp= "
        FOR %%R in (!proj.cpy!) DO (
            FOR /F "tokens=1-5" %%1 in ("%%~R") DO (
                SET /A "proj.x=%%2", "chg.proj=(%%4 + 1) %% %%5"
                IF "!chg.proj!" == "0" (
                    SET /A "proj.x+=1"
                )
                FOR %%X in (!proj.x!) DO (
                    IF not "!zombie.hit!" == "!zombie.hit:[%%1;%%X]=!" (
                        SET /A hit=!zombie.hit:[%%1;%%X]=1,!
                        SET "proj.disp=!proj.disp!%\e%[38;2;146;224;167m%\e%[%%1;%%XH%\e%[2A%\e%[D\%\e%[D%\e%[B/"
                        FOR %%H in (!hit!) DO (
                            SET /A "zombie.%%H.hp-=1"
                            IF !zombie.%%H.hp! LEQ 0 (
                                SET "zombies=!zombies: %%H =!"
                                SET "zombie.hit=!zombie.hit:[%%1;%%X]=!"
                                SET "zombie.msg=!zombie.msg!,zombie.%%H.die=1"
                            )
                        )
                    ) else IF not "%%X" == "40" (
                        SET "proj.disp=!proj.disp!%\e%[%%1;%%2H%%3"
                        SET proj=!proj! "%%1 %%X %%3 !chg.proj! %%5"
                    )
                )
            )

        )
        ECHO frame=!frame!!plant.msg!!sun.msg!!zombie.msg! SET "proj.disp=!proj.disp!"
        SET "plant.msg="
        SET "sun.msg="
        SET "zombie.msg="
        SET /A "plant.hit=0", "zombie.hit=0"
    )
)

:RENDERER
CALL :MACROS

CALL :SET_PLANTS
CALL :SET_ZOMBIES
CALL :SET_HOUSE

CALL :MAKE_ANIM peashoot 5
CALL :MAKE_ANIM sunflower 12
CALL :MAKE_ANIM wallnut 30
CALL :MAKE_ANIM normal.0 25
CALL :MAKE_ANIM normal.1 25
CALL :MAKE_ANIM cone.0 25
CALL :MAKE_ANIM cone.1 25
CALL :MAKE_ANIM mad.0 15
CALL :MAKE_ANIM mad.1 15
CALL :MAKE_ANIM bucket.0 25
CALL :MAKE_ANIM bucket.1 25

CALL :MAKE_SELECT_SPRITE
CALL :MAKE_GRID_SPRITE

SET "plant.type.0=peashoot"
SET "plant.type.1=wallnut"
SET "plant.type.2=sunflower"
SET "zombie.type.0=normal"
SET "zombie.type.1=cone"
SET "zombie.type.2=mad"
SET "zombie.type.3=bucket"

SET "plants= "
SET "zombies= "
SET /A "plant.new=zombie.new=-1", "sun=50", "plant.select=0"

ECHO %\e%[?25l
FOR /L %%# in () do (
    SET /P "input="
    IF defined input (
        FOR /F "tokens=1,*" %%A in ("!input!") DO (
            SET /A %%A
            %%B
        )
        IF not "!plant.new!" == "-1" (
            FOR %%Q in (!plant.type!) DO (
                SET "plant.!plant.new!.type=!plant.type.%%Q!
            )
            SET /A "plant.!plant.new!.cur=0","plant.!plant.new!.x=plant.x","plant.!plant.new!.y=plant.y"
            SET "plants=!plants! !plant.new! "
            SET "plant.new=-1"
        )
        IF not "!zombie.new!" == "-1" (
            FOR %%Q in (!zombie.type!) DO (
                SET "zombie.!zombie.new!.type=!zombie.type.%%Q!
            )
            SET /A "zombie.!zombie.new!.cur=0","zombie.!zombie.new!.x=zombie.x","zombie.!zombie.new!.y=zombie.y","zombie.!zombie.new!.mode=0"
            SET "zombies=!zombies! !zombie.new! "
            SET "zombie.new=-1"
        )
        
        SET "plant.disp="
        FOR %%Q in (!plants!) DO (
            IF "!plant.%%Q.die!" == "1" (
                SET "plants=!plants: %%Q =!"
            ) else (
                SET /A "chg=frame %% !plant.%%Q.type!.every"
                IF "!chg!" == "0" (
                    SET /A "plant.%%Q.cur=(plant.%%Q.cur + 1) %% !plant.%%Q.type!.max"

                )
                FOR /F "tokens=1-2" %%1 in ("!plant.%%Q.type! !plant.%%Q.cur!") DO (
                    SET "plant.disp=!plant.disp!%\e%[!plant.%%Q.y!;!plant.%%Q.x!H!%%1#%%2!"
                )
            )
        )
        SET "proj.disp=!proj.disp:#=%\e%[2A%\e%[38;2;130;221;99m!"
        SET "zombie.disp="
        FOR %%Q in (!zombies!) DO (
            IF "!zombie.%%Q.die!" == "1" (
                SET "zombies=!zombies: %%Q =!"
            ) else (
                SET /A "chg=frame %% !zombie.%%Q.type!.!zombie.%%Q.mode!.every"
                IF "!chg!" == "0" (
                    SET /A "zombie.%%Q.cur=(zombie.%%Q.cur + 1) %% !zombie.%%Q.type!.!zombie.%%Q.mode!.max"
                )
                FOR /F "tokens=1-3" %%1 in ("!zombie.%%Q.type! !zombie.%%Q.cur! !zombie.%%Q.mode!") DO (
                    SET "zombie.disp=!zombie.disp!%\e%[!zombie.%%Q.y!;!zombie.%%Q.x!H!%%1.%%3#%%2!"
                )
            )
        )
        FOR %%S in (!plant.select!) DO (
            SET "sel.disp=!selbar.%%S!"
        )
        
        ECHO %\e%[2J%\e%[2;4H%col:c=255;208;72%☼ !sun!!house.disp!!sel.disp!!grid.disp!!proj.disp!!plant.disp!!zombie.disp!
        SET "input="
        
    )
)
GOTO :EOF

:MAKE_ANIM <sprite> <every>
FOR /F "tokens=*" %%G in ('SET %1#') DO (
    SET /A "%1.max+=1"
)

SET "%1.every=%2"
GOTO :EOF

:MAKE_SELECT_SPRITE
::hardcoded since only 3 plants
SET "chip.0=%bcl:c=34;74;30%%col:c=150;235;120%0 pea 100%\e%[0m"
SET "chip.1=%bcl:c=76;46;20%%col:c=222;156;96%1 nut 50%\e%[0m"
SET "chip.2=%bcl:c=100;76;18%%col:c=255;220;100%2 sun 50%\e%[0m"
SET "chips=%\e%[2;13H%chip.0%%\e%[2;24H%chip.1%%\e%[2;34H%chip.2%"
SET "box.0.on=%\e%[1;12H%col:c=236;232;210%┌─────────┐%\e%[2;12H│%\e%[2;22H│%\e%[3;12H└─────────┘"
SET "box.0.off=%\e%[1;12H%col:c=84;92;82%┌─────────┐%\e%[2;12H│%\e%[2;22H│%\e%[3;12H└─────────┘"
SET "box.1.on=%\e%[1;23H%col:c=236;232;210%┌────────┐%\e%[2;23H│%\e%[2;32H│%\e%[3;23H└────────┘"
SET "box.1.off=%\e%[1;23H%col:c=84;92;82%┌────────┐%\e%[2;23H│%\e%[2;32H│%\e%[3;23H└────────┘"
SET "box.2.on=%\e%[1;33H%col:c=236;232;210%┌────────┐%\e%[2;33H│%\e%[2;42H│%\e%[3;33H└────────┘"
SET "box.2.off=%\e%[1;33H%col:c=84;92;82%┌────────┐%\e%[2;33H│%\e%[2;42H│%\e%[3;33H└────────┘"
SET "selbar.0=%chips%%box.0.on%%box.1.off%%box.2.off%"
SET "selbar.1=%chips%%box.0.off%%box.1.on%%box.2.off%"
SET "selbar.2=%chips%%box.0.off%%box.1.off%%box.2.on%"
GOTO :EOF

:SET_WAVES <level>
IF "%1" == "1" (
    SET wave.max=2
    SET "wave.0=50;0 1000;0;0 1100;1;0 900;0;0 5;0"
    SET "wave.1=10;1;1 1100;1; 10;0;1 550;0;1 10;0;1"
    SET "wave.2=100;0;0 20;1;1 1100;1;0 5;1;1 100;1 1200;1;1 100;1;1"
)
SET "wave=%wave.0%"
TITLE WAVE 0
GOTO :EOF

:CREATE_TILE_MAPPING
SET /A "tile.x=5", "tile.y=8"
FOR %%A in (A B C D E F G H I J K L M N O P Q R S T) DO (
    IF "!tile.x!" == "30" (
        SET /A "tile.x=5", "tile.y+=5"
    )
    SET /A "tile.x+=5", "occ.%%A=0"
    SET "tile.%%A=tile.x=!tile.x!,tile.y=!tile.y!"
)
GOTO :EOF

:MAKE_GRID_SPRITE
SET "gcol.0=%col:c=56;86;50%"
SET "gcol.1=%col:c=74;110;64%"
SET /A "tile.x=5", "tile.y=8"
SET "grid.disp="
FOR %%A in (a b c d e f g h i j k l m n o p q r s t) DO (
    IF "!tile.x!" == "30" (
        SET /A "tile.x=5", "tile.y+=5"
    )
    SET /A "tile.x+=5", "gs=((tile.x/5)+(tile.y/5)) %% 2"
    FOR %%S in (!gs!) DO (
        SET "grid.disp=!grid.disp!%\e%[!tile.y!;!tile.x!H!gcol.%%S!%%A"
    )
)
GOTO :EOF

:SET_ZOMBIES
SET "normal.0#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=82;104;74%▌"
SET "normal.0#1=%col:c=46;40;36%▐▐%up:n=1%%bk:n=3%%col:c=82;62;50%▐▐▌▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=82;104;74%▌"
SET "normal.1#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▲▲%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▼▼%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=82;104;74%▌"
SET "normal.1#1=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=82;104;74%▌"

SET "cone.0#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=255;103;0%█►"
SET "cone.0#1=%col:c=46;40;36%▐▐%up:n=1%%bk:n=3%%col:c=82;62;50%▐▐▌▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=255;103;0%█►"
SET "cone.1#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▲▲%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▼▼%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=255;103;0%█►"
SET "cone.1#1=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=255;103;0%█►"

SET "mad.0#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=235;64;52%••%\e%[0m%col:c=82;104;74%┘"
SET "mad.0#1=%col:c=46;40;36%▐▐%up:n=1%%bk:n=3%%col:c=82;62;50%▐▐▌▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=235;64;52%••%\e%[0m%col:c=82;104;74%┘"
SET "mad.1#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▲▲%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▼▼%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=235;64;52%••%\e%[0m%col:c=82;104;74%┘"
SET "mad.1#1=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=235;64;52%••%\e%[0m%col:c=82;104;74%┘"

SET "bucket.0#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=194;190;190%█▌"
SET "bucket.0#1=%col:c=46;40;36%▐▐%up:n=1%%bk:n=3%%col:c=82;62;50%▐▐▌▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=194;190;190%█▌"
SET "bucket.1#0=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▲▲%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=186;177;177%▼▼%\e%[0m%col:c=82;104;74%▌%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=194;190;190%█▌"
SET "bucket.1#1=%col:c=46;40;36%▐%nx:n=1%▌%up:n=1%%bk:n=3%%col:c=82;62;50%▌█▐%up:n=1%%bk:n=3%%col:c=122;150;108%▄%col:c=66;74;92%█%col:c=122;150;108%▄%up:n=1%%bk:n=3%%bcl:c=122;150;108%%col:c=0;0;0%••%\e%[0m%col:c=194;190;190%█▌"
GOTO :EOF

:SET_HOUSE
SET "hcol.0=%col:c=198;180;142%"
SET "hcol.1=%col:c=170;152;116%"
SET "house.disp=%\e%[4;1H%col:c=158;74;52%████%col:c=108;50;36%▄%\e%[5;1H%col:c=158;74;52%██████%col:c=108;50;36%▄"
FOR /L %%R in (6, 1, 23) DO (
    SET /A "hs=%%R %% 2"
    FOR %%S in (!hs!) DO (
        SET "house.disp=!house.disp!%\e%[%%R;1H!hcol.%%S!█████%col:c=138;122;92%█"
    )
)
SET "house.disp=!house.disp!%bcl:c=90;62;40%%col:c=255;220;130%%\e%[7;3H▄▄%\e%[8;3H▀▀%\e%[12;3H▄▄%\e%[13;3H▀▀%\e%[17;3H▄▄%\e%[18;3H▀▀%\e%[0m"
SET "house.disp=!house.disp!%\e%[20;3H%col:c=112;70;42%▄▄▄%\e%[21;3H███%\e%[22;3H███%\e%[23;3H███%\e%[24;1H%col:c=96;90;82%▀▀▀▀▀▀%\e%[22;5H%bcl:c=112;70;42%%col:c=255;208;72%•%\e%[0m"
GOTO :EOF

:SET_PLANTS
SET "peashoot#0=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%│%up:n=1%%bk:n=1%%bcl:c=153;224;150%%col:c=0;0;0%•%\e%[0m%col:c=130;221;99%▄"
SET "peashoot#1=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%\%up:n=1%%bk:n=2%%bcl:c=153;224;150%%col:c=0;0;0%•%\e%[0m%col:c=130;221;99%▄"
SET "peashoot#2=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%│%up:n=1%%bk:n=1%%bcl:c=153;224;150%%col:c=0;0;0%•%\e%[0m%col:c=130;221;99%▄"
SET "peashoot#3=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%/%up:n=1%%bcl:c=153;224;150%%col:c=0;0;0%•%\e%[0m%col:c=130;221;99%▄"
SET "peashoot#4=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%│%up:n=1%%bk:n=1%%bcl:c=153;224;150%%col:c=0;0;0%-%\e%[0m%col:c=130;221;99%▄"
SET "peashoot#5=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%\%up:n=1%%bk:n=2%%bcl:c=153;224;150%%col:c=0;0;0%•%\e%[0m%col:c=130;221;99%▄"
SET "peashoot#6=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%│%up:n=1%%bk:n=1%%bcl:c=153;224;150%%col:c=0;0;0%•%\e%[0m%col:c=130;221;99%▄"
SET "peashoot#7=%col:c=130;221;99%%bk:n=1%_│_%up:n=1%%bk:n=2%/%up:n=1%%bcl:c=153;224;150%%col:c=0;0;0%•%\e%[0m%col:c=130;221;99%▄"

SET "sunflower#0=%col:c=70;140;60%%bk:n=1%_│_%up:n=1%%bk:n=3%%bcl:c=150;96;40%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=255;208;72%▄▄▄"
SET "sunflower#1=%col:c=70;140;60%%bk:n=1%_\_%up:n=1%%bk:n=4%%bcl:c=150;96;40%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=236;180;52%▄▄▄"
SET "sunflower#2=%col:c=70;140;60%%bk:n=1%_│_%up:n=1%%bk:n=3%%bcl:c=150;96;40%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=255;208;72%▄▄▄"
SET "sunflower#3=%col:c=70;140;60%%bk:n=1%_/_%up:n=1%%bk:n=2%%bcl:c=150;96;40%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=236;180;52%▄▄▄"
SET "sunflower#4=%col:c=70;140;60%%bk:n=1%_│_%up:n=1%%bk:n=3%%bcl:c=150;96;40%%col:c=40;28;16%─ ─%\e%[0m%up:n=1%%bk:n=3%%col:c=255;208;72%▄▄▄"
SET "sunflower#5=%col:c=70;140;60%%bk:n=1%_\_%up:n=1%%bk:n=4%%bcl:c=150;96;40%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=236;180;52%▄▄▄"
SET "sunflower#6=%col:c=70;140;60%%bk:n=1%_│_%up:n=1%%bk:n=3%%bcl:c=150;96;40%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=255;208;72%▄▄▄"
SET "sunflower#7=%col:c=70;140;60%%bk:n=1%_/_%up:n=1%%bk:n=2%%bcl:c=150;96;40%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=236;180;52%▄▄▄"
SET "sunflower#8=%col:c=70;140;60%%bk:n=1%_│_%up:n=1%%bk:n=3%%bcl:c=170;112;48%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=255;230;120%▄▄▄"
SET "sunflower#9=%col:c=70;140;60%%bk:n=1%_│_%up:n=1%%bk:n=3%%bcl:c=190;128;56%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=255;244;180%▄▄▄%up:n=1%%bk:n=3%\%nx:n=1%/"
SET "sunflower#10=%col:c=70;140;60%%bk:n=1%_│_%up:n=1%%bk:n=3%%bcl:c=170;112;48%%col:c=40;28;16%• •%\e%[0m%up:n=1%%bk:n=3%%col:c=255;230;120%▄▄▄"

SET "wallnut#0=%bk:n=1%%bcl:c=119;63;26%%col:c=119;63;26%▀▀▀%up:n=1%%bk:n=3%%col:c=0;0;0%○%col:c=119;63;26%█%col:c=0;0;0%○%up:n=1%%bk:n=3%%\e%[0m%col:c=119;63;26%▐█▌"
SET "wallnut#1=%bk:n=1%%bcl:c=119;63;26%%col:c=119;63;26%▀▀▀%up:n=1%%bk:n=3%%col:c=0;0;0%○%col:c=119;63;26%█%col:c=0;0;0%○%up:n=1%%bk:n=3%%\e%[0m%col:c=119;63;26%▐█▌"
SET "wallnut#2=%bk:n=1%%bcl:c=119;63;26%%col:c=119;63;26%▀▀▀%up:n=1%%bk:n=3%%col:c=0;0;0%─%col:c=119;63;26%█%col:c=0;0;0%─%up:n=1%%bk:n=3%%\e%[0m%col:c=119;63;26%▐█▌"

GOTO :EOF

:CONTROL
FOR /L %%C in () do (
    FOR /F "tokens=*" %%A in ('CHOICE /C:012ABCDEFGHIJKLMNOPQRST /N') DO (
        IF exist "%~dpn0.quit" (
            DEL /F /Q "%~dpn0.quit"
            EXIT
        )
        <NUL SET /P ".=%%A"
    )
)
GOTO :EOF

:MACROS
FOR /F %%A in ('ECHO PROMPT $E ^| CMD') DO SET "\e=%%A"
SET "col=%\e%[38;2;cm"
SET "bcl=%\e%[48;2;cm"
SET "up=%\e%[nA"
SET "dn=%\e%[nB"
SET "bk=%\e%[nD"
SET "nx=%\e%[nC"
SET "$music=(PUSHD Music & START /B CSCRIPT //NOLOGO "%~f0?.wsf" //JOB:Music type name.mp3 & POPD)>NUL"
SET "$silence=TASKKILL /F /IM CSCRIPT.exe >NUL 2>NUL"
GOTO :EOF

:PRELUDE
SET "save=Path ComSpec TEMP SystemRoot SystemDrive save"
FOR /F "tokens=1 delims==" %%A in ('SET') DO (
    IF "%save%" == "!save:%%A=!" (
        SET "%%A="
    )
)
SET "save="
MODE 45, 25
(CHCP 65001)>NUL
(DEL /F /Q "%~dpn0.quit") 2>NUL
GOTO :EOF

----- Begin wsf script --->
<package>
  <job id="Music">
    <script language="JScript">
        var player = new ActiveXObject("WMPlayer.OCX.7");
        player.URL = WScript.arguments(1);
        player.settings.volume = 100;
        player.settings.setMode("loop", WScript.arguments(0) == "Track");
        player.controls.play();
        while (player.playState !== 1) {
            WScript.Sleep(100);
        }
    </script>
  </job>
</package>