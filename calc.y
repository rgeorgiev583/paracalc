%{
    #include <stdio.h>
    int yylex(void);
    void yyerror(char*);
%}

%token INTEGER
%left '+' '-'
%left '*' '/'

%%

stmt:
    expr               { printf("%d\n", $1); }
    | /* nothing */
    ;

expr:
    term
    | expr '+' term    { $$ = $1 + $3; }
    | expr '-' term    { $$ = $1 - $3; }
    ;

term:
    factor
    | term '*' factor  { $$ = $1 * $3; }
    | term '/' factor  { $$ = $1 / $3; }
    ;

factor:
    INTEGER
    | '(' expr ')'     { $$ = $2; }
    ;

%%

void yyerror(char *s)
{
    fprintf(stderr, "%s\n", s);
}

int main(void)
{
    yyparse();
}
