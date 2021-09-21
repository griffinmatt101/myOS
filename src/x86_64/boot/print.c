#include "print.h"

//constants
const static uint8_t NUM_COLS = 80;
const static uint8_t NUM_ROWS = 25;

//video memory holds array of chars
struct Char
{
  uint8_t character; //character represented with ascii
  uint8_t color; //and with 8 bit color code

};

struct Char* buffer = (struct Char*)0xb8000;//buffer variable that references video memory, cast as pointer to char struct
size_t col = 0; //keep track of column
size_t row = 0; //and row
uint8_t color = PRINT_COLOR_WHITE | PRINT_COLOR_BLACK << 4; //and color, look up left sheft operator for this case

void clear_row(size_t row)
{
  struct Char empty = (struct Char) {
    character: ' ',
    color: color,
  };

  //for each column in this row, print empty character defined above
  for(size_t col = 0; col < NUM_COLS; col++) 
  {
    buffer[col + NUM_COLS * row] = empty; //update character in buffer
  }
}

void print_clear()
{
  for(size_t i = 0; i < NUM_ROWS; i++)
  {
    clear_row(i);
  }
}

void print_char(char character)
{
  if(character == '\n')
  {
    print_newline();
    return;
  }
  //print new line if column we're at exceeds total num of columns
  if(col > NUM_COLS) 
  {
    print_newline();
  }

  buffer[col + NUM_COLS*row] = (struct Char) {
    character: (uint8_t) character,
    color: color,
  };
  col++;
}

//print str function here