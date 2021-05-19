;Bootloader starts first
;Job is to locate a particular OS
;multiboot2 spec

section .multiboot_header

header_start:

  ; magic number, multiboot2
  dd 0xe85250d6

  ; architecture, protected mode i386
  dd 0

  ; header length
  dd header_end - header_start

  ; checksum = 0x100000000 - (all the data in header)
  dd 0x100000000 - (0xe85250d6 + 0 + (header_end-header_start))

  ; end tag
  dw 0
  dw 0
  dd 8

header_end: