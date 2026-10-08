/* Bump allocator toi gian cho host test (khong can free that). */
#include <stddef.h>

static unsigned char heap_pool[512];
static size_t heap_off = 0;

void *ws_malloc(size_t n) {
    n = (n + 7u) & ~((size_t)7u);
    if (heap_off + n > sizeof(heap_pool)) return NULL;
    void *p = &heap_pool[heap_off];
    heap_off += n;
    return p;
}

void ws_free(void *p) {
    (void)p;
}
