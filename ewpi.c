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
    char *url;
    char *tarname;
    const char *taropt;
    int deps_count;
    char **deps;
    unsigned int downloaded : 1;
    unsigned int extracted : 1;
    unsigned int installed : 1;
    unsigned int is_git : 1;
} Package;

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
    printf("Usage: %s prefix host [number of make jobs]\n", argv0);
    printf("Example: %s $HOME/ewpi i686-w64-mingw32 4\n", argv0);
    printf("The prefix must be an absolute directory\n");
    printf("Possible values for host: i686-w64-mingw32 and x86_64-w64-mingw32\n");
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
_ew_version_get(char *ver, int *maj, int *min, int *mic)
{
  char buf[128];
  char *start;
  char *iter;

  *maj = 0;
  *min = 0;
  *mic = 0;
  strcpy(buf, ver);
  start = buf;
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
        iter = strchr(start, '.');
        if (iter)
          {
            *iter = '\0';
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
            _ew_version_get(pkg->version, &pkg->vmaj, &pkg->vmin, &pkg->vmic);
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
            else if ((strcmp(tarname, "gz") == 0) || (strcmp(tarname, "tgz") == 0))
                pkg->taropt = "zf";
            else if (strcmp(tarname, "bz2") == 0)
                pkg->taropt = "jf";
            else
                pkg->taropt = "Jf";
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
_ew_packages_dst_set(void)
{
    int i;
    char buf_git[PATH_MAX];
    char buf_dst[PATH_MAX];

    for (i = 0; i < _ew_package_count_total; i++)
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
                     (_ewpi_pkgs[i].vmic > pkg.vmic)))
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
        _ew_copy(buf_git, buf_dst, "post.sh");
        _ew_copy(buf_git, buf_dst, "cross_toolchain.txt");
    }
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

    iter = _ewpi_pkgs;
    count = 0;
    for (int i = 0; i < _ew_package_count_total; i++, iter++)
    {
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
    /* compute the largest name (including version) of the packages */
    for (int i = 0; i < _ew_package_count_total; i++)
    {
        if ((int)(strlen(_ewpi_pkgs[i].name) + 1 + strlen(_ewpi_pkgs[i].version)) > _ew_package_name_size_max)
            _ew_package_name_size_max = strlen(_ewpi_pkgs[i].name) + 1 + strlen(_ewpi_pkgs[i].version);
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
    *iter++ = '\%';
    *iter++ = '\0';
    printf("\r%s", buf);
    fflush(stdout);
}

static void
_ew_packages_extract(void)
{
    char buf[4096];
    Package *iter;
    int count;
    int c;

    iter = _ewpi_pkgs;
    count = 0;
    for (int i = 0; i < _ew_package_count_total; i++, iter++)
    {
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
        const char *taropt;
        int ret;

        iter = _ewpi_pkgs + _ew_package_index[i];
        if (iter->extracted)
            continue;

        name = iter->name;
        tarname = iter->tarname;
        taropt = iter->taropt;

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
_ew_packages_install(const char *prefix, const char *host, const char *jobopt)
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
        const char *taropt;
        int ret;

        iter = _ewpi_pkgs + _ew_package_index[i];
        if (iter->installed)
            continue;

        name = iter->name;
        tarname = iter->tarname;
        taropt = iter->taropt;

        _ew_packages_status_disp(c, _ew_package_count_not_installed, name, iter->version);

        snprintf(buf, 4095,
                 "cd %s/%s && sh ./install.sh %s %s %s %s %s %s",
                 _ew_package_dir_dst, name,
                 name, tarname, prefix, host, taropt, jobopt);
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
_ew_packages_clean(void)
{
    char buf[4096];

    printf("\n:: Cleaning...\n");
    fflush(stdout);

    for (int i = 0; i < _ew_package_count_total; i++)
    {
        const char *name;
        const char *version;
        const char *tarname;
        const char *taropt;
        int ret;

        name = _ewpi_pkgs[i].name;
        version = _ewpi_pkgs[i].version;
        tarname = _ewpi_pkgs[i].tarname;
        taropt = _ewpi_pkgs[i].taropt;

        _ew_packages_status_disp(i, _ew_package_count_total, name, version);

        snprintf(buf, 4095,
                 "cd %s/%s && sh ./post.sh %s %s %s",
                 _ew_package_dir_dst, name,
                 name, tarname, taropt);
        ret = system(buf);
        if (ret != 0)
        {
            printf(" Can not clean %s\n", name);
        }
    }

    _ew_packages_status_disp(_ew_package_count_total - 1, _ew_package_count_total, NULL, NULL);
    printf("\n");
}

int main(int argc, char *argv[])
{
    char *prefix = NULL;
    char *host = NULL;
    char *jobopt = "";

    if (argc < 3)
    {
        _ew_usage(argv[0]);
        return 1;
    }

    /* prefix must be absolute */
    prefix = argv[1];
    if (!_ew_path_is_absolute(prefix))
        return 1;

    /* host value */
    host = argv[2];
    if ((strcmp(host, "i686-w64-mingw32") != 0) &&
        (strcmp(host, "x86_64-w64-mingw32") != 0))
    {
        printf("Possible values for host: i686-w64-mingw32 or x86_64-w64-mingw32\n");
        fflush(stdout);
        return 1;
    }

    /* number of jobs */
    if (argv[3])
        jobopt = argv[3];

    printf(":: Prepare directories in %s...\n", prefix);
    _ew_packages_dir_set(prefix);

    _ew_packages_count_total();
    _ew_packages_get_git();
    _ew_packages_dst_set();

    printf(":: Check which package is not installed...\n");
    fflush(stdout);
    _ew_packages_status_set();

    printf(":: Build the dependency tree...\n");
    fflush(stdout);
    _ew_package_index = (int *)malloc(_ew_package_count_total * sizeof(int));
    if(!_ew_package_index)
        return 1;

    _ew_packages_tree("efl");
    _ew_packages_not_installed_disp();
    _ew_packages_download();
    _ew_packages_longest_name();
    _ew_packages_extract();
    _ew_packages_install(prefix, host, jobopt);
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
