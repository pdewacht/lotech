#include <conio.h>
#include <i86.h>
#include "tndlpt.h"

int tndlpt_init(bool force)
{
  outp(0x2C0, 0x9F);
  outp(0x2C0, 0xBF);
  outp(0x2C0, 0xDF);
  outp(0x2C0, 0xFF);

  return 1;
}
