

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

int ewpi_map_new(Map *map, const char *filename);

void ewpi_map_del(Map *map);
