%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

extern int yylineno;
%}

/* Declaración de tokens */
%token INICIO FIN IMPRIMIR
%token ID CONSTANTE CADENA
%token ASIGNACION
%token SUMA PRODUCTO
%token PUNTOYCOMA PARENIZQUIERDO PARENDERECHO
%token ERROR

/* Asociatividad y precedencia de operadores */
%left SUMA
%left PRODUCTO
%left DIVISION
%start programa

%%

/* Reglas de la Gramática */

programa:
      INICIO lista_sentencias FIN
    ;

lista_sentencias:
      /* vacío */
    | lista_sentencias sentencia
    ;

sentencia:
      asignacion PUNTOYCOMA
    | impresion PUNTOYCOMA
    ;

asignacion:
      ID ASIGNACION expresion
    ;

impresion:
      IMPRIMIR expresion
    ;

expresion:
      CONSTANTE
    | ID
    | CADENA
    | expresion SUMA expresion
    | expresion PRODUCTO expresion
    | PARENIZQUIERDO expresion PARENDERECHO
    ;

%%

/* Sección de código de usuario */

void yyerror(const char *s) {
    fprintf(stderr, "Error de sintaxis en línea %d: %s\n", yylineno, s);
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
