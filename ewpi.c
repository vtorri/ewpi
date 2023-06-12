#define _DEFAULT_SOURCE
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
# include <dirent.h>
#include <unistd.h>

#ifdef _WIN32
# include <windows.h>
# ifdef PATH_MAX
#  undef  PATH_MAX
# endif
# define PATH_MAX 32767
#else
# include <linux/limits.h>
# include <sys/mman.h>
# include <unistd.h>
# include <fcntl.h>
#endif

#include "ewpi_map.h"

#define EWPI_DEBUG 0

#define EWPI_NAME(it) \
    (it[0] == 'n') && \
    (it[1] == 'a') && \
    (it[2] == 'm') && \
    (it[3] == 'e') && \
    (it[4] == ':') && \
    (it[5] == ' ')

#define EWPI_VERSION(it) \
    (it[0] == 'v') && \
    (it[1] == 'e') && \
    (it[2] == 'r') && \
    (it[3] == 's') && \
    (it[4] == 'i') && \
    (it[5] == 'o') && \
    (it[6] == 'n') && \
    (it[7] == ':') && \
    (it[8] == ' ')

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

typedef struct
{
    char *name;
    char *version;
    int vmaj;
    int vmin;
    int vmic;
    int vrev;
    char *url;
    char *tarname;
    int deps_count;
    char **deps;
    unsigned int downloaded : 1;
    unsigned int extracted : 1;
    unsigned int installed : 1;
    unsigned int is_git : 1;
} Package;

static const int _ew_vmaj = 1;
static const int _ew_vmin = 0;

static char *_ew_package_dir_git = NULL;
static char *_ew_package_dir_dst = NULL;
static int _ew_package_count_total = 0;
static int _ew_package_deps_dst_count = 0;
static int *_ew_package_index = NULL;
static int _ew_package_count_not_downloaded = 0;
static int _ew_package_count_not_extracted = 0;
static int _ew_package_count_not_installed = 0;
static int _ew_package_name_size_max = 0;

static Package *_ewpi_pkgs = NULL;

static void *
_ew_str_get(const unsigned char *start, const unsigned char *end)
{
    char *str;

    str = (char *)malloc(end - start + 1);
    memcpy(str, start, end - start);
    str[end - start] = '\0';

    return str;
}

static void
_ew_usage(const char *argv0)
{
    printf("Usage: %s [OPTION]\n", argv0);
    printf("\n");
    printf("Compile and install the EFL dependencies.\n");
    printf("\n");
    printf("Optional arguments:\n");
    printf("  --help        show this help message and exit\n");
    printf("  --version     show the Ewpi version and exit\n");
    printf("  --prefix=DIR  install in  DIR (must be an absolute path)\n");
    printf("                  [default=$HOME/ewpi_$arch] $arch=32|64 base on\n");
    printf("                  host value\n");
    printf("  --host=VAL    host triplet, either i686-w64-mingw32 or x86_64-w64-mingw32\n");
    printf("                  [default=x86_64-w64-mingw32]\n");
    printf("  --arch=VAL    value passed to -march and -mtune gcc options\n");
    printf("                  [default=i686|x86-64], depending on host value\n");
    printf("  --winver=VAL  requested Windows version, win7 or win10 [default=win10]\n");
    printf("  --verbose     verbose mode\n");
    printf("  --strip       strip DLL\n");
    printf("  --nsis        strip DLL and create the NSIS installer\n");
    printf("  --efl         install the EFL\n");
    printf("  --jobs=VAL    maximum number of used jobs [default=maximum]\n");
    printf("  --clean       remove the archives and the created directories\n");
    printf("                  (not removed by default)\n");
    printf("\n");
    printf("Examples:\n");
    printf("  ./ewpi --prefix=/opt/ewpi_32 --host=i686-w64-mingw32\n");
    printf("  ./ewpi --host=x86_64-w64-mingw32 --efl --jobs=4\n");
    printf("\n");
    fflush(stdout);
}

static int
_ew_path_is_absolute(const char *path)
{
#ifdef _WIN32
        if (!((strlen(path) >= 2) &&
              (((path[0] >= 'a') && (path[0] <= 'z')) ||
               ((path[0] >= 'A') && (path[0] <= 'Z'))) &&
              (path[1] == ':')))
        {
            printf("The path must be an absolute directory\n");
            fflush(stdout);
            return 0;
        }
#else
        if (*path != '/')
        {
            printf("The path must be an absolute directory\n");
            fflush(stdout);
            return 0;
        }
#endif
        return 1;
}

static int
_ew_path_exists(const char *path)
{
    struct stat buf;

    if (stat(path, &buf) != 0)
        return 0;

    return S_ISDIR(buf.st_mode);
}

static int
_ew_file_exists(const char *file)
{
    struct stat buf;

    if ((stat(file, &buf) == 0) && S_ISREG(buf.st_mode))
        return buf.st_size;

    return 0;
}

