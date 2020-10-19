#include <conio.h>
#include <dos.h>
#include <stdbool.h>
#include <stdlib.h>
#include "zlib/zlib.h"
#include "../tndlpt/tndlpt.h"
#include "vgm.h"

#define STR(x) #x
#define XSTR(x) STR(x)

static volatile int interrupted = 0;

static void __interrupt __far ctrlc_handler()
{
  interrupted = 1;
}

void warnx(const char *fmt, ...)
{
  va_list ap;
  va_start(ap, fmt);
  vcprintf(fmt, ap);
  cprintf("\r\n");
  va_end(ap);
}

int main(int argc, char *argv[])
{
  gzFile f;
  char *filename;
  short lpt_base;

  cputs("== LOTECH test program (" XSTR(VERSION) ") ==\r\n\r\n");

  if (argc > 1) {
    filename = argv[1];
  } else {
    filename = "LOTEST.VGZ";
  }
  f = gzopen(filename, "rb");
  if (!f) {
    cprintf("Can't open file \"%s\"\r\n", filename);
    return 1;
  }
  if (!music_setup(f)) {
    cputs("Not a Tandy VGM file\r\n");
    return 1;
  }

  if (!tndlpt_init(false)) {
    cputs("\r\nError: LOTECH is not responding\r\n");
    /* return 1; */
    tndlpt_init(true);
  }

  cputs("\r\nPress any key to start the music...");
  do {
    getch();
  } while (kbhit());
  cputs("\r\n\r\nPress any key to stop...");
  _dos_setvect(0x23, ctrlc_handler);

  music_start();
  while (!interrupted && music_loop() && !kbhit()) {
  }
  music_shutdown();

  while (kbhit()) {
    getch();
  }
  cputs("\r\n\r\n");
  return 0;
}
