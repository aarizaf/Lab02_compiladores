#!/bin/bash
# Script de limpieza para Linux/Ubuntu

echo "Limpiando archivos generados..."

rm -f lex.yy.c
rm -f analizador.tab.c
rm -f analizador.tab.h
rm -f analizador
rm -f salida*.txt

echo "✓ Limpieza completada"