static int
_ew_mkdir(const char *pathname, int mode)
{
#if _WIN32
    return mkdir(pathname);
    (void)mode;
#else
    return mkdir(pathname, mode);
#endif
}

static int
_ew_mkdir_p(const char *path)
{
    char *p;
    char *iter;

    p = strdup(path);
    if (!p)
        return 0;

    iter = strchr(p, '/');
    if (!iter)
        goto free_p;
    /* Windows : "*:/" and Unix : "/" so we skip first "/" */
    iter++;

    while (1)
    {
        iter = strchr(iter, '/');
        if (!iter)
        {
            _ew_mkdir(p, S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
            break;
        }

        *iter = '\0';
        if (!_ew_path_exists(p))
        {
            if (_ew_mkdir(p, S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH))
                goto free_p;
        }
        *iter = '/';
        iter++;
    }

    free(p);

    return 1;

  free_p:
    free(p);

    return 0;
}

static const char *_ew_req_host[] =
{
    "gcc",
    "g++",
    "ar",
    "dlltool",
    "nm",
    "ranlib",
    "strip",
    "windres",
    NULL
};

static const char *_ew_req[] =
{
    "make",
    "cmake",
    "python",
    "meson",
    "ninja",
    "yasm",
    "nasm",
    "gperf",
    "wget",
    "bison",
    "flex",
    "makensis",
    NULL
};

static int
_ew_requirements(const char *host)
{
    char buf[4096];
    int ret;

    for (int i = 0; _ew_req_host[i]; i++)
    {
#ifdef _WIN32
        const char *path;
        char cmd[4096];

        if (i >= 2)
        {
            if (strcmp(host, "x86_64-w64-mingw32") == 0)
                path = "/mingw64/bin/";
            else
                path = "/mingw32/bin/";
            strcpy(cmd, "cp ");
            strcat(cmd, path);
            strcat(cmd, _ew_req_host[i]);
            strcat(cmd, ".exe");
            strcat(cmd, " ");
            strcat(cmd, path);
            strcat(cmd, host);
            strcat(cmd, "-");
            strcat(cmd, _ew_req_host[i]);
            strcat(cmd, ".exe");
            system(cmd);
        }
#endif
        strcpy(buf, host);
        strcat(buf, "-");
        strcat(buf, _ew_req_host[i]);
        strcat(buf, " --version > NUL 2>&1");
        ret = system(buf);
        printf("  %s : %s\n", _ew_req_host[i], (ret == 0) ? "yes" : "no");
        fflush(stdout);
        if (ret != 0) return 0;
    }

    for (int i = 0; _ew_req[i]; i++)
    {
        const char *ver;
        if (strcmp(_ew_req[i], "makensis") == 0)
            ver = "-VERSION";
        else
            ver = "--version";

        snprintf(buf, 4095, "%s %s > NUL 2>&1", _ew_req[i], ver);
        ret = system(buf);
        printf("  %s : %s\n", _ew_req[i], (ret == 0) ? "yes" : "no");
        fflush(stdout);
        if (ret != 0) return 0;
    }

    return 1;
}

static int
_ew_packages_dir_set(const char *prefix)
{
    char buf[PATH_MAX];
    char *iter;
    size_t l1;
    size_t l2;

    /* first, package in the git repo */
    if (!getcwd(buf, PATH_MAX))
        return 0;

    iter = buf;
    while (*iter)
    {
        if (*iter == '\\') *iter = '/';
        iter++;
    }

    l1 = strlen(buf);
    l2 = sizeof("/packages") - 1;

    if ((l1 + l2) > (PATH_MAX))
        return 0;

    if (!strcat(buf, "/packages"))
        return 0;

    _ew_package_dir_git = strdup(buf);

    /* then, package in the destination */
    *buf = 0;
    l1 = strlen(prefix);
    l2 = sizeof("/share/ewpi/packages") - 1;

    if ((l1 + l2) > (PATH_MAX))
        return 0;

    strcpy(buf, prefix);

    if (!strcat(buf, "/share/ewpi/packages"))
        return 0;

    _ew_package_dir_dst = strdup(buf);

    _ew_mkdir_p(_ew_package_dir_dst);

    return 1;
}

static void
_ew_packages_count_total()
{
    DIR *dir;
    struct dirent *f;

    dir = opendir(_ew_package_dir_git);
    if (!dir)
        return;

    while ((f = readdir(dir)))
    {
        if ((strcmp(f->d_name, ".") == 0) ||
            (strcmp(f->d_name, "..") == 0))
            continue;

        _ew_package_count_total++;
    }

    closedir(dir);
}

static void
_ew_version_get(char *ver, int *maj, int *min, int *mic, int *rev)
{
    char buf[128];
    char *start;
    char *iter;

    *maj = 0;
    *min = 0;
    *mic = 0;
    *rev = 0;

    strcpy(buf, ver);
    start = buf;

    iter = strchr(start, '-');
    if (iter)
    {
        *iter = '\0';
        iter++;
        *rev = atoi(iter);
    }

    iter = strchr(start, '.');
    if (iter)
    {
        *iter = '\0';
        *maj = atoi(start);
        start = iter + 1;
        iter = strchr(start, '.');
        if (iter)
        {
            *iter = '\0';
            *min = atoi(start);
            start = iter + 1;
            if (*start != '\0')
            {
                *mic = atoi(start);
            }
        }
        else
            *min = atoi(start);
    }
    else
        *maj = atoi(start);
}

static void
_ew_packages_fill(Map *map, Package *pkg)
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
            pkg->name = _ew_str_get(iter2, iter);
        }
        else if (EWPI_VERSION(iter))
        {
            const unsigned char *iter2;

            iter += 9;
            iter2 = iter;
            while (*iter != '\n') iter++;
            pkg->version = _ew_str_get(iter2, iter);
            _ew_version_get(pkg->version, &pkg->vmaj, &pkg->vmin, &pkg->vmic, &pkg->vrev);
        }
        else if (EWPI_URL(iter))
        {
            const unsigned char *iter2;
            char *tarname;

            iter += 5;
            iter2 = iter;
            while (*iter != '\n') iter++;
            pkg->url = _ew_str_get(iter2, iter);
            tarname = strrchr(pkg->url, '/');
            tarname++;
            pkg->tarname = strdup(tarname);
            tarname = strrchr(tarname, '.');
            tarname++;
            if (strcmp(tarname, "git") == 0)
                pkg->is_git = 1;
        }
        else if (EWPI_DEPS(iter))
        {
            iter += 5;
            if (*iter == '\n')
            {
                pkg->deps_count = 0;
                pkg->deps = NULL;
            }
            else
            {
                const unsigned char *iter2;
                int j;

                iter2 = iter;
                pkg->deps_count = 0;
                while (*iter != '\n')
                {
                    if (*iter == ' ')
                        pkg->deps_count++;
                    iter++;
                }
                pkg->deps = (char **)malloc(pkg->deps_count * sizeof(char *));
                j = 0;
                iter2++;
                iter = iter2;
                while (*iter != '\n')
                {
                    if (*iter == ' ')
                    {
                        pkg->deps[j] = (char *)malloc(iter - iter2 + 1);
                        memcpy(pkg->deps[j], iter2, iter - iter2);
                        pkg->deps[j][iter - iter2] = '\0';
                        j++;
                        iter2 = iter + 1;
                    }
                    iter++;
                }
                pkg->deps[j] = (char *)malloc(iter - iter2 + 1);
                memcpy(pkg->deps[j], iter2, iter - iter2);
                pkg->deps[j][iter - iter2] = '\0';
            }
        }

        iter++;
    }
}

