chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion
title [GUARDIÃO DO PING - SISTEMA TENDÃO]
color 0A

set "FALHAS=0"
set "RECONEXOES=0"
set "IPDESTINO=8.8.8.8"
set "ssid="

call :GetSSID

:loop
cls
call :MostraInfo

ping -n 1 -w 300 !IPDESTINO! | findstr /i "TTL=" >nul

if !errorlevel! EQU 0 (
    echo ^|   [✓] Conexao OK                             ^| 
    set FALHAS=0
) else (
    ping -n 1 -w 800 !IPDESTINO! | findstr /i "TTL=" >nul
    if !errorlevel! EQU 0 (
        echo ^| [~] Oscilação detectada, mas recuperou   ^|
        set FALHAS=0
    ) else (
        set /a FALHAS+=1
        echo ^|   [X] Falha #!FALHAS!                               ^| 
    )
)

if !FALHAS! GEQ 1 (
    echo +----------------------------------------------+
    echo ^| [⚠] !FALHAS!  falhas detectadas. Iniciando reconexão...
    call :AutoReconectar
    set /a RECONEXOES+=1
    set FALHAS=0
)

echo +==============================================+
timeout /t 1 >nul
goto loop

:MostraInfo    
    echo +==============================================+
    echo ^|     ⚔️  GUARDIÃO DO PING - SISTEMA TENDÃO™   ^|
    echo +----------------------------------------------+
    echo ^| Rede atual.........: !ssid!          ^|
    echo ^| Monitorando........: !IPDESTINO!                 ^|
    echo ^| Reconexões.........: !RECONEXOES!                       ^|
    echo ^| Falhas consecutivas: !FALHAS!                       ^|
    echo ^| Hora atual.........: !time:~0,8!                ^|
    echo +----------------------------------------------+
    echo ^| Status:                                      ^| 
goto :eof

:AutoReconectar
    call :GetSSID
    echo ^|    - Rede detectada: !ssid!
    echo ^|    - Desconectando...
    netsh wlan disconnect >nul
    timeout /t 2 >nul
    echo ^|    - Reconectando a "!ssid!"...
    netsh wlan connect name="!ssid!" >nul
    echo ^|    - Reconexao concluída!
    timeout /t 2 >nul
goto :eof

:GetSSID
    echo ^| ► Detectando nome da rede atual...
    for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /C:" SSID"') do (
        set ssid=%%a
    )
    for /f "tokens=* delims= " %%a in ("!ssid!") do set "ssid=%%a
goto :eof
