/*
 * Minimal MikrOS ColdFire no-MMU PID 1 probe.
 * Build with a ColdFire-compatible uClibc-ng toolchain targeting FLAT binaries.
 * An ordinary m68k-linux-gnu ELF is NOT a substitute on no-MMU Linux.
 */
#include <fcntl.h>
#include <unistd.h>

static void say(const char *s)
{
    unsigned long n = 0;
    int fd = open("/dev/console", O_WRONLY | O_NOCTTY);
    if (fd < 0)
        fd = 1;
    while (s[n])
        ++n;
    (void)write(fd, s, n);
    if (fd != 1)
        (void)close(fd);
}

int main(void)
{
    say("MIKROS_COLDFIRE_INIT_OK\\n");
    for (;;)
        pause();
    return 0;
}
