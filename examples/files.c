#include "../minihttpd.h"
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <time.h>

#define PUBLIC_DIR "."

static char *get_mime_type(const char *path) {
	const char *dot = strrchr(path, '.');
	if (!dot)
		return "application/octet-stream";
	if (strcasecmp(dot, ".html") == 0)
		return "text/html";
	else if (strcasecmp(dot, ".css") == 0)
		return "text/css";
	else if (strcasecmp(dot, ".js") == 0)
		return "application/javascript";
	else if (strcasecmp(dot, ".ico") == 0)
		return "image/x-icon";
	else if (strcasecmp(dot, ".png") == 0)
		return "image/png";
	else if (strcasecmp(dot, ".txt") == 0)
		return "text/plain";
	else
		return "application/octet-stream";
}

static minihttpd_response_t handler(const char *path, void *user_data) {
	(void)user_data;

	if (strstr(path, "..")) {
		return (minihttpd_response_t){NULL, 0, NULL, 0};
	}

	char filepath[256];
	if (strcmp(path, "/") == 0) {
		snprintf(filepath, sizeof(filepath), "%s/index.html", PUBLIC_DIR);
	} else {
		snprintf(filepath, sizeof(filepath), "%s%s", PUBLIC_DIR, path);
	}

	FILE *f = fopen(filepath, "rb");
	if (!f) {
		return (minihttpd_response_t){NULL, 0, NULL, 0};
	}

	if (fseek(f, 0, SEEK_END) != 0) {
		fclose(f);
		return (minihttpd_response_t){NULL, 0, NULL, 0};
	}
	long size = ftell(f);
	if (size < 0) {
		fclose(f);
		return (minihttpd_response_t){NULL, 0, NULL, 0};
	}
	rewind(f);

	char *buffer = malloc((size_t)size);
	if (!buffer) {
		fclose(f);
		return (minihttpd_response_t){NULL, 0, NULL, 0};
	}

	size_t read_bytes = fread(buffer, 1, (size_t)size, f);
	fclose(f);

	if (read_bytes != (size_t)size) {
		free(buffer);
		return (minihttpd_response_t){NULL, 0, NULL, 0};
	}

	return (minihttpd_response_t){buffer, (size_t)size, get_mime_type(filepath), 1};
}

int main(int argc, char **argv) {
	int port = 8080;
	if (argc == 3 && strcmp(argv[1], "--port") == 0)
		port = atoi(argv[2]);

	minihttpd_t *server = minihttpd_init(port, handler);
	if (!server) {
		fprintf(stderr, "Failed to start server\n");
		return 1;
	}

	printf("Listening on http://localhost:%i\n", port);
	minihttpd_run(server);

	minihttpd_free(server);
	return 0;
}
