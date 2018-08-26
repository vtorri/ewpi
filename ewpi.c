#define _DEFAULT_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>

#ifdef _WIN32
# include <windows.h>
#else
# include <linux/limits.h>
# include <sys/mman.h>
# include <unistd.h>
# include <dirent.h>
# include <fcntl.h>
#endif

#include "ewpi_map.h"

#define EWPI_DEBUG 1
#define EWPI_DELETE 0

#ifdef _WIN32
# ifdef PATH_MAX
#  undef  PATH_MAX
# endif
# define PATH_MAX 32767
# define SEP_STR L"\\"
# define PACKAGES_STR L"\\packages"
# define CD L"cd packages/"
# define TAR_GZ L" && tar zxf "
# define TAR_XZ L" && tar Jxf "
typedef wchar_t Ewpi_Path;
#else
# define SEP_STR "/"
# define PACKAGES_STR "/packages"
# define CD "cd packages/"
# define TAR_GZ " && tar zxf "
# define TAR_XZ " && tar Jxf "
typedef char Ewpi_Path;
#endif

typedef struct
{
    char *name;
    char *url;
    int deps_count;
    char **deps;
    unsigned int installed : 1;
    unsigned int selected : 1;
} Package;

static Ewpi_Path *_ewpi_pkg_dir = NULL;
static int _ewpi_pkgs_count = 0;
static int _ewpi_pkgs_list_count = 0;
static Package *_ewpi_pkgs = NULL;
static size_t _ewpi_max_name_length = 0;
static int _ewpi_deps_count = 0;
static int *_ewpi_deps_index = NULL;

#define EWPI_NAME(it) \
    (it[0] == 'n') && \
    (it[1] == 'a') && \
    (it[2] == 'm') && \
    (it[3] == 'e') && \
    (it[4] == ':') && \
    (it[5] == ' ')

#define EWPI_URL(it) \
    (it[0] == 'u') && \
    (it[1] == 'r') && \
    (it[2] == 'l') && \
    (it[3] == ':') && \
    (it[4] == ' ')

#define EWPI_DEPS(it) \
    (it[0] == 'd') && \
    (it[1] == 'e') && \
    (it[2] == 'p') && \
    (it[3] == 's') && \
    (it[4] == ':')

#define EWPI_INSTALLED(it) \
    (iter[0] == 'i') && \
    (iter[1] == 'n') && \
    (iter[2] == 's') && \
    (iter[3] == 't') && \
    (iter[4] == 'a') && \
    (iter[5] == 'l') && \
    (iter[6] == 'l') && \
    (iter[7] == 'e') && \
    (iter[8] == 'd') && \
    (iter[9] == ':') && \
    (iter[10] == ' ')

static void *
_ewmp_str_get(const unsigned char *start, const unsigned char *end)
{
    char *str;

    str = (char *)malloc(end - start + 1);
    memcpy(str, start, end - start);
    str[end - start] = '\0';

    return str;
}

static Ewpi_Path *
_ewpi_strdup(const Ewpi_Path *str)
{
#ifdef _WIN32
    return _wcsdup(str);
#else
    return strdup(str);
#endif
}

static size_t
_ewpi_strlen(const Ewpi_Path *str)
{
#ifdef _WIN32
    return (size_t)lstrlenW(str);
#else
    return strlen(str);
#endif
}

static Ewpi_Path *
_ewpi_strcat(Ewpi_Path *dst, const Ewpi_Path *src)
{
#ifdef _WIN32
    return lstrcatW(dst, src);
#else
    return strcat(dst, src);
#endif
}

static int
ewpi_pkg_dir_set()
{
    Ewpi_Path buf[PATH_MAX];
    size_t l1;
    size_t l2;

#ifdef _WIN32
    if (!GetCurrentDirectoryW(PATH_MAX - 1, buf))
        return 0;
#else
    if (!getcwd(buf, PATH_MAX))
        return 0;
#endif

    l1 = _ewpi_strlen(buf);
    l2 = _ewpi_strlen(PACKAGES_STR);

    if ((l1 + l2) > (PATH_MAX))
        return 0;

    if (!_ewpi_strcat(buf, PACKAGES_STR))
        return 0;

    _ewpi_pkg_dir = _ewpi_strdup(buf);

    return (_ewpi_pkg_dir != NULL);
}

