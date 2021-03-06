default: build

.PHONY: default build run clean

build/multiboot_header.o: multiboot_header.asm
	mkdir -p build
	nasm -f elf64 -o build/multiboot_header.o multiboot_header.asm

build/boot.o: boot.asm
	mkdir -p build
	nasm -f elf64 -o build/boot.o boot.asm

build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
	ld -n -o build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o

build/os.iso: build/kernel.bin grub.cfg
	mkdir -p build/isofiles/boot/grub
	cp grub.cfg build/isofiles/boot/grub
	cp build/kernel.bin build/isofiles/boot
	grub-mkrescue -o build/os.iso build/isofiles

build: build/os.iso

run: build/os.iso
	qemu-system-x86_64 -cdrom build/os.iso

clean:
	rm -rf build
