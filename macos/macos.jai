//
// This file was auto-generated using the following command:
//
// jai generate.jai - -compile
//



SIMDUTF_CPLUSPLUS17 :: 1;

SIMDUTF_CPLUSPLUS14 :: 1;

SIMDUTF_CPLUSPLUS11 :: 1;

SIMDUTF_IS_ARM64 :: 1;

SIMDUTF_VERSION_STRING :: "9.0.0";

SIMDUTF_FEATURE_DETECT_ENCODING :: 1;

SIMDUTF_FEATURE_ASCII :: 1;

SIMDUTF_FEATURE_LATIN1 :: 1;

SIMDUTF_FEATURE_UTF8 :: 1;

SIMDUTF_FEATURE_UTF16 :: 1;

SIMDUTF_FEATURE_UTF32 :: 1;

SIMDUTF_FEATURE_BASE64 :: 1;

SIMDUTF_NEED_TRAILING_ZEROES :: 1;

SIMDUTF_IMPLEMENTATION_ARM64 :: SIMDUTF_IS_ARM64;

SIMDUTF_CAN_ALWAYS_RUN_ARM64 :: 1;

SIMDUTF_COMPILER_SUPPORTS_VBMI2 :: 1;

SIMDUTF_CAN_ALWAYS_RUN_ICELAKE :: 0;

SIMDUTF_CAN_ALWAYS_RUN_HASWELL :: 0;

SIMDUTF_CAN_ALWAYS_RUN_WESTMERE :: 0;

SIMDUTF_CAN_ALWAYS_RUN_LASX :: 0;

SIMDUTF_CAN_ALWAYS_RUN_FALLBACK :: SIMDUTF_IMPLEMENTATION_FALLBACK;

SIMDUTF_CAN_ALWAYS_RUN_LSX :: 0;

SIMDUTF_IMPLEMENTATION_FALLBACK :: 0;

SIMDUTF_USE_STATIC_INITIALIZATION :: 0;

encoding_type :: enum u32 {
    UTF8        :: 1;
    UTF16_LE    :: 2;
    UTF16_BE    :: 4;
    UTF32_LE    :: 8;
    UTF32_BE    :: 16;
    Latin1      :: 32;

    unspecified :: 0;
}

endianness :: enum u32 {
    LITTLE :: 0;
    BIG    :: 1;
    NATIVE :: 0;
}

error_code :: enum u32 {
    SUCCESS                  :: 0;
    HEADER_BITS              :: 1;
    TOO_SHORT                :: 2;

    TOO_LONG                 :: 3;

    OVERLONG                 :: 4;

    TOO_LARGE                :: 5;

    SURROGATE                :: 6;

    INVALID_BASE64_CHARACTER :: 7;

    BASE64_INPUT_REMAINDER   :: 8;

    BASE64_EXTRA_BITS        :: 9;

    OUTPUT_BUFFER_TOO_SMALL  :: 10;
    OTHER                    :: 11;
}

result :: struct {
    error: error_code;
    // In case of error, indicates the position of the error. In
    // case of success, indicates the number of code units
    // validated/written.
    count: u64;
}

full_result :: struct {
    error:         error_code;
    input_count:   u64;
    output_count:  u64;
    // true if the error is due to padding, only
    // meaningful when error is not SUCCESS
    padding_error  := false;
}

SIMDUTF_VERSION :: enum u32 {
    MAJOR    :: 9;

    MINOR    :: 0;

    REVISION :: 0;

    SIMDUTF_VERSION_MAJOR    :: MAJOR;

    SIMDUTF_VERSION_MINOR    :: MINOR;

    SIMDUTF_VERSION_REVISION :: REVISION;
}

scalar :: struct {
    anon_namespace :: struct {
        base64 :: struct {
            reduced_input :: struct {
                equalsigns:        u64; // number of padding characters '=', typically 0, 1, 2.
                equallocation:     u64; // location of the first padding character if any
                srclen:            u64; // length of the input buffer before padding
                // length of the input buffer with padding but
                // without ignorable characters
                full_input_length: u64;
            }
        }
    }
}

default_line_length: u64 : 76;

