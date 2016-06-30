%{
    #include "y.tab.h"
    #include <stdlib.h>
    void yyerror(char*);
%}

%%

0|[1-9][0-9]*  {
                    yylval = atoi(yytext);
                    return INTEGER;
                }

[-+()/*]        { return *yytext; }

[ \t\n]         ; /* skip whitespace */

.               yyerror("unknown character");

%%

int yywrap(void)
{
    return 1;
}
