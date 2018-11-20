global start

section .text
bits 32
start:
    ; **** Creating the Page Table ****

    ; Point the first entry of the level 4 page table to the first entry in the 
    ; p3 table.
    mov eax, p3_table
    or  eax, 0b11       ; setting ‘present bit’ and the ‘writable bit’
    mov dword [p4_table + 0], eax

    ; Point the first entry of the level 3 page table to the first entry in the 
    ; p2 table.
    mov eax, p2_table
    or  eax, 0b11       ; setting ‘present bit’ and the ‘writable bit’
    mov dword [p3_table + 0], eax

    ; Point each page level 2 entry to a page
    mov eax, 0          ; counter variable
.map_p2_table:
    mov eax, 0x200000   ; 2MB
    mul ecx             ; offset calculation
    or  eax, 0b10000011 ; setting 'huge page' bit, and ‘present bit’ and the ‘writable bit’
    mov [p2_table + ecx * 8], eax ; each table entry is eight bytes in size

    inc ecx
    ; The page table is 4096 bytes, each entry is 8 bytes, so that means there are 512 entries.
    ; This will give us 512 * 2 MB: 1 GB of memory.
    cmp ecx, 512        
    jne .map_p2_table

    ; **** Enabling Paging ****
    ; We have a valid page table, we need to inform the hardware about it:

    ; A control register (cr) is a processor register which changes or controls the general 
    ; behavior of a CPU.
    ;
    ; CR3 enables the processor to translate linear addresses into physical addresses by locating 
    ; the page directory and page tables for the current task. CR3 become the page directory 
    ; base register (PDBR), which stores the physical address of the first page directory entry.
    mov eax, p4_table
    mov cr3, eax

    ; * Enabling ‘Physical Address Extension’
    ; PAE defines a page table hierarchy of three levels: 
    ;   Level 4 - Page directory pointer table
    ;   Level 3 - Page directory
    ;   Level 2 - Memory page (2MB)
    ; With table entries of 64 bits each instead of 32, this allows more room for the physical 
    ; page address, or "page frame number" field, in the page table entry.
    ; The entries in the page directory have an additional flag in bit 7, named PS (for page size). 
    ; If the system has set this bit to 1, the page directory entry does not point to a page table 
    ; but to a single, large 2 MB page.
    mov eax, cr4
    or  eax, 1 << 5
    mov cr4, eax

    ; * Setting the long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8      ; Set bit 8 on model specific register: long mode enable
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31     ; If 1, enable paging and use the CR3 register, else disable paging.
    or eax, 1 << 16     ; When set, the CPU can't write to read-only pages when privilege level is 0.
    mov cr0, eax        ; Commit config


    ; 'Hello world!' message print:
    mov word [0xb8000], 0x0248 ; H
    mov word [0xb8002], 0x0265 ; e
    mov word [0xb8004], 0x026c ; l
    mov word [0xb8006], 0x026c ; l
    mov word [0xb8008], 0x026f ; o
    mov word [0xb800a], 0x022c ; ,
    mov word [0xb800c], 0x0220 ;
    mov word [0xb800e], 0x0277 ; w
    mov word [0xb8010], 0x026f ; o
    mov word [0xb8012], 0x0272 ; r
    mov word [0xb8014], 0x026c ; l
    mov word [0xb8016], 0x0264 ; d
    mov word [0xb8018], 0x0221 ; !
    hlt

section .bss

align 4096

p4_table:
    resb    4096
p3_table:
    resb    4096
p2_table:
    resb    4096

