; entry point into myOS

global start ; need access when linking

section .text
bits 32 ; will switch to 64 bit mode later
start:
  mov esp, stack_top

  ; subroutines
  call check_multiboot
  call check_cpuid ; provides cpu info
  call check_long_mode ; using cpuid

  ; print 'OK' (ok = 0x2f4b2f4f)
  ; write to "video memory"
  mov dword [0xb8000], 0x2f4b2f4f
  hlt 

check_multiboot:
  cmp eax, 0x36d76289
  jne .no_multiboot
  ret

.no_multiboot:
  mov al, "M" ; error code ("M" for multiboot)
  jmp error

error:
  ; print "ERR: X", where X is the error code
  mov dword [0xb8000], 0x4f524f45
  mov dword [0xb8004], 0x4f3a4f52
  mov dword [0xb8008], 0x4f204f20
  mov dword [0xb800a], al ; error code
  hlt

section .bss ; statically allocated variables
stack_bottom:
  resb 4096 * 4 ; 16 kB of memory
stack_top: