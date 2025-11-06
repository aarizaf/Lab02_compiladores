#!/bin/bash
# Script para probar todas las funcionalidades

echo "========================================="
echo " Ejecutando todas las pruebas"
echo "========================================="
echo ""

# Verificar que el ejecutable existe
if [ ! -f "./analizador" ]; then
    echo "ERROR: El ejecutable no existe"
    echo "Ejecuta primero: ./compilar.sh"
    exit 1
fi

# Prueba 1: Programa correcto
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Prueba 1: Programa SIN errores (prueba1.py)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "prueba1.py" ]; then
    ./analizador prueba1.py salida1.txt
    echo ""
    echo "Resultado:"
    cat salida1.txt
    echo ""
else
    echo "⚠ Archivo prueba1.py no encontrado"
fi

# Prueba 2: Programa con errores
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Prueba 2: Programa CON errores (prueba2.py)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "prueba2.py" ]; then
    ./analizador prueba2.py salida2.txt
    echo ""
    echo "Resultado:"
    cat salida2.txt
    echo ""
else
    echo "⚠ Archivo prueba2.py no encontrado"
fi

# Prueba 3: Archivo por defecto
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Prueba 3: Archivo por defecto (entrada.txt)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "entrada.txt" ]; then
    ./analizador entrada.txt salida.txt
    echo ""
    echo "Resultado:"
    cat salida.txt
    echo ""
else
    echo "⚠ Archivo entrada.txt no encontrado"
fi

# Prueba 4: Programa completo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Prueba 4: Programa extenso (prueba3_completa.py)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ -f "prueba3_completa.py" ]; then
    ./analizador prueba3_completa.py salida3.txt
    echo ""
    echo "Resultado:"
    cat salida3.txt
    echo ""
else
    echo "⚠ Archivo prueba3_completa.py no encontrado"
fi

echo "========================================="
echo " ✓ Todas las pruebas completadas"
echo "========================================="