// base64_options are used to specify the base64 encoding options.
// ASCII spaces are ' ', '\t', '\n', '\r', '\f'
// garbage characters are characters that are not part of the base64 alphabet
// nor ASCII spaces.
base64_reverse_padding: u64 : 2;

base64_options :: enum u64 {
    default                       :: 0;
    url                           :: 1;
    default_no_padding            :: 2;

    url_with_padding              :: 3;

    default_accept_garbage        :: 4;

    url_accept_garbage            :: 5;

    default_or_url                :: 8;

    default_or_url_accept_garbage :: 12;

    base64_default                       :: default;
    base64_url                           :: url;
    base64_default_no_padding            :: default_no_padding;

    base64_url_with_padding              :: url_with_padding;

    base64_default_accept_garbage        :: default_accept_garbage;

    base64_url_accept_garbage            :: url_accept_garbage;

    base64_default_or_url                :: default_or_url;

    base64_default_or_url_accept_garbage :: default_or_url_accept_garbage;
}

// last_chunk_handling_options are used to specify the handling of the last
// chunk in base64 decoding.
// https://tc39.es/proposal-arraybuffer-base64/spec/#sec-frombase64
last_chunk_handling_options :: enum u64 {
    loose               :: 0;
    strict              :: 1;

    stop_before_partial :: 2;

    only_full_chunks    :: 3;
}

anon_namespace_1 :: struct {
    tables :: struct {
        base64 :: struct {
            to_base64_value: [256] u8;

            to_base64_url_value: [256] u8;

            to_base64_default_or_url_value: [256] u8;
        }

        utf8_to_utf16 :: struct {
            /**
            * utf8bigindex uses about 8 kB
            * shufutf8 uses about 3344 B
            *
            * So we use a bit over 11 kB. It would be
            * easy to save about 4 kB by only
            * storing the index in utf8bigindex, and
            * deriving the consumed bytes otherwise.
            * However, this may come at a significant (10% to 20%)
            * performance penalty.
            */
            shufutf8: [209] [16] u8;

            /* number of two bytes : 64 */
            /* number of two + three bytes : 145 */
            /* number of two + three + four bytes : 209 */
            utf8bigindex: [4096] [2] u8;
        }

        utf16_to_utf8 :: struct {
            // 1 byte for length, 16 bytes for mask
            pack_1_2_utf8_bytes: [256] [17] u8;

            // 1 byte for length, 16 bytes for mask
            pack_1_2_3_utf8_bytes: [256] [17] u8;
        }

        utf32_to_utf16 :: struct {
            pack_utf32_to_utf16le: [16] [16] u8;

            pack_utf32_to_utf16be: [16] [16] u8;
        }
    }
}

