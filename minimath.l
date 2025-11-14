%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "minimath.tab.h" // generado por bison

extern int yylineno;
%}

%option noyywrap
%option yylineno

/* EXPRESIONES REGULARES */
LETRA        [a-zA-Z]
DIGITO       [0-9]
LETRA_GRIEGA_SOLA (\xCE\xB1)
IDENTIFICADOR_COMUN ([a-zA-Z_][a-zA-Z0-9_]{0,15})
IDENTIFICADOR_LARGO  ([a-zA-Z_][a-zA-Z0-9_]{16,})

%%
"imprimir"  { return IMPRIMIR; }
"INICIO"    { return INICIO; }
"FIN"       { return FIN; }

{IDENTIFICADOR_LARGO} {
    fprintf(stderr, "AL: el identificador '%s' en la linea %d es muy largo\n",
            yytext, yylineno);
    return ERROR;
}

{LETRA_GRIEGA_SOLA} {
    return ID;
}

{IDENTIFICADOR_COMUN} {
    return ID;
}

{DIGITO}+ {
    return CONSTANTE;
}

'[^'\n]*' {
    return CADENA;
}

"="   { return ASIGNACION; }
"+"   { return SUMA; }
"*"   { return PRODUCTO; }
"/"   { return DIVISION; }
";"   { return PUNTOYCOMA; }
"("   { return PARENIZQUIERDO; }
")"   { return PARENDERECHO; }

[ \t\n]+      { /* espacio/tab/salto no hacer nada */ }

. {
    fprintf(stderr, "AL: no reconoce '%s' en la linea %d\n", yytext, yylineno);
    return ERROR;
}

%%
