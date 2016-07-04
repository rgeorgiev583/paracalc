#include <omp.h>
#include "parser.h"
#include "timers.h"

void compute_preallocation_sizes(parsing_ctx* ctx,int32_t threads){

  float cur_node_estimate;

  ctx->NODE_ALLOC_SIZE = 1;
  cur_node_estimate = 1;
  while (cur_node_estimate < ctx->token_list_length) {
    cur_node_estimate *= __RHS_LENGTH;
    ctx->NODE_ALLOC_SIZE += (uint32_t) cur_node_estimate;
  }
  ctx->NODE_ALLOC_SIZE -= cur_node_estimate;
  ctx->NODE_ALLOC_SIZE = ctx->NODE_ALLOC_SIZE*2/3/threads;
  ctx->NODE_REALLOC_SIZE = ctx->NODE_ALLOC_SIZE/10 + 1;

  ctx->PREC_ALLOC_SIZE = ctx->token_list_length/100;
  ctx->PREC_ALLOC_SIZE += 4096/sizeof(token_node *) - ((ctx->PREC_ALLOC_SIZE*sizeof(token_node *)) % 4096)/sizeof(token_node *);
  ctx->PREC_REALLOC_SIZE = ctx->PREC_ALLOC_SIZE/10;
}

void pretty_print_parse_status(uint32_t parse_status){
   fprintf(stdout, "Parse action finished: ");
   switch (parse_status){
     case __PARSE_SUCCESS:
       fprintf(stdout,  "Successful parse.\n");
       break;
     case __PARSE_NOT_RECOGNIZED:
      fprintf(stdout, "The string does not belong to the language.\n");
      break;
     case __PARSE_IN_PROGRESS:
      fprintf(stdout, "Chunk parse ended, more parsing to be done.\n");
      break;
     default:
      fprintf(stdout, "Invalid return code!\n");
  }
}

token_node *parse(int32_t threads, int32_t lex_thread_max_num, char *file_name)
{
  uint32_t i, parse_status;
  uint32_t step_size, step_index;
  uint8_t *results;
  parsing_ctx ctx;
  token_node **bounds;
  token_node *list_ptr;
  token_node *l_token = NULL;
  thread_shared_t shared;
  thread_context_t *contexts;
  struct timespec parse_timer_start, parse_timer_end, lex_timer_start, lex_timer_end;
  double lexing_time, parsing_time, total_time;
  /* Redirect stderr. */
#ifdef __DEBUG
  if (freopen("DEBUG", "w", stderr) == NULL) {
    DEBUG_STDOUT_PRINT("OPP> Error: could not redirect stderr to DEBUG.\n")
  }
#endif

  init_offline_structures(&ctx);

  portable_clock_gettime(&lex_timer_start);

  DEBUG_STDOUT_PRINT("OPP> Lexing...\n")
  perform_lexing(file_name, &ctx);
  portable_clock_gettime(&lex_timer_end);

  portable_clock_gettime(&parse_timer_start);

  compute_preallocation_sizes(&ctx,threads);
  bounds = compute_bounds(ctx.token_list_length, threads, ctx.token_list);

  VERBOSE_PRINT("OPP> Number of threads used in the current run: %d\n", threads)

  omp_set_dynamic(0);               // Explicitly disable dynamic teams
  omp_set_num_threads(threads + 1); // Use `threads` threads for all consecutive parallel regions

  /* Allocate threads. */
  contexts = (thread_context_t *) malloc(sizeof(thread_context_t) * (threads + 1));
  results = (uint8_t *) malloc(sizeof(uint8_t)*(threads + 1));
  if (contexts == NULL || results == NULL) {
      VERBOSE_PRINT("ERROR> Thread allocation failed!\n")
      return NULL;
  }
  shared.args = contexts;
  shared.results = results;
  shared.ctx = &ctx;

  /* Create and launch threads. */
  step_size = threads;
  step_index = 0;
  /* Create initial common threads. */
  for (i = 0; i < threads; ++i) {
    VERBOSE_PRINT("OPP> Creating thread %d.\n", i)
    contexts[i].id = i;
    /* Set list_begin. */
    if (i == 0) {
      contexts[i].list_begin = bounds[i];
      VERBOSE_PRINT("OPP> list begin first thread %s\n", gr_token_to_string(bounds[i]->token));
    } else {
      list_ptr = bounds[i]->next;
      contexts[i].list_begin = list_ptr;
      VERBOSE_PRINT("OPP> list begin thread %d is %s\n", i, gr_token_to_string(list_ptr->token));
    }
    /* Get prev context. */
    if (i == 0) {
      l_token = new_token_node(__TERM, NULL);
      VERBOSE_PRINT("OPP> c_prev context thread %d is __TERM\n", i);
    } else {
      list_ptr = bounds[i];
      l_token = new_token_node(list_ptr->token, NULL);
      VERBOSE_PRINT("OPP> c_prev context thread %d is %s\n", i, gr_token_to_string(list_ptr->token));
    }
    l_token->next = contexts[i].list_begin;
    contexts[i].c_prev = l_token;
    /* Get next context. */
    if (i == threads - 1) {
      l_token = new_token_node(__TERM, NULL);
      VERBOSE_PRINT("OPP> c_next context thread %d is __TERM\n", i);
    } else {
      list_ptr = bounds[i + 1]->next;
      l_token = new_token_node(list_ptr->token, NULL);
      VERBOSE_PRINT("OPP> c_next context thread %d is %s\n", i, gr_token_to_string(list_ptr->token));
    }
    contexts[i].c_next = l_token;
    /* Set list end. */
    contexts[i].list_end = (i + 1 < threads ? bounds[i + 1]->next : NULL);
    contexts[i].num_parents = 0;
    #pragma omp parallel
    #pragma omp single nowait
    #pragma omp task shared(shared)
    thread_task(&shared, &contexts[i]);
  }

  contexts[threads].id = threads;
  contexts[threads].c_prev = contexts[0].c_prev;
  contexts[threads].c_next = contexts[i - 1].c_next;
  contexts[threads].num_parents = threads;
  thread_task(&shared, &contexts[threads]);
  parse_status = results[threads];

  /* Free threads and arguments. */
  VERBOSE_PRINT("OPP> Freeing threads.\n")
  for (i = 0; i < threads; ++i) {
    free(contexts[i].c_prev);
    free(contexts[i].c_next);
  }

  // clock_gettime(CLOCK_REALTIME, &timer_r);
  portable_clock_gettime(&parse_timer_end);
  pretty_print_parse_status(parse_status);

  lexing_time=compute_time_interval(&lex_timer_start, &lex_timer_end);
  parsing_time=compute_time_interval(&parse_timer_start, &parse_timer_end);
  total_time=lexing_time+parsing_time;

  fprintf(stdout, "\nLexer: %lf ms\nParser: %lf ms\nTotal: %lf ms\n",lexing_time*1000,parsing_time*1000,total_time*1000);

  return ctx.token_list;
}

