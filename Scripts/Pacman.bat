@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

IF "%1" == "" (
    >NUL REG ADD HKCU\Console\PacMan /v FaceName /t REG_SZ /d "Lucida Console" /f
    START "PacMan" "%~0" Font
    EXIT
) else IF "%1" == "Font" (
    >NUL REG DELETE HKCU\Console\PacMan /f
) else (
    GOTO :%1
)

TITLE PacMan
MODE 30, 30
(CHCP 65001)>NUL

CALL :MACROS

SET "direction=W A S D"
SET "mov[W]=y]-=1"
SET "mov[A]=x]-=1"
SET "mov[S]=y]+=1"
SET "mov[D]=x]+=1"
SET "ghost[blinky]=%col:c=255;0;0%▓"
SET "ghost[inky]=%col:c=0;255;255%▓"
SET "ghost[pinky]=%col:c=255;184;255%▓"
SET "ghost[clyde]=%col:c=255;184;82%▓"
SET "ghost[base]= inky  blinky  pinky  clyde "
SET "ghost[cur]=%ghost[base]%"
SET "map[pelbou]= "
SET "map[powerup]=.6$7..6$23..22$7..22$23."
SET map[classic]="1-19"."1-1" "19-19"."1-1" "3-4" "6-8" "12-14" "16-17" "19-19"."1-1" "19-19"."1-1" "3-4" "6-8" "12-14" "16-17" "19-19"."1-1" "19-19"."1-4" "6-8" "12-14" "16-19"."4-4" "6-6" "14-14" "16-16"."1-4" "6-6" "8-8" "12-12" "14-14" "16-19"."1-1" "8-8" "12-12" "19-19"."1-4" "6-6" "8-8" "12-12" "14-14" "16-19"."4-4" "6-6" "14-14" "16-16"."1-4" "6-8" "12-14" "16-19"."1-1" "19-19"."1-1" "3-4" "6-8" "12-14" "16-17" "19-19"."1-1" "19-19"."1-1" "3-4" "6-8" "12-14" "16-17" "19-19""1-19"."1-1" "19-19"."1-19"
SET /A "char[x]=d[x]=15","char[y]=d[y]=6", "pac[invinc]=0", "score=0"
SET /A "inky[x]=inky[st]=14", "inky[y]=14", "clyde[x]=clyde[st]=15", "clyde[y]=14", "blinky[x]=blinky[st]=15", "blinky[y]=12", "pinky[x]=pinky[st]=16", "pinky[y]=14"

CALL :CREATEMAP classic powerup

