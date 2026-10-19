int ewpi_spawn(const char *host, const char *prog, const char *option);

/* Same as above, but passing NULL for prog/option means "no argument"
 * instead of the literal empty string. */
int ewpi_spawnv(const char *host, const char *prog, const char *arg);

/* Run argv[0] (NULL-terminated) without a shell. cwd may be NULL.
 * Returns 1 when the process exits 0, otherwise 0. */
int ewpi_run(const char *cwd, const char *const argv[]);