static int
_ew_packages_get_git(void)
{
    char buf[PATH_MAX];
    DIR *dir;
    struct dirent *f;
    Package *iter;

    _ewpi_pkgs = (Package *)calloc(_ew_package_count_total, sizeof(Package));
    if (!_ewpi_pkgs)
        return 0;

    dir = opendir(_ew_package_dir_git);
    if (!dir)
        goto free_pkgs;

    iter = _ewpi_pkgs;
    while ((f = readdir(dir)))
    {
        Map map;

        if ((strcmp(f->d_name, ".") == 0) ||
            (strcmp(f->d_name, "..") == 0))
            continue;
        strcpy(buf, _ew_package_dir_git);
        strcat(buf, "/");
        strcat(buf, f->d_name);
        strcat(buf, "/");
        strcat(buf, f->d_name);
        strcat(buf, ".ewpi");

        if (!ewpi_map_new(&map, buf))
            continue;

        _ew_packages_fill(&map, iter);

        ewpi_map_del(&map);

#if EWPI_DEBUG
        printf(" name: %s\n", iter->name);
        printf(" version: %s\n", iter->version);
        printf(" url: %s\n", iter->url);
        printf(" deps:");
        int j;
        for (j = 0; j < iter->deps_count; j++)
            printf(" %s", iter->deps[j]);
        printf("\n");
        printf(" inst: %d\n", iter->installed);
#endif
        iter++;
    }

    closedir(dir);

    return 1;

  free_pkgs:
    free(_ewpi_pkgs);

    return 0;
}

static int
_ew_copy(const char *path_git, const char *path_dst, const char *filename)
{
    char f_git[4096];
    char f_dst[4096];
    char *buf_git = NULL;
    FILE *file;
    size_t size;
    size_t sz;

    strcpy(f_git, path_git);
    strcat(f_git, "/");
    strcat(f_git, filename);

    /* get f_git size */
    size = _ew_file_exists(f_git);
    if (!size)
        return 0;

    buf_git = (char *)malloc(size);
    if (!buf_git)
        return 0;

    file = fopen(f_git, "rb");
    if (!file)
        goto free_buf_git;

    sz = fread(buf_git, 1, size, file);
    if (sz != size)
        goto close_file;

    fclose(file);

    strcpy(f_dst, path_dst);
    strcat(f_dst, "/");
    strcat(f_dst, filename);

    file = fopen(f_dst, "wb");
    if (!file)
        goto free_buf_git;

    sz = fwrite(buf_git, 1, size, file);

    fclose(file);
    free(buf_git);

    if (sz != size)
    {
        printf(" size mismatch %d %d\n", (int)size, (int)sz);
        fflush(stdout);
        unlink(f_dst);
        return 0;
    }

    return 1;

  close_file:
    fclose(file);
  free_buf_git:
    free(buf_git);

    return 0;
}

