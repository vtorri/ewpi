

#ifdef _WIN32
# include <windows.h>
#else
# include <stdio.h>
# include <sys/types.h>
# include <sys/stat.h>
# include <sys/mman.h>
# include <unistd.h>
# include <dirent.h>
# include <fcntl.h>
#endif

#include "ewpi_map2.h"

#ifdef _WIN32

int
ewpi_map_new(Map *map, const char *filename)
{
    BY_HANDLE_FILE_INFORMATION info;

    if (!filename)
        return 0;

    map->file = CreateFile(filename,
                           GENERIC_READ,
                           FILE_SHARE_READ,
                           NULL,
                           OPEN_EXISTING,
                           FILE_ATTRIBUTE_NORMAL,
                           NULL);
    if (map->file == INVALID_HANDLE_VALUE)
        return 0;

    if (!GetFileInformationByHandle(map->file, &info))
        goto close_file;

    if (!(info.dwFileAttributes | FILE_ATTRIBUTE_NORMAL))
        goto close_file;

#ifdef _WIN64
    map->length = (((size_t)info.nFileSizeHigh) << 32) | (size_t)info.nFileSizeLow;
#else
    map->length = (size_t)info.nFileSizeLow;
#endif

    map->map = CreateFileMapping(map->file,
                                 NULL, PAGE_READONLY,
                                 0, 0, NULL);
    if (!map->map)
        goto close_file;

    map->base = MapViewOfFile(map->map, FILE_MAP_READ, 0, 0, 0);
    if (!map->base)
        goto close_file_map;

    return 1;

  close_file_map:
    CloseHandle(map->map);
  close_file:
    CloseHandle(map->file);

    return 0;
}

void
ewpi_map_del(Map *map)
{
    UnmapViewOfFile(map->base);
    CloseHandle(map->map);
    CloseHandle(map->file);
}

#else

int
ewpi_map_new(Map *map, const char *filename)
{
    struct stat st;

    if (!filename)
        return 0;

    map->fd = open(filename, O_RDONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
    if (map->fd == -1)
    {
        printf("Can not open file %s\n", filename);
        return 0;
    }

    if (fstat(map->fd, &st) == -1)
    {
        printf("Can not retrieve stat from file %s\n", filename);
        goto close_fd;
    }

    if (!(S_ISREG(st.st_mode) || S_ISLNK(st.st_mode)))
    {
        printf("file %s is not a regular file nor a symbolic link\n", filename);
        goto close_fd;
    }

    map->length = st.st_size;

    map->base = mmap(NULL, map->length, PROT_READ, MAP_SHARED, map->fd, 0);
    if (!map->base)
    {
        printf("Can not map file %s into memory\n", filename);
        goto close_fd;
    }

    return 1;

  close_fd:
    close(map->fd);

    return 0;
}

void
ewpi_map_del(Map *map)
{
    munmap(map->base, map->length);
    close(map->fd);
}

#endif