ECHO %ESC%[?25l%col:c=229;235;52%%ESC%[8;11HDIFFICULTY%ESC%[10;11H[A] EASY%ESC%[12;11H[B] NORMAL%ESC%[14;11H[C] HARD
(CHOICE /C ABC /N)>NUL
IF %errorlevel% EQU 1 (
    SET "speed=55"
) else IF %errorlevel% EQU 2 (
    SET "speed=45"
) else (
    SET "speed=35"
)

:MENU
SETLOCAL
DEL "%~dpn0.quit" 2>NUL
"%~F0" CONTROL W >"%temp%\%~n0_signal.txt" | "%~F0" GAME <"%temp%\%~n0_signal.txt"
ECHO %ESC%[25;6H[A] TO REPLAY%ESC%[26;6H[B] TO EXIT
(CHOICE /C AB /N)>NUL
IF %errorlevel% EQU 1 (
    ENDLOCAL
    GOTO :MENU
)
EXIT

:GAME
ECHO %ESC%[2J%ESC%[5;6H%pel[disp]%%ESC%[5;5H%map[disp]%%ESC%[%char[y]%;%char[x]%H%col:c=229;235;52%█
FOR /L %%Q in (3, -1, 0) DO (
    IF %%Q EQU 0 (
         ECHO %ESC%[24;13HSTART
    ) else (
         ECHO %ESC%[24;15H%%Q
    )
    FOR /L %%J in (1, 3, 1000000) DO REM
)
FOR /L %%# in () DO (
    SET /P "input="
    IF defined input (
        2>NUL SET /A !every:#=20! || (
            FOR %%A in (!input!) DO (
                SET /A "d[x]=char[x]", "d[y]=char[y]", "d[!mov[%%A]!"
                FOR %%Q in (".!d[y]!$!d[x]!.") DO (
                    IF "%map[bou]%" == "!map[bou]:%%~Q=!" (
                        IF not "!map[powerbou]:%%~Q=!" == "!map[powerbou]!" (
                            SET /A "pac[invinc]=4", "score+=50"
                            SET "map[powerbou]=!map[powerbou]:%%~Q=!"
                        ) else IF "!map[pelbou]:%%~Q=!" == "!map[pelbou]!" (
                            SET /A "score+=10"
                            SET "map[pelbou]=!map[pelbou]!%%~Q"
                        )
                        ECHO %ESC%[!char[y]!;!char[x]!H 
                        SET /A "char[!mov[%%A]!"
                    )
                )
            )
        )
    )
    2>NUL SET /A !every:#=%speed%! || (
        SET "ghost[disp]="
        IF !pac[invinc]! GTR 2 (
            SET "ghost[add]=%col:c=255;255;255%▒"
        ) else IF !pac[invinc]! GTR 0 (
            SET "ghost[add]=%col:c=10;18;148%▒"
        ) else (
            SET "ghost[add]=#"
        )
        FOR %%G in (!ghost[cur]!) DO (
            SET "ghost[dir]=N"
            SET /A "d[x]=%%G[x] - char[x]", "d[y]=%%G[y] - char[y]"
            IF !pac[invinc]! GTR 0 (
                IF !d[y]! LSS 0 (
                    SET "ghost[dir]=W"
                ) else IF !d[y]! GTR 0 (
                    SET "ghost[dir]=S"
                )
                IF "!ghost[dir]!" == "N" (
                    IF !d[x]! LSS 0 (
                        SET "ghost[dir]=A"
                    ) else IF !d[x]! GTR 0 (
                        SET "ghost[dir]=D"
                    )
                )
            ) else (
                IF !d[y]! LSS 0 (
                    SET "ghost[dir]=S"
                ) else IF !d[y]! GTR 0 (
                    SET "ghost[dir]=W"
                )
                IF "!ghost[dir]!" == "N" (
                    IF !d[x]! LSS 0 (
                        SET "ghost[dir]=D"
                    ) else IF !d[x]! GTR 0 (
                        SET "ghost[dir]=A"
                    )
                )
            )
            FOR %%A in (!ghost[dir]!) DO (
                SET /A "d[x]=%%G[x]", "d[y]=%%G[y]", "d[!mov[%%A]!"
                FOR /F "tokens=1-2" %%Q in (".!%%G[y]!$!%%G[x]!. .!d[y]!$!d[x]!.") DO (
                    IF "%map[bou]%" == "!map[bou]:%%~R=!" (
                        IF not "!map[powerbou]:%%~Q=!" == "!map[powerbou]!" (
                            SET "ghost[disp]=!ghost[disp]!%col:c=222;161;133%%ESC%[!%%G[y]!;!%%G[x]!H○"
                        ) else IF "!map[pelbou]:%%~Q=!" == "!map[pelbou]!" (
                            SET "ghost[disp]=!ghost[disp]!%col:c=222;161;133%%ESC%[!%%G[y]!;!%%G[x]!H•"
                        ) else (
                            SET "ghost[disp]=!ghost[disp]!%ESC%[!%%G[y]!;!%%G[x]!H "
                        )
                        SET /A "%%G[!mov[%%A]!"
                    ) else (
                        SET "dir[count]=0"
                        SET "dir[pos]="
                        FOR %%D in (!direction:%%A^=!) DO (
                            SET /A "d[x]=%%G[x]", "d[y]=%%G[y]", "d[!mov[%%D]!"
                            FOR %%N in (".!d[y]!$!d[x]!.") DO (
                                IF "%map[bou]%" == "!map[bou]:%%~N=!" (
                                    SET /A "dir[count]+=1"
                                    SET "dir[!dir[count]!]=%%D"
                                )
                            )
                        )
                        SET /A "dir[rand]=(!RANDOM! %% dir[count]) + 1"
                        FOR %%K in (!dir[rand]!) DO (
                            FOR %%P in (!dir[%%K]!) DO (
                                IF not "!map[powerbou]:%%~Q=!" == "!map[powerbou]!" (
                                    SET "ghost[disp]=!ghost[disp]!%col:c=222;161;133%%ESC%[!%%G[y]!;!%%G[x]!H○"
                                ) else IF "!map[pelbou]:%%~Q=!" == "!map[pelbou]!" (
                                    SET "ghost[disp]=!ghost[disp]!%col:c=222;161;133%%ESC%[!%%G[y]!;!%%G[x]!H•"
                                ) else (
                                    SET "ghost[disp]=!ghost[disp]!%ESC%[!%%G[y]!;!%%G[x]!H "
                                )
                                SET /A "%%G[!mov[%%P]!"
                            )
                        )
                    )
                )
            )
            IF "!ghost[add]!" == "#" (
                SET "ghost[disp]=!ghost[disp]!%ESC%[!%%G[y]!;!%%G[x]!H!ghost[%%G]!"
                IF "!%%G[y]!$!%%G[x]!" == "!char[y]!$!char[x]!" (
                    ECHO %ESC%[24;6HGAME OVER, PRESS [W]
                    (COPY NUL "%~dpn0.quit")>NUL
                    EXIT
                )
            ) else (
                IF "!%%G[y]!$!%%G[x]!" == "!char[y]!$!char[x]!" (
                    SET /A "%%G[y]=14", "%%G[x]=%%G[st]", "score+=200"
                    SET "ghost[cur]=!ghost[cur]: %%G =!"
                ) else (
                    SET "ghost[disp]=!ghost[disp]!%ESC%[!%%G[y]!;!%%G[x]!H!ghost[add]!"
                )
            )
        )
    )
    2>NUL SET /A !every:#=500! || (
        IF !pac[invinc]! GTR 0 (
            SET /A "pac[invinc]-=1"
            IF !pac[invinc]! EQU 0 (
                SET "ghost[cur]=!ghost[base]!"
            )
        )
    )
    2>NUL SET /A !every:#=2! && (
        SET "pac[col]=%col:c=229;235;52%"
    ) || (
        SET "pac[col]=%col:c=194;157;12%"
    )
    ECHO %ESC%[4;6H%col:c=255;255;255%!score!!pac[col]!%ESC%[!char[y]!;!char[x]!H█!ghost[disp]!
    SET /A "frame+=1"
)

:CREATEMAP <map> <powerup>
SETLOCAL
SET "map[data]=!map[%~1]!" & SET "map[count]=1"
SET map[!map[count]!]=%map[data]:.= & SET /A map[count]+=1 & SET map[!map[count]!]=%
FOR /L %%G in (1, 1, 19) DO (
    SET "pel[line]=!pel[line]!•"
)
FOR /L %%# in (1, 1, %map[count]%) DO (
    SET "pel[disp]=!pel[disp]!%pel[line]%%dn:n=1%%bk:n=19%"
    FOR %%Q in (!map[%%#]!) DO (
        FOR /F "tokens=1-2 delims=-" %%A in ("%%~Q") DO (
            SET "map[disp]=!map[disp]!%ESC%[5G%ESC%[%%AC"
            FOR /L %%P in (%%A, 1, %%B) DO (
                SET /A "d[y]=%%# + 4","d[x]=%%P + 5"
                SET "map[bou]=!map[bou]!.!d[y]!$!d[x]!"
                SET "map[disp]=!map[disp]!█"
            )
        )
    )
    SET "map[disp]=!map[disp]!%dn:n=1%%ESC%[5G"
)
FOR %%Q in (!map[%~2]:.^= !) DO (
    FOR /F "tokens=1-2 delims=$" %%A in ("%%Q") DO (
        SET "pel[disp]=!pel[disp]!%ESC%[%%A;%%BH○"
    )
)
ENDLOCAL & SET "map[disp]=%col:c=33;33;222%%map[disp]%" & SET "map[bou]=%map[bou]%." & SET "map[powerbou]=!map[%~2]!" & SET "pel[disp]=%col:c=222;161;133%%pel[disp]%"
GOTO :EOF

:CONTROL
FOR /L %%C in () do (
    FOR /F "tokens=*" %%A in ('CHOICE /C:WASD /N') DO (
        IF exist "%~dpn0.quit" (
            DEL "%~dpn0.quit"
            EXIT
        )
        <NUL SET /P ".=%%A"
    )
)
GOTO :EOF

:MACROS
FOR /F %%A in ('ECHO prompt $E^| cmd') DO SET "ESC=%%A"
SET every="1/((frame %% #)^0)"
SET "col=%ESC%[38;2;cm"
SET "up=%ESC%[nA"
SET "dn=%ESC%[nB"
SET "bk=%ESC%[nD"
SET "nx=%ESC%[nC"
GOTO :EOF
