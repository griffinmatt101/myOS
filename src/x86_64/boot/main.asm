; entry point into myOS

global start ; need access when linking

section .text
bits 32 ; will switch to 64 bit mode later
start:
  ; print 'OK' (ok = 0x2f4b2f4f)
  ; write to "video memory"
  mov dword [0xb8000], 0x2f4b2f4f
  hlt 