static void
_ew_packages_dst_set(const char *prefix)
{
    char buf_git[PATH_MAX];
    char buf_dst[PATH_MAX];

    for (int i = 0; i < _ew_package_count_total; i++)
    {
        char buf_ewpi[PATH_MAX];

        strcpy(buf_git, _ew_package_dir_git);
        strcat(buf_git, "/");
        strcat(buf_git, _ewpi_pkgs[i].name);

        strcpy(buf_dst, _ew_package_dir_dst);
        strcat(buf_dst, "/");
        strcat(buf_dst, _ewpi_pkgs[i].name);

        strcpy(buf_ewpi, _ewpi_pkgs[i].name);
        strcat(buf_ewpi, ".ewpi");

        if (_ew_path_exists(buf_dst))
        {
            /*
             * if directory exists, we compare versions from git and dst
             * and if git is newer, we suppress the 'installed' file
             */
            char buf_ewpi_dst[PATH_MAX];
            Package pkg;
            Map map;

            strcpy(buf_ewpi_dst, buf_dst);
            strcat(buf_ewpi_dst, "/");
            strcat(buf_ewpi_dst, buf_ewpi);
            if (ewpi_map_new(&map, buf_ewpi_dst))
            {
                _ew_packages_fill(&map, &pkg);
                /* if version in git is greater, we remove "installed" file */
                if ((_ewpi_pkgs[i].vmaj > pkg.vmaj) ||
                    ((_ewpi_pkgs[i].vmaj == pkg.vmaj) &&
                     (_ewpi_pkgs[i].vmin > pkg.vmin)) ||
                    ((_ewpi_pkgs[i].vmaj == pkg.vmaj) &&
                     (_ewpi_pkgs[i].vmin == pkg.vmin) &&
                     (_ewpi_pkgs[i].vmic > pkg.vmic)) ||
                    ((_ewpi_pkgs[i].vmaj == pkg.vmaj) &&
                     (_ewpi_pkgs[i].vmin == pkg.vmin) &&
                     (_ewpi_pkgs[i].vmic == pkg.vmic) &&
                     (_ewpi_pkgs[i].vrev > pkg.vrev)))
                {
                    char buf[PATH_MAX];

                    strcpy(buf, buf_dst);
                    strcat(buf, "/");
                    strcat(buf, "downloaded");
                    unlink(buf);
                    strcpy(buf, buf_dst);
                    strcat(buf, "/");
                    strcat(buf, "extracted");
                    unlink(buf);
                    strcpy(buf, buf_dst);
                    strcat(buf, "/");
                    strcat(buf, "installed");
                    unlink(buf);
                }
                ewpi_map_del(&map);
            }
        }
        else
        {
            /* Otherwise, the dst directory does not exist, so we create it. */
            _ew_mkdir(buf_dst, S_IRUSR | S_IWUSR | S_IXUSR | S_IRGRP | S_IXGRP | S_IROTH | S_IXOTH);
        }

        /*
         * we always copy all the files, in case:
         * a new package is installed
         * or a build system has changed
         * or something else :-)
         */
        _ew_copy(buf_git, buf_dst, buf_ewpi);
        _ew_copy(buf_git, buf_dst, "install.sh");
        _ew_copy(buf_git, buf_dst, "cross_toolchain.txt");
    }

    if (!getcwd(buf_git, PATH_MAX))
        return;

    if ((strlen(prefix) + sizeof("/share/ewpi") - 1) > (PATH_MAX))
        return;

    strcpy(buf_dst, prefix);
    strcat(buf_dst, "/share/ewpi");
    _ew_copy(buf_git, buf_dst, "common.sh");
}

