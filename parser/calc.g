%nonterminal expr
%nonterminal term
%nonterminal factor

%axiom expr

%terminal LPAR
%terminal RPAR
%terminal PLUS
%terminal MINUS
%terminal TIMES
%terminal OVER
%terminal UINT

%%

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
