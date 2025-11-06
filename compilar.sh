#!/bin/bash
# Script de compilación para Linux/Ubuntu/WSL

echo "========================================="
echo " Compilando Analizador Sintáctico"
echo "========================================="
echo ""

# Verificar que las herramientas estén instaladas
echo "Verificando herramientas necesarias..."

if ! command -v bison &> /dev/null; then
    echo "ERROR: bison no está instalado"
    echo "Instalar con: sudo apt-get install bison"
    exit 1
fi

if ! command -v flex &> /dev/null; then
    echo "ERROR: flex no está instalado"
    echo "Instalar con: sudo apt-get install flex"
    exit 1
fi

if ! command -v gcc &> /dev/null; then
    echo "ERROR: gcc no está instalado"
    echo "Instalar con: sudo apt-get install gcc"
    exit 1
fi

echo "✓ Todas las herramientas están disponibles"
echo ""

# Paso 1: Generar parser con Bison
echo "[1/3] Generando parser con Bison..."
bison -d analizador.y
if [ $? -ne 0 ]; then
    echo "ERROR: Bison falló"
    exit 1
fi
echo "✓ OK"

# Paso 2: Generar lexer con Flex
echo "[2/3] Generando lexer con Flex..."
flex analizador.l
if [ $? -ne 0 ]; then
    echo "ERROR: Flex falló"
    exit 1
fi
echo "✓ OK"

# Paso 3: Compilar con GCC
echo "[3/3] Compilando con GCC..."
gcc -o analizador analizador.tab.c lex.yy.c -lfl 2>/dev/null || gcc -o analizador analizador.tab.c lex.yy.c
if [ $? -ne 0 ]; then
    echo "ERROR: GCC falló"
    exit 1
fi
echo "✓ OK"

echo ""
echo "========================================="
echo " ✓ Compilación exitosa!"
echo " Ejecutable: ./analizador"
echo "========================================="
echo ""
echo "Para ejecutar: ./analizador entrada.txt salida.txt"
echo ""