static void
_ew_packages_status_set()
{
    DIR *dir;
    struct dirent *f;

    dir = opendir(_ew_package_dir_dst);
    if (!dir)
        return;

    while ((f = readdir(dir)))
    {
        char buf[PATH_MAX];
        char buf_pkg[PATH_MAX];
        Package *iter;

        if ((strcmp(f->d_name, ".") == 0) ||
            (strcmp(f->d_name, "..") == 0))
            continue;

        iter = NULL;
        for (int i = 0; i < _ew_package_count_total; i++)
        {
            if (strcmp(_ewpi_pkgs[i].name, f->d_name) == 0)
            {
                iter = _ewpi_pkgs + i;
                break;
            }
        }
        if (!iter)
        {
            printf("Can not find the package %s, exiting...\n", f->d_name);
            fflush(stdout);
            exit(1);
        }

        strcpy(buf_pkg, _ew_package_dir_dst);
        strcat(buf_pkg, "/");
        strcat(buf_pkg, f->d_name);
        strcat(buf_pkg, "/");

        strcpy(buf, buf_pkg);
        strcat(buf, "downloaded");

        if (_ew_file_exists(buf))
            iter->downloaded = 1;
        else
            _ew_package_count_not_downloaded++;

        strcpy(buf, buf_pkg);
        strcat(buf, "extracted");

        if (_ew_file_exists(buf))
            iter->extracted = 1;
        else
            _ew_package_count_not_extracted++;

        strcpy(buf, buf_pkg);
        strcat(buf, "installed");

        if (_ew_file_exists(buf))
            iter->installed = 1;
        else
            _ew_package_count_not_installed++;

        iter++;
    }

    closedir(dir);
}

static void
_ew_packages_tree(const char *pkg_name)
{
    Package pkg;
    int idx;
    int already_in = 0;

    /* get the index of the package */
    for (idx = 0; idx < _ew_package_count_total; idx++)
    {
        if (strcmp(pkg_name, _ewpi_pkgs[idx].name) == 0)
            break;
    }
    pkg = _ewpi_pkgs[idx];

    for (int i = 0; i < pkg.deps_count; i++)
        _ew_packages_tree(pkg.deps[i]);

    for (int i = 0; i < _ew_package_deps_dst_count; i++)
    {
        if (_ew_package_index[i] == idx)
            already_in = 1;
    }

    if (!already_in)
    {
        _ew_package_index[_ew_package_deps_dst_count] = idx;
        _ew_package_deps_dst_count++;

    }
}

static void
_ew_packages_not_installed_disp(void)
{

    printf("\nPackages (%d)\n", _ew_package_count_not_installed);
    fflush(stdout);
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        int idx = _ew_package_index[i];
        if (!_ewpi_pkgs[idx].installed)
            printf("  %s-%s\n", _ewpi_pkgs[idx].name, _ewpi_pkgs[idx].version);
    }
    printf("\n");
    fflush(stdout);
}

static void
_ew_packages_download(void)
{
    char buf[4096];
    Package *iter;
    int count;

    count = 0;
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        iter = _ewpi_pkgs + _ew_package_index[i];
        strcpy(buf, _ew_package_dir_dst);
        strcat(buf, "/");
        strcat(buf, iter->name);
        strcat(buf, "/downloaded");
        if (!_ew_file_exists(buf))
            count++;
        else
            iter->downloaded = 1;
    }

    if (count == 0)
        return;

    printf(":: Download sources...\n");
    fflush(stdout);
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        int ret;

        iter = _ewpi_pkgs + _ew_package_index[i];
        if (iter->downloaded)
            continue;

        strcpy(buf, "cd ");
        strcat(buf, _ew_package_dir_dst);
        strcat(buf, "/");
        strcat(buf, iter->name);
        strcat(buf, " && ");

        if (iter->is_git)
        {
            if (iter->downloaded)
            {
                strcat(buf, "git pull");
            }
            else
            {
                strcat(buf, "git clone ");
                strcat(buf, iter->url);
            }
        }
        else
        {
            strcat(buf, "wget -q --show-progress --no-check-certificate ");
            strcat(buf, iter->url);
        }
        fflush(stdout);
        ret = system(buf);
        if (ret != 0)
        {
            printf("error while downloading package %s (ret = %d)\n", iter->name, ret);
            exit(1);
        }
        else
        {
            strcpy(buf, "echo 1 > ");
            strcat(buf, _ew_package_dir_dst);
            strcat(buf, "/");
            strcat(buf, iter->name);
            strcat(buf, "/downloaded");
            system(buf);
            if (iter->is_git)
            {
                strcpy(buf, "echo 1 > ");
                strcat(buf, _ew_package_dir_dst);
                strcat(buf, "/");
                strcat(buf, iter->name);
                strcat(buf, "/extracted");
                system(buf);
            }
        }
    }
}

static void
_ew_packages_longest_name()
{
    Package *iter;

    /* compute the largest name (including version) of the packages */
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        iter = _ewpi_pkgs + _ew_package_index[i];
        if ((int)(strlen(iter->name) + 1 + strlen(iter->version)) > _ew_package_name_size_max)
            _ew_package_name_size_max = strlen(iter->name) + 1 + strlen(iter->version);
    }
}

