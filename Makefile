all: myshell

myshell: main.s io.s parsing_strings.s builtin.s
	gcc main.s io.s parsing_strings.s builtin.s -o myshell

clean:
	rm -f myshell