static void
ewpi_packages_count()
{
#ifdef _WIN32
    Ewpi_Path buf[PATH_MAX];
    WIN32_FIND_DATAW data;
    HANDLE h;

    if ((4 + lstrlenW(_ewpi_pkg_dir) + 2) > (PATH_MAX - 1))
        return;

    if ((!lstrcpyW(buf, L"\\\\?\\")) ||
        (!lstrcatW(buf, _ewpi_pkg_dir)) ||
        (!lstrcatW(buf, L"\\*")))
        return;

    if ((h = FindFirstFileW(buf, &data)) == INVALID_HANDLE_VALUE)
        return;

    do
    {
        if ((lstrcmpW(data.cFileName, L".") == 0) ||
            (lstrcmpW(data.cFileName, L"..") == 0))
            continue;

        _ewpi_pkgs_count++;
    } while (FindNextFileW(h, &data));

    FindClose(h);
#else
    DIR *dir;
    struct dirent *f;

    dir = opendir(_ewpi_pkg_dir);
    if (!dir)
        return;

    while ((f = readdir(dir)))
    {
        if ((strcmp(f->d_name, ".") == 0) ||
            (strcmp(f->d_name, "..") == 0))
            continue;

        _ewpi_pkgs_count++;
    }

    closedir(dir);
#endif
}

static void
ewpi_packages_fill(Map *map, int i)
{
    const unsigned char *iter;

    iter = map->base;

    while ((int)(iter - map->base) < (int)map->length)
    {
        if (EWPI_NAME(iter))
        {
            const unsigned char *iter2;

            iter += 6;
            iter2 = iter;
            while (*iter != '\n') iter++;
            _ewpi_pkgs[i].name = _ewmp_str_get(iter2, iter);
        }
        else if (EWPI_URL(iter))
        {
            const unsigned char *iter2;

            iter += 5;
            iter2 = iter;
            while (*iter != '\n') iter++;
            _ewpi_pkgs[i].url = _ewmp_str_get(iter2, iter);
        }
        else if (EWPI_DEPS(iter))
        {
            iter += 5;
            if (*iter == '\n')
            {
                _ewpi_pkgs[i].deps_count = 0;
                _ewpi_pkgs[i].deps = NULL;
            }
            else
            {
                const unsigned char *iter2;
                int j;

                iter2 = iter;
                _ewpi_pkgs[i].deps_count = 0;
                while (*iter != '\n')
                {
                    if (*iter == ' ')
                        _ewpi_pkgs[i].deps_count++;
                    iter++;
                }
                _ewpi_pkgs[i].deps = (char **)malloc(_ewpi_pkgs[i].deps_count * sizeof(char *));
                j = 0;
                iter2++;
                iter = iter2;
                while (*iter != '\n')
                {
                    if (*iter == ' ')
                    {
                        _ewpi_pkgs[i].deps[j] = (char *)malloc(iter - iter2 + 1);
                        memcpy(_ewpi_pkgs[i].deps[j], iter2, iter - iter2);
                        _ewpi_pkgs[i].deps[j][iter - iter2] = '\0';
                        j++;
                        iter2 = iter + 1;
                    }
                    iter++;
                }
                _ewpi_pkgs[i].deps[j] = (char *)malloc(iter - iter2 + 1);
                memcpy(_ewpi_pkgs[i].deps[j], iter2, iter - iter2);
                _ewpi_pkgs[i].deps[j][iter - iter2] = '\0';
            }
        }
        else if (EWPI_INSTALLED(iter))
        {
            const unsigned char *iter2;

            iter += 11;
            iter2 = iter;
            while (*iter != '\n') iter++;
            _ewpi_pkgs[i].installed = ((iter - iter2) == 2) ? 0 : 1;
        }

        iter++;
    }
}

