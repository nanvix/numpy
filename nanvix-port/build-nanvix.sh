#!/bin/bash
# Cross-compile numpy _multiarray_umath for Nanvix (i686)
# Run inside Docker: ghcr.io/nanvix/toolchain-gcc:latest
set -e

NUMPY_ROOT="/workspace/numpy"
GENDIR="$NUMPY_ROOT/numpy/core/src/_generated"
CFGDIR="$NUMPY_ROOT/nanvix-port/generated-headers"
APIDIR="$NUMPY_ROOT/nanvix-port/generated-headers"
PYINC="$NUMPY_ROOT/nanvix-port/cpython-headers/python3.12"
OUTDIR="$NUMPY_ROOT/dist/obj"

CC="i686-nanvix-gcc"
CXX="i686-nanvix-g++"
AR="i686-nanvix-ar"

CFLAGS="-m32 -march=pentiumpro -Os -fdata-sections -ffunction-sections \
  -DNDEBUG -DNPY_DISABLE_OPTIMIZATION -DNPY_NO_SMP -DNPY_NO_SIGNAL \
  -DNPY_INTERNAL_BUILD=1 \
  -D_MULTIARRAYMODULE -D_UMATHMODULE \
  -Wno-unused-function -Wno-deprecated-declarations -Wno-unused-variable \
  -Wno-sign-compare -Wno-unused-but-set-variable -Wno-missing-field-initializers"

CXXFLAGS="-m32 -march=pentiumpro -Os -fdata-sections -ffunction-sections \
  -std=c++17 -DNDEBUG -DNPY_DISABLE_OPTIMIZATION -DNPY_NO_SMP -DNPY_NO_SIGNAL \
  -DNPY_INTERNAL_BUILD=1 \
  -D_MULTIARRAYMODULE -D_UMATHMODULE \
  -Wno-unused-function -Wno-deprecated-declarations -Wno-unused-variable \
  -Wno-sign-compare -Wno-missing-field-initializers"

INCLUDES="-I$PYINC \
  -I$NUMPY_ROOT/numpy/core/include \
  -I$NUMPY_ROOT/numpy/core/src/common \
  -I$NUMPY_ROOT/numpy/core/src/multiarray \
  -I$NUMPY_ROOT/numpy/core/src/npymath \
  -I$NUMPY_ROOT/numpy/core/src/umath \
  -I$CFGDIR \
  -I$APIDIR \
  -I$GENDIR"

mkdir -p "$OUTDIR"

compile_c() {
    local src="$1"
    local obj="$OUTDIR/$(basename "${src%.*}").o"
    echo "  CC  $(basename $src)"
    $CC $CFLAGS $INCLUDES -c "$src" -o "$obj" 2>&1 || { echo "FAILED: $src"; return 1; }
}

compile_cxx() {
    local src="$1"
    local obj="$OUTDIR/$(basename "${src%.*}").o"
    echo "  CXX $(basename $src)"
    $CXX $CXXFLAGS $INCLUDES -c "$src" -o "$obj" 2>&1 || { echo "FAILED: $src"; return 1; }
}

compile_gen() {
    local src="$GENDIR/$1"
    local obj="$OUTDIR/${1%.*}.o"
    echo "  CC  $1 (generated)"
    $CC $CFLAGS $INCLUDES -c "$src" -o "$obj" 2>&1 || { echo "FAILED: $src"; return 1; }
}

echo "=== Phase 1: npymath library ==="
SRC="$NUMPY_ROOT/numpy/core/src/npymath"
compile_cxx "$SRC/halffloat.cpp"
compile_c "$SRC/npy_math.c"
compile_cxx "$SRC/ieee754.cpp"
compile_gen "npy_math_complex.c"

echo ""
echo "=== Phase 2: common sources ==="
SRC="$NUMPY_ROOT/numpy/core/src/common"
compile_c "$SRC/array_assign.c"
compile_c "$SRC/mem_overlap.c"
compile_c "$SRC/npy_argparse.c"
compile_c "$SRC/npy_hashtable.c"
compile_c "$SRC/npy_longdouble.c"
compile_c "$SRC/ucsnarrow.c"
compile_c "$SRC/ufunc_override.c"
compile_c "$SRC/numpyos.c"
compile_c "$SRC/npy_cpu_features.c"

