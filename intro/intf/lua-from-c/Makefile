all: test

test: test.o
	gcc -Wall -o test test.c -L/usr/local/lib -lpthread -lrt -llua -lm -ldl

clean:
	rm -rf test.o test

