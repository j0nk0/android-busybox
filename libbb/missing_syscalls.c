/*
 * Copyright 2012, Denys Vlasenko
 *
 * Licensed under GPLv2, see file LICENSE in this source tree.
 */
//kbuild:lib-y += missing_syscalls.o

#include "libbb.h"

#if defined(ANDROID) || defined(__ANDROID__)
/*# include <linux/timex.h> - for struct timex, but may collide with <time.h> */
# include <sys/syscall.h>
pid_t getsid(pid_t pid)
{
	return syscall(__NR_getsid, pid);
}

int stime(const time_t *t)
{
	struct timeval tv;
	tv.tv_sec = *t;
	tv.tv_usec = 0;
	return settimeofday(&tv, NULL);
}

int sethostname(const char *name, size_t len)
{
	return syscall(__NR_sethostname, name, len);
}

struct timex;
int adjtimex(struct timex *buf)
{
	return syscall(__NR_adjtimex, buf);
}

int pivot_root(const char *new_root, const char *put_old)
{
	return syscall(__NR_pivot_root, new_root, put_old);
}

int swapon(const char *path, int swapflags)
{
    return syscall(__NR_swapon, path, swapflags);
}

int swapoff(const char *path)
{
    return syscall(__NR_swapoff, path);
}

#if __ANDROID_API__ < 16
int setxattr(const char *path, const char *name, const void *value, size_t size, int flags)
{
    return syscall(__NR_setxattr, path, name, value, size, flags);
}

int lsetxattr(const char *path, const char *name, const void *value, size_t size, int flags)
{
    return syscall(__NR_lsetxattr, path, name, value, size, flags);
}

int removexattr(const char *path, const char *name)
{
    return syscall(__NR_removexattr, path, name);
}

int lremovexattr(const char *path, const char *name)
{
    return syscall(__NR_lremovexattr, path, name);
}
#endif

#endif
