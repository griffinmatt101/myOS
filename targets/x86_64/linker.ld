ENTRY(start)

SECTIONS
{
  . = 1M; /*current address = 1 MB; all os data will start 1 MB in; conventional*/

  .boot :
  {
    KEEP(*(.multiboot_header))
  }

  .text :
  {
    *(.text) /*CPU instructions*/
  }
}