static int
ewpi_packages_list()
{
    Ewpi_Path buf[PATH_MAX];
#ifdef _WIN32
    wchar_t buf2[PATH_MAX];
    WIN32_FIND_DATAW data;
    HANDLE h;
    size_t l1;
    int i;

    _ewpi_pkgs = (Package *)calloc(_ewpi_pkgs_count, sizeof(Package));
    if (!_ewpi_pkgs)
        return 0;

    if ((!lstrcpyW(buf, L"\\\\?\\")) ||
        (!lstrcatW(buf, _ewpi_pkg_dir)) ||
        (!lstrcatW(buf, L"\\*")))
        goto free_pkgs;

    if ((!lstrcpyW(buf2, _ewpi_pkg_dir)) ||
        (!lstrcatW(buf2, L"\\")))
        goto free_pkgs;

    l1 = lstrlenW(buf2);

    if ((h = FindFirstFileW(buf, &data)) == INVALID_HANDLE_VALUE)
        goto free_pkgs;

    i = 0;
    do
    {
        Map map;

        if ((lstrcmpW(data.cFileName, L".") == 0) ||
            (lstrcmpW(data.cFileName, L"..") == 0) ||
            ((l1 + lstrlenW(data.cFileName)) > PATH_MAX))
            continue;

        lstrcpyW(buf2, _ewpi_pkg_dir);
        lstrcatW(buf2, L"\\");
        lstrcatW(buf2, data.cFileName);
        lstrcatW(buf2, L"\\");
        lstrcatW(buf2, data.cFileName);
        lstrcatW(buf2, L".ewpi");

        if (!ewpi_map_new(&map, buf2))
            continue;

        ewpi_packages_fill(&map, i);

        ewpi_map_del(&map);

#if EWPI_DEBUG
        fprintf(stderr, " name: %s\n", _ewpi_pkgs[i].name);
        fprintf(stderr, " url: %s\n", _ewpi_pkgs[i].url);
        fprintf(stderr, " deps:");
        int j;
        for (j = 0; j < _ewpi_pkgs[i].deps_count; j++)
            fprintf(stderr, " %s", _ewpi_pkgs[i].deps[j]);
        fprintf(stderr, "\n");
        fprintf(stderr, " inst: %d\n", _ewpi_pkgs[i].installed);
#endif
        i++;
    } while (FindNextFileW(h, &data));

    FindClose(h);

    return 1;

  free_pkgs:
    free(_ewpi_pkgs);

    return 0;
#else
    DIR *dir;
    struct dirent *f;
    int i;

    _ewpi_pkgs = (Package *)calloc(_ewpi_pkgs_count, sizeof(Package));
    if (!_ewpi_pkgs)
        return 0;

    dir = opendir(_ewpi_pkg_dir);
    if (!dir)
        goto free_pkgs;

    i = 0;
    while ((f = readdir(dir)))
    {
        Map map;

        if ((strcmp(f->d_name, ".") == 0) ||
            (strcmp(f->d_name, "..") == 0))
            continue;
        strcpy(buf, _ewpi_pkg_dir);
        strcat(buf, "/");
        strcat(buf, f->d_name);
        strcat(buf, "/");
        strcat(buf, f->d_name);
        strcat(buf, ".ewpi");

        if (!ewpi_map_new(&map, buf))
            continue;

        ewpi_packages_fill(&map, i);

        ewpi_map_del(&map);

#if EWPI_DEBUG
        fprintf(stderr, " name: %s\n", _ewpi_pkgs[i].name);
        fprintf(stderr, " url: %s\n", _ewpi_pkgs[i].url);
        fprintf(stderr, " deps:");
        int j;
        for (j = 0; j < _ewpi_pkgs[i].deps_count; j++)
            fprintf(stderr, " %s", _ewpi_pkgs[i].deps[j]);
        fprintf(stderr, "\n");
        fprintf(stderr, " inst: %d\n", _ewpi_pkgs[i].installed);
#endif
        i++;
    }

    closedir(dir);

    return 1;

  free_pkgs:
    free(_ewpi_pkgs);

    return 0;
#endif
}

