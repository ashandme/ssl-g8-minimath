%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "minimath.tab.h"

char *yy_prev_text = NULL;

void print_token(int type, const char* text);

#define SAVE_PREV_TEXT() \
    do { free(yy_prev_text); yy_prev_text = strdup(yytext); } while (0)
%}

%option noyywrap
%option yylineno

LETRA        [a-zA-Z]
DIGITO       [0-9]
LETRA_GRIEGA ([\xCE][\x91-\xBF]|[\xCF][\x80-\xB7])
IDENTIFICADOR_VALIDO ({LETRA}|{LETRA_GRIEGA}|_)({LETRA}|{LETRA_GRIEGA}|{DIGITO}|_){0,15}
IDENTIFICADOR_LARGO  ({LETRA}|{LETRA_GRIEGA}|_)({LETRA}|{LETRA_GRIEGA}|{DIGITO}|_){16,}

%%

"si"        { SAVE_PREV_TEXT(); print_token(TOKEN_SI, yytext); return TOKEN_SI; }
"sino"      { SAVE_PREV_TEXT(); print_token(TOKEN_SINO, yytext); return TOKEN_SINO; }
"imprimir"  { SAVE_PREV_TEXT(); print_token(TOKEN_IMPRIMIR, yytext); return TOKEN_IMPRIMIR; }
"def"       { SAVE_PREV_TEXT(); print_token(TOKEN_DEF, yytext); return TOKEN_DEF; }
"INICIO"    { SAVE_PREV_TEXT(); print_token(TOKEN_INICIO, yytext); return TOKEN_INICIO; }
"FIN"       { SAVE_PREV_TEXT(); print_token(TOKEN_FIN, yytext); return TOKEN_FIN; }

"=="        { SAVE_PREV_TEXT(); print_token(TOKEN_IGUAL_IGUAL, yytext); return TOKEN_IGUAL_IGUAL; }
"!="        { SAVE_PREV_TEXT(); print_token(TOKEN_DISTINTO, yytext); return TOKEN_DISTINTO; }
">="        { SAVE_PREV_TEXT(); print_token(TOKEN_MAYOR_IGUAL, yytext); return TOKEN_MAYOR_IGUAL; }
"<="        { SAVE_PREV_TEXT(); print_token(TOKEN_MENOR_IGUAL, yytext); return TOKEN_MENOR_IGUAL; }
">"         { SAVE_PREV_TEXT(); print_token(TOKEN_MAYOR, yytext); return TOKEN_MAYOR; }
"<"         { SAVE_PREV_TEXT(); print_token(TOKEN_MENOR, yytext); return TOKEN_MENOR; }

{IDENTIFICADOR_LARGO} {
    fprintf(stderr, "Error: Identificador '%s' en la línea %d excede la longitud máxima de 16 caracteres.\n",
            yytext, yylineno);
    print_token(TOKEN_ERROR, yytext);
    return TOKEN_ERROR;
}

{IDENTIFICADOR_VALIDO} {
    SAVE_PREV_TEXT();
    print_token(TOKEN_IDENTIFICADOR, yytext);
    return TOKEN_IDENTIFICADOR;
}

{DIGITO}+ {
    SAVE_PREV_TEXT();
    print_token(TOKEN_NUMERO_ENTERO, yytext);
    return TOKEN_NUMERO_ENTERO;
}

\'([^\'\n]*)\' {
    SAVE_PREV_TEXT();
    print_token(TOKEN_CADENA_TEXTO, yytext);
    return TOKEN_CADENA_TEXTO;
}

