@ECHO OFF & CLS
CALL :Fn_Initialize %~NDP0
REM CALL :Fn_Trustlevel %~NDP0 %*

ECHO;"Hello-world"
ECHO;"こんにちは世界"
ECHO;"안녕하세요 세상"
ECHO;"你好世界"

ECHO Exitcode: %ERRORLEVEL% & PAUSE
EXIT /B %ERRORLEVEL%

::  ========[有延迟扩展变量]========
::  枚举指定文件夹-return EXITMATH DIR1-999...n
:Fn_EnumFolder
SET /A "EXITMATH=0"
FOR /L %%A IN (1, 1, %EXITMATH%) DO (SET "DIR%%A=") & (SET /A "EXITMATH=0")
FOR /F "Delims=" %%B IN ('DIR /O /B "%~1" 2^>NUL') DO (SET /A "EXITMATH+=1" & SET "DIR!EXITMATH!=%%B")
EXIT /B %ERRORLEVEL%

::  ========[无延迟扩展变量]========
::  初始化选项设置-no return
:Fn_Initialize
IF "%~1" NEQ "" (IF EXIST "%~DP1" (
    CHCP 65001
    TITLE %~N1
    PUSHD "%~DP1" & CD /D "%~DP1"
))
EXIT /B %ERRORLEVEL%

::  检查管理员身份-no return
:Fn_Trustcheck
FLTMC>NUL 2>NUL || (ECHO [ERROR] Please manually switch administrator identity permissions & PAUSE & EXIT)
EXIT /B %ERRORLEVEL%

::  管理员身份运行-no return
:Fn_Trustlevel
SET "EXITANSI="
CALL :Fn_Spiltlimit %*
VER|FINDSTR /R /I " [ 5.1.*]">NUL && GOTO :LB_TrustWinNT5
VER|FINDSTR /R /I " [ 6.1.*]">NUL && GOTO :LB_TrustWinNT6
:LB_TrustWinNT5
FLTMC>NUL 2>NUL || (MSHTA VBScript:CreateObject^("Shell.Application"^).ShellExecute^("CMD.EXE","/C %~S1 %EXITANSI%","","RUNAS",1^)^(Window.Close^) & EXIT)
ECHO [INFO]  You are trustlevel in Windows XP+
EXIT /B %ERRORLEVEL%
:LB_TrustWinNT6
FLTMC>NUL 2>NUL || (PowerShell -Command "Start-Process '%~DPNX1' ' %EXITANSI%' -Verb RunAs" & EXIT)
ECHO [INFO]  You are trustlevel in Windows 7+
EXIT /B %ERRORLEVEL%

::  判断系统的架构-return EXITANSI
:Fn_PlatformNT
SET "EXITANSI="
IF "%PROCESSOR_ARCHITECTURE%" EQU "x86" (SET "EXITANSI=x86")
IF "%PROCESSOR_ARCHITECTURE%" EQU "AMD64" (SET "EXITANSI=x64")
EXIT /B %ERRORLEVEL%

::  获取网卡设备器-return EXITNAME EXITADDR EXITMATH
:Fn_GetMacByStr
SET "EXITNAME="
SET "EXITADDR="
SET "EXITMATH="
FOR /F "Skip=1 Delims=, Tokens=1, 3*" %%A IN ('GETMAC /V /FO CSV') DO (
    IF DEFINED DEBUGMOD (ECHO [DEBUG] %%~A - %%~B)
    ECHO %%~A %%~B | FINDSTR "%~1" >NUL 2>NUL && (SET "EXITNAME=%%~A" & SET "EXITADDR=%%~B" & SET /A "EXITMATH+=1")
)
EXIT /B %ERRORLEVEL%

::  获取Netsh-Idx-return EXITMATH
:Fn_GetIdxByStr
SET "EXITMATH="
FOR /F "Skip=3 Tokens=1*" %%A IN ('NETSH INTER IPV4 SHOW INTER') DO (
    IF DEFINED DEBUGMOD (ECHO [DEBUG] %%~A - %%~B)
    ECHO %%~A %%~B | FINDSTR "%~1" >NUL 2>NUL && (SET "EXITMATH=%%~A")
)
EXIT /B %ERRORLEVEL%

::  字符串分割还原-return EXITANSI
:Fn_Spiltlimit
SET "EXITANSI="
FOR /F "Tokens=* Delims=" %%A IN ("%*") DO (
    IF "%EXITANSI%" EQU "" (SET "EXITANSI=%%~A") ELSE (
        SET "EXITANSI=%EXITANSI% %%~A"
    )
)
EXIT /B %ERRORLEVEL%

::  取指定目录数量-return EXITMATH
:Fn_GetFolders
SET /A "EXITMATH=0"
IF "%~1" NEQ "" (IF EXIST "%~1" (
    FOR /D %%A IN ("%~1\*") DO (SET /A "EXITMATH+=1")
)) ELSE (FOR /D %%A IN ("*") DO (SET /A "EXITMATH+=1"))
EXIT /B %ERRORLEVEL%

