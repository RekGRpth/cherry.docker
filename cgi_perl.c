#include <EXTERN.h>
#include <perl.h>
#include "XSUB.h"

void xs_init(pTHX);

static PerlInterpreter *interpreter;

void uwsgi_cgi_load_perl() {
    if (!(interpreter = perl_alloc())) { fprintf(stderr, "!perl_alloc"); exit(EXIT_FAILURE); }
    perl_construct(interpreter);
    PL_origalen = 1;
}

void uwsgi_cgi_run_perl(char *filename) {
    char *embedding[] = { "", filename, NULL };
    if (perl_parse(interpreter, xs_init, 2, embedding, NULL)) { fprintf(stderr, "perl_parse"); exit(EXIT_FAILURE); }
    if (perl_run(interpreter)) { fprintf(stderr, "perl_run"); exit(EXIT_FAILURE); }
}
