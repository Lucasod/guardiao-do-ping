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
    set "IP_DESTINO=8.8.8.8"
    set "OSCILACOES=0"
    set "FALHAS=0"
    set "RECONEXOES=0"
    set "SSID="    
    set "SSID_ANTERIOR="    
    set "ULTIMA_SSID_OK="
    set "TIMEOUT_MINIMO=300"
    set "TIMEOUT_MAXIMO=800"
goto :eof

:IniciaGuardiao
    call :MostraInfo
    call :VerificaConexao
    call :MostraFimLinha
goto :eof

:MostraInfo
    call :PegaSSID    
    echo +==============================================+
    echo ^|     ⚔️  GUARDIÃO DO PING - SISTEMA TENDÃO™   
    echo +----------------------------------------------+
    echo ^| Rede atual.........: !SSID!
    echo ^| Monitorando........: !IP_DESTINO!
    echo ^| Oscilações.........: !OSCILACOES!
    echo ^| Falhas consecutivas: !FALHAS!
    echo ^| Reconexões.........: !RECONEXOES!
    echo ^| Hora atual.........: !time:~0,8!
    echo +----------------------------------------------+
    echo ^| Status:                                       
goto :eof

:PegaSSID
    set "SSID="
    for /f "tokens=2 delims=:" %%a in ('netsh wlan show interfaces ^| findstr /C:" SSID" ^| findstr /V "BSSID"') do (
        if not defined ssid set "SSID=%%a"
    )
    for /f "tokens=* delims= " %%a in ("!SSID!") do set "SSID=%%a"
goto :eof

:VerificaConexao        
    call :PingComTimeout !TIMEOUT_MINIMO!

    if !errorlevel! EQU 0 (
        echo ^|   [✓] Conexao OK                              
        set FALHAS=0
        set ULTIMA_SSID_OK=!SSID!
    ) else (
        call :PingComTimeout !TIMEOUT_MAXIMO!
        if !errorlevel! EQU 0 (
            echo ^| [~] Oscilação detectada, mas recuperou   
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
    ping -n 1 -w !timeout! !IP_DESTINO! >nul
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
    set "SSID_ANTERIOR=!SSID!"
    call :PegaSSID

    if /i "!SSID!" NEQ "!SSID_ANTERIOR!" (
       call :AguardaTrocaRede
    )

    call :ReconectaRede    
goto :eof

:AguardaTrocaRede
    echo ^|    - ⚠️ Rede está trocando: "!SSID_ANTERIOR!" → "!SSID!" 
    echo ^|    - Aguardando estabilização antes de qualquer ação... 
    timeout /t 10 >nul
goto :eof

:ReconectaRede
    echo ^|    - Rede detectada: !SSID!
    if "!SSID!"=="" (
        if "!ULTIMA_SSID_OK!"=="" (
            echo ^|    - Nenhuma SSID funcional salva para reconectar! 
        ) else (
            echo ^|    - SSID vazia! Tentando reconectar na última SSID funcional: !ULTIMA_SSID_OK!
            netsh wlan connect name="!ULTIMA_SSID_OK!" >nul
            if !errorlevel! neq 0 (
                echo ^|    - Erro ao reconectar à "!ULTIMA_SSID_OK!"!
            ) else (
                echo ^|    - Reconexao concluída em "!ULTIMA_SSID_OK!"!
            )
        )
    ) else (
        echo ^|    - Desconectando...
        netsh wlan disconnect >nul
        timeout /t 2 >nul
        echo ^|    - Reconectando a "!SSID!"...
        netsh wlan connect name="!SSID!" >nul
        if !errorlevel! neq 0 (
            echo ^|    - Erro ao reconectar à "!SSID!"!
            if not "!ULTIMA_SSID_OK!"=="" (
                echo ^|    - Tentando reconectar na última SSID funcional: !ULTIMA_SSID_OK!
                netsh wlan connect name="!ULTIMA_SSID_OK!" >nul
                if !errorlevel! neq 0 (
                    echo ^|    - Erro ao reconectar à "!ULTIMA_SSID_OK!"!
                ) else (
                    echo ^|    - Reconexao concluída em "!ULTIMA_SSID_OK!"!
                )
            )
        ) else (
            echo ^|    - Reconexao concluída!
        )
    )
    timeout /t 10 >nul
goto :eof

:MostraFimLinha
    echo +==============================================+
    timeout /t 1 >nul
    cls
goto :eof
