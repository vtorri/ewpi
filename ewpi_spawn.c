#include <string.h>

#ifdef _WIN32
# include <stdio.h>
# include <windows.h>
#else
# include <errno.h>
# include <fcntl.h>
# include <stdlib.h>
# include <sys/wait.h>
# include <unistd.h>
#endif

#include "ewpi_spawn.h"

#ifdef _WIN32

int ewpi_spawn(const char *host, const char *prog, const char *option)
{
    char cmd[1024];
    STARTUPINFOA si;
    PROCESS_INFORMATION pi;
    SECURITY_ATTRIBUTES sa;
    HANDLE pipe_out_read = NULL;
    HANDLE pipe_out_write = NULL;
    HANDLE pipe_err_read = NULL;
    HANDLE pipe_err_write = NULL;
    DWORD exit_code = 1;
    BOOL res = FALSE;
    int written;

    if (prog == NULL || *prog == '\0')
        return 0;

    if (option == NULL)
        option = "";

    if (host != NULL && *host != '\0')
    {
        written = snprintf(cmd, sizeof(cmd), "%s-%s %s",
                           host, prog, option);
    }
    else
    {
        written = snprintf(cmd, sizeof(cmd), "%s %s",
                           prog, option);
    }

    if (written < 0 || (size_t)written >= sizeof(cmd))
        return 0;

    ZeroMemory(&sa, sizeof(sa));
    sa.nLength = sizeof(SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor = NULL;
    sa.bInheritHandle = TRUE;

    if (!CreatePipe(&pipe_out_read, &pipe_out_write, &sa, 0))
        goto cleanup;

    if (!SetHandleInformation(pipe_out_read, HANDLE_FLAG_INHERIT, 0))
        goto cleanup;

    if (!CreatePipe(&pipe_err_read, &pipe_err_write, &sa, 0))
        goto cleanup;

    if (!SetHandleInformation(pipe_err_read, HANDLE_FLAG_INHERIT, 0))
        goto cleanup;

    ZeroMemory(&pi, sizeof(pi));

    ZeroMemory(&si, sizeof(si));
    si.cb = sizeof(si);
    si.dwFlags = STARTF_USESTDHANDLES;
    si.hStdError = pipe_err_write;
    si.hStdOutput = pipe_out_write;

    if (!CreateProcessA(NULL, cmd, NULL, NULL,
                        TRUE, 0UL, NULL, NULL, &si, &pi))
        goto cleanup;

    CloseHandle(pipe_err_write);
    pipe_err_write = NULL;
    CloseHandle(pipe_out_write);
    pipe_out_write = NULL;

    WaitForSingleObject(pi.hProcess, INFINITE);

    res = GetExitCodeProcess(pi.hProcess, &exit_code);

    CloseHandle(pi.hProcess);
    pi.hProcess = NULL;

    CloseHandle(pi.hThread);
    pi.hThread = NULL;

    if (!res)
        goto cleanup;

    if (exit_code != 0UL)
        goto cleanup;

    return 1;

cleanup:
    if (pi.hProcess != NULL)
        CloseHandle(pi.hProcess);

    if (pi.hThread != NULL)
        CloseHandle(pi.hThread);

    if (pipe_out_read != NULL)
        CloseHandle(pipe_out_read);

    if (pipe_out_write != NULL)
        CloseHandle(pipe_out_write);

    if (pipe_err_read != NULL)
        CloseHandle(pipe_err_read);

    if (pipe_err_write != NULL)
        CloseHandle(pipe_err_write);

    return 0;
}

#else

int ewpi_spawn(const char *host, const char *prog, const char *option)
{
    pid_t pid;

    pid = fork();
    if (pid < 0)
        return 0;

    if (pid == 0)
    {
        /* child */
        char cmd[256];
        char *args[3];
        int fd;

        fd = open("/dev/null", O_WRONLY);
        if (fd <  0) exit(1);
        if (dup2(fd, 1) < 0) exit(1);
        if (dup2(fd, 2) < 0) exit(1);
        if (close(fd) < 0) exit(1);;

        *cmd = '\0';
        if (host)
        {
            strcat(cmd, host);
            strcat(cmd, "-");
        }
        strcat(cmd, prog);
        args[0] = cmd;
        args[1] = (char *)option;
        args[2] = NULL;
        execvp(args[0], args);
        exit(errno);
    }
    else
    {
        /* parent */
        int status;
        int ret;

        ret = waitpid(pid, &status, 0);
        if (ret != 0)
            return 0;

        return WIFEXITED(status) ? WEXITSTATUS(status) == 0 : 0;
    }
}

#endif
