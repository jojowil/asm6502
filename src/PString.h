#ifndef PString_H_INCL
#define PString_H_INCL

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <string.h>
#include "git-banned.h"

typedef struct {
    unsigned char length;   // length as the first value
    char chars[255];        // 255 chars
} PString;

// Functions for the management of the PString environment.
static void ps_beg(void);

static void ps_init_tmp_arena(void);

static void ps_end();

static void ps_ccpy(PString *dst, const char *src);

// Utility functions
static long myatol(const char *buf, int radix);

// Functions for managing PStrings and C-strings.
static PString ps_new(const char *src);

static void ps_ccpy(PString *dst, const char *src);

static int ps_len(PString src);

static char *ps_cstr(PString src);

static char *ps_tmp(PString src);

static PString ps_cat(const char *fmt, ...);

static PString ps_sub(PString src, int pos, int len);

static int ps_pos(PString src, const char *pattern);

static PString ps_str(long);

static long ps_val(PString src, int radix);

static int ps_cmp(PString s1, PString s2);

static int ps_equ(PString s1, const char *s2);

#ifdef PString_IMPL

/*
static char *ARENA = NULL; // ARENA pointer.
static int ARENA_SIZE = 0; // size in 256 byte structs.
static int ARENA_POS = 0; // current position.
*/

#ifndef ARENA_SIZE
#define ARENA_SIZE 256
#endif
static char *TMP_ARENA[ARENA_SIZE];
static int TMP_ARENA_SIZE = ARENA_SIZE;
static int TMP_ARENA_POS = 0; // current position.

// Initialize the temp arena to NULL
static void ps_init_tmp_arena(void) {
    for (int x = 0; x < ARENA_SIZE; x++)
        TMP_ARENA[x] = NULL;
}

// This is the function you call before you create ps_tmp()'s
static void ps_begin(void) {
    ps_init_tmp_arena();
}

// This is the cleanup function you call after done with ps_tmp()'s
static void ps_end() {
    for (int x = 0; x < TMP_ARENA_SIZE; x++)
        if (TMP_ARENA[x] != NULL)
            free(TMP_ARENA[x]);
}

// Create PString using a C string to initialize it
static PString ps_new(const char *src) {
    PString d;
    d.length = 0;
    if (src == NULL) return d;
    int sl = (int)strlen(src);

    memcpy(&d.chars, src, sl);
    d.length = sl;
#ifdef DEBUG
    printf("d.length = %d\n", d.length);
#endif
    return d;
}

/* Replace contents with a C string. PString to PString copy is between structs.
 *
 * Sets errno to E2BIG if size exceeded.
 * NULL will empty the dst.
 */
static void ps_ccpy(PString *dst, const char *src) {
    if (src == NULL) { dst->length = 0; return; }
    const char *p = src;
    int x = 0;

    int sl = (int)strlen(src);
    memcpy(dst->chars, src, sl);
    dst->length = sl;
}

// Safe atol(). Used by ps_val();
static long myatol(const char *buf, int radix) {
    errno = 0;
    char *p;
    long a = strtol(buf, &p, radix); // also sets ERANGE

    // *p can be '\0' or '\n', but p cannot be buf.
    if (!((!*p || *p == '\n') && p != buf && !errno))
        errno = EINVAL;
    return a;
}

// Function to get the PString length. Kind of unneeded, but... it's O(1)
static int ps_len(PString src) {
    return src.length;
}

/* Create a C string of fixed size (256). You MUST free() these!
 *
 * returns NULL is something goes wrong...
 */
static char *ps_cstr(PString src) {
    char *d = NULL;
#ifdef DEBUG
    printf("s.length is %d\n", src.length);
#endif
    if ((d = (char *) malloc(256 * sizeof(char))) != NULL) {
        memcpy(d, src.chars, src.length);
        d[src.length] = '\0';
    }
#ifdef DEBUG
    if (d) printf("strlen(d) = %lu\n", strlen(d));
#endif
    return d;
}

// Create a temp C string after ps_begin(). These are all cleaned up with ps_end().
static char *ps_tmp(PString src) {
    char *d = NULL;
#ifdef DEBUG
    printf("src.length is %d\n", src.length);
#endif
    if ((TMP_ARENA[TMP_ARENA_POS] = (char *) malloc(256 * sizeof(char))) != NULL) {
        d = TMP_ARENA[TMP_ARENA_POS++];
        memcpy(d, src.chars, src.length);
        d[src.length] = '\0';
    }
#ifdef DEBUG
    printf("strlen(d) = %lu\n", strlen(d));
#endif
    return d;
}

