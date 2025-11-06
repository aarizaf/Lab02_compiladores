%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "analizador.tab.h"

typedef struct {
    char *nombre;
    int id_num;
} Identificador;

#define MAX_IDENTIFICADORES 200
Identificador tabla_ids[MAX_IDENTIFICADORES];
int num_identificadores = 0;
int ultima_linea_token = 1; 

int buscar_o_agregar_id(char* nombre);
extern void registrar_error(int linea);
extern int hubo_error_lexico;
%}

%option yylineno
%option noyywrap

%%

[ \t\r]+        { /* Ignorar espacios y tabs */ }
\n              { /* Ignorar saltos de línea  */ }
"#".*           { /* Ignorar comentarios */ }

"and"           { ultima_linea_token = yylineno; return AND; }
"break"         { ultima_linea_token = yylineno; return BREAK; }
"continue"      { ultima_linea_token = yylineno; return CONTINUE; }
"def"           { ultima_linea_token = yylineno; return DEF; }
"elif"          { ultima_linea_token = yylineno; return ELIF; }
"else"          { ultima_linea_token = yylineno; return ELSE; }
"for"           { ultima_linea_token = yylineno; return FOR; }
"if"            { ultima_linea_token = yylineno; return IF; }
"import"        { ultima_linea_token = yylineno; return IMPORT; }
"in"            { ultima_linea_token = yylineno; return IN; }
"is"            { ultima_linea_token = yylineno; return IS; }
"not"           { ultima_linea_token = yylineno; return NOT; }
"or"            { ultima_linea_token = yylineno; return OR; }
"pass"          { ultima_linea_token = yylineno; return PASS; }
"print"         { ultima_linea_token = yylineno; return PRINT; }
"return"        { ultima_linea_token = yylineno; return RETURN; }
"while"         { ultima_linea_token = yylineno; return WHILE; }
"True"          { ultima_linea_token = yylineno; return TRUE; }
"False"         { ultima_linea_token = yylineno; return FALSE; }
"range"         { ultima_linea_token = yylineno; return RANGE; }

[a-zA-Z_][a-zA-Z0-9_]* { 
    ultima_linea_token = yylineno;
    yylval.id_val = buscar_o_agregar_id(yytext);
    yylval.str_val = strdup(yytext);
    return IDENTIFICADOR;
}

"**="           { return POT_ASIG; }
"//="           { return DIV_ENT_ASIG; }
"<<="           { return DESP_IZQ_ASIG; }
">>="           { return DESP_DER_ASIG; }
"=="            { return COMP_IGUAL; }
"!="            { return DISTINTO; }
"<>"            { return DISTINTO; }
"<="            { return MENOR_IGUAL; }
">="            { return MAYOR_IGUAL; }
"+="            { return SUMA_ASIG; }
"-="            { return RESTA_ASIG; }
"*="            { return MULT_ASIG; }
"/="            { return DIV_ASIG; }
"&="            { return AND_ASIG; }
"|="            { return OR_ASIG; }
"^="            { return XOR_ASIG; }
"%="            { return MOD_ASIG; }
"**"            { return POT; }
"//"            { return DIV_ENT; }
"<<"            { return DESP_IZQ; }
">>"            { return DESP_DER; }
"+"             { return SUMA; }
"-"             { return MENOS; }
"*"             { return MULT; }
"/"             { return DIV; }
"%"             { return MOD; }
"<"             { return MENOR; }
">"             { return MAYOR; }
"&"             { return AND_BIT; }
"|"             { return OR_BIT; }
"^"             { return XOR_BIT; }
"~"             { return NOT_BIT; }
"="             { return ASIG; }

[0-9]+[Ll]      { 
    yylval.str_val = strdup(yytext);
    return LONG_INT; 
}

([+-]?([0-9]+\.[0-9]+|[0-9]+\.[0-9]*|[0-9]*\.[0-9]+|[0-9]+))([eE][+-]?[0-9]+)?[jJ] { 
    yylval.str_val = strdup(yytext);
    return IMAGINARIO; 
}

([+-]?([0-9]+\.[0-9]+|[0-9]+\.[0-9]*|[0-9]*\.[0-9]+))([eE][+-]?[0-9]+)? { 
    yylval.str_val = strdup(yytext);
    return REAL; 
}

[+-]?[0-9]+     { 
    yylval.int_val = atoi(yytext);
    yylval.str_val = strdup(yytext);
    return ENTERO; 
}

\"[^\"\n]*\"    { 
    yylval.str_val = strdup(yytext);
    return CADENA; 
}

'[^'\n]*'       { 
    yylval.str_val = strdup(yytext);
    return CADENA; 
}

"("             { return PARABRE; }
")"             { return PARCIERR; }
"["             { return CORABRE; }
"]"             { return CORCIERR; }
":"             { return DOSPUNTOS; }
","             { return COMA; }
";"             { return PTOCOMA; }
"."             { return PUNTO; }

.               {
    fprintf(stderr, "Error léxico en línea %d: carácter no reconocido '%s'\n", yylineno, yytext);
    registrar_error(yylineno); // Registrar inmediatamente el error léxico
    hubo_error_lexico = 1; // Marcar que hubo error léxico
    return ERROR_LEXICO;
}

%%

int buscar_o_agregar_id(char* nombre) {
    for (int i = 0; i < num_identificadores; i++) {
        if (strcmp(tabla_ids[i].nombre, nombre) == 0) {
            return tabla_ids[i].id_num;
        }
    }
    if (num_identificadores < MAX_IDENTIFICADORES) {
        tabla_ids[num_identificadores].nombre = strdup(nombre);
        tabla_ids[num_identificadores].id_num = num_identificadores + 1;
        return tabla_ids[num_identificadores++].id_num;
    }
    return -1;
}