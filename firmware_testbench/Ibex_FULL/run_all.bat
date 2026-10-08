@echo off
REM run_all.bat - bam dup de chay 1 testbench Ibex + tu mo waveform ket qua.
REM Khong can mo Vivado truoc - script tu lam het.
REM
REM CACH DUNG: bam dup file nay, hoac chay tu cmd:
REM   run_all.bat tb_ibex_ecb aes_ecb
REM Neu bam dup khong co tham so, se hoi truc tiep.

setlocal
if defined XILINX_VIVADO (set VIVADO=%XILINX_VIVADO%\bin\vivado.bat) else (set VIVADO=F:\vivado\Vivado\2024.2\bin\vivado.bat)
REM May khac: sua dong tren hoac dat bien moi truong XILINX_VIVADO=<thu muc cai Vivado 2024.2>

if "%~1"=="" (
    set /p TBNAME="Ten testbench (vd tb_ibex_ecb): "
) else (
    set TBNAME=%~1
)
if "%~2"=="" (
    set /p COENAME="Ten file coe, khong duoi .coe (vd aes_ecb): "
) else (
    set COENAME=%~2
)

cd /d "%~dp0"
echo.
echo ===== Dang chay mo phong %TBNAME% (coe=%COENAME%) =====
echo.
call "%VIVADO%" -mode batch -source run_manual_sim.tcl -tclargs %TBNAME% %COENAME% -nolog -nojournal

set WDB=%~dp0_sim_run\%TBNAME%.wdb
if exist "%WDB%" (
    echo.
    echo ===== Mo phong xong, dang mo waveform trong Vivado GUI =====
    start "IbexWave" /B "%VIVADO%" "%WDB%" >nul 2>&1
) else (
    echo.
    echo ===== KHONG THAY FILE .wdb - mo phong that bai, xem log o tren =====
    pause
)
endlocal
