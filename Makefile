CC = gcc
CFLAGS = -Wall -Wextra -std=c11

all: libminihttpd.a libminihttpd.so.1 examples/hello

minihttpd.o: minihttpd.c minihttpd.h
	$(CC) $(CFLAGS) -fPIC -c minihttpd.c -o $@

libminihttpd.a: minihttpd.o
	ar rcs $@ $^

libminihttpd.so.1: minihttpd.o
	$(CC) -shared -o $@ $^

examples/hello: examples/hello.c libminihttpd.a
	$(CC) $(CFLAGS) $< libminihttpd.a -o $@

run: examples/hello
	./examples/hello

clean:
	rm -f *.o *.a *.so examples/*.o examples/hello

.PHONY: all run clean
