#ifndef _ICONV_H_MOCK_
#define _ICONV_H_MOCK_

#include <stddef.h>

typedef void* iconv_t;

// Returns a dummy non-zero handle
static inline iconv_t iconv_open(const char *tocode, const char *fromcode) {
    (void)tocode; (void)fromcode;
    return (iconv_t)1; 
}

// Simple pass-through character copier
static inline size_t iconv(iconv_t cd, char **inbuf, size_t *inbytesleft, char **outbuf, size_t *outbytesleft) {
    (void)cd;
    if (!inbuf || !*inbuf) return 0;
    
    size_t len = (*inbytesleft < *outbytesleft) ? *inbytesleft : *outbytesleft;
    for (size_t i = 0; i < len; i++) {
        (*outbuf)[i] = (*inbuf)[i];
    }
    *inbuf += len;
    *inbytesleft -= len;
    *outbuf += len;
    *outbytesleft -= len;
    return 0;
}

static inline int iconv_close(iconv_t cd) {
    (void)cd;
    return 0;
}

#endif