static void ps_tmp_dump(void) {
    printf("Total number of allocations is %d of %d\n", TMP_ARENA_POS, TMP_ARENA_SIZE);
    for (int x = 0; x < TMP_ARENA_POS; x++)
        printf("TMP-ARENA[%d] = %p\n", x, TMP_ARENA[x]);
}

/* Simple concatenate function using simplified printf() format.
 *
 * PString p = ps_cat("psp", p1, s1, p2);
 *
 * Allows you to mix PString and C strings.
 * Sets errno to E2BIG if size exceeded.
 * Sets errno to EINVAL if unknown conversion.
 */
static PString ps_cat(const char *fmt, ...) {
    PString d;
    d.length = 0;
    va_list args;

    for (va_start(args, fmt); *fmt != '\0'; ++fmt) {
#ifdef DEBUG
        printf("Processing %c,", *fmt);
#endif
        switch (*fmt) {
            case 'p': {
                PString p = va_arg(args, PString);
                int dl = d.length, pl = p.length, cl = dl + pl;
#ifdef DEBUG
                printf("dl = %d, pl = %d, cl = %d\n", dl, pl, cl);
#endif
                if (cl > 255) {
                    errno = E2BIG;
                    goto END;
                }
                for (int x = 0; x < pl; x++)
                    d.chars[x + dl] = p.chars[x];
                d.length = cl;
                break;
            }
            case 's': {
                const char *s = va_arg(args, const char *);
                int dl = d.length, sl = (int) strlen(s), cl = dl + sl;
#ifdef DEBUG
                printf("dl = %d, sl = %d, cl = %d\n", dl, sl, cl);
#endif
                if (cl > 255) {
                    errno = E2BIG;
                    goto END;
                }
                for (int x = 0; x < sl; x++)
                    d.chars[x + dl] = s[x];
                d.length = cl;
                break;
            }
            default:
                errno = EINVAL;
                goto END;
        }
    }
END:
    va_end(args);
#ifdef DEBUG
    printf("d.length = %d\n", d.length);
#endif
    return d;
}

/* Get substring of PString
 *
 * Sets errno to EINVAL if pos is out of bounds
 * If len exceeds the end, returns to the end.
 */
static PString ps_sub(PString src, int pos, int len) {
    PString d;
    d.length = 0;
    int sl = src.length;
    if (pos < 0 || pos > sl - 1) {
        errno = EINVAL;
    } else {
        sl = src.length;
        // let's get the right length without going over.
        if (sl + len > 255)
            len = 255 - src.length;
        else if (len + pos > sl)
            len = sl - pos;
        memcpy(d.chars, &src.chars[pos], len);
        d.length = len;
    }
    return d;
}

// Find first occurrence of patter in PString.
static int ps_pos(PString src, const char *pattern) {
    char *s = ps_cstr(src);
    char *pos = strstr(s, pattern);
    if (s) free(s);
    return pos == NULL ? -1 : (int) (pos - s);
}

// Convert long to PString.
static PString ps_str(long v) {
    char d[30];
    snprintf(d, sizeof d, "%ld", v);
    return ps_new(d);
}

// Converts PString number to long, safely.
static long ps_val(PString src, int radix) {
    char *s = ps_cstr(src);
    long res = myatol(s, radix);
    free(s);
    return res;
}

// Performs comparison giving strcmp result.
static int ps_cmp(PString s1, PString s2) {
    char *s, *t;

    // do not use ps_begin()/ps_end() here!
    if ((s = ps_cstr(s1)) == NULL) return 0;
    if ((t = ps_cstr(s2)) == NULL) {
        free(s);
        return 0;
    }
    int res = strcmp(s, t);
    free(s);
    free(t);
    return res;
}

// Compares PString and C strin for equality.
static int ps_equ(PString s1, const char *s2) {
    int s1l = s1.length, s2l = (int) strlen(s2);
    if (s1l != s2l) return 0;
    for (int x = 0; x < s1l; x++)
        if (s1.chars[x] != s2[x]) return 0;
    return 1;
}

#endif // PString_IMPL

#endif // PString_H_INCL