static int
_ewpi_pkg_index_get(const char *name)
{
    for (int i = 0; i < _ewpi_pkgs_count; i++)
    {
        if (strcmp(name, _ewpi_pkgs[i].name) == 0)
            return i;
    }

    return -1;
}

static void
_ewpi_list_fill(const char *name)
{
    Package pkg;
    int idx;
    int already_in = 0;

    idx = _ewpi_pkg_index_get(name);
    pkg = _ewpi_pkgs[idx];

    for (int i = 0; i < pkg.deps_count; i++)
        _ewpi_list_fill(pkg.deps[i]);

    for (int i = 0; i < _ewpi_deps_count; i++)
    {
        if (_ewpi_deps_index[i] == idx)
            already_in = 1;
    }

    /* FIXME: check if selected also */

    if (!already_in)
    {
        size_t len;

        _ewpi_deps_index[_ewpi_deps_count] = idx;
        _ewpi_deps_count++;
        len = strlen(pkg.name);
        if (len > _ewpi_max_name_length)
            _ewpi_max_name_length = len;

    }
}

static void
_ewpi_pkgs_extract(const char *name, const char *url)
{
    char buf[PATH_MAX];
    const char *tarname;
    const char *taropt;
    const char *taropt2;
    char *filename;
    int ret = 0;

    tarname = strrchr(url, '/');
    tarname++;

    filename = strrchr(url, '.');
    filename++;
    if ((*filename == 'g') || (*filename =='t'))
    {
        taropt = "xzf";
        taropt2 = "tzf";
    }
    else if (*filename == 'b')
    {
        taropt = "xjf";
        taropt2 = "tjf";
    }
    else
    {
        taropt = "xJf";
        taropt2 = "tJf";
    }

    snprintf(buf, sizeof(buf),
             "sh ./packages/%s/pre.sh %s %s %s %s",
             name, name, taropt, tarname, taropt2);
    /* fprintf(stderr, "%s\n", buf); */
    ret = system(buf);
    if (ret != 0)
    {
        fprintf(stderr, "error while extracting %s archive (%s)\n", name, tarname);
        exit(1);
    }
}

static void
_ewpi_pkgs_clean(const char *name, const char *url)
{
    char buf[PATH_MAX];
    const char *tarname;
    const char *taropt2;
    char *filename;
    int ret;

    tarname = strrchr(url, '/');
    tarname++;

    filename = strrchr(url, '.');
    filename++;
    if ((*filename == 'g') || (*filename =='t'))
    {
        taropt2 = "tzf";
    }
    else if (*filename == 'b')
    {
        taropt2 = "tjf";
    }
    else
    {
        taropt2 = "tJf";
    }

    snprintf(buf, sizeof(buf),
             "sh ./packages/%s/post.sh %s %s %s",
             name, name, tarname, taropt2);
    ret = system(buf);
    if (ret != 0)
    {
        fprintf(stderr, "error while cleaning %s. see post.log\n", name);
        exit(1);
    }
    //fprintf(stderr, "%s\n", buf);
}

