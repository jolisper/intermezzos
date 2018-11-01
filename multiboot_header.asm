section .multiboot_header
header_start:
    dd 0xe85250d6   ; magic number, required by multiboot protocol
    dd 0            ; protected mode code
    dd header_end - header_start

    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; required end tag
    dw 0            ; type
    dw 0            ; flags
    dw 8            ; size
header_end:
