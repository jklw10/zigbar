#ifndef CONFIG_H
#define CONFIG_H

// 1. Core ZBar version macros expected by error.c
#define ZBAR_VERSION_MAJOR 0
#define ZBAR_VERSION_MINOR 23
#define ZBAR_VERSION_PATCH 90

// 2. Enable the decoders you want to support
#define ENABLE_EAN 1
#define ENABLE_CODE128 1
#define ENABLE_CODE39 1
#define ENABLE_I25 1
#define ENABLE_QRCODE 1

// 3. Disable platform GUI/Video components we are not using
#define HAVE_VIDEO 0
#define HAVE_V4L2 0
#define HAVE_X 0
#define HAVE_IMAGEMAGICK 0

// 4. Standard headers to ensure cross-platform formatting macros are loaded
#include <stdint.h>
#include <inttypes.h>

// Fallback if PRIx32 format macro is not defined by standard headers on a platform
#ifndef PRIx32
#define PRIx32 "x"
#endif

#endif