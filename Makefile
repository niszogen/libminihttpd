CC = gcc
CFLAGS = -Wall -Wextra --pedantic
PREFIX ?= /usr/local
LIBDIR ?= $(PREFIX)/lib
INSTALL ?= install
BUILD_DIR ?= build

all: $(BUILD_DIR)/libminihttpd.a $(BUILD_DIR)/libminihttpd.so.1 $(BUILD_DIR)/examples/hello $(BUILD_DIR)/examples/files

$(BUILD_DIR)/minihttpd.o: minihttpd.c minihttpd.h
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -fPIC -c minihttpd.c -o $@

$(BUILD_DIR)/libminihttpd.a: $(BUILD_DIR)/minihttpd.o
	@mkdir -p $(dir $@)
	ar rcs $@ $^

$(BUILD_DIR)/libminihttpd.so.1: $(BUILD_DIR)/minihttpd.o
	@mkdir -p $(dir $@)
	$(CC) -shared -o $@ $^

$(BUILD_DIR)/examples/hello: examples/hello.c $(BUILD_DIR)/libminihttpd.a
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< $(BUILD_DIR)/libminihttpd.a -o $@

$(BUILD_DIR)/examples/files: examples/files.c $(BUILD_DIR)/libminihttpd.a
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< $(BUILD_DIR)/libminihttpd.a -o $@

run-hello: $(BUILD_DIR)/examples/hello
	./$(BUILD_DIR)/examples/hello

run-files: $(BUILD_DIR)/examples/files
	./$(BUILD_DIR)/examples/files

install: $(BUILD_DIR)/libminihttpd.so.1
	$(INSTALL) -d $(DESTDIR)$(LIBDIR)
	$(INSTALL) -m 755 $< $(DESTDIR)$(LIBDIR)/libminihttpd.so.1
	ln -sf libminihttpd.so.1 $(DESTDIR)$(LIBDIR)/libminihttpd.so

uninstall:
	rm -f $(DESTDIR)$(LIBDIR)/libminihttpd.so.1 $(DESTDIR)$(LIBDIR)/libminihttpd.so

clean:
	rm -rf $(BUILD_DIR)
	rm -f *.o *.a *.so* examples/*.o examples/hello examples/files

.PHONY: all run-hello run-files clean install uninstall
