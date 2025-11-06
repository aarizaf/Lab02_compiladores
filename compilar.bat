@echo off
REM Script de compilación para Windows
REM LAB03 - Analizador Sintáctico Python

echo ========================================
echo  Compilando Analizador Sintactico
echo ========================================
echo.

echo [1/3] Generando parser con Bison...
bison -d analizador.y
if %errorlevel% neq 0 (
    echo ERROR: Bison fallo. Verifica que este instalado.
    pause
    exit /b 1
)
echo OK

echo.
echo [2/3] Generando lexer con Flex...
flex analizador.l
if %errorlevel% neq 0 (
    echo ERROR: Flex fallo. Verifica que este instalado.
    pause
    exit /b 1
)
echo OK

echo.
echo [3/3] Compilando con GCC...
gcc -o analizador analizador.tab.c lex.yy.c
if %errorlevel% neq 0 (
    echo ERROR: GCC fallo. Verifica que este instalado.
    pause
    exit /b 1
)
echo OK

echo.
echo ========================================
echo  Compilacion exitosa!
echo  Ejecutable: analizador.exe
echo ========================================
echo.
echo Para ejecutar: analizador.exe entrada.txt salida.txt
echo.
pause
