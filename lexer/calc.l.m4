changequote(`[[', `]]')dnl
define([[TOKEN_CHAR]], [[<INITIAL>{$1} {
    flex_token->token = $1;
    ch = (char*) malloc(sizeof(char));
    *ch = '$2';
    flex_token->semantic_value = (void*) ch;
    return __LEX_CORRECT;
}]])dnl
dnl
%option noyywrap
%option noinput
%option nounput

LPAR     \(
RPAR     \)
PLUS     \+
MINUS     -
TIMES    \*
OVER      /
UINT     0|[1-9][0-9]*
SPACE    [ \t\n]

%%

%{
    #include <stdlib.h>
    #include <limits.h>
    #include <errno.h>

    #include "grammar_tokens.h"
    #include "flex_return_codes.h"

    struct lex_token {
        gr_token token;
        void* semantic_value;
    };

    extern struct lex_token* flex_token;
    char *ch;
    uint32_t *num;
%}

TOKEN_CHAR([[LPAR]],  [[(]])
TOKEN_CHAR([[RPAR]],  [[)]])
TOKEN_CHAR([[PLUS]],  [[+]])
TOKEN_CHAR([[MINUS]], [[-]])
TOKEN_CHAR([[TIMES]], [[*]])
TOKEN_CHAR([[OVER]],  [[/]])

<INITIAL>{UINT} {
    flex_token->token = UINT;
    num = (unsigned long int*) malloc(sizeof(unsigned long int));
    *num = strtoul(yytext, NULL, 10);
    if (*num == ULONG_MAX && errno == ERANGE || *num == 0 && errno == EINVAL) {
       /* Could not convert. */
       return __ERROR;
    }
    flex_token->semantic_value = (void*) num;
    return __LEX_CORRECT;
}

<INITIAL>{SPACE} ; /* skip whitespace */
<INITIAL>. { return __ERROR; }

%%
