%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern int yylineno;
extern int ultima_linea_token;
extern FILE *yyin;
extern char *yytext;

void yyerror(const char *s);

FILE *salida;
int errores_sintacticos = 0;
int lineas_con_error[1000];
int num_lineas_error = 0;
int ajustar_linea_error = 0; // Flag para ajustar el número de línea
int hubo_error_lexico = 0; // Flag para indicar que hubo un error léxico reciente

void registrar_error(int linea) {
    for (int i = 0; i < num_lineas_error; i++) {
        if (lineas_con_error[i] == linea) return;
    }
    lineas_con_error[num_lineas_error++] = linea;
}

int ya_tiene_error_en_linea(int linea) {
    for (int i = 0; i < num_lineas_error; i++) {
        if (lineas_con_error[i] == linea) return 1;
    }
    return 0;
}
%}

%glr-parser

%union {
    int int_val;
    char *str_val;
    int id_val;
}

%token <str_val> IDENTIFICADOR CADENA ENTERO REAL LONG_INT IMAGINARIO
%token <int_val> id_val

%token AND BREAK CONTINUE DEF ELIF ELSE FOR IF IMPORT IN IS NOT OR PASS PRINT RETURN WHILE TRUE FALSE RANGE
%token POT_ASIG DIV_ENT_ASIG DESP_IZQ_ASIG DESP_DER_ASIG COMP_IGUAL DISTINTO MENOR_IGUAL MAYOR_IGUAL
%token SUMA_ASIG RESTA_ASIG MULT_ASIG DIV_ASIG AND_ASIG OR_ASIG XOR_ASIG MOD_ASIG
%token POT DIV_ENT DESP_IZQ DESP_DER SUMA MENOS MULT DIV MOD MENOR MAYOR
%token AND_BIT OR_BIT XOR_BIT NOT_BIT ASIG
%token PARABRE PARCIERR CORABRE CORCIERR DOSPUNTOS COMA PTOCOMA PUNTO
%token ERROR_LEXICO

%left OR
%left AND  
%left NOT
%left COMP_IGUAL DISTINTO MENOR MAYOR MENOR_IGUAL MAYOR_IGUAL IS
%left OR_BIT
%left XOR_BIT
%left AND_BIT
%left DESP_IZQ DESP_DER
%left SUMA MENOS
%left MULT DIV MOD DIV_ENT
%right NOT_BIT
%right POT

%start programa

%%

programa:
    /* vacío */
    | lista_items
    ;

lista_items:
    item
    | lista_items item
    | error { 
        if (!hubo_error_lexico) {
            registrar_error(yylineno > 1 ? yylineno - 1 : yylineno);
        }
        // NO resetear hubo_error_lexico aquí
        yyerrok; yyclearin; 
    }
    ;

item:
    stmt_simple { hubo_error_lexico = 0; /* Resetear después de procesar statement correcto */ }
    | error DOSPUNTOS { 
        if (!hubo_error_lexico) {
            int linea_error = yylineno - 1;
            // Solo registrar si no hay ya un error en esa línea o en yylineno
            if (!ya_tiene_error_en_linea(linea_error) && !ya_tiene_error_en_linea(yylineno)) {
                registrar_error(linea_error);
            }
        }
        // NO resetear hubo_error_lexico aquí
        yyerrok; yyclearin; 
    }
    | error ASIG expresion { 
        if (!hubo_error_lexico) {
            registrar_error(yylineno);
        }
        // NO resetear hubo_error_lexico aquí
        yyerrok; yyclearin; 
    }
    | error PARABRE params_opt PARCIERR { 
        if (!hubo_error_lexico) {
            registrar_error(yylineno);
        }
        // NO resetear hubo_error_lexico aquí
        yyerrok; yyclearin; 
    }
    | error PARCIERR { 
        if (!hubo_error_lexico) {
            registrar_error(yylineno);
        }
        // NO resetear hubo_error_lexico aquí
        yyerrok; yyclearin; 
    }
    ;

stmt_simple:
    IDENTIFICADOR ASIG expresion
    | IDENTIFICADOR COMA IDENTIFICADOR ASIG expresion COMA expresion  
    | IDENTIFICADOR op_asig expresion
    | DEF IDENTIFICADOR PARABRE params_opt PARCIERR DOSPUNTOS
    | FOR IDENTIFICADOR IN expresion DOSPUNTOS
    | FOR IDENTIFICADOR IN RANGE PARABRE expresion PARCIERR DOSPUNTOS
    | FOR IDENTIFICADOR IN RANGE PARABRE expresion COMA expresion PARCIERR DOSPUNTOS
    | FOR IDENTIFICADOR IN CORABRE lista_expr_opt CORCIERR DOSPUNTOS
    | WHILE expresion DOSPUNTOS
    | IF expresion DOSPUNTOS
    | ELIF expresion DOSPUNTOS
    | ELSE DOSPUNTOS
    | RETURN
    | RETURN expresion
    | BREAK
    | CONTINUE
    | PASS
    | PRINT PARABRE lista_expr_opt PARCIERR
    | IMPORT IDENTIFICADOR
    ;

