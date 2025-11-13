%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

extern int yylineno;
extern char *yytext;
extern char *yy_prev_text;
%}

%define parse.error verbose

%token TOKEN_SI TOKEN_SINO TOKEN_IMPRIMIR TOKEN_DEF
%token TOKEN_INICIO TOKEN_FIN
%token TOKEN_IDENTIFICADOR TOKEN_NUMERO_ENTERO TOKEN_CADENA_TEXTO
%token TOKEN_IGUAL TOKEN_LPAREN TOKEN_RPAREN
%token TOKEN_LBRACKET TOKEN_RBRACKET
%token TOKEN_ASTERISCO TOKEN_SLASH TOKEN_MAS TOKEN_MENOS
%token TOKEN_PUNTO_Y_COMA TOKEN_COMA
%token TOKEN_MAYOR TOKEN_MENOR TOKEN_MAYOR_IGUAL TOKEN_MENOR_IGUAL
%token TOKEN_IGUAL_IGUAL TOKEN_DISTINTO
%token TOKEN_ERROR

%start programa

%left TOKEN_MAS TOKEN_MENOS
%left TOKEN_ASTERISCO TOKEN_SLASH
%left TOKEN_MAYOR TOKEN_MENOR TOKEN_MAYOR_IGUAL TOKEN_MENOR_IGUAL TOKEN_IGUAL_IGUAL TOKEN_DISTINTO

%%

programa:
      TOKEN_INICIO sentencias TOKEN_FIN
   ;

sentencias:
      /* vacío */
    | sentencia
    | sentencias sentencia
   ;

sentencia:
      asignacion TOKEN_PUNTO_Y_COMA
    | impresion TOKEN_PUNTO_Y_COMA
    | estructura_si
    | definicion_funcion
   ;

asignacion:
      TOKEN_IDENTIFICADOR TOKEN_IGUAL expresion
   ;

impresion:
      TOKEN_IMPRIMIR expresion
   ;

estructura_si:
      TOKEN_SI TOKEN_LPAREN expresion TOKEN_RPAREN TOKEN_INICIO sentencias TOKEN_FIN
    | TOKEN_SI TOKEN_LPAREN expresion TOKEN_RPAREN TOKEN_INICIO sentencias TOKEN_FIN TOKEN_SINO TOKEN_INICIO sentencias TOKEN_FIN
   ;

definicion_funcion:
      TOKEN_DEF TOKEN_IDENTIFICADOR TOKEN_LPAREN lista_parametros TOKEN_RPAREN TOKEN_INICIO sentencias TOKEN_FIN
   ;

lista_parametros:
      /* vacío */ 
    | TOKEN_IDENTIFICADOR
    | lista_parametros TOKEN_COMA TOKEN_IDENTIFICADOR
   ;

expresion:
      TOKEN_NUMERO_ENTERO
    | TOKEN_IDENTIFICADOR
    | TOKEN_CADENA_TEXTO
    | expresion TOKEN_MAS expresion
    | expresion TOKEN_MENOS expresion
    | expresion TOKEN_ASTERISCO expresion
    | expresion TOKEN_SLASH expresion
    | TOKEN_LPAREN expresion TOKEN_RPAREN
    | expresion TOKEN_MAYOR expresion
    | expresion TOKEN_MENOR expresion
    | expresion TOKEN_MAYOR_IGUAL expresion
    | expresion TOKEN_MENOR_IGUAL expresion
    | expresion TOKEN_IGUAL_IGUAL expresion
    | expresion TOKEN_DISTINTO expresion
   ;

%%

void yyerror(const char *s) {
    extern int yylineno;
    extern char *yy_prev_text;

    fprintf(stderr, "Error de sintaxis en línea %d cerca de '%s'.\n",
            yylineno, yy_prev_text ? yy_prev_text : "EOF");

    // Sugerencias inteligentes según el último token
    if (yy_prev_text) {
        if (strcmp(yy_prev_text, "FIN") == 0 ||
            strcmp(yy_prev_text, "def") == 0 ||
            strcmp(yy_prev_text, "imprimir") == 0 ||
            strcmp(yy_prev_text, "si") == 0 ||
            strcmp(yy_prev_text, "sino") == 0 ||
            strcmp(yy_prev_text, "INICIO") == 0) {

            fprintf(stderr, "Sugerencia: revisá si falta un ';' antes de '%s'.\n", yy_prev_text);
        }
    }
}

int main(int argc, char *argv[]) {
    extern FILE *yyin;
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Error al abrir archivo");
            return 1;
        }
    }

    printf("Iniciando análisis sintáctico...\n");
    int resultado = yyparse();

    if (resultado == 0)
        printf("Análisis sintáctico completado correctamente.\n");
    else
        printf("Hubo errores de sintaxis.\n");

    return 0;
}