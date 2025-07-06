@echo off
setlocal
REM CompileYourOS.bat
REM This batch script compiles bootloader.asm and creates a bootable .img file.
REM Designed for Windows. Requires NASM and PowerShell (built-in).

REM --- Configuration ---
SET NASM_FILE=bootloader.asm
SET BIN_FILE=bootloader.bin
SET IMG_FILE=boot.img
SET QEMU_CMD=qemu-system-i386 -fda %IMG_FILE%

REM --- Change directory to where this script is located ---
REM This makes the script portable, so you can run it from anywhere.
cd /d "%~dp0"

echo.
echo --- Starting Bootloader Build Process ---
echo.

REM --- 1. Check for NASM ---
where nasm >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo ERROR: NASM not found!
    echo Please install NASM and ensure it's in your system's PATH.
    echo Download NASM from: https://www.nasm.us/
    goto :end
)

REM --- 2. Assemble the Assembly Code ---
echo Assembling %NASM_FILE% into %BIN_FILE%...
nasm %NASM_FILE% -f bin -o %BIN_FILE%

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: NASM assembly failed!
    echo Please check %NASM_FILE% for syntax errors.
    goto :end
)

echo Assembly successful.

REM --- 3. Create the Bootable Disk Image using PowerShell ---
echo.
echo Creating bootable image %IMG_FILE% from %BIN_FILE% using PowerShell...

REM PowerShell command to read the binary file and write it to the image file.
REM [System.IO.File]::ReadAllBytes reads the content of %BIN_FILE% as a byte array.
REM [System.IO.File]::WriteAllBytes writes that byte array to %IMG_FILE%.
REM This will create %IMG_FILE% with the exact size of %BIN_FILE% (512 bytes).
powershell -Command "& { [System.IO.File]::WriteAllBytes('%IMG_FILE%', [System.IO.File]::ReadAllBytes('%BIN_FILE%')) }"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: Failed to create %IMG_FILE% using PowerShell!
    echo Ensure %BIN_FILE% exists and is accessible.
    goto :end
)

echo Image %IMG_FILE% created successfully.

REM --- Optional: Run in QEMU ---
echo.
SET /P RUN_QEMU="Do you want to run the bootloader in QEMU now? (Y/N): "
IF /I "%RUN_QEMU%"=="Y" (
    echo.
    echo Launching QEMU with %IMG_FILE%...
    REM Check for QEMU before attempting to run
    where qemu-system-i386 >nul 2>&1
    IF %ERRORLEVEL% NEQ 0 (
        echo WARNING: QEMU not found in PATH. Cannot launch automatically.
        echo Please install QEMU or run it manually.
        echo Download QEMU from: https://www.qemu.org/download/
    ) ELSE (
        %QEMU_CMD%
    )
) ELSE (
    echo Skipping QEMU launch.
)

:end
echo.
echo --- Build Process Finished ---
echo.
pause