static void
_ew_packages_status_disp(int i, int count, const char *name, const char* version)
{
    char buf[4096];
    char *iter;
    size_t len;
    size_t len2;
    int nbr_sharp = 40;
    int sharp;
    int percent;
    size_t j;

    snprintf(buf, 4095, "(%2d/%d) ", i + 1, count);
    len = strlen(buf);
    iter = buf + len;
    if (name)
    {
        len = strlen(name);
        for (j = 0; j < len; j++)
            *iter++ = name[j];
        *iter++ = '-';
        len2 = strlen(version);
        for (j = 0; j < len2; j++)
            *iter++ = version[j];
        for (j = 0; j < (_ew_package_name_size_max  - (len + 1 + len2)); j++)
            *iter++ = ' ';
    }
    else
    {
        for (j = 0; j < (size_t)_ew_package_name_size_max; j++)
            *iter++ = ' ';
    }
    *iter++ = ' ';
    *iter++ = '[';
    sharp = (nbr_sharp * (i + 1)) / count;
    percent = (100 * (i + 1)) / count;
    for (j = 0; j < (size_t)sharp; j++, iter++)
        *iter = '#';
    for (; j < (size_t)nbr_sharp; j++, iter++)
        *iter = ' ';
    *iter++ = ']';
    *iter++ = ' ';
    if (percent < 10)
    {
        *iter++ = ' ';
        *iter++ = ' ';
        *iter++ = (char)(percent + '0');
    }
    else if (percent < 100)
    {
        *iter++ = ' ';
        *iter++ = (char)((percent / 10) + '0');
        *iter++ = (char)((percent % 10) + '0');
    }
    else
    {
        *iter++ = '1';
        *iter++ = '0';
        *iter++ = '0';
    }
    *iter++ = '%';
    *iter++ = '\0';
    printf("\r%s", buf);
    fflush(stdout);
}

static void
_ew_packages_extract(int verbose)
{
    char buf[4096];
    Package *iter;
    int count;
    int c;

    count = 0;
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        iter = _ewpi_pkgs + _ew_package_index[i];
        strcpy(buf, _ew_package_dir_dst);
        strcat(buf, "/");
        strcat(buf, iter->name);
        strcat(buf, "/extracted");
        if (!_ew_file_exists(buf))
            count++;
        else
            iter->extracted = 1;
    }

    if (count == 0)
        return;

    printf(":: Extraction of sources...\n");
    fflush(stdout);

    c = 0;
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        const char *name;
        const char *tarname;
        const char *ext;
        char taropt[5];
        int idx;
        int ret;

        iter = _ewpi_pkgs + _ew_package_index[i];
        if (iter->extracted)
            continue;

        name = iter->name;
        tarname = iter->tarname;
        ext = strrchr(tarname, '.');
        ext++;

        idx = 0;
        if (verbose)
            taropt[idx++] = 'v';
        if ((strcmp(ext, "gz") == 0) || (strcmp(ext, "tgz") == 0))
            taropt[idx++] = 'z';
        else if (strcmp(ext, "bz2") == 0)
            taropt[idx++] = 'j';
        else
        {
            taropt[idx++] = 'J';
            taropt[idx++] = 'h';
        }
        taropt[idx++] = 'f';
        taropt[idx++] = '\0';

        _ew_packages_status_disp(c, count, name, iter->version);

        snprintf(buf, 4095,
                 "cd %s/%s && tar x%s %s",
                 _ew_package_dir_dst, name,
                 taropt, tarname);
        fflush(stdout);
        ret = system(buf);
        if (ret != 0)
        {
            printf(" Can not extract %s\n", tarname);
            exit(1);
        }
        else
        {
            strcpy(buf, "echo 1 > ");
            strcat(buf, _ew_package_dir_dst);
            strcat(buf, "/");
            strcat(buf, name);
            strcat(buf, "/extracted");
            system(buf);
        }

        c++;
    }

    _ew_packages_status_disp(count - 1, count, NULL, NULL);
    printf("\n");
}

static void
_ew_packages_install(const char *prefix, const char *host, const char *arch, const char *jobopt, int verbose, const char *winver)
{
    char buf[4096];
    Package *iter;
    int c;

    if (_ew_package_count_not_installed == 0)
        return;

    printf("\n:: Installation of packages...\n");
    fflush(stdout);

    c = 0;
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        const char *name;
        const char *tarname;
        int ret;

        iter = _ewpi_pkgs + _ew_package_index[i];
        if (iter->installed)
            continue;

        name = iter->name;
        tarname = iter->tarname;

        _ew_packages_status_disp(c, _ew_package_count_not_installed, name, iter->version);

        snprintf(buf, 4095,
                 "cd %s/%s && sh ./install.sh %s %s %s %s %s %s %s",
                 _ew_package_dir_dst, name,
                 arch, tarname, prefix, host, (*jobopt == 0) ? "no" : jobopt, verbose ? "yes" : "no", winver);
        ret = system(buf);
        if (ret != 0)
        {
            printf(" Can not install %s\n", name);
            exit(1);
        }
        else
        {
            strcpy(buf, "echo 1 > ");
            strcat(buf, _ew_package_dir_dst);
            strcat(buf, "/");
            strcat(buf, name);
            strcat(buf, "/installed");
            system(buf);
        }

        c++;
    }

    _ew_packages_status_disp(_ew_package_count_not_installed - 1, _ew_package_count_not_installed, NULL, NULL);
    printf("\n");
}

