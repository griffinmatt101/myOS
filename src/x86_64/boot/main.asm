; entry point into myOS

global start ; need access when linking
extern long_mode_start

section .text
bits 32 ; will switch to 64 bit mode later
start:
  mov esp, stack_top

  ; subroutines
  call check_multiboot
  call check_cpuid ; provides cpu info
  call check_long_mode ; using cpuid

  ; Paging -> must implement virtual memory to enter 64-bit long mode
  ; Paging allows us to map virtual addresses to physical addresses with Page Tables
  ; A single page is a chunk of 4 kB of memory; map 1 page of virtual mem to 1 page of physical mem
  ; 4 types of page tables: L4, L3, L2, L1; each table can hold 512 entries
  ; Each virtual address takes up 48 bits of the 64 bits available (other bits are unused)
  ; CPU treats first 9 bits as an index into the L4 page table
  ; L4 entry will point to the L3 page table etc
  ; L1 entry will point to the start of a page in physical memory
  call setup_page_tables
  call enable_paging

  ; enable global descriptor table
  lgdt [gdt64.pointer]
  jmp gdt64.code_segment: long_mode_start; load code segment into code selector

  hlt 

check_multiboot:
  cmp eax, 0x36d76289
  jne .no_multiboot
  ret

.no_multiboot:
  mov al, "M" ; error code ("M" for multiboot)
  jmp error

; flip id bit of flags register to 1
check_cpuid:
  pushfd ; push flags register on to stack
  pop eax ; pop off of stack into eax register
  mov ecx, eax ; make copy in ecx register to compare if successful
  xor eax, 1 << 21 ; flip bit 21 (where cpuid is)
  push eax ; push back on to stack
  popfd ; pop into flags register

  pushfd
  pop eax
  push eax
  popfd

  cmp eax, ecx ; if they match, cpu did not allow us to flip bit -> cpuid is not available
  je .no_cpuid
  ret

.no_cpuid:
  mov al, "C" ; "C" for cpuid
  jmp error

check_long_mode:
  ; check if cpuid supports extended processor info
  mov eax, 0x80000000
  cpuid ; takes eax as implicit arg; if cpuid stores num in eax > 0x80000000, it supports extended processor info
  cmp eax, 0x80000001
  jb .no_long_mode

  mov eax, 0x80000001
  cpuid ; if lm bit is set, long mode is available
  test edx, 1 << 29
  jz .no_long_mode ; lm bit(29) not set 

  ret

.no_long_mode:
  mov al, "L" ; "L" for long mode
  jmp error

setup_page_tables:
  ; Identity mapping -> map physic addr to same virtual addr
  mov eax, page_table_l3 ; take addr of L3 table and move into eax
  ; log2(4096) = 12, so the first 12 bits of every entry will always be 0
  ; cpu uses these bits to store flags instead
  or eax, 0b11 ; present and writable bits
  mov [page_table_l4], eax

  mov eax, page_table_l2
  or eax, 0b11
  mov [page_table_l3], eax
  ; **TODO** Review why we don't need L1 table

  mov ecx, 0 ; counter
.loop:
  ; map 2MB page
  mov eax, 0x200000
  mul ecx ; multiply by counter to get correct addr for next page
  or eax, 0b10000011 ; present and writable bits, plus huge page flag
  mov [page_table_l2 + ecx*8], eax

  inc ecx ; increment counter
  cmp ecx, 512 ; checks if the whole table is mapped
  jne .loop ; if not, continue to loop

  ret

enable_paging:
  ; pass page table location to cpu; cpu looks for this in CR3 register
  mov eax, page_table_l4 ; move addr of l4 table into eax register
  mov cr3, eax

  ; enable physical address extension (PAE)
  mov eax, cr4
  or eax, 1 << 5 ; 5th bit is PAE flag
  mov cr4, eax ; save changes back into cr4 register

  ; enable long mode
  ; need to work with model specific registers
  mov ecx, 0xC0000080 ; magic value
  rdmsr ; read model specific register
  or eax, 1 << 8 ; long mode flag is at bit 8
  wrmsr ; write back into model specific register

  ; enable paging
  mov eax, cr0
  or eax, 1 << 31 ; paging flag is bit 31
  mov cr0, eax

  ret

error:
  ; print "ERR: X", where X is the error code
  mov dword [0xb8000], 0x4f524f45
  mov dword [0xb8004], 0x4f3a4f52
  mov dword [0xb8008], 0x4f204f20
  mov byte [0xb800a], al ; error code
  hlt

section .bss ; statically allocated variables
; reserve some memory for page tables
align 4096 ; align those 4kB tables
page_table_l4:
  resb 4096
page_table_l3:
  resb 4096
page_table_l2:
  resb 4096
stack_bottom:
  resb 4096 * 4 ; 16 kB of memory
stack_top:

; global descriptor table required to enter 64-bit mode
section .rodata ; create read only data section 
gdt64:
  dq 0 ; must begin with 0 entry
.code_segment: equ $ - gdt64 ; offset inside descriptor table (current addr - start of table)
  dq (1 << 41) | (1 << 44) | (1 << 47) | (1 << 53); code segment; enable executable flag, set descriptor type to 1 for code and data segments, enable present flag, enable 64-bit flag

; create pointer to gdt
.pointer:
  dw $ - gdt64 - 1 ; length of table (minus 1)
  dq gdt64 ; store pointer using gdt64 label