::  转换大小写字母-return EXITANSI
:Fn_ConvertChr
SET "EXITANSI=%*"
SET "CASEDOWN=a b c d e f g h i j k l m n o p q r s t u v w x y z"
SET "CASECRUP=A B C D E F G H I J K L M N O P Q R S T U V W X Y Z"
FOR /F "Delims=" %%A IN ("%EXITANSI%") DO (SET "EXITANSI=%%~A")
FOR %%A IN (%CASEDOWN%) DO (CALL SET "EXITANSI=%%EXITANSI:%%A=%%A%%")
EXIT /B %ERRORLEVEL%

::  转换相/绝对路径-return EXITANSI
:Fn_ConvertDir
SET "EXITANSI=%CD%" & CD /D "%~1" >NUL 2>NUL || (
    ECHO [ERROR] Invalid directory
    EXIT /B %ERRORLEVEL%
)
SET "EXITANSI=%CD%" && (CD /D "%EXITANSI%" >NUL 2>NUL)
EXIT /B %ERRORLEVEL%

::  获取字符串长度-return EXITMATH
:Fn_GetCharLen
SET "EXITANSI=%~1"
SET /A "EXITMATH=0"
IF "%~1" EQU "" (EXIT /B %ERRORLEVEL%)
:LB_ForCharLen
REM ECHO %EXITANSI% - %EXITMATH%
SET "EXITANSI=%EXITANSI:~1%"
IF DEFINED EXITANSI (SET /A "EXITMATH+=1" & GOTO :LB_ForCharLen )
EXIT /B %ERRORLEVEL%

::  获取字符出现次数-return EXITLINE
:Fn_GetCharStr
SET "EXITLINE="
SET "EXITANSI=%~1"
SET /A "EXITMATH=0"
IF "%~1" EQU "" (EXIT /B %ERRORLEVEL%)
:LB_ForCharStr
IF DEFINED DEBUGMOD (ECHO [DEBUG] %EXITANSI% - %EXITMATH% - %EXITLINE%)
IF "%EXITANSI:~0, 1%" EQU "%~2" (IF "%EXITLINE%" EQU "" (
    SET "EXITLINE=%EXITMATH%") ELSE (
    SET "EXITLINE=%EXITLINE% %EXITMATH%"
))
SET "EXITANSI=%EXITANSI:~1%"
IF DEFINED EXITANSI ( SET /A "EXITMATH+=1" & GOTO :LB_ForCharStr )
EXIT /B %ERRORLEVEL%

::  获取字符开始次数-return EXITMATH
:Fn_GetCharFst
SET "EXITANSI=%~1"
SET /A "EXITMATH=0"
IF "%~1" EQU "" (EXIT /B %ERRORLEVEL%)
:LB_ForCharFst
IF DEFINED DEBUGMOD (ECHO [DEBUG] %EXITANSI% - %EXITMATH% - %EXITANSI:~0, 1% - %~2)
IF "%EXITANSI:~0, 1%" EQU "%~2" (EXIT /B %ERRORLEVEL%)
SET "EXITANSI=%EXITANSI:~1%"
IF DEFINED EXITANSI ( SET /A "EXITMATH+=1" & GOTO :LB_ForCharFst )
EXIT /B %ERRORLEVEL%

::  获取字符结尾次数-return EXITMATH
:Fn_GetCharEnd
SET "EXITLINE="
SET "EXITANSI=%~1"
SET /A "EXITMATH=0"
IF "%~1" EQU "" (EXIT /B %ERRORLEVEL%)
:LB_ForCharEnd
IF DEFINED DEBUGMOD (ECHO [DEBUG] %EXITANSI% - %EXITMATH% - %EXITANSI:~0, 1% - %~2)
IF "%EXITANSI:~0, 1%" EQU "%~2" (IF "%EXITLINE%" EQU "" (SET "EXITLINE=%EXITMATH%"))
SET "EXITANSI=%EXITANSI:~1%"
IF DEFINED EXITANSI ( SET /A "EXITMATH+=1" & GOTO :LB_ForCharEnd )
EXIT /B %ERRORLEVEL%

