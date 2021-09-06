@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION
IF "%1" == "" (
    >NUL REG ADD HKCU\Console\Flappy /V FaceName /T REG_SZ /D "Lucida Console" /F
    >NUL REG ADD HKCU\Console\Flappy /V FontSize /T REG_DWORD /D 0x00180008 /F
    START "Flappy" "%~0" Font
    EXIT
) else IF "%1" == "Font" (
    >NUL REG DELETE HKCU\Console\Flappy /f
) else (
    GOTO :%1
)

MODE 30, 25
(CHCP 65001)>NUL
FOR /F %%A in ('ECHO PROMPT $E^| CMD') DO SET "ESC=%%A"
SET "up=%ESC%[nA"
SET "dn=%ESC%[nB"
SET "bk=%ESC%[nD"
SET "nx=%ESC%[nC"
SET "exit=ECHO %dn:n=1%%ESC%[48;2;55;128;128m%ESC%[38;2;212;172;87m%nx:n=4%Press W to Continue :(^&(COPY NUL "%~dpn0.quit")^>NUL^&EXIT ^!score^!"
SET "every=SET /A "d[num]=frame %% #"& IF ^!d[num]^! EQU 0"

SET col[full]="200;133;222" "203;204;124" "121;199;173"
SET bird[full]="\█" "─█" "/█"
SET "pipe[bdy]=║"
SET "pipe[top]=╥"
SET "pipe[btm]=╨"
SET "pipe[max]=%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%%pipe[bdy]%%bk:n=1%%dn:n=1%"
SET "cloud[1]=%dn:n=2%█"
SET "cloud[2]=%dn:n=1%█%dn:n=1%%bk:n=1%█"
SET "cloud[3]=█%dn:n=1%%bk:n=1%█%dn:n=1%%bk:n=1%█"
SET "cloud[4]=█%dn:n=1%%bk:n=1%█%dn:n=1%%bk:n=1%█"
SET "cloud[5]=█%dn:n=1%%bk:n=1%█%dn:n=1%%bk:n=1%█"
SET "cloud[6]=%dn:n=1%█%dn:n=1%%bk:n=1%█"
SET "cloud[7]=%dn:n=2%█"

FOR %%G in (col bird) DO (
    FOR %%B in (!%%G[full]!) DO (
        SET /A "d[num]+=1"
        SET "%%G[!d[num]!]=%%~B"
    )
    SET "d[num]=0"
)
FOR /L %%G in (1, 1, 7) DO (
    FOR /L %%Q in (%%G, 1, 7) DO (
        SET "cld[end][%%G]=!cld[end][%%G]!!cloud[%%Q]!%up:n=2%"
    )
    FOR /L %%Q in (1, 1, %%G) DO (
        SET "cld[bgn][%%G]=!cld[bgn][%%G]!!cloud[%%Q]!%up:n=2%"
    )
)
SET "bird[cur]=%bird[1]%"
SET /A "bird[frame]=0", "bird[y]=14", "frame=pipe[num]=0", "bird[rand]=(%RANDOM% %% 3) + 1", "score=0", "score[high]=0"
DEL "%~dpn0.quit" 2>NUL

