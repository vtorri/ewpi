#include <stdio.h>

#ifdef _WIN32
# include <windows.h>
#else
#endif

#include "ewpi_spawn.h"

#ifdef _WIN32

int ewpi_spawn(char *cmd)
{
    STARTUPINFO si;
    PROCESS_INFORMATION pi;
    SECURITY_ATTRIBUTES sa;
    HANDLE pipe_out_read;
    HANDLE pipe_out_write;
    HANDLE pipe_err_read;
    HANDLE pipe_err_write;
    DWORD exit_code;
    BOOL res;

    sa.nLength = sizeof(SECURITY_ATTRIBUTES);
    sa.lpSecurityDescriptor = NULL;
    sa.bInheritHandle = TRUE;

    if (!CreatePipe(&pipe_out_read, &pipe_out_write, &sa, 0))
        return 0;

    if (!SetHandleInformation(pipe_out_read, HANDLE_FLAG_INHERIT, 0) )
        goto close_pipe_out;

    if (!CreatePipe(&pipe_err_read, &pipe_err_write, &sa, 0))
        goto close_pipe_out;

    if (!SetHandleInformation(pipe_err_read, HANDLE_FLAG_INHERIT, 0))
        goto close_pipe_err;

    ZeroMemory(&pi, sizeof(PROCESS_INFORMATION));

    ZeroMemory(&si, sizeof(STARTUPINFO));
    si.cb = sizeof(STARTUPINFO);
    si.dwFlags = STARTF_USESTDHANDLES;
    si.hStdError = pipe_err_write;
    si.hStdOutput = pipe_out_write;

    if (!CreateProcess(NULL, cmd, NULL, NULL,
                       TRUE, 0UL, NULL, NULL, &si, &pi))
        goto close_pipe_err;

    CloseHandle(pipe_err_write);
    CloseHandle(pipe_out_write);

    WaitForSingleObject(pi.hProcess, INFINITE);

    res = GetExitCodeProcess(pi.hProcess, &exit_code);

    CloseHandle(pi.hProcess);
    CloseHandle(pi.hThread);

    if (!res)
        goto close_pipe_err;

    if (exit_code != 0UL)
        goto close_pipe_err;

    return 1;

  close_pipe_err:
    CloseHandle(pipe_err_read);
    CloseHandle(pipe_err_write);
  close_pipe_out:
    CloseHandle(pipe_out_read);
    CloseHandle(pipe_out_write);

    return 0;
}

#else

int ewpi_spawn(const char *process, const char *option)
{
}

#endif