op_asig:
    SUMA_ASIG | RESTA_ASIG | MULT_ASIG | DIV_ASIG | MOD_ASIG
    | POT_ASIG | DIV_ENT_ASIG | AND_ASIG | OR_ASIG | XOR_ASIG
    | DESP_IZQ_ASIG | DESP_DER_ASIG
    ;

params_opt:
    /* vacío */
    | params
    ;

params:
    IDENTIFICADOR
    | params COMA IDENTIFICADOR
    ;

lista_expr_opt:
    /* vacío */
    | lista_expr
    ;

lista_expr:
    expresion
    | lista_expr COMA expresion
    ;

expresion:
    expr_or
    ;

expr_or:
    expr_and
    | expr_or OR expr_and
    ;

expr_and:
    expr_comp
    | expr_and AND expr_comp
    ;

expr_comp:
    expr_bit
    | expr_comp MENOR expr_bit
    | expr_comp MAYOR expr_bit
    | expr_comp MENOR_IGUAL expr_bit
    | expr_comp MAYOR_IGUAL expr_bit
    | expr_comp COMP_IGUAL expr_bit
    | expr_comp DISTINTO expr_bit
    | expr_comp IS expr_bit
    ;

expr_bit:
    expr_shift
    | expr_bit OR_BIT expr_shift
    | expr_bit XOR_BIT expr_shift
    | expr_bit AND_BIT expr_shift
    ;

expr_shift:
    expr_arit
    | expr_shift DESP_IZQ expr_arit
    | expr_shift DESP_DER expr_arit
    ;

expr_arit:
    expr_term
    | expr_arit SUMA expr_term
    | expr_arit MENOS expr_term
    ;

expr_term:
    expr_factor
    | expr_term MULT expr_factor
    | expr_term DIV expr_factor
    | expr_term MOD expr_factor
    | expr_term DIV_ENT expr_factor
    ;

expr_factor:
    expr_unario
    | expr_factor POT expr_unario
    ;

expr_unario:
    postfix
    | NOT expr_unario
    | NOT_BIT expr_unario
    | MENOS expr_unario
    | SUMA expr_unario
    ;

postfix:
    primario
    | postfix CORABRE expresion CORCIERR
    | postfix PARABRE lista_expr_opt PARCIERR
    ;

primario:
    ENTERO
    | REAL
    | LONG_INT
    | IMAGINARIO
    | CADENA
    | TRUE
    | FALSE
    | IDENTIFICADOR
    | CORABRE lista_expr_opt CORCIERR
    | PARABRE expresion PARCIERR
    ;

%%

void yyerror(const char *s) {
    // No hacemos nada aquí, las reglas de error manejan el registro
    // Los errores léxicos ya fueron registrados por el lexer
    errores_sintacticos++;
    // No resetear hubo_error_lexico aquí
}

int main(int argc, char *argv[]) {
    char *archivo_entrada = "entrada.txt";
    char *archivo_salida = "salida.txt";
    
    if (argc > 1) {
        archivo_entrada = argv[1];
    }
    if (argc > 2) {
        archivo_salida = argv[2];
    }
    
    yyin = fopen(archivo_entrada, "r");
    if (!yyin) {
        fprintf(stderr, "Error: No se puede abrir el archivo '%s'\n", archivo_entrada);
        return 1;
    }
    
    salida = fopen(archivo_salida, "w");
    if (!salida) {
        fprintf(stderr, "Error: No se puede crear el archivo de salida '%s'\n", archivo_salida);
        fclose(yyin);
        return 1;
    }
    
    fprintf(salida, "Prueba con el archivo de entrada\n");
    
    yyparse();
    
    if (num_lineas_error == 0) {
        fprintf(salida, "0 errores\n");
        printf("Análisis completado: 0 errores\n");
    } else {
        for (int i = 0; i < num_lineas_error; i++) {
            fprintf(salida, "línea %d error\n", lineas_con_error[i]);
        }
        printf("Análisis completado: %d líneas con errores\n", num_lineas_error);
    }
    
    fclose(yyin);
    fclose(salida);
    
    return 0;
}
