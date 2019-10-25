#include <EXTERN.h>
#include <perl.h>

void xs_init(pTHX);

static PerlInterpreter *interpreter;

void uwsgi_cgi_load_perl() {
    interpreter = perl_alloc();
    perl_construct(interpreter);
}

void uwsgi_cgi_run_perl(char *filename) {
    char *embedding[] = { "", filename, NULL };
    perl_parse(interpreter, xs_init, 2, embedding, NULL);
    perl_run(interpreter);
}