:START
SETLOCAL
TITLE Flappy Bird
ECHO %ESC%[?25l%ESC%[48;2;55;128;128m%ESC%[2J%ESC%[38;2;212;172;87m%ESC%[8;11HFLAPPY BIRD%ESC%[9;9HHigh Score : !score[high]!%ESC%[11;9H[Press any Key]%ESC%[%bird[y]%;10H%ESC%[38;2;!col[%bird[rand]%]!m%bird[cur]%%ESC%[23;1H%ESC%[48;2;50;168;82m%ESC%[38;2;133;110;48m▲_▲_▲_▲_▲_▲_▲_▲_▲_▲_▲_▲_▲_▲_▲_%ESC%[0m
PAUSE>NUL
"%~F0" CONTROL W >"%temp%\%~n0_signal.txt" | "%~F0" GAME <"%temp%\%~n0_signal.txt"&SET "score=!ERRORLEVEL!"
IF %score% GTR %score[high]% (
    SET "score[high]=%score%"
)
ENDLOCAL&SET "score[high]=%score%"
GOTO :START

:GAME
TITLE Press W to Jump
FOR /L %%# in () DO (
    SET /P "input="
    IF defined input (
        SET "bird[jmp]=5"
        SET "input="
    )
    %every:#=5% (
        IF !bird[frame]! EQU 3 (
            SET "bird[frame]=1"
        ) else (
            SET /A "bird[frame]+=1"
        )
        FOR %%F in (!bird[frame]!) DO (
            SET "bird[cur]=!bird[%%F]!"
        )
    )
    %every:#=30% (
        SET "pipe[disp]="
        FOR %%P in (!pipe[list]!) DO (
            FOR /F "tokens=1-5 delims=;" %%A in ("!pipe%%P!") DO (
                IF %%C EQU 1 (
                    SET "pipe[list]=!pipe[list]:%%P=!"
                ) else (
                    IF %%C EQU 10 (
                        IF !bird[y]! LEQ %%D (
                            %exit%
                        ) else IF !bird[y]! GEQ %%E (
                            %exit%
                        )
                        SET /A "score+=1"
                        TITLE Score : !score!
                    )
                    SET "pipe[disp]=!pipe[disp]!%ESC%[1;%%CH!pipe[max]:~0,%%A!%dn:n=1%%pipe[btm]%%dn:n=5%%bk:n=1%%pipe[top]%%dn:n=1%%bk:n=1%!pipe[max]:~0,%%B!"
                    SET /A "d[num]=%%C - 1"
                    SET "pipe%%P=%%A;%%B;!d[num]!;%%D;%%E"
                )
            )
        )
    )
    %every:#=20% (
        SET "cld[disp]="
        FOR %%P in (!cld[list]!) DO (
            FOR /F "tokens=1-3 delims=;" %%A in ("!cld%%P!") DO (
                IF %%C EQU 1 (
                    SET "cld[disp]=!cld[disp]!%ESC%[%%A;%%CH"
                    SET "cld[disp]=!cld[disp]!!cld[end][%%B]!
                    SET /A "cld[adj]=%%B + 1"
                    IF !cld[adj]! EQU 8 (
                        SET "cld[list]=!cld[list]:%%P=!"
                    ) else (
                        SET "cld%%P=%%A;!cld[adj]!;%%C"
                    )
                ) else (
                    SET "cld[disp]=!cld[disp]!%ESC%[%%A;%%CH"
                    SET "cld[disp]=!cld[disp]!!cld[bgn][%%B]!
                    SET /A "d[num]=%%C - 1", "cld[adj]=%%B"
                    IF %%C GTR 23 (
                        SET /A "cld[adj]+=1"
                    ) else IF !d[num]! EQU 1 (
                        SET "cld[adj]=1"
                    )
                    SET "cld%%P=%%A;!cld[adj]!;!d[num]!"

                )
            )
        )
        IF !bird[jmp]! NEQ 0 (
            IF !bird[y]! EQU 1 (
                SET "bird[jmp]=0"
            ) else (
                SET /A "bird[jmp]-=1", "bird[y]-=1"
            )
        ) else (
            %every:#=5% (
                IF !bird[y]! NEQ 22 (
                    SET /A "bird[y]+=1"
                ) else (
                    %exit%
                )
            )
        )
    )
    %every:#=250% (
        SET /A "pipe[rand]=!RANDOM! %% 5"
        IF !pipe[rand]! EQU 0 (
            SET /A "pipe[num]+=1", "pipe[rand]=(!RANDOM! %% 15) + 1", "d[num]=(9 * pipe[rand]) - 1", "d[adj]=((21 - (pipe[rand] + 5)) * 9) - 1", "d[max]=pipe[rand] + 5"
            SET "pipe[!pipe[num]!]=!d[num]!;!d[adj]!;29;!pipe[rand]!;!d[max]!"
            SET "pipe[list]=!pipe[list]! [!pipe[num]!]"
        )
    )
    %every:#=275% (
        SET /A "cld[rand]=!RANDOM! %% 3"
        IF !cld[rand]! EQU 0 (
            SET /A "cld[num]+=1", "cld[rand]=(!RANDOM! %% 17) + 2"
            SET "cld[!cld[num]!]=!cld[rand]!;1;29"
            SET "cld[list]=!cld[list]! [!cld[num]!]"
        )
    )
    ECHO %ESC%[48;2;55;128;128m%ESC%[22;30H%ESC%[1J%ESC%[38;2;255;255;255m!cld[disp]!%ESC%[!bird[y]!;10H%ESC%[38;2;!col[%bird[rand]%]!m!bird[cur]!%ESC%[48;2;113;191;46m%ESC%[38;2;212;172;87m!pipe[disp]!%ESC%[0m
    SET /A "frame+=1"
)

:CONTROL
FOR /L %%C in () do (
    FOR /F "tokens=*" %%A in ('CHOICE /C:W /N') DO (
        IF exist "%~dpn0.quit" (
            DEL "%~dpn0.quit"
            EXIT
        )
        <NUL SET /P ".=%%A"
    )
)
GOTO :EOF
