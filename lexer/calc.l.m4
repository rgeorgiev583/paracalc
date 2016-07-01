changequote(`[[', `]]')dnl
define([[TOKEN_CHAR]], [[<INITIAL>{$1} {
    flex_token->token = $1;
    char ch = '$2';
    flex_token->semantic_value = push_sem_value_on_stack(flex_token->stack_char, (void *)&ch, flex_token->realloc_size, 0);
    if(flex_token->num_chars >= flex_token->chunk_length)
        flex_token->chunk_ended = 1;
    return __LEX_CORRECT;
}]])dnl
dnl
%option noyywrap
%option noinput
%option nounput
%option reentrant

%{
    #include <stdlib.h>
    #include <limits.h>
    #include <errno.h>

    #include "grammar_tokens.h"
    #include "flex_return_codes.h"
    #include "flex_token.h"
    #include "sem_value_stack.h"

    char *ch;
    uint32_t *num;
%}

%option extra-type="struct lex_token *"

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
struct lex_token * flex_token = yyextra;
%}

TOKEN_CHAR([[LPAR]],  [[(]])
TOKEN_CHAR([[RPAR]],  [[)]])
TOKEN_CHAR([[PLUS]],  [[+]])
TOKEN_CHAR([[MINUS]], [[-]])
TOKEN_CHAR([[TIMES]], [[*]])
TOKEN_CHAR([[OVER]],  [[/]])

<INITIAL>{UINT} {
    flex_token->token = UINT;
    unsigned long int num = strtoul(yytext, NULL, 10);
    if ((num == ULONG_MAX && errno == ERANGE) || (num == 0 && errno == EINVAL)) {
       /* Could not convert. */
       return __ERROR;
    }
    flex_token->semantic_value = push_sem_value_on_stack(flex_token->stack_int, (void *)&num, flex_token->realloc_size, 1);
    return __LEX_CORRECT;
}

<INITIAL>{SPACE} {
    /* skip whitespace */
    if(flex_token->num_chars >= flex_token->chunk_length)
        return __END_OF_CHUNK;
}

<INITIAL>. { return __ERROR; }

%%
