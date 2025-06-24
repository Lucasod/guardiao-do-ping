chcp 65001 >nul
@echo off
setlocal enabledelayedexpansion
title [GUARDIÃO DO PING - SISTEMA TENDÃO]
color 0A

call :IniciaScript

:IniciaScript
    call :DefineVariaveis

    :loop
        call :IniciaGuardiao    
    goto loop    
goto :eof

:DefineVariaveis
    set "IPDESTINO=8.8.8.8"
    set "OSCILACOES=0"
    set "FALHAS=0"
    set "RECONEXOES=0"
    set "ssid="
    set "TIMEOUTMINIMO=300"
    set "TIMEOUTMAXIMO=800"
goto :eof

:IniciaGuardiao
    call :MostraInfo
    call :VerificaConexao
    call :MostraFimLinha
goto :eof

:MostraInfo
    call :PegaSSID    
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

:PegaSSID
    set "ssid="
    for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /C:" SSID" ^| findstr /V "BSSID"') do (
        if not defined ssid set "ssid=%%a"
    )
    for /f "tokens=* delims= " %%a in ("!ssid!") do set "ssid=%%a"
goto :eof

:VerificaConexao        
    call :PingComTimeout !TIMEOUTMINIMO!

    if !errorlevel! EQU 0 (
        echo ^|   [✓] Conexao OK                             ^| 
        set FALHAS=0
    ) else (
        call :PingComTimeout !TIMEOUTMAXIMO!
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

:PingComTimeout
    setlocal
    set "timeout=%~1"
    ping -n 1 -w !timeout! !IPDESTINO! >nul
    endlocal    
goto :eof

:VerificaFalha
    if !FALHAS! GEQ 3 (
        echo +----------------------------------------------+
        echo ^| [⚠] !FALHAS! falhas detectadas. Iniciando reconexão...
        call :AutoReconectar
        set /a RECONEXOES+=1
        set FALHAS=0
        set OSCILACOES=0   
    )
goto :eof

:AutoReconectar
    set "ssid_anterior=!ssid!"
    call :PegaSSID

    if /i "!ssid!" NEQ "!ssid_anterior!" (
       call :AguardaTrocaRede
    )

    call :ReconectaRede    
goto :eof

:AguardaTrocaRede
    echo ^|    - ⚠️ Rede está trocando: "!ssid_anterior!" → "!ssid!"
    echo ^|    - Aguardando estabilização antes de qualquer ação...
    timeout /t 10 >nul
goto :eof

:ReconectaRede
    echo ^|    - Rede detectada: !ssid!
    echo ^|    - Desconectando...
    netsh wlan disconnect >nul
    timeout /t 2 >nul
    echo ^|    - Reconectando a "!ssid!"...
    netsh wlan connect name="!ssid!" >nul
    if !errorlevel! neq 0 (
        echo ^|    - Erro ao reconectar à "!ssid!"!
    ) else (
        echo ^|    - Reconexao concluída!
    )
    timeout /t 10 >nul
goto :eof

:MostraFimLinha
    echo +==============================================+
    timeout /t 1 >nul
    cls
goto :eof
