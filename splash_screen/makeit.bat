@echo off
if exist splash.obj del splash.obj
if exist splash.dll del splash.dll
\masm32\bin\ml /c /coff splash.asm
\masm32\bin\Link /SUBSYSTEM:WINDOWS /DLL /DEF:splash.def splash.obj 
del splash.obj
del splash.exp
dir splash.*
pause