"="   { SAVE_PREV_TEXT(); print_token(TOKEN_IGUAL, yytext); return TOKEN_IGUAL; }
"("   { SAVE_PREV_TEXT(); print_token(TOKEN_LPAREN, yytext); return TOKEN_LPAREN; }
")"   { SAVE_PREV_TEXT(); print_token(TOKEN_RPAREN, yytext); return TOKEN_RPAREN; }
"["   { SAVE_PREV_TEXT(); print_token(TOKEN_LBRACKET, yytext); return TOKEN_LBRACKET; }
"]"   { SAVE_PREV_TEXT(); print_token(TOKEN_RBRACKET, yytext); return TOKEN_RBRACKET; }
"*"   { SAVE_PREV_TEXT(); print_token(TOKEN_ASTERISCO, yytext); return TOKEN_ASTERISCO; }
"/"   { SAVE_PREV_TEXT(); print_token(TOKEN_SLASH, yytext); return TOKEN_SLASH; }
"+"   { SAVE_PREV_TEXT(); print_token(TOKEN_MAS, yytext); return TOKEN_MAS; }
"-"   { SAVE_PREV_TEXT(); print_token(TOKEN_MENOS, yytext); return TOKEN_MENOS; }
";"   { SAVE_PREV_TEXT(); print_token(TOKEN_PUNTO_Y_COMA, yytext); return TOKEN_PUNTO_Y_COMA; }
","   { SAVE_PREV_TEXT(); print_token(TOKEN_COMA, yytext); return TOKEN_COMA; }

[ \t\r\n]+   { /* ignorar espacios, tabs y saltos de línea */ }

. {
    fprintf(stderr, "Error: Caracter inesperado '%s' en la línea %d\n", yytext, yylineno);
    print_token(TOKEN_ERROR, yytext);
    return TOKEN_ERROR;
}

%%

void print_token(int type, const char* text) {
    const char* type_str;
    switch (type) {
        case TOKEN_SI: type_str = "Palabra reservada (si)"; break;
        case TOKEN_SINO: type_str = "Palabra reservada (sino)"; break;
        case TOKEN_IMPRIMIR: type_str = "Palabra reservada (imprimir)"; break;
        case TOKEN_DEF: type_str = "Palabra reservada (def)"; break;
        case TOKEN_INICIO: type_str = "Palabra reservada (INICIO)"; break;
        case TOKEN_FIN: type_str = "Palabra reservada (FIN)"; break;
        case TOKEN_IDENTIFICADOR: type_str = "Identificador"; break;
        case TOKEN_NUMERO_ENTERO: type_str = "Número entero"; break;
        case TOKEN_CADENA_TEXTO: type_str = "Cadena de texto"; break;
        case TOKEN_IGUAL: type_str = "Símbolo (=)"; break;
        case TOKEN_LPAREN: type_str = "Símbolo (()"; break;
        case TOKEN_RPAREN: type_str = "Símbolo ())"; break;
        case TOKEN_LBRACKET: type_str = "Símbolo ([)"; break;
        case TOKEN_RBRACKET: type_str = "Símbolo (])"; break;
        case TOKEN_ASTERISCO: type_str = "Símbolo (*)"; break;
        case TOKEN_SLASH: type_str = "Símbolo (/)"; break;
        case TOKEN_MAS: type_str = "Símbolo (+)"; break;
        case TOKEN_MENOS: type_str = "Símbolo (-)"; break;
        case TOKEN_PUNTO_Y_COMA: type_str = "Fin de sentencia (;)"; break;
        case TOKEN_COMA: type_str = "Símbolo (,)"; break;
        case TOKEN_MAYOR: type_str = "Operador mayor (>)"; break; // Aquí
        case TOKEN_MENOR: type_str = "Operador menor (<)"; break; // Aquí
        case TOKEN_MAYOR_IGUAL: type_str = "Operador mayor o igual (>=)"; break;
        case TOKEN_MENOR_IGUAL: type_str = "Operador menor o igual (<=)"; break;
        case TOKEN_IGUAL_IGUAL: type_str = "Operador igual a (==)"; break;
        case TOKEN_DISTINTO: type_str = "Operador distinto de (!=)"; break;
        case TOKEN_ERROR: type_str = "Error"; break;
        default: type_str = "Desconocido"; break;
    }
    printf("Token: %-30s Lexema: '%s'\n", type_str, text);
}