void init_offline_structures(parsing_ctx *ctx)
{
  ctx->token_list = NULL;
  ctx->grammar = NULL;
  ctx->token_list_length = 0;
  init_grammar(ctx);
}

token_node **compute_bounds(uint32_t length, uint8_t n, token_node *token_list)
{
  token_node **bounds;
  token_node *list;
  uint32_t n_len, n_itr, t_pos;

  bounds = (token_node**) malloc(sizeof(token_node*)*n);
  n_len = length / n;
  list = token_list;
  bounds[0] = list;
  list = list->next;
  t_pos = 1;
  n_itr = 1;
  while (list != NULL && t_pos < n_len*n) {
    if (t_pos % n_len == 0) {
      bounds[n_itr] = list;
      DEBUG_STDOUT_PRINT("PARSER> bounds %d has token %s in position %d \n", n_itr, gr_token_to_string(list->token), t_pos);
      ++n_itr;
    }
    list = list->next;
    ++t_pos;
  }
  return bounds;
}


void thread_task(thread_shared_t* thread_shared, thread_context_t* thread_context)
{
  struct timespec thread_timer_start, thread_timer_end;
  double thread_time;
  portable_clock_gettime(&thread_timer_start);
  thread_context_t *thread_arguments;
  uint32_t parse_result,i;
  uint32_t parent_index;
  token_node *list_ptr;
  uint32_t parse_status = __PARSE_IN_PROGRESS;

  thread_arguments = thread_shared->args;
  if (thread_context->num_parents > 0) {
    /* Wait for parent threads to finish. */
    #pragma omp taskwait
    for (i = 0; i < thread_context->num_parents; ++i) {
      parse_status = thread_shared->results[i];
      if (parse_status != __PARSE_IN_PROGRESS) {
        break;
      }
    }
    /* Join subtrees. */
    for (i = 0; i < thread_context->num_parents; ++i) {
      parent_index = i;
      list_ptr = thread_arguments[parent_index].c_prev;
      while (list_ptr->parent != NULL) {
        list_ptr = list_ptr->parent;
      }
      if (list_ptr != thread_shared->ctx->token_list) {
        list_ptr->next = thread_arguments[parent_index].c_prev->next;
      }
    }
    /* Get list_begin and list_end. */
    list_ptr = thread_arguments[0].list_begin;
    while (list_ptr->parent != NULL) {
      list_ptr = list_ptr->parent;
    }
    thread_context->list_begin = list_ptr;
    thread_context->list_end = thread_arguments[thread_context->num_parents - 1].list_end;
  }
  /* Launch parser. */
  if (parse_status == __PARSE_IN_PROGRESS) {
    parse_result = opp_parse(thread_context->c_prev, thread_context->c_next, thread_context->list_begin, thread_context->list_end, thread_shared->ctx);

  if (thread_context->num_parents > 0)
    VERBOSE_PRINT("Main routine> result %d\n", parse_result)
  else
    VERBOSE_PRINT("Thread %d> result %d\n", thread_context->id, parse_result)
  thread_shared->results[thread_context->id] = parse_result;

#ifdef __DEBUG
    if (parse_result== 0) {
      PRINT_TOKEN_NODE_TREE(thread_shared->ctx, 0, thread_shared->ctx->token_list)
    }
#endif

  } else {
    thread_shared->results[thread_context->id] = parse_status;
  }
  portable_clock_gettime(&thread_timer_end);
  thread_time = compute_time_interval(&thread_timer_start, &thread_timer_end);
  if (thread_context->num_parents > 0)
    VERBOSE_PRINT("Main routine> execution time was %lf ms\n", thread_time * 1000)
  else
    VERBOSE_PRINT("Thread %d> execution time was %lf ms\n", thread_context->id, thread_time * 1000)
}

