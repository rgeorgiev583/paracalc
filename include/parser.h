#ifndef __PARSER_H_
#define __PARSER_H_

#include <unistd.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "config.h"

#include "debug_functions.h"
#include "grammar.h"
#include "opp.h"
#include "lex.h"
typedef struct thread_context_t{
  uint8_t id;
  uint16_t num_parents;
  token_node *list_begin;
  token_node *list_end;
  token_node *c_prev;
  token_node *c_next;
} thread_context_t;

typedef struct thread_shared_t{
  uint8_t *results;
  parsing_ctx *ctx;
  struct thread_context_t *args;
} thread_shared_t;

token_node *parse(int32_t threads,int32_t lex_thread_max_num, char *file_name);
void init_offline_structures(parsing_ctx *ctx);
token_node **compute_bounds(uint32_t length, uint8_t n, token_node *token_list);
void thread_task(thread_shared_t* thread_shared, thread_context_t* thread_context);
#endif
