

typedef struct
{
    unsigned char *base;
    size_t length;
#ifdef _WIN32
    HANDLE file;
    HANDLE map;
#else
    int fd;
#endif
} Map;

#ifdef _WIN32

int ewpi_map_new(Map *map, const wchar_t *filename);

#else

int ewpi_map_new(Map *map, const char *filename);

#endif

void ewpi_map_del(Map *map);