/**
* Implementation for NEON (ARMv8).
*/
arm64 :: struct {
    anon_namespace_2 :: struct {
        simd :: struct {
            simd8 :: struct(T: Type) {
                using,except(T) simd8__raw:             simd8__RAW(T);
                #if size_of(simd8__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd8 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd8
            simd8__RAW :: struct(T: Type) {}

            //
            // Base class of simd8<uint8_t> and simd8<bool>, both of which use uint8x16_t
            // internally.
            //
            base_u8 :: struct(T: Type, Mask: Type = simd8) {
                using,except(T, Mask) base_u8__raw:           base_u8__RAW(T, Mask);
                #if size_of(base_u8__RAW(T, Mask)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // base_u8 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base_u8
            base_u8__RAW :: struct(T: Type, Mask: Type = simd8) {
                SIZE: s32 : 16;
            }

            simd8x64 :: struct(T: Type) {
                using,except(T) simd8x64__raw:          simd8x64__RAW(T);
                #if size_of(simd8x64__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd8x64 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd8x64
            simd8x64__RAW :: struct(T: Type) {}

            /* begin file src/simdutf/arm64/simd16-inl.h */
            simd16 :: struct(T: Type) {
                using,except(T) simd16__raw:            simd16__RAW(T);
                #if size_of(simd16__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd16 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd16
            simd16__RAW :: struct(T: Type) {}

            base_u16 :: struct(T: Type, Mask: Type = simd16) {
                using,except(T, Mask) base_u16__raw:          base_u16__RAW(T, Mask);
                #if size_of(base_u16__RAW(T, Mask)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // base_u16 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base_u16
            base_u16__RAW :: struct(T: Type, Mask: Type = simd16) {
                /// the size of vector in bytes
                SIZE: s32 : 16;
            }

            base16 :: struct(T: Type, Mask: Type = simd16) {
                using,except(T, Mask) base16__raw:            base16__RAW(T, Mask);
                #if size_of(base16__RAW(T, Mask)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #overlay (base_u16__raw) #as base_u16: base_u16(T); // Support cast to base_u16
            }
                        // base16 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base16
            base16__RAW :: struct(T: Type, Mask: Type = simd16) {
                using,except(T, Mask) base_u16__raw: base_u16__RAW(T);
                bitmask_t :: u16;
                bitmask2_t :: u32;
            }

            base16_numeric :: struct(T: Type) {
                using,except(T) base16_numeric__raw:    base16_numeric__RAW(T);
                #if size_of(base16_numeric__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #overlay (base16__raw) #as base16: base16(T); // Support cast to base16
            }
                        // base16_numeric without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base16_numeric
            base16_numeric__RAW :: struct(T: Type) {
                using,except(T) base16__raw: base16__RAW(T);
            }

            simd16x32 :: struct(T: Type) {
                using,except(T) simd16x32__raw:         simd16x32__RAW(T);
                #if size_of(simd16x32__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd16x32 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd16x32
            simd16x32__RAW :: struct(T: Type) {}

            /* end file src/simdutf/arm64/simd16-inl.h */
            /* begin file src/simdutf/arm64/simd32-inl.h */
            simd32 :: struct(T: Type) {
                using,except(T) simd32__raw:            simd32__RAW(T);
                #if size_of(simd32__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd32 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd32
            simd32__RAW :: struct(T: Type) {}

            /* end file src/simdutf/arm64/simd32-inl.h */
            /* begin file src/simdutf/arm64/simd64-inl.h */
            simd64 :: struct(T: Type) {
                using,except(T) simd64__raw:            simd64__RAW(T);
                #if size_of(simd64__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd64 without padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd64
            simd64__RAW :: struct(T: Type) {}
        }

        block64 :: struct {}

        /* begin file src/arm64/arm_convert_utf32_to_utf16.cpp */
        expansion_result_t :: struct {
            u16count: u64;

            _:        [0] u8 #align 16; // Force expansion_result_t alignment to match the C/C++ equivalent
        }

        // Walks through a buffer in block-sized increments, loading the last part with
        // spaces
        buf_block_reader :: struct(STEP_SIZE: u64) {
            buf:          *u8;
            len:          u64;
            lenminusstep: u64;
            idx:          u64;
        }

        utf8_validation :: struct {
            utf8_checker :: struct {
                // If this is nonzero, there has been a UTF-8 error.
                error:            simd.simd8(u8);

                // The last input we received
                prev_input_block: simd.simd8(u8);

                // Whether the last input we received was incomplete (used for ASCII fast
                // path)
                prev_incomplete:  simd.simd8(u8);
            }
        }

        utf8_to_utf16 :: struct {
            validating_transcoder :: struct {
                // If this is nonzero, there has been a UTF-8 error.
                error: simd.simd8(u8);
            }
        }

        utf8_to_utf32 :: struct {
            validating_transcoder :: struct {
                // If this is nonzero, there has been a UTF-8 error.
                error: simd.simd8(u8);
            }
        }

        utf8_to_latin1 :: struct {
            validating_transcoder :: struct {
                // If this is nonzero, there has been a UTF-8 error.
                error: simd.simd8(u8);
            }
        }
    }
}

/* C-friendly subset of simdutf errors */
simdutf_error_code :: enum u32 {
    SUCCESS                  :: 0;
    HEADER_BITS              :: 1;
    TOO_SHORT                :: 2;
    TOO_LONG                 :: 3;
    OVERLONG                 :: 4;
    TOO_LARGE                :: 5;
    SURROGATE                :: 6;
    INVALID_BASE64_CHARACTER :: 7;
    BASE64_INPUT_REMAINDER   :: 8;
    BASE64_EXTRA_BITS        :: 9;
    OUTPUT_BUFFER_TOO_SMALL  :: 10;
    OTHER                    :: 11;

    SIMDUTF_ERROR_SUCCESS                  :: SUCCESS;
    SIMDUTF_ERROR_HEADER_BITS              :: HEADER_BITS;
    SIMDUTF_ERROR_TOO_SHORT                :: TOO_SHORT;
    SIMDUTF_ERROR_TOO_LONG                 :: TOO_LONG;
    SIMDUTF_ERROR_OVERLONG                 :: OVERLONG;
    SIMDUTF_ERROR_TOO_LARGE                :: TOO_LARGE;
    SIMDUTF_ERROR_SURROGATE                :: SURROGATE;
    SIMDUTF_ERROR_INVALID_BASE64_CHARACTER :: INVALID_BASE64_CHARACTER;
    SIMDUTF_ERROR_BASE64_INPUT_REMAINDER   :: BASE64_INPUT_REMAINDER;
    SIMDUTF_ERROR_BASE64_EXTRA_BITS        :: BASE64_EXTRA_BITS;
    SIMDUTF_ERROR_OUTPUT_BUFFER_TOO_SMALL  :: OUTPUT_BUFFER_TOO_SMALL;
    SIMDUTF_ERROR_OTHER                    :: OTHER;
}

simdutf_result :: struct {
    error: simdutf_error_code;
    count: u64; /* position of error or number of code units validated */
}

simdutf_full_result :: struct {
    error:        simdutf_error_code;
    input_count:  u64; /* number of input units consumed */
    output_count: u64; /* number of output bytes written */
}

simdutf_encoding_type :: enum u32 {
    UNSPECIFIED :: 0;
    UTF8        :: 1;
    UTF16_LE    :: 2;
    UTF16_BE    :: 4;
    UTF32_LE    :: 8;
    UTF32_BE    :: 16;

    SIMDUTF_ENCODING_UNSPECIFIED :: UNSPECIFIED;
    SIMDUTF_ENCODING_UTF8        :: UTF8;
    SIMDUTF_ENCODING_UTF16_LE    :: UTF16_LE;
    SIMDUTF_ENCODING_UTF16_BE    :: UTF16_BE;
    SIMDUTF_ENCODING_UTF32_LE    :: UTF32_LE;
    SIMDUTF_ENCODING_UTF32_BE    :: UTF32_BE;
}

/* Validate UTF-8: returns true iff input is valid UTF-8 */
simdutf_validate_utf8 :: (buf: *u8, len: u64) -> bool #foreign libsimdutf;

/* Validate UTF-8 with detailed result */
simdutf_validate_utf8_with_errors :: (buf: *u8, len: u64) -> simdutf_result #foreign libsimdutf;

/* Encoding detection */
simdutf_autodetect_encoding :: (input: *u8, length: u64) -> simdutf_encoding_type #foreign libsimdutf;

simdutf_detect_encodings :: (input: *u8, length: u64) -> s32 #foreign libsimdutf;

/* ASCII validation */
simdutf_validate_ascii :: (buf: *u8, len: u64) -> bool #foreign libsimdutf;

simdutf_validate_ascii_with_errors :: (buf: *u8, len: u64) -> simdutf_result #foreign libsimdutf;

/* UTF-16 ASCII checks */
simdutf_validate_utf16_as_ascii :: (buf: *u16, len: u64) -> bool #foreign libsimdutf;

simdutf_validate_utf16be_as_ascii :: (buf: *u16, len: u64) -> bool #foreign libsimdutf;

simdutf_validate_utf16le_as_ascii :: (buf: *u16, len: u64) -> bool #foreign libsimdutf;

/* UTF-16/UTF-8/UTF-32 validation (native/endian-specific) */
simdutf_validate_utf16 :: (buf: *u16, len: u64) -> bool #foreign libsimdutf;

simdutf_validate_utf16le :: (buf: *u16, len: u64) -> bool #foreign libsimdutf;

simdutf_validate_utf16be :: (buf: *u16, len: u64) -> bool #foreign libsimdutf;

simdutf_validate_utf16_with_errors :: (buf: *u16, len: u64) -> simdutf_result #foreign libsimdutf;

simdutf_validate_utf16le_with_errors :: (buf: *u16, len: u64) -> simdutf_result #foreign libsimdutf;

simdutf_validate_utf16be_with_errors :: (buf: *u16, len: u64) -> simdutf_result #foreign libsimdutf;

simdutf_validate_utf32 :: (buf: *u32, len: u64) -> bool #foreign libsimdutf;

simdutf_validate_utf32_with_errors :: (buf: *u32, len: u64) -> simdutf_result #foreign libsimdutf;

/* to_well_formed UTF-16 helpers */
simdutf_to_well_formed_utf16le :: (input: *u16, len: u64, output: *u16) -> void #foreign libsimdutf;

simdutf_to_well_formed_utf16be :: (input: *u16, len: u64, output: *u16) -> void #foreign libsimdutf;

simdutf_to_well_formed_utf16 :: (input: *u16, len: u64, output: *u16) -> void #foreign libsimdutf;

/* Counting */
simdutf_count_utf16 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf;

simdutf_count_utf16le :: (input: *u16, length: u64) -> u64 #foreign libsimdutf;

simdutf_count_utf16be :: (input: *u16, length: u64) -> u64 #foreign libsimdutf;

simdutf_count_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf;

/* Length estimators */
simdutf_utf8_length_from_latin1 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf;

simdutf_latin1_length_from_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf;

simdutf_latin1_length_from_utf16 :: (length: u64) -> u64 #foreign libsimdutf;

simdutf_latin1_length_from_utf32 :: (length: u64) -> u64 #foreign libsimdutf;

simdutf_utf16_length_from_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf;

simdutf_utf32_length_from_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf;

simdutf_utf8_length_from_utf16 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf;

simdutf_utf8_length_from_utf32 :: (input: *u32, length: u64) -> u64 #foreign libsimdutf;

simdutf_utf8_length_from_utf16_with_replacement :: (input: *u16, length: u64) -> simdutf_result #foreign libsimdutf;

simdutf_utf8_length_from_utf16le :: (input: *u16, length: u64) -> u64 #foreign libsimdutf;

simdutf_utf8_length_from_utf16be :: (input: *u16, length: u64) -> u64 #foreign libsimdutf;

simdutf_utf8_length_from_utf16le_with_replacement :: (input: *u16, length: u64) -> simdutf_result #foreign libsimdutf;

simdutf_utf8_length_from_utf16be_with_replacement :: (input: *u16, length: u64) -> simdutf_result #foreign libsimdutf;

/* Conversions: latin1 <-> utf8, utf8 <-> utf16/utf32, utf16 <-> utf8, etc. */
simdutf_convert_latin1_to_utf8 :: (input: *u8, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_latin1_to_utf8_safe :: (input: *u8, length: u64, output: *u8, utf8_len: u64) -> u64 #foreign libsimdutf;

simdutf_convert_latin1_to_utf16le :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_latin1_to_utf16be :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_latin1_to_utf16 :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_latin1_to_utf32 :: (input: *u8, length: u64, output: *u32) -> u64 #foreign libsimdutf;

simdutf_convert_utf8_to_latin1 :: (input: *u8, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf8_to_utf16le :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_utf8_to_utf16be :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_utf8_to_utf16 :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_utf8_to_utf32 :: (input: *u8, length: u64, output: *u32) -> u64 #foreign libsimdutf;

simdutf_convert_utf8_to_latin1_with_errors :: (input: *u8, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf8_to_utf16_with_errors :: (input: *u8, length: u64, output: *u16) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf8_to_utf16le_with_errors :: (input: *u8, length: u64, output: *u16) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf8_to_utf16be_with_errors :: (input: *u8, length: u64, output: *u16) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf8_to_utf32_with_errors :: (input: *u8, length: u64, output: *u32) -> simdutf_result #foreign libsimdutf;

/* Conversions assuming valid input */
simdutf_convert_valid_utf8_to_latin1 :: (input: *u8, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf8_to_utf16le :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf8_to_utf16be :: (input: *u8, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf8_to_utf32 :: (input: *u8, length: u64, output: *u32) -> u64 #foreign libsimdutf;

/* UTF-16 -> UTF-8 and related conversions */
simdutf_convert_utf16_to_utf8 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf16le_to_utf8 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf16be_to_utf8 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf16_to_utf8_safe :: (input: *u16, length: u64, output: *u8, utf8_len: u64) -> u64 #foreign libsimdutf;

simdutf_convert_utf16_to_latin1 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf16le_to_latin1 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf16be_to_latin1 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf16_to_latin1_with_errors :: (input: *u16, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf16le_to_latin1_with_errors :: (input: *u16, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf16be_to_latin1_with_errors :: (input: *u16, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf16_to_utf8_with_errors :: (input: *u16, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf16le_to_utf8_with_errors :: (input: *u16, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf16be_to_utf8_with_errors :: (input: *u16, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_valid_utf16_to_utf8 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf16_to_latin1 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf16le_to_latin1 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf16be_to_latin1 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf16le_to_utf8 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf16be_to_utf8 :: (input: *u16, length: u64, output: *u8) -> u64 #foreign libsimdutf;

/* UTF-16 <-> UTF-32 conversions */
simdutf_convert_utf16_to_utf32 :: (input: *u16, length: u64, output: *u32) -> u64 #foreign libsimdutf;

simdutf_convert_utf16le_to_utf32 :: (input: *u16, length: u64, output: *u32) -> u64 #foreign libsimdutf;

simdutf_convert_utf16be_to_utf32 :: (input: *u16, length: u64, output: *u32) -> u64 #foreign libsimdutf;

simdutf_convert_utf16_to_utf32_with_errors :: (input: *u16, length: u64, output: *u32) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf16le_to_utf32_with_errors :: (input: *u16, length: u64, output: *u32) -> simdutf_result #foreign libsimdutf;

simdutf_convert_utf16be_to_utf32_with_errors :: (input: *u16, length: u64, output: *u32) -> simdutf_result #foreign libsimdutf;

/* Valid UTF-16 conversions */
simdutf_convert_valid_utf16_to_utf32 :: (input: *u16, length: u64, output: *u32) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf16le_to_utf32 :: (input: *u16, length: u64, output: *u32) -> u64 #foreign libsimdutf;

simdutf_convert_valid_utf16be_to_utf32 :: (input: *u16, length: u64, output: *u32) -> u64 #foreign libsimdutf;

/* UTF-32 -> ... conversions */
simdutf_convert_utf32_to_utf8 :: (input: *u32, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf32_to_utf8_with_errors :: (input: *u32, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

simdutf_convert_valid_utf32_to_utf8 :: (input: *u32, length: u64, output: *u8) -> u64 #foreign libsimdutf;

simdutf_convert_utf32_to_utf16 :: (input: *u32, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_utf32_to_utf16le :: (input: *u32, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_utf32_to_utf16be :: (input: *u32, length: u64, output: *u16) -> u64 #foreign libsimdutf;

simdutf_convert_utf32_to_latin1_with_errors :: (input: *u32, length: u64, output: *u8) -> simdutf_result #foreign libsimdutf;

/* --- Find helpers --- */
simdutf_find :: (start: *u8, end: *u8, character: u8) -> *u8 #foreign libsimdutf;

simdutf_find_utf16 :: (start: *u16, end: *u16, character: u16) -> *u16 #foreign libsimdutf;

/* --- Base64 enums and helpers --- */
simdutf_base64_options :: enum u32 {
    DEFAULT                       :: 0;
    URL                           :: 1;
    DEFAULT_NO_PADDING            :: 2;
    URL_WITH_PADDING              :: 3;
    DEFAULT_ACCEPT_GARBAGE        :: 4;
    URL_ACCEPT_GARBAGE            :: 5;
    DEFAULT_OR_URL                :: 8;
    DEFAULT_OR_URL_ACCEPT_GARBAGE :: 12;

    SIMDUTF_BASE64_DEFAULT                       :: DEFAULT;
    SIMDUTF_BASE64_URL                           :: URL;
    SIMDUTF_BASE64_DEFAULT_NO_PADDING            :: DEFAULT_NO_PADDING;
    SIMDUTF_BASE64_URL_WITH_PADDING              :: URL_WITH_PADDING;
    SIMDUTF_BASE64_DEFAULT_ACCEPT_GARBAGE        :: DEFAULT_ACCEPT_GARBAGE;
    SIMDUTF_BASE64_URL_ACCEPT_GARBAGE            :: URL_ACCEPT_GARBAGE;
    SIMDUTF_BASE64_DEFAULT_OR_URL                :: DEFAULT_OR_URL;
    SIMDUTF_BASE64_DEFAULT_OR_URL_ACCEPT_GARBAGE :: DEFAULT_OR_URL_ACCEPT_GARBAGE;
}

simdutf_last_chunk_handling_options :: enum u32 {
    LOOSE               :: 0;
    STRICT              :: 1;
    STOP_BEFORE_PARTIAL :: 2;
    ONLY_FULL_CHUNKS    :: 3;

    SIMDUTF_LAST_CHUNK_LOOSE               :: LOOSE;
    SIMDUTF_LAST_CHUNK_STRICT              :: STRICT;
    SIMDUTF_LAST_CHUNK_STOP_BEFORE_PARTIAL :: STOP_BEFORE_PARTIAL;
    SIMDUTF_LAST_CHUNK_ONLY_FULL_CHUNKS    :: ONLY_FULL_CHUNKS;
}

/* maximal binary length estimators */
simdutf_maximal_binary_length_from_base64 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf;

simdutf_maximal_binary_length_from_base64_utf16 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf;

/* base64 decoding/encoding */
simdutf_base64_to_binary :: (input: *u8, length: u64, output: *u8, options: simdutf_base64_options, last_chunk_options: simdutf_last_chunk_handling_options) -> simdutf_result #foreign libsimdutf;

simdutf_base64_to_binary_utf16 :: (input: *u16, length: u64, output: *u8, options: simdutf_base64_options, last_chunk_options: simdutf_last_chunk_handling_options) -> simdutf_result #foreign libsimdutf;

simdutf_base64_length_from_binary :: (length: u64, options: simdutf_base64_options) -> u64 #foreign libsimdutf;

simdutf_base64_length_from_binary_with_lines :: (length: u64, options: simdutf_base64_options, line_length: u64) -> u64 #foreign libsimdutf;

simdutf_binary_to_base64 :: (input: *u8, length: u64, output: *u8, options: simdutf_base64_options) -> u64 #foreign libsimdutf;

simdutf_binary_to_base64_with_lines :: (input: *u8, length: u64, output: *u8, line_length: u64, options: simdutf_base64_options) -> u64 #foreign libsimdutf;

/* safe decoding that provides an in/out outlen parameter */
simdutf_base64_to_binary_safe :: (input: *u8, length: u64, output: *u8, outlen: *u64, options: simdutf_base64_options, last_chunk_options: simdutf_last_chunk_handling_options, decode_up_to_bad_char: bool) -> simdutf_result #foreign libsimdutf;

simdutf_base64_to_binary_safe_utf16 :: (input: *u16, length: u64, output: *u8, outlen: *u64, options: simdutf_base64_options, last_chunk_options: simdutf_last_chunk_handling_options, decode_up_to_bad_char: bool) -> simdutf_result #foreign libsimdutf;

/* detailed decoding returning input_count and output_count */
simdutf_base64_to_binary_details :: (input: *u8, length: u64, output: *u8, options: simdutf_base64_options, last_chunk_options: simdutf_last_chunk_handling_options) -> simdutf_full_result #foreign libsimdutf;

simdutf_base64_to_binary_details_utf16 :: (input: *u16, length: u64, output: *u8, options: simdutf_base64_options, last_chunk_options: simdutf_last_chunk_handling_options) -> simdutf_full_result #foreign libsimdutf;

/* single-character base64 validation */
simdutf_base64_valid :: (input: u8, options: simdutf_base64_options) -> bool #foreign libsimdutf;

simdutf_base64_valid_utf16 :: (input: u16, options: simdutf_base64_options) -> bool #foreign libsimdutf;

#scope_file

libsimdutf :: #library,no_dll "bin/arm64/libsimdutf";
