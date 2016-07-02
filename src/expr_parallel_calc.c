#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <ctype.h>
#include <gmp.h>
#include "parser.h"


int main(int argc, char **argv)
{
  int32_t c, threads;
  char* file_name;
  FILE* out = stdout;

  /* Get input parameters. */
  threads = 1;
  file_name = NULL;
  c = getopt(argc, argv, ":j:o:");
  while (c != -1) {
    switch (c) {
      case 'j':
        threads = atoi(optarg);
        break;
      case 'o':
        out = fopen(optarg, "a");
        if (!out)
          fprintf(stderr, "Could not open output file (%s).\n", optarg);
        break;
      default:
        if (optopt == 'j' || optopt == 'o')
          fprintf(stdout, "Option -%c requires an argument.\n", optopt);
        else if (isprint(optopt))
          fprintf(stdout, "Unknown option `-%c'.\n", optopt);
        else
          fprintf(stdout, "Unknown option character `\\x%x'.\n", optopt);
        return 0;
    }
    c = getopt(argc, argv, ":j:");
  }
  if (optind == argc - 1) {
    file_name = argv[argc - 1];
  } else {
    fprintf(stdout, "Parallel Calculator\n Usage: %s [-j threads] filename\n", argv[0]);
    return 0;
  }
  token_node* result = parse(threads,0, file_name);
  if (out == stdout)
    printf("\nResult is: ");
  mpz_out_str(out, 10, *(mpz_t*) result->value);
  fprintf(out, "\n");
  if (out != stdout)
  {
    fclose(out);
    printf("\n");
  }

  return 0;
}
