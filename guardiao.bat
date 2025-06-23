chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion
title [GUARDIÃO DO PING - SISTEMA TENDÃO]
color 0A

set "IPDESTINO=8.8.8.8"
set "OSCILACOES=0"
set "FALHAS=0"
set "RECONEXOES=0"
set "ssid="

:loop
cls
call :MostraInfo

call :VerificaConexao

echo +==============================================+
timeout /t 1 >nul
goto loop

:VerificaConexao
    call :PingComTimeout 300

    if !errorlevel! EQU 0 (
        echo ^|   [✓] Conexao OK                             ^| 
        set FALHAS=0
    ) else (
        call :PingComTimeout 800
        if !errorlevel! EQU 0 (
            echo ^| [~] Oscilação detectada, mas recuperou   ^|
            set FALHAS=0
            set /a OSCILACOES+=1
        ) else (
            set /a OSCILACOES+=1
            set /a FALHAS+=1
        )
    )

    if !OSCILACOES! GEQ 3 (
        call :VerificaFalha 
    )    
goto :eof

:VerificaFalha
    if !FALHAS! GEQ 3 (
        echo +----------------------------------------------+
        echo ^| [⚠] !FALHAS! falhas detectadas. Iniciando reconexão...
        call :AutoReconectar
        set /a RECONEXOES+=1
        set FALHAS=0
    )
goto :eof


:MostraInfo
    call :GetSSID    
    echo +==============================================+
    echo ^|     ⚔️  GUARDIÃO DO PING - SISTEMA TENDÃO™   ^|
    echo +----------------------------------------------+
    echo ^| Rede atual.........: !ssid!          ^|
    echo ^| Monitorando........: !IPDESTINO!                 ^|
    echo ^| Oscilações.........: !OSCILACOES!                      ^|
    echo ^| Falhas consecutivas: !FALHAS!                       ^|
    echo ^| Reconexões.........: !RECONEXOES!                       ^|
    echo ^| Hora atual.........: !time:~0,8!                ^|
    echo +----------------------------------------------+
    echo ^| Status:                                      ^| 
goto :eof

:PingComTimeout
    setlocal
    set "timeout=%~1"
    ping -n 1 -w !timeout! !IPDESTINO! >nul    
goto :eof

:AutoReconectar
    set "ssid_anterior=!ssid!"
    call :GetSSID

    if /i "!ssid!" NEQ "!ssid_anterior!" (
        echo ^|    - ⚠️ Rede está trocando: "!ssid_anterior!" → "!ssid!"
        echo ^|    - Aguardando estabilização antes de qualquer ação...
        timeout /t 10 >nul
        goto :eof
    )

    echo ^|    - Rede detectada: !ssid!
    echo ^|    - Desconectando...
    netsh wlan disconnect >nul
    timeout /t 2 >nul
    echo ^|    - Reconectando a "!ssid!"...
    netsh wlan connect name="!ssid!" >nul
    echo ^|    - Reconexao concluída!
    timeout /t 10 >nul
goto :eof

:GetSSID
    for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /C:" SSID"') do (
        set ssid=%%a
    )
    for /f "tokens=* delims= " %%a in ("!ssid!") do set "ssid=%%a"
goto :eof

