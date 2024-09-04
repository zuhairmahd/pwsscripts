@echo off
set WORKINGDIR=Win11_24H2_English_x64
set DEST= Win11_24H2_English_x64.iso
set BOOTDIR=windows\fwfiles

  rem
  rem Set the correct boot argument based on availability of boot apps
  rem
  set BOOTDATA=1#pEF,e,b"%BOOTDIR%\efisys.bin"
  if exist "%BOOTDIR%\etfsboot.com" (
    set BOOTDATA=2#p0,e,b"%BOOTDIR%\etfsboot.com"#pEF,e,b"%BOOTDIR%\efisys.bin"
  )

  rem
  rem Create the ISO file using the appropriate OSCDImg command
  rem
  echo Creating %DEST%...
  echo.
  oscdimg -bootdata:%BOOTDATA% -u1 -udfver102 "%WORKINGDIR%" "%DEST%"
  if errorlevel 1 (
    echo ERROR: Failed to create "%DEST%" file.
    goto fail
  )
  goto success

:success
set EXITCODE=0
echo.
echo Success
echo.
goto done

:fail
  echo Sorry, it didn't work out

  :done