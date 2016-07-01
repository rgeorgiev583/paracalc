#include <gmp.h>
mpz_t res;

#define CALCULATE(lhs, rhs1, op, rhs3) {\
    mpz_init(res);\
    mpz_##op(res, (mpz_t) rhs1, (mpz_t) rhs3);\
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
    term                   { $$ = $1; }
    | expr PLUS term       { CALCULATE($$,$1,add,$3); }
    | expr MINUS term      { CALCULATE($$,$1,sub,$3); }
    ;

term:
    factor                 { $$ = $1; }
    | term TIMES factor    { CALCULATE($$,$1,mul,$3); }
    | term OVER factor     { CALCULATE($$,$1,cdiv_q,$3); }
    ;

factor:
    UINT                   { $$ = $1; }
    | LPAR expr RPAR       { $$ = $2; }
    ;
