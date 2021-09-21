#include "print.h"

void kernel_main() 
{
  print_clear(); //clears the screen
  print_set_color(PRINT_COLOR_YELLO, PRINT_COLOR_BLACK); //change foreground and background colors (respectively)
  print_str("Hello 64-bit World!"); //print text
}