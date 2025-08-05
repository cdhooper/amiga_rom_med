#include <stdlib.h>
#include <string.h>
#ifndef AMIGA
#include <unistd.h>
#include <err.h>
#endif
#include "med_cmdline.h"
#include "printf.h"

int
main(int argc, char **argv)
{
    char *cmdbuf = cmd_string_from_argv(argc - 1, argv + 1);

    if (cmdbuf == NULL) {
        exit(cmdline());
    } else {
        int rc = cmd_exec_string(cmdbuf);
        free(cmdbuf);
        exit(rc);
    }
}
