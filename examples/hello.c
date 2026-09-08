#include "../minihttpd.h"
#include <stdio.h>
#include <string.h>

static minihttpd_response_t handler(const char *path, void *user_data) {
	(void)user_data;

	if (strcmp(path, "/") == 0) {
		static const char *body = "Hello from libminihttpd!\n";
		return (minihttpd_response_t){body, strlen(body), "text/plain"};
	}
	if (strcmp(path, "/hi.json") == 0) {
		static const char *body = "{\"message\":\"hi :D\"}\n";
		return (minihttpd_response_t){body, strlen(body), "application/json"};
	}

	return (minihttpd_response_t){NULL, 0, NULL}; // -> 404
}

int main(void) {
	minihttpd_t *server = minihttpd_init(8080, handler);
	if (!server) {
		fprintf(stderr, "Failed to start server\n");
		return 1;
	}

	printf("Listening on http://localhost:8080\n");
	minihttpd_run(server);

	minihttpd_free(server);
	return 0;
}