static void
_ewpi_pkgs_install(int i, const char *prefix, const char *host)
{
    char buf[PATH_MAX];
    const char *name;
    const char *url;
    const char *tarname;
    const char *taropt2;
    char *filename;
    int ret;

    name = _ewpi_pkgs[_ewpi_deps_index[i]].name;
    url = _ewpi_pkgs[_ewpi_deps_index[i]].url;

    tarname = strrchr(url, '/');
    tarname++;

    filename = strrchr(url, '.');
    filename++;
    if ((*filename == 'g') || (*filename =='t'))
    {
        taropt2 = "tzf";
    }
    else if (*filename == 'b')
    {
        taropt2 = "tjf";
    }
    else
    {
        taropt2 = "tJf";
    }

    snprintf(buf, sizeof(buf),
             "sh ./packages/%s/install.sh %s %s %s %s %s",
             name, name, tarname, prefix, host, taropt2);
    /* fprintf(stderr, "%s\n", buf); */
    fprintf(stderr, "%s: compiling", name);
    fflush(stderr);
    ret = system(buf);
    fprintf(stderr, "\r%s: installed (ret=%d) \n", name, ret);
    fflush(stderr);
    if (ret != 0)
    {
        fprintf(stderr, "error while installing %s. see config.log or make.log\n", name);
        exit(1);
    }
}

static void
usage(const char *argv0)
{
    fprintf(stderr, "Usage: %s prefix host\n", argv0);
    fprintf(stderr, "Example: %s $HOME/ewpi i686-w64-mingw32\n", argv0);
    fprintf(stderr, "The prefix must be an absolute directory\n");
    fprintf(stderr, "Possible values for host: i686-w64-mingw32 and x86_64-w64-mingw32\n");
}

