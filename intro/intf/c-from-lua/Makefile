all: test

test: test.o
	gcc -Wall -shared -fPIC -o test.so -llua test.c	

clean:
	rm -rf test.o test.so

