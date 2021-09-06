@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
IF not "%1" == "" (
    GOTO :%1
)
TITLE Snake
MODE 30, 22
FOR /F %%A in ('ECHO prompt $E^| cmd') DO SET "ESC=%%A"
(CHCP 65001)>NUL

SET "mov[W]=y]-=1"
SET "mov[A]=x]-=1"
SET "mov[S]=y]+=1"
SET "mov[D]=x]+=1"
SET "snake[bou]=.0;0."
SET "skin[1]=%ESC%[38;2;105;78;148m▒$%ESC%[38;2;184;20;184m▓"
SET "skin[2]=%ESC%[38;2;235;180;52m♣$%ESC%[38;2;209;109;38m♥"
SET "skin[3]=%ESC%[38;2;212;38;61m◙$%ESC%[38;2;222;100;116m◘"
SET /A "map[width]=30", "map[height]=15", "char[0][x]=d[x]=3","char[0][y]=d[y]=3","snake[mass]=1","pel[x]=0","snake[speed]=16"

CALL :MAKEMAP %map[width]% %map[height]%

SET "exit=ECHO %ESC%[1;1H%disp[kill]%%ESC%[38;2;255;255;255m%ESC%[%map[height]%;1H%ESC%[3BOuch...Press W to Continue&(COPY NUL "%~dpn0.quit")>NUL&EXIT"
DEL "%~dpn0.quit" 2>NUL
ECHO %ESC%[?25l%ESC%[38;2;255;255;255mChoose your skin&FOR /L %%Q in (1, 1, 3) DO (
    ECHO %ESC%[B%ESC%[38;2;255;255;255m[%%Q] !skin[%%Q]:$=!!skin[%%Q]:$=!!skin[%%Q]:$=!
)
(CHOICE /C 123 /N)>NUL
FOR /F "tokens=1-2 delims=$" %%A in ("!skin[%errorlevel%]!") DO (
    SET "snake[cha][1]=%%A"&SET "snake[cha][2]=%%B"
)
SET "snake[disp]=%ESC%[%char[0][y]%;%char[0][x]%H%ESC%[38;2;184;20;184m%snake[cha][2]%"

:START
SETLOCAL
"%~F0" CONTROL >"%temp%\%~n0_signal.txt" | "%~F0" GAME <"%temp%\%~n0_signal.txt"
ENDLOCAL
GOTO :START

:GAME
FOR /L %%# in () DO (
    SET /P "input="
    SET /A "frames+=1"
    IF !pel[x]! EQU 0 (
        SET /A "pel[x]=!RANDOM! * ((%map[width]% - 1) - 2 + 1) / 32768 + 2", "pel[y]=!RANDOM! * ((%map[height]% - 1) - 2 + 1) / 32768 + 2"
        SET "pel[disp]=%ESC%[!pel[y]!;!pel[x]!H%ESC%[38;2;50;168;82m■"
    )
    IF defined input (
        FOR %%A in (!input!) DO (
            IF not "!input[cur]!" == "!mov[%%A]!" (
                SET "input[new]=1"
            )
            SET "input[cur]=!mov[%%A]!"
        )
    )
    (SET /A "1/((((~(0-(frames %% snake[speed]))>>31)&1)&((~((frames %% snake[speed])-0)>>31)&1))|input[new])" 2>NUL) && (
        SET /A "d[x]=char[0][x]","d[y]=char[0][y]","d[!input[cur]!","input[new]=0"
        IF !d[x]! LSS %map[width]% ( IF !d[x]! GTR 1 (
            IF !d[y]! LSS %map[height]% ( IF !d[y]! GTR 1 (
                SET "snake[disp]="
                SET /A "d[shift][x]=char[0][x]=d[x]","d[shift][y]=char[0][y]=d[y]"
                IF "!pel[x]!;!pel[y]!" == "!d[x]!;!d[y]!" (
                    SET /A "pel[x]=0","snake[mass]+=1"
                )
                IF !snake[mass]! NEQ 1 (
                    FOR %%Q in (".!d[x]!;!d[y]!.") DO (
                        IF not "!snake[bou]!" == "!snake[bou]:%%~Q=!" (
                            %exit%
                        )
                    )
                )
                SET "snake[bou]="
                FOR /L %%M in (1, 1, !snake[mass]!) DO (
                    SET "snake[bou]=!snake[bou]!.!char[%%M][x]!;!char[%%M][y]!"
                    SET /A "d[save][x]=char[%%M][x]","d[save][y]=char[%%M][y]", "char[%%M][x]=d[shift][x]","char[%%M][y]=d[shift][y]", "d[shift][x]=d[save][x]","d[shift][y]=d[save][y]","d[disp]=%%M %% 2"
                    IF !d[disp]! EQU 0 (
                        SET "snake[disp]=!snake[disp]!%ESC%[!char[%%M][y]!;!char[%%M][x]!H%ESC%[38;2;105;78;148m%snake[cha][1]%"
                    ) else (
                        SET "snake[disp]=!snake[disp]!%ESC%[!char[%%M][y]!;!char[%%M][x]!H%ESC%[38;2;184;20;184m%snake[cha][2]%"
                    )
                )
                SET "snake[bou]=!snake[bou]!."
            ) else (%exit%)) else (%exit%)
        ) else (%exit%)) else (%exit%)
    )
    ECHO %ESC%[2J%ESC%[1;1H%disp[map]%!pel[disp]!!snake[disp]!%ESC%[38;2;255;255;255m%ESC%[%map[height]%;1H%ESC%[BScore : !snake[mass]!%ESC%[1G%ESC%[BUse WASD to move
)

:MAKEMAP <width> <height>
SETLOCAL
SET "disp[border]="
FOR /L %%W in (1, 1, %1) DO (
    SET "disp[border]=!disp[border]!█"
)
SET /A  "width[adj]=%1 - 2","height[adj]=%2 - 1"
SET "disp[map]=%disp[border]%#%ESC%[B%ESC%[%1D%disp[border]%"
FOR /L %%H in (2, 1, %height[adj]%) DO (
    SET "disp[map]=!disp[map]:#=%ESC%[B%ESC%[%1D█%ESC%[%width[adj]%C█#!"
)
SET "disp[map]=%disp[map]:#=%"
ENDLOCAL&SET "disp[map]=%ESC%[38;2;148;194;224m%disp[map]%"&SET "disp[kill]=%ESC%[38;2;41;100;138m%disp[map]:█=X%"
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
