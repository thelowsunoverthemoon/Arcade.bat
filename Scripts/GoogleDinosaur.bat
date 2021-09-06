@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
IF not "%1" == "" (
    GOTO :%1
)
MODE 70, 18
FOR /F %%A in ('ECHO prompt $E^| cmd') DO SET "ESC=%%A"
SET every="1/(((~(0-(frames %% #))>>31)&1)&((~((frames %% #)-0)>>31)&1))"
SET "framerate=FOR /L %%J in (1,500,1000000) DO REM"
SET "up=%ESC%[nA"
SET "dn=%ESC%[nB"
SET "bk=%ESC%[nD"
SET "nx=%ESC%[nC"
SET cactus[full]="Ã%bk:n=1%%up:n=1%´" "´%bk:n=1%%up:n=1%Ú" "Å%bk:n=1%%up:n=1%¿" "³%bk:n=1%%up:n=1%¿" "³%bk:n=1%%up:n=1%³"
SET dino[full]="Ù³%bk:n=2%%up:n=1%ÛÛ%bk:n=1%%up:n=1%Û" "³Ù%bk:n=2%%up:n=1%ÛÛ%bk:n=1%%up:n=1%Û" "³³%bk:n=2%%up:n=1%ÛÛ%bk:n=1%%up:n=1%Û"
FOR %%E in (cactus dino) DO (
    FOR %%Q in (!%%E[full]!) DO (
        SET /A "d[num]+=1"
        SET "%%E[!d[num]!]=%%~Q"
    )
    SET "d[num]="
)
SET /A "rate=1000", "dino[y]=12", "sky[col]=255"
SET "sprite=%dino[1]%"
DEL "%~dpn0.quit" 2>nul

:START
SETLOCAL
TITLE Google Dinosaur
ECHO %ESC%[?25l%ESC%[38;2;0;0;0m%ESC%[48;2;255;255;255m%ESC%[2J%ESC%[12;15H%dino[3]%%ESC%[8;26HPress any Key to Play%ESC%[12;1H
PAUSE>NUL
FOR /L %%Q in (1, 1, 70) DO (
    <NUL SET /P "=ß"
    %framerate%
)
"%~F0" CONTROL W >"%temp%\%~n0_signal.txt" | "%~F0" GAME <"%temp%\%~n0_signal.txt"
ENDLOCAL
GOTO :START

:GAME
TITLE Press W to Jump
FOR /L %%# in () DO (
    SET /P "input="
    SET /A "frames+=1"
    IF "!input!" == "W" (
        IF not defined dino[jump] (
            SET "dino[jump]=1"
        )
    )
    2>NUL SET /A !every:#=2500! && (
        IF !rate! GTR 300 (
            SET /A "rate-=10"
        )
        IF !sky[col]! EQU 255 (
            SET /A "sky[col]=255","dino[col]=0","sky[check]=-17"
        ) else (
            SET /A "sky[col]=0","dino[col]=255","sky[check]=17"
        )
    )
    2>NUL SET /A !every:#=50! && (
        SET /A "score+=1"
        IF "!sprite!" == "%dino[1]%" (
            SET "sprite=%dino[2]%"
        ) else (
            SET "sprite=%dino[1]%"
        )
    )
    2>NUL SET /A !every:#=25! && (
        IF defined sky[check] (
            SET /A "sky[col]+=!sky[check]!","dino[col]-=!sky[check]!"
            ECHO %ESC%[48;2;!sky[col]!;!sky[col]!;!sky[col]!m%ESC%[38;2;!dino[col]!;!dino[col]!;!dino[col]!m
            FOR %%Q in (255 0) DO (
                IF !sky[col]! EQU %%Q (
                    SET "sky[check]="
                )
            )
        )
        IF defined dino[jump] (
            IF !dino[jump]! EQU 7 (
                SET /A "dino[y]+=1"
                IF !dino[y]! EQU 12 (
                    SET "input="
                    SET "dino[jump]="
                )
            ) else (
                SET /A "dino[y]-=1", "dino[jump]+=1"
            )
        )
        SET "proj[disp]="
        FOR %%P in (!proj[all]!) DO (
            FOR /F "tokens=1-2 delims=$" %%A in ("!proj%%P!") DO (
                SET /A "d[num]=%%B-1"
                SET "proj%%P=%%A$!d[num]!"
                IF !d[num]! LSS 1 (
                    SET "proj%%P="
                    SET "proj[all]=!proj[all]:%%P=!"
                ) else IF !d[num]! LEQ 70 (
                    SET "proj[disp]=!proj[disp]!%ESC%[12;!d[num]!H%%A"
                    IF !d[num]! EQU 15 (
                        IF not defined dino[jump] (
                            ECHO %ESC%[8;25HOuch^^! Press W to Continue%ESC%
                            (COPY NUL "%~dpn0.quit")>NUL
                            EXIT !score!
                        )
                    )
                )

            )
        )

    )
    ECHO %ESC%[12;70H%ESC%[1J%ESC%[3;55HScore : !score!%ESC%[!dino[y]!;15H!sprite!!proj[disp]!
    FOR %%Q in (!rate!) DO (
        2>NUL SET /A !every:#=%%Q! && (
            SET /A "d[rand]=!RANDOM!*3/32768+1"
            FOR /L %%I in (1, 1, !d[rand]!) DO (
                SET /A "proj[num]+=1","d[rand]=69+%%I","d[num]=!RANDOM!*5/32768+1"
                SET "proj[all]=!proj[all]! [!proj[num]!]"
                FOR %%E in (!d[num]!) DO (
                    SET "proj[!proj[num]!]=!cactus[%%E]!$!d[rand]!"
                )
            )
        )
    )
)

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
