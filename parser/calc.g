%nonterminal stmt
%nonterminal expr
%nonterminal term
%nonterminal factor

%axiom stmt

%terminal LPAR
%terminal RPAR
%terminal PLUS
%terminal MINUS
%terminal TIMES
%terminal OVER
%terminal UINT

%%

stmt:
    expr               { printf("%d\n", $1); }
    | /* nothing */
    ;

expr:
    term
    | expr PLUS term       { }
    | expr MINUS term      { }
    ;

term:
    factor
    | term TIMES factor    { }
    | term OVER factor     { }
    ;

factor:
    UINT
    | LPAR expr RPAR       { }
    ;

%%
