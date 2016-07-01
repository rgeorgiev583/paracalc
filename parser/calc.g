unsigned long int* res;

#define CALCULATE(lhs, rhs1, op, rhs3) {\
    res = (unsigned long int*) malloc(sizeof(unsigned long int));\
    *res = *(unsigned long int*) rhs1 op *(unsigned long int*) rhs3;\
    lhs = (void*) res;\
}

%%

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
    | expr PLUS term       { CALCULATE($$,$1,+,$3); }
    | expr MINUS term      { CALCULATE($$,$1,-,$3); }
    ;

term:
    factor
    | term TIMES factor    { CALCULATE($$,$1,*,$3); }
    | term OVER factor     { CALCULATE($$,$1,/,$3); }
    ;

factor:
    UINT
    | LPAR expr RPAR       { $$ = $2; }
    ;
