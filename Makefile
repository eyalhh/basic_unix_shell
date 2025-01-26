myshell: parsing_strings.o main.o builtin.o
	gcc -o myshell parsing_strings.o main.o builtin.o -fPIC

parsing_strings.o: parsing_strings.s
	gcc -c parsing_strings.s -o parsing_strings.o -fPIC

main.o: main.s
	gcc -c main.s -o main.o -fPIC

builtin.o: builtin.s
	gcc -c builtin.s -o builtin.o -fPIC

clean:
	rm -f *.o myshell
