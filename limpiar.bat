@echo off
REM Script de limpieza para Windows

echo Limpiando archivos generados...

if exist lex.yy.c del lex.yy.c
if exist analizador.tab.c del analizador.tab.c
if exist analizador.tab.h del analizador.tab.h
if exist analizador.exe del analizador.exe
if exist salida.txt del salida.txt
if exist saliday.txt del saliday.txt

echo Limpieza completada.
pause
