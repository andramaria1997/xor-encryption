tema2: tema2.asm
	nasm -f elf32 -o tema2.o $< -g
	gcc -m32 -o $@ tema2.o -g

clean:
	rm -f tema2 tema2.o
