%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

extern int yylineno;

/* --- TABLA DE SIMBOLOS --- */
struct symbol {
    char *name;
    int value;
    struct symbol *next;
};

struct symbol *symbol_table = NULL;

struct symbol *lookup(char *name);
void insert(char *name, int value);
void check_identifier_value(char* name);
%}

%union {
    int ival;
    char *sval;
}

/* Declaración de tokens */
%token INICIO FIN
%token <sval> IMPRIMIR ID CADENA
%token <ival> CONSTANTE
%token ASIGNACION
%token DIVISION
%token SUMA PRODUCTO
%token PUNTOYCOMA PARENIZQUIERDO PARENDERECHO
%token ERROR

%type <ival> expresion

/* Asociatividad y precedencia de operadores */
%left SUMA
%left PRODUCTO DIVISION

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
      ID ASIGNACION expresion { insert($1, $3); }
    ;

impresion:
      IMPRIMIR PARENIZQUIERDO ID PARENDERECHO { check_identifier_value($3); }
    | IMPRIMIR PARENIZQUIERDO CADENA PARENDERECHO { printf("%s\n", $3); }
    | IMPRIMIR PARENIZQUIERDO expresion PARENDERECHO { printf("%d\n", $3); }
    ;

expresion:
      CONSTANTE           { $$ = $1; }
    | ID                  { struct symbol *s = lookup($1); if (s) $$ = s->value; else { yyerror("AS: Identificador no definido"); $$ = 0; } }
    | expresion SUMA expresion      { $$ = $1 + $3; }
    | expresion PRODUCTO expresion  { $$ = $1 * $3; }
    | expresion DIVISION expresion  { if ($3 != 0) $$ = $1 / $3; else { yyerror("AS: Division por cero"); $$ = 0; } }
    | PARENIZQUIERDO expresion PARENDERECHO { $$ = $2; }
    ;

%%

/* Sección de código de usuario */

void yyerror(const char *s) {
    fprintf(stderr, "AS: Error en línea %d: %s\n", yylineno, s);
}

/* --- Symbol Table Functions --- */
struct symbol *lookup(char *name) {
    for (struct symbol *sp = symbol_table; sp != NULL; sp = sp->next) {
        if (strcmp(sp->name, name) == 0) {
            return sp;
        }
    }
    return NULL; /* not found */
}

void insert(char *name, int value) {
    struct symbol *sp = lookup(name);
    if (sp == NULL) { /* new symbol */
        sp = (struct symbol *) malloc(sizeof(struct symbol));
        sp->name = strdup(name);
        sp->next = symbol_table;
        symbol_table = sp;
    }
    sp->value = value;
}
/* OBJETIVO DEL TP */
void check_identifier_value(char* name) {
    struct symbol *s = lookup(name);
    if (s) {
        if (s->value >= 1 && s->value <= 100) {
            printf("AS: El identificador '%s' está entre 1 y 100.\n", s->name);
        } else if (s->value > 100) {
            printf("AS: El identificador '%s' es mayor a 101.\n", s->name);
        } else {
            printf("AS: El identificador '%s' tiene un valor (%d) que no está en los rangos de interés.\n", s->name, s->value);
        }
    } else {
        fprintf(stderr, "AS: Identificador '%s' no definido al imprimir.\n", name);
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
        printf("Análisis sintáctico (AS) completado correctamente.\n");
    else
        printf("Hubo errores de sintaxis.\n");

    return 0;
}
