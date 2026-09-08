CC = gcc
CFLAGS = -Wall -Wextra --pedantic

all: libminihttpd.a libminihttpd.so.1 examples/hello examples/files

minihttpd.o: minihttpd.c minihttpd.h
	$(CC) $(CFLAGS) -fPIC -c minihttpd.c -o $@

libminihttpd.a: minihttpd.o
	ar rcs $@ $^

libminihttpd.so.1: minihttpd.o
	$(CC) -shared -o $@ $^

examples/hello: examples/hello.c libminihttpd.a
	$(CC) $(CFLAGS) $< libminihttpd.a -o $@

examples/files: examples/files.c libminihttpd.a
	$(CC) $(CFLAGS) $< libminihttpd.a -o $@

run-hello: examples/hello
	./examples/hello

run-files: examples/files
	./examples/files

clean:
	rm -f *.o *.a *.so examples/*.o examples/hello examples/files

.PHONY: all run clean