echo ""
echo "=== Phase 3: multiarray sources ==="
SRC="$NUMPY_ROOT/numpy/core/src/multiarray"
for f in \
    abstractdtypes.c alloc.c arrayobject.c array_coercion.c array_method.c \
    array_assign_scalar.c array_assign_array.c arrayfunction_override.c \
    buffer.c calculation.c compiled_base.c common.c common_dtype.c \
    convert.c convert_datatype.c conversion_utils.c ctors.c \
    datetime.c datetime_strings.c datetime_busday.c datetime_busdaycal.c \
    descriptor.c dlpack.c dtypemeta.c dragon4.c dtype_transfer.c dtype_traversal.c \
    experimental_public_dtype_api.c flagsobject.c getset.c hashdescr.c \
    item_selection.c iterators.c legacy_dtype_implementation.c \
    mapping.c methods.c multiarraymodule.c \
    nditer_api.c nditer_constr.c nditer_pywrap.c \
    number.c refcount.c sequence.c shape.c scalarapi.c \
    strfuncs.c temp_elide.c typeinfo.c usertypes.c vdot.c
do
    compile_c "$SRC/$f"
done

# Template-generated multiarray files
for f in arraytypes.c einsum.c einsum_sumprod.c lowlevel_strided_loops.c \
         nditer_templ.c scalartypes.c
do
    compile_gen "$f"
done

# Textreading sources
SRC="$NUMPY_ROOT/numpy/core/src/multiarray/textreading"
for f in conversions.c field_types.c growth.c readtext.c rows.c \
         stream_pyobject.c str_to_int.c
do
    compile_c "$SRC/$f"
done
compile_cxx "$SRC/tokenize.cpp"

echo ""
echo "=== Phase 4: npysort C++ sources ==="
SRC="$NUMPY_ROOT/numpy/core/src/npysort"
for f in quicksort.cpp mergesort.cpp timsort.cpp heapsort.cpp \
         radixsort.cpp selection.cpp binsearch.cpp
do
    compile_cxx "$SRC/$f"
done

echo ""
echo "=== Phase 5: umath sources ==="
SRC="$NUMPY_ROOT/numpy/core/src/umath"
for f in ufunc_type_resolution.c dispatching.c extobj.c \
         legacy_array_method.c override.c reduction.c \
         ufunc_object.c umathmodule.c wrapping_array_method.c \
         _scaled_float_dtype.c
do
    compile_c "$SRC/$f"
done
compile_cxx "$SRC/clip.cpp"
compile_cxx "$SRC/string_ufuncs.cpp"

# Template-generated umath files
for f in funcs.inc loops.c matmul.c scalarmath.c
do
    # funcs.inc needs special handling - it's included, not compiled directly
    if [ "$f" = "funcs.inc" ]; then
        continue
    fi
    compile_gen "$f"
done

echo ""
echo "=== Phase 6: dispatch-able sources (baseline only) ==="
# These .dispatch.c files are compiled with NPY_DISABLE_OPTIMIZATION
# so they only produce baseline implementations
for f in argfunc.dispatch.c \
         loops_arithm_fp.dispatch.c loops_arithmetic.dispatch.c \
         loops_autovec.dispatch.c loops_comparison.dispatch.c \
         loops_exponent_log.dispatch.c loops_hyperbolic.dispatch.c \
         loops_logical.dispatch.c loops_minmax.dispatch.c \
         loops_modulo.dispatch.c loops_trigonometric.dispatch.c \
         loops_umath_fp.dispatch.c loops_unary.dispatch.c \
         loops_unary_complex.dispatch.c loops_unary_fp.dispatch.c \
         loops_unary_fp_le.dispatch.c
do
    compile_gen "$f"
done

echo ""
echo "=== Phase 7: Additional sources ==="
# __multiarray_api.c and __ufunc_api.c are #included inside
# multiarraymodule.c and umathmodule.c respectively, not compiled separately.

# arm64 exports stub (needed for symbol)
compile_c "$NUMPY_ROOT/numpy/core/src/npymath/arm64_exports.c"

echo ""
echo "=== Phase 8: Creating static archive ==="
$AR rcs "$OUTDIR/libnumpy_core.a" "$OUTDIR"/*.o
echo "Created: $OUTDIR/libnumpy_core.a ($(du -h "$OUTDIR/libnumpy_core.a" | cut -f1))"
echo "Objects: $(ls "$OUTDIR"/*.o | wc -l) files"
echo ""
echo "=== BUILD COMPLETE ==="