::  强停止指定进程-no return
:Fn_TaskkillPE
IF "%~1" EQU "" (ECHO [ERROR] You haven't provided the parameters yet & EXIT /B %ERRORLEVEL%)
TASKKILL /IM "%~1" /F /T
EXIT /B %ERRORLEVEL%

::  配置项读写设置-no return
:CFG_ReadVal
FOR /F "Eol=[ Tokens=*" %%A IN ('TYPE %~1') DO (
FOR /F "Eol=# Tokens=*" %%A IN ("%%A") DO (
FOR /F "Eol=; Tokens=*" %%A IN ("%%A") DO (
FOR /F "Delims== Tokens=1,2*" %%B IN ("%%A") DO (REM 
    IF DEFINED DEBUGMOD (ECHO [DEBUG] %%A - %%B - %%C)
    IF "%%B" EQU "%~2" (SET "%%B=%%C")
))))
EXIT /B %ERRORLEVEL%
:CFG_WriteVal
FOR /F "Tokens=*" %%A IN ('TYPE %~1') DO (
FOR /F "Delims== Tokens=1,2*" %%B IN ("%%A") DO (
    IF DEFINED DEBUGMOD (ECHO [DEBUG] %%A - %%B - %%C)
    IF "%%B" EQU "%~2" (ECHO %%B=%~3>>%~1.new) ELSE (ECHO %%A>>%~1.new)
))
MOVE "%~1.new" "%~1" >NUL 2>NUL
EXIT /B %ERRORLEVEL%

::  注册表控制设置-no return
:REG_Load_
REG LOAD "%~1" "%~2"
EXIT /B %ERRORLEVEL%
:REG_Unload_
REG UNLOAD "%~1" "%~2"
EXIT /B %ERRORLEVEL%
:REG_Reload_
CALL :REG_Unload_ "%~1" "%~2"
CALL :REG_Load_ "%~1" "%~2"
EXIT /B %ERRORLEVEL%
:REG_Add_
SET "EXITMATH="
IF DEFINED DEBUGMOD (ECHO [DEBUG] %~1 - %~2 - %~3 - %~4)
FOR /F "Tokens=* Delims= " %%A IN (%*) DO (IF DEFINED DEBUGMOD (ECHO [DEBUG] %%A)
    ECHO %%A | FINDSTR /C:"/reg:32" /C:"/REG:32" >NUL 2>NUL && (SET /A "EXITMATH=32")
    ECHO %%A | FINDSTR /C:"/reg:64" /C:"/REG:64" >NUL 2>NUL && (SET /A "EXITMATH=64")
)
IF DEFINED EXITMATH (
    REM REG ADD "HKLM\XXX" "VALUE" "/REG:32"
    IF "%~4" EQU "" (REG ADD "%~1" /VE /D "%~2" /F /REG:%EXITMATH%) ELSE (
    IF "%~5" EQU "" (REG ADD "%~1" /V "%~2" /D "%~3" /F /REG:%EXITMATH%) ELSE (
    IF "%~6" EQU "" (REG ADD "%~1" /V "%~2" /T "%~3" /D "%~4" /F /REG:%EXITMATH%)))
) ELSE (
    REM REG ADD "HKLM\XXX" "VALUE"
    IF "%~3" EQU "" (REG ADD "%~1" /VE /D "%~2" /F) ELSE (
    IF "%~4" EQU "" (REG ADD "%~1" /V "%~2" /D "%~3" /F) ELSE (
    IF "%~5" EQU "" (REG ADD "%~1" /V "%~2" /T "%~3" /D "%~4" /F)))
)
EXIT /B %ERRORLEVEL%
:REG_Del_
SET "EXITMATH="
IF DEFINED DEBUGMOD (ECHO [DEBUG] %~1 - %~2 - %~3 - %~4)
FOR /F "Tokens=* Delims= " %%A IN (%*) DO (IF DEFINED DEBUGMOD (ECHO [DEBUG] %%A)
    ECHO %%A | FINDSTR /C:"/reg:32" /C:"/REG:32" >NUL 2>NUL && (SET /A "EXITMATH=32")
    ECHO %%A | FINDSTR /C:"/reg:64" /C:"/REG:64" >NUL 2>NUL && (SET /A "EXITMATH=64")
)
IF DEFINED EXITMATH (
  IF "%~2" EQU "" (REG DELETE "%~1" /F /REG:%EXITMATH%) ELSE (REG DELETE "%~1" /V "%~2" /F /REG:%EXITMATH%)
) ELSE (
  IF "%~2" EQU "" (REG DELETE "%~1" /F) ELSE (REG DELETE "%~1" /V "%~2" /F)
)
EXIT /B %ERRORLEVEL%
:REG_Cpy_
REG COPY "%~1" "%~2" /S /F
EXIT /B %ERRORLEVEL%
:REG_Moveto_
REG QUERY "%~1" >NUL 2>NUL || (ECHO [ERROR] KEY-Path: %~1 & EXIT /B %ERRORLEVEL%)
CALL :REG_Cpy_ "%~1" "%~2"
CALL :REG_Del_ "%~1"
EXIT /B %ERRORLEVEL%
:REG_Rename_
FOR /F "Skip=2 Tokens=1, 2*" %%A IN ('REG QUERY "%~1" /V "%~2" 2^>NUL') DO (
    IF DEFINED DEBUGMOD (ECHO [DEBUG] %%A - %%B - %%C)
    CALL :REG_Del_ "%~1" "%~2"
    CALL :REG_Add_ "%~1" "%~3" "%%B" "%%C"
    EXIT /B %ERRORLEVEL%
)
ECHO [ERROR] KEY-Value: %~2
EXIT /B %ERRORLEVEL%