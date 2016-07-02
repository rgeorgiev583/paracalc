changequote(`[[', `]]')dnl
define([[TOKEN_CHAR]], [[<INITIAL>{$1} {
    flex_token->token = $1;
    flex_token->semantic_value = NULL;
    return __LEX_CORRECT;
}]])dnl
dnl
%{
#include <stdlib.h>
#include <gmp.h>
%}

%option noyywrap
%option noinput
%option nounput

LPAR     \(
RPAR     \)
PLUS     \+
MINUS     -
TIMES    \*
OVER     \/
UINT     0|[1-9][0-9]*
SPACE    [ \t\n]

%%

%{
#include "grammar_tokens.h"
#include "flex_return_codes.h"

struct lex_token {
    gr_token token;
    void* semantic_value;
};

extern struct lex_token* flex_token;
mpz_t* num;
%}

TOKEN_CHAR([[LPAR]])
TOKEN_CHAR([[RPAR]])
TOKEN_CHAR([[PLUS]])
TOKEN_CHAR([[MINUS]])
TOKEN_CHAR([[TIMES]])
TOKEN_CHAR([[OVER]])

<INITIAL>{UINT} {
    flex_token->token = UINT;
    num = malloc(sizeof(mpz_t));
    if (mpz_init_set_str(*num, yytext, 10) == -1) {
       /* Could not convert. */
       return __ERROR;
    }
    flex_token->semantic_value = num;
    return __LEX_CORRECT;
}

<INITIAL>{SPACE} ; /* skip whitespace */
<INITIAL>. { return __ERROR; }

%%