int main(int argc, char *argv[])
{
    char *prefix = NULL;
    char *host = NULL;

    if (argc != 3)
    {
        usage(argv[0]);
        return 1;
    }

    prefix = argv[1];
    {
        /* check if directory is absolute */
#ifdef _WIN32
        if (!((strlen(prefix) >= 2) &&
              (((prefix[0] >= 'a') && (prefix[0] <= 'z')) ||
               ((prefix[0] >= 'A') && (prefix[0] <= 'Z'))) &&
              (prefix[1] == ':')))
        {
            fprintf(stderr, "Usage: %s prefix host\n", argv[0]);
            fprintf(stderr, "The prefix must be an absolute directory\n");
            return 1;
        }
#else
        if (*prefix != '/')
        {
            fprintf(stderr, "Usage: %s prefix host\n", argv[0]);
            fprintf(stderr, "The prefix must be an absolute directory\n");
            return 1;
        }
#endif
    }

    host = argv[2];
    if ((strcmp(host, "i686-w64-mingw32") != 0) && (strcmp(host, "x86_64-w64-mingw32") != 0))
    {
        fprintf(stderr, "Usage: %s prefix host\n", argv[0]);
        fprintf(stderr, "Possible values for host: i686-w64-mingw32 and x86_64-w64-mingw32\n");
        return 1;
    }

    if (!ewpi_pkg_dir_set())
    {
        fprintf(stderr, "can not set package dir\n");
        return 1;
    }

    ewpi_packages_count();
    fprintf(stderr, "count : %d\n", _ewpi_pkgs_count);
    ewpi_packages_list();

    _ewpi_deps_index = (int *)malloc(_ewpi_pkgs_count * sizeof(int));
    _ewpi_list_fill("efl");

    for (int i = 0; i < _ewpi_pkgs_count; i++)
    {
        fprintf(stderr, " ***** %s\n", _ewpi_pkgs[_ewpi_deps_index[i]].name);
    }

    /* remove te last one (as it is EFL itself) */
    _ewpi_pkgs_list_count = _ewpi_pkgs_count - 1;

#if ! EWPI_DELETE
    fprintf(stderr, "Download packages :\n");
    {
        for (int i = 0; i < _ewpi_pkgs_list_count; i++)
        {
            char buf1[1024];
            char *name;
            char *url;
            size_t l1;
            int ret;

            name = _ewpi_pkgs[_ewpi_deps_index[i]].name;
            url = _ewpi_pkgs[_ewpi_deps_index[i]].url;

            l1 = strlen("wget -q --show-progress --no-check-certificate ");
            memcpy(buf1, "wget -q --show-progress --no-check-certificate ", l1);
            memcpy(buf1 + l1, url, strlen(url));
            l1 += strlen(url);
            memcpy(buf1 + l1, " -O packages/", strlen(" -O packages/"));
            l1 += strlen(" -O packages/");
            memcpy(buf1 + l1, name, strlen(name));
            l1 += strlen(name);
            memcpy(buf1 + l1, "/", 1);
            l1 += 1;
            url = strrchr(url, '/');
            url++;
            memcpy(buf1 + l1, url, strlen(url) + 1);
            ret = system(buf1);
            if (ret != 0)
            {
                fprintf(stderr, "error while downloading package %s (ret = %d)\n", name, ret);
                exit(1);
            }
        }
    }

    /* Extracting */
    {
        char info[80];

        for (int i = 0; i < _ewpi_pkgs_list_count; i++)
        {
            const char *ext = "Extracting: ";
            const char *name;
            const char *url;
            size_t k;
            size_t j;

            name = _ewpi_pkgs[_ewpi_deps_index[i]].name;
            url = _ewpi_pkgs[_ewpi_deps_index[i]].url;
            _ewpi_pkgs_extract(name, url);

            for (k = 0; k < strlen(ext); k++)
                info[k] = ext[k];
            info[k++] = ' ';
            info[k++] = '[';
            for (j = 1; j <= (size_t)(i+1); j++, k++)
                info[k] = '*';
            for (; j <= (size_t)_ewpi_pkgs_list_count; j++, k++)
                info[k] = ' ';
            info[k++] = ']';
            info[k++] = ' ';
            if ((i+1) < 10)
            {
                info[k++] = ' ';
                info[k++] = '0' + (i + 1);
            }
            else
            {
                info[k++] = '0' + ((i + 1) / 10);
                info[k++] = '0' + ((i + 1) % 10);
            }
            info[k++] = '/';
            info[k++] = '0' + _ewpi_pkgs_list_count / 10;
            info[k++] = '0' + _ewpi_pkgs_list_count % 10;
            info[k++] = '\0';
            fprintf(stderr, "%s\r", info);
            fflush(stderr);
        }
        fprintf(stderr, "\n");
        fflush(stderr);
    }

    fprintf(stderr, "Installing :\n");
    {
        for (int i = 0; i < _ewpi_pkgs_list_count; i++)
        {
            _ewpi_pkgs_install(i, prefix, host);
        }
    }
#endif /* EWPI_DELETE */

    /* Cleaning */
    {
        char info[80];

        for (int i = 0; i < _ewpi_pkgs_list_count; i++)
        {
            const char *ext = "Cleaning:  ";
            const char *name;
            const char *url;
            size_t k;
            size_t j;

            name = _ewpi_pkgs[_ewpi_deps_index[i]].name;
            url = _ewpi_pkgs[_ewpi_deps_index[i]].url;
            _ewpi_pkgs_clean(name, url);

            for (k = 0; k < strlen(ext); k++)
                info[k] = ext[k];
            info[k++] = ' ';
            info[k++] = '[';
            for (j = 1; j <= (size_t)(i + 1); j++, k++)
                info[k] = '*';
            for (; j <= (size_t)_ewpi_pkgs_list_count; j++, k++)
                info[k] = ' ';
            info[k++] = ']';
            info[k++] = ' ';
            if ((i + 1) < 10)
            {
                info[k++] = ' ';
                info[k++] = '0' + (i + 1);
            }
            else
            {
                info[k++] = '0' + ((i + 1) / 10);
                info[k++] = '0' + ((i + 1) % 10);
            }
            info[k++] = '/';
            info[k++] = '0' + _ewpi_pkgs_list_count / 10;
            info[k++] = '0' + _ewpi_pkgs_list_count % 10;
            info[k++] = '\0';
            fprintf(stderr, "%s\r", info);
            fflush(stderr);
        }
        fprintf(stderr, "\n");
        fflush(stderr);
    }

    return 0;

  free_pkg_dir:
    free(_ewpi_pkg_dir);

    return 1;
}
