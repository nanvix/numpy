/* config.h -- Generated for Nanvix (i686, 32-bit, no SIMD, no threading) */

#ifndef NUMPY_CORE_SRC_COMMON_NPY_CONFIG_H_
#error config.h should never be included directly, include npy_config.h instead
#endif

/* Type sizes (i686-nanvix-gcc) */
#define SIZEOF_PY_INTPTR_T 4
#define SIZEOF_OFF_T       8
#define SIZEOF_PY_LONG_LONG 8

/* Functions available in Nanvix newlib */
/* #undef HAVE_BACKTRACE */
/* #undef HAVE_MADVISE */
#define HAVE_FTELLO 1
#define HAVE_FSEEKO 1
/* #undef HAVE_FALLOCATE */
#define HAVE_STRTOLD_L 1
#define HAVE__THREAD 1
/* #undef HAVE___DECLSPEC_THREAD_ */

/* Optional headers */
/* #undef HAVE_FEATURES_H */
/* #undef HAVE_XLOCALE_H */
#define HAVE_DLFCN_H 1
/* #undef HAVE_EXECINFO_H */
/* #undef HAVE_LIBUNWIND_H */
#define HAVE_SYS_MMAN_H 1
/* No SIMD headers on i686-nanvix */
/* #undef HAVE_XMMINTRIN_H */
/* #undef HAVE_EMMINTRIN_H */
/* #undef HAVE_IMMINTRIN_H */

/* GCC builtins */
#define HAVE___BUILTIN_ISNAN 1
#define HAVE___BUILTIN_ISINF 1
#define HAVE___BUILTIN_ISFINITE 1
#define HAVE___BUILTIN_BSWAP32 1
#define HAVE___BUILTIN_BSWAP64 1
#define HAVE___BUILTIN_EXPECT 1
#define HAVE___BUILTIN_MUL_OVERFLOW 1
#define HAVE___BUILTIN_PREFETCH 1

/* GCC attributes */
#define HAVE_ATTRIBUTE_OPTIMIZE_UNROLL_LOOPS 1
#define HAVE_ATTRIBUTE_OPTIMIZE_OPT_3 1
#define HAVE_ATTRIBUTE_OPTIMIZE_OPT_2 1
#define HAVE_ATTRIBUTE_NONNULL 1

/* C99 complex support */
#define HAVE_COMPLEX_H 1
#define HAVE_CABS 1
#define HAVE_CACOS 1
#define HAVE_CACOSH 1
#define HAVE_CARG 1
#define HAVE_CASIN 1
#define HAVE_CASINH 1
#define HAVE_CATAN 1
#define HAVE_CATANH 1
#define HAVE_CEXP 1
#define HAVE_CLOG 1
#define HAVE_CPOW 1
#define HAVE_CSQRT 1
#define HAVE_CABSF 1
#define HAVE_CACOSF 1
#define HAVE_CACOSHF 1
#define HAVE_CARGF 1
#define HAVE_CASINF 1
#define HAVE_CASINHF 1
#define HAVE_CATANF 1
#define HAVE_CATANHF 1
#define HAVE_CEXPF 1
#define HAVE_CLOGF 1
#define HAVE_CPOWF 1
#define HAVE_CSQRTF 1
#define HAVE_CABSL 1
#define HAVE_CACOSL 1
#define HAVE_CACOSHL 1
#define HAVE_CARGL 1
#define HAVE_CASINL 1
#define HAVE_CASINHL 1
#define HAVE_CATANL 1
#define HAVE_CATANHL 1
#define HAVE_CEXPL 1
#define HAVE_CLOGL 1
#define HAVE_CPOWL 1
#define HAVE_CSQRTL 1
#define HAVE_CSINF 1
#define HAVE_CSINHF 1
#define HAVE_CCOSF 1
#define HAVE_CCOSHF 1
#define HAVE_CTANF 1
#define HAVE_CTANHF 1
#define HAVE_CSIN 1
#define HAVE_CSINH 1
#define HAVE_CCOS 1
#define HAVE_CCOSH 1
#define HAVE_CTAN 1
#define HAVE_CTANH 1
#define HAVE_CSINL 1
#define HAVE_CSINHL 1
#define HAVE_CCOSL 1
#define HAVE_CCOSHL 1
#define HAVE_CTANL 1
#define HAVE_CTANHL 1

/* No SVML */
/* #undef NPY_CAN_LINK_SVML */

/* No relaxed strides debug */
#define NPY_RELAXED_STRIDES_DEBUG 0

/* Long double: Intel extended 80-bit in 12 bytes, little-endian */
#define HAVE_LDOUBLE_INTEL_EXTENDED_12_BYTES_LE 1
/* #undef HAVE_LDOUBLE_INTEL_EXTENDED_16_BYTES_LE */
/* #undef HAVE_LDOUBLE_MOTOROLA_EXTENDED_12_BYTES_BE */
/* #undef HAVE_LDOUBLE_IEEE_DOUBLE_LE */
/* #undef HAVE_LDOUBLE_IEEE_DOUBLE_BE */
/* #undef HAVE_LDOUBLE_IEEE_QUAD_LE */
/* #undef HAVE_LDOUBLE_IEEE_QUAD_BE */
/* #undef HAVE_LDOUBLE_IBM_DOUBLE_DOUBLE_LE */
/* #undef HAVE_LDOUBLE_IBM_DOUBLE_DOUBLE_BE */

#ifndef __cplusplus
/* #undef inline */
#endif