static void
_ew_recursive_rm(const char *path)
{
    if (_ew_path_exists(path))
    {
        DIR *dir;
        struct dirent *f;

        dir = opendir(path);
        if (dir)
        {
            while ((f = readdir(dir)))
            {
                char buf[4096];

                if ((strcmp(f->d_name, ".") == 0) ||
                    (strcmp(f->d_name, "..") == 0))
                    continue;

                snprintf(buf, 4095, "%s/%s", path, f->d_name);
                _ew_recursive_rm(buf);
            }

            closedir(dir);
        }
        //printf("path: %s\n", path);
        rmdir(path);
    }
    else
    {
        //printf("file : %s\n", path);
        unlink(path);
    }
}

static void
_ew_packages_clean_directories(char *pkg_dir)
{
    DIR *dir;
    struct dirent *f;

    dir = opendir(pkg_dir);
    if (dir)
    {
        char buf2[4096];

        while ((f = readdir(dir)))
        {
            if ((strcmp(f->d_name, ".") == 0) ||
                (strcmp(f->d_name, "..") == 0))
                continue;

            strcpy(buf2, pkg_dir);
            strcat(buf2, "/");
            strcat(buf2, f->d_name);
            if (_ew_path_exists(buf2))
                _ew_recursive_rm(buf2);
        }
        closedir(dir);
    }
}

static void
_ew_packages_clean(void)
{
    char buf[4096];
    Package *iter;

    printf("\n:: Cleaning...\n");
    fflush(stdout);

    for (int i = 0; i < _ew_package_count_total; i++)
    {
        const char *name;
        const char *version;
        const char *tarname;

        iter = _ewpi_pkgs + _ew_package_index[i];
        name = iter->name;
        version = iter->version;
        tarname = iter->tarname;

        _ew_packages_status_disp(i, _ew_package_count_total, name, version);

        strcpy(buf, _ew_package_dir_dst);
        strcat(buf, "/");
        strcat(buf, name);
        _ew_packages_clean_directories(buf);
        strcat(buf, "/");
        strcat(buf, tarname);
        unlink(buf);
    }

    _ew_packages_status_disp(_ew_package_count_total - 1, _ew_package_count_total, NULL, NULL);
    printf("\n");
}

static void
_ew_packages_strip(const char *prefix, const char *host)
{
    char buf[4096];
    int ret;

    printf("\n:: Stripping DLL...\n");
    fflush(stdout);

    snprintf(buf, 4095,
             "sh ./ewpi_strip.sh %s %s",
             prefix, host);
    ret = system(buf);
    if (ret != 0)
    {
        printf(" Can not strip DLL\n");
        fflush(stdout);
    }

    printf("\n");
}

static void
_ew_packages_nsis(const char *prefix, const char *host, const char *winver, int efl)
{
    char buf[4096];
    const char *arch;
    const char *arch_suf;
    int ret;

    _ew_packages_strip(prefix, host);

    printf("\n:: Create NSIS installer...\n");
    fflush(stdout);

    if (strcmp(host, "i686-w64-mingw32") == 0)
    {
        arch = "i686";
        arch_suf = "32";
    }
    else
    {
        arch = "x86_64";
        arch_suf = "64";
    }

    if (efl)
    {
        snprintf(buf, 4095,
                 "sh ./efl_nsis.sh %s %d.%d %s %s %s",
                 prefix, _ew_vmaj, _ew_vmin, arch, arch_suf, winver);
    }
    else
    {
        snprintf(buf, 4095,
                 "sh ./ewpi_nsis.sh %s %d.%d %s %s %s",
                 prefix, _ew_vmaj, _ew_vmin, arch, arch_suf, winver);
    }
    ret = system(buf);
    if (ret != 0)
    {
        printf(" Can not create NSIS installer\n");
        fflush(stdout);
    }

    printf("\n");
}

