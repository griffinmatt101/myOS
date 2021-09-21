global long_mode_start
extern kernel_main

section .text
bits 64
long_mode_start:
  ; load 0(null) into data segment registers
  mov ax, 0
  mov ss, ax
  mov ds, ax 
  mov es, ax 
  mov fs, ax 
  mov gs, ax
  
  ; print 'OK' (ok = 0x2f4b2f4f)
  ; write to "video memory"
  ; mov dword [0xb8000], 0x2f4b2f4f
  ; ^ can now be called with kernel main
  call kernel_main

  hlt