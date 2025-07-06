@echo off
REM BeAnOSDev
REM This batch script compiles bootloader.asm and creates a bootable .img file.

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

REM --- 1. Assemble the Assembly Code ---
echo Assembling %NASM_FILE% into %BIN_FILE%...
nasm %NASM_FILE% -f bin -o %BIN_FILE%

IF ERRORLEVEL 1 (
    echo.
    echo ERROR: NASM assembly failed!
    echo Please check %NASM_FILE% for syntax errors.
    goto :end
)

echo Assembly successful.

REM --- 2. Create the Bootable Disk Image ---
echo.
echo Creating bootable image %IMG_FILE% from %BIN_FILE%...

REM Using dd to copy the 512-byte bootloader into a new image file.
REM 'bs=512' sets block size to 512 bytes (standard boot sector size).
REM 'count=1' copies only one block.
REM 'conv=notrunc' ensures that if the image file already exists and is larger,
REM                it won't be truncated, just the first 512 bytes are overwritten.
dd if=%BIN_FILE% of=%IMG_FILE% bs=512 count=1 conv=notrunc

IF ERRORLEVEL 1 (
    echo.
    echo ERROR: Failed to create %IMG_FILE% using dd!
    echo Ensure 'dd' is installed and accessible in your PATH.
    goto :end
)

echo Image %IMG_FILE% created successfully.

REM --- Optional: Run in QEMU ---
echo.
SET /P RUN_QEMU="Do you want to run the bootloader in QEMU now? (Y/N): "
IF /I "%RUN_QEMU%"=="Y" (
    echo.
    echo Launching QEMU with %IMG_FILE%...
    %QEMU_CMD%
) ELSE (
    echo Skipping QEMU launch.
)

:end
echo.
echo --- Build Process Finished ---
echo.
pause