int main(int argc, char *argv[])
{
    char *prefix = NULL;
    char *host = "x86_64-w64-mingw32";
    char *arch =  NULL;;
    char *jobopt = "";
    char *winver = "win10";
    size_t len;
    int strip = 0;
    int nsis = 0;
    int verbose = 0;
    int efl = 0;
    int cleaning = 0;
    int ret;

    for (int i = 1; i < argc; i++)
    {
        if (strcmp(argv[i], "--help") == 0)
        {
            _ew_usage(argv[0]);
            exit(0);
        }
        if (strcmp(argv[i], "--version") == 0)
        {
            printf("Ewpi version %d.%d\n", _ew_vmaj, _ew_vmin);
            exit(0);
        }
        else if (strncmp(argv[i], "--prefix=", strlen("--prefix=")) == 0)
        {
            prefix = argv[i] + strlen("--prefix=");
        }
        else if (strncmp(argv[i], "--host=", strlen("--host=")) == 0)
        {
            char *opt;

            opt = argv[i] + strlen("--host=");
            if (strcmp(opt, "i686-w64-mingw32") == 0)
                host = "i686-w64-mingw32";
            else if (strcmp(opt, "x86_64-w64-mingw32") == 0)
                host = "x86_64-w64-mingw32";
            else
            {
                _ew_usage(argv[0]);
                exit(1);
            }
        }
        else if (strncmp(argv[i], "--arch=", strlen("--arch=")) == 0)
        {
            arch = argv[i] + strlen("--arch=");
        }
        else if (strncmp(argv[i], "--winver=", strlen("--winver=")) == 0)
        {
            char *opt;

            opt = argv[i] + strlen("--winver=");
            if (strcmp(opt, "win7") == 0)
                winver = "win7";
            else if (strcmp(opt, "win10") == 0)
                winver = "win10";
            else
            {
                _ew_usage(argv[0]);
                exit(1);
            }
        }
        else if (strcmp(argv[i], "--strip") == 0)
        {
            strip = 1;
        }
        else if (strcmp(argv[i], "--nsis") == 0)
        {
            nsis = 1;
        }
        else if (strcmp(argv[i], "--verbose") == 0)
        {
            verbose = 1;
        }
        else if (strcmp(argv[i], "--efl") == 0)
        {
            efl = 1;
        }
        else if (strncmp(argv[i], "--jobs=", strlen("--jobs=")) == 0)
        {
            jobopt = argv[i] + strlen("--jobs=");
        }
        else if (strcmp(argv[i], "--clean") == 0)
        {
            cleaning = 1;
        }
        else
        {
            _ew_usage(argv[0]);
            exit(1);
        }
    }

    if (!prefix)
    {
        char buf[PATH_MAX];

        strcpy(buf, getenv("HOME"));
        if (strcmp(host, "i686-w64-mingw32") == 0)
            strcat(buf, "/ewpi_32");
        else
            strcat(buf, "/ewpi_64");
        prefix = strdup(buf);
    }

    if (!arch)
    {
        if (strcmp(host, "i686-w64-mingw32") == 0)
            arch = "i686";
        else
            arch = "x86-64";
    }

    /* use slash in prefix, not backslash */
    {
        char *iter = prefix;
        while (*iter)
        {
            if (*iter == '\\') *iter = '/';
            iter++;
        }
    }

    /* remove possible trailing slash */
    len = strlen(prefix);
    if (prefix[len - 1] == '/')
        prefix[len - 1] = '\0';

    /* prefix must be absolute */
    if (!_ew_path_is_absolute(prefix))
    {
        printf("prefix must be an absolute path, exiting...\n");
        return 1;
    }

    printf(":: Configuration...\n");
    printf("  prefix:    %s\n", prefix);
    printf("  host:      %s\n", host);
    printf("  arch:      %s\n", arch);
    printf("  strip:     %s\n", strip ? "yes" : "no");
    printf("  installer: %s\n", nsis ? "yes" : "no");
    printf("  verbose:   %s\n", verbose ? "yes" : "no");
    printf("  efl:       %s\n", efl ? "yes" : "no");
    printf("  jobs:      %s\n", jobopt);
    printf("\n");
    fflush(stdout);

    printf(":: Checking requirements...\n");
    ret = _ew_requirements(host);
    if (!ret)
    {
        printf("one of the requirement is not found, exiting...\n");
        return 1;
    }

    printf(":: Prepare directories in %s...\n", prefix);
    _ew_packages_dir_set(prefix);

    _ew_packages_count_total();
    _ew_packages_get_git();
    _ew_packages_dst_set(prefix);

    printf(":: Check which package is not installed...\n");
    fflush(stdout);
    _ew_packages_status_set();

    printf(":: Build the dependency tree...\n");
    fflush(stdout);
    _ew_package_index = (int *)malloc(_ew_package_count_total * sizeof(int));
    if(!_ew_package_index)
        return 1;

    _ew_packages_tree("efl");
    if (!efl)
    {
        _ew_package_count_total--;
        _ew_package_count_not_installed--;
    }
    _ew_packages_not_installed_disp();
    _ew_packages_download();
    _ew_packages_longest_name();
    _ew_packages_extract(verbose);
    _ew_packages_install(prefix, host, arch, jobopt, verbose, winver);
    if (strip && !nsis)
        _ew_packages_strip(prefix, host);
    if (nsis)
    {
        _ew_packages_nsis(prefix, host, winver, efl);
    }
    if (cleaning)
        _ew_packages_clean();

    free(_ew_package_index);
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        free(_ewpi_pkgs[i].name);
        free(_ewpi_pkgs[i].version);
        free(_ewpi_pkgs[i].url);
        free(_ewpi_pkgs[i].tarname);
        for (int j = 0; j < _ewpi_pkgs[i].deps_count; j++)
            free(_ewpi_pkgs[i].deps[j]);
        free(_ewpi_pkgs[i].deps);
    }
    free(_ewpi_pkgs);

    return 0;
}
