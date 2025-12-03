//
// This file was auto-generated using the following command:
//
// jai generate.jai
//



SIMDUTF_CPLUSPLUS14 :: 1;

SIMDUTF_CPLUSPLUS11 :: 1;

SIMDUTF_VISUAL_STUDIO :: 1;

SIMDUTF_CLANG_VISUAL_STUDIO :: 1;

SIMDUTF_IS_X86_64 :: 1;

SIMDUTF_VERSION_STRING :: "7.7.0";

SIMDUTF_FEATURE_DETECT_ENCODING :: 1;
SIMDUTF_FEATURE_ASCII :: 1;
SIMDUTF_FEATURE_LATIN1 :: 1;
SIMDUTF_FEATURE_UTF8 :: 1;
SIMDUTF_FEATURE_UTF16 :: 1;
SIMDUTF_FEATURE_UTF32 :: 1;
SIMDUTF_FEATURE_BASE64 :: 1;

SIMDUTF_NEED_TRAILING_ZEROES :: 1;

SIMDUTF_CAN_ALWAYS_RUN_ARM64 :: 0;

SIMDUTF_COMPILER_SUPPORTS_VBMI2 :: 1;

SIMDUTF_IMPLEMENTATION_ICELAKE :: (SIMDUTF_IS_X86_64) && (SIMDUTF_COMPILER_SUPPORTS_VBMI2);

SIMDUTF_CAN_ALWAYS_RUN_ICELAKE :: 0;

SIMDUTF_IMPLEMENTATION_HASWELL :: SIMDUTF_IS_X86_64;

SIMDUTF_CAN_ALWAYS_RUN_HASWELL :: 0;

SIMDUTF_SIMD_HAS_BYTEMASK :: 1;

SIMDUTF_IMPLEMENTATION_WESTMERE :: SIMDUTF_IS_X86_64;

SIMDUTF_CAN_ALWAYS_RUN_WESTMERE :: 0;

SIMDUTF_CAN_ALWAYS_RUN_LSX :: 0;

SIMDUTF_CAN_ALWAYS_RUN_FALLBACK :: SIMDUTF_IMPLEMENTATION_FALLBACK;

SIMDUTF_CAN_ALWAYS_RUN_LASX :: 0;

SIMDUTF_IMPLEMENTATION_FALLBACK :: 1;
//
// Implementation-specific overrides
//

encoding_type :: enum s32 {
    UTF8        :: 1;
    UTF16_LE    :: 2;
    UTF16_BE    :: 4;
    UTF32_LE    :: 8;
    UTF32_BE    :: 16;
    Latin1      :: 32;

    unspecified :: 0;
}

endianness :: enum s32 {
    LITTLE :: 0;
    BIG    :: 1;
}

match_system :: (e: endianness) -> bool #foreign libsimdutf "?match_system@simdutf@@YA_NW4endianness@1@@Z";

// Note that BOM for UTF8 is discouraged.
BOM :: struct {
    /**
    * Checks for a BOM. If not, returns unspecified
    * @param input         the string to process
    * @param length        the length of the string in code units
    * @return the corresponding encoding
    */
    check_bom :: (byte: *u8, length: u64) -> encoding_type #foreign libsimdutf "?check_bom@BOM@simdutf@@YA?AW4encoding_type@2@PEBE_K@Z";

    /**
    * Returns the size, in bytes, of the BOM for a given encoding type.
    * Note that UTF8 BOM are discouraged.
    * @param bom         the encoding type
    * @return the size in bytes of the corresponding BOM
    */
    bom_byte_size :: (bom: encoding_type) -> u64 #foreign libsimdutf "?bom_byte_size@BOM@simdutf@@YA_KW4encoding_type@2@@Z";
}

error_code :: enum s32 {
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

    Constructor :: (this: *result, err: error_code, pos: u64) -> void #cpp_method #foreign libsimdutf "??0result@simdutf@@QEAA@W4error_code@1@_K@Z";

    is_err :: (this: *result) -> bool #cpp_method #foreign libsimdutf "?is_err@result@simdutf@@QEBA_NXZ";
}

full_result :: struct {
    error:         error_code;
    input_count:   u64;
    output_count:  u64;
    // true if the error is due to padding, only
    // meaningful when error is not SUCCESS
    padding_error  := false;

    Constructor :: (this: *full_result, err: error_code, pos_in: u64, pos_out: u64) -> void #cpp_method #foreign libsimdutf "??0full_result@simdutf@@QEAA@W4error_code@1@_K1@Z";

    Constructor :: (this: *full_result, err: error_code, pos_in: u64, pos_out: u64, padding_err: bool) -> void #cpp_method #foreign libsimdutf "??0full_result@simdutf@@QEAA@W4error_code@1@_K1_N@Z";
}

SIMDUTF_VERSION :: enum s32 {
    MAJOR    :: 7;

    MINOR    :: 7;

    REVISION :: 0;

    SIMDUTF_VERSION_MAJOR    :: MAJOR;

    SIMDUTF_VERSION_MINOR    :: MINOR;

    SIMDUTF_VERSION_REVISION :: REVISION;
}

default_line_length: u64 : 76;

/**
* Autodetect the encoding of the input, a single encoding is recommended.
* E.g., the function might return simdutf::encoding_type::UTF8,
* simdutf::encoding_type::UTF16_LE, simdutf::encoding_type::UTF16_BE, or
* simdutf::encoding_type::UTF32_LE.
*
* @param input the string to analyze.
* @param length the length of the string in bytes.
* @return the detected encoding type
*/
autodetect_encoding :: (input: *u8, length: u64) -> encoding_type #foreign libsimdutf "?autodetect_encoding@simdutf@@YA?AW4encoding_type@1@PEBD_K@Z";

/**
* Autodetect the possible encodings of the input in one pass.
* E.g., if the input might be UTF-16LE or UTF-8, this function returns
* the value (simdutf::encoding_type::UTF8 | simdutf::encoding_type::UTF16_LE).
*
* Overridden by each implementation.
*
* @param input the string to analyze.
* @param length the length of the string in bytes.
* @return the detected encoding type
*/
detect_encodings :: (input: *u8, length: u64) -> s32 #foreign libsimdutf "?detect_encodings@simdutf@@YAHPEBD_K@Z";

/**
* Validate the UTF-8 string. This function may be best when you expect
* the input to be almost always valid. Otherwise, consider using
* validate_utf8_with_errors.
*
* Overridden by each implementation.
*
* @param buf the UTF-8 string to validate.
* @param len the length of the string in bytes.
* @return true if and only if the string is valid UTF-8.
*/
validate_utf8 :: (buf: *u8, len: u64) -> bool #foreign libsimdutf "?validate_utf8@simdutf@@YA_NPEBD_K@Z";

/**
* Validate the UTF-8 string and stop on error.
*
* Overridden by each implementation.
*
* @param buf the UTF-8 string to validate.
* @param len the length of the string in bytes.
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of code units validated if
* successful.
*/
validate_utf8_with_errors :: (buf: *u8, len: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?validate_utf8_with_errors@simdutf@@YA?AUresult@1@PEBD_K@Z";

/**
* Validate the ASCII string.
*
* Overridden by each implementation.
*
* @param buf the ASCII string to validate.
* @param len the length of the string in bytes.
* @return true if and only if the string is valid ASCII.
*/
validate_ascii :: (buf: *u8, len: u64) -> bool #foreign libsimdutf "?validate_ascii@simdutf@@YA_NPEBD_K@Z";

/**
* Validate the ASCII string and stop on error. It might be faster than
* validate_utf8 when an error is expected to occur early.
*
* Overridden by each implementation.
*
* @param buf the ASCII string to validate.
* @param len the length of the string in bytes.
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of code units validated if
* successful.
*/
validate_ascii_with_errors :: (buf: *u8, len: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?validate_ascii_with_errors@simdutf@@YA?AUresult@1@PEBD_K@Z";

/**
* Validate the ASCII string as a UTF-16 sequence.
* An UTF-16 sequence is considered an ASCII sequence
* if it could be converted to an ASCII string losslessly.
*
* Overridden by each implementation.
*
* @param buf the UTF-16 string to validate.
* @param len the length of the string in bytes.
* @return true if and only if the string is valid ASCII.
*/
validate_utf16_as_ascii :: (buf: *u16, len: u64) -> bool #foreign libsimdutf "?validate_utf16_as_ascii@simdutf@@YA_NPEB_S_K@Z";

/**
* Validate the ASCII string as a UTF-16BE sequence.
* An UTF-16 sequence is considered an ASCII sequence
* if it could be converted to an ASCII string losslessly.
*
* Overridden by each implementation.
*
* @param buf the UTF-16BE string to validate.
* @param len the length of the string in bytes.
* @return true if and only if the string is valid ASCII.
*/
validate_utf16be_as_ascii :: (buf: *u16, len: u64) -> bool #foreign libsimdutf "?validate_utf16be_as_ascii@simdutf@@YA_NPEB_S_K@Z";

/**
* Validate the ASCII string as a UTF-16LE sequence.
* An UTF-16 sequence is considered an ASCII sequence
* if it could be converted to an ASCII string losslessly.
*
* Overridden by each implementation.
*
* @param buf the UTF-16LE string to validate.
* @param len the length of the string in bytes.
* @return true if and only if the string is valid ASCII.
*/
validate_utf16le_as_ascii :: (buf: *u16, len: u64) -> bool #foreign libsimdutf "?validate_utf16le_as_ascii@simdutf@@YA_NPEB_S_K@Z";

/**
* Using native endianness; Validate the UTF-16 string.
* This function may be best when you expect the input to be almost always
* valid. Otherwise, consider using validate_utf16_with_errors.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-16 string to validate.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @return true if and only if the string is valid UTF-16.
*/
validate_utf16 :: (buf: *u16, len: u64) -> bool #foreign libsimdutf "?validate_utf16@simdutf@@YA_NPEB_S_K@Z";

/**
* Validate the UTF-16LE string. This function may be best when you expect
* the input to be almost always valid. Otherwise, consider using
* validate_utf16le_with_errors.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-16LE string to validate.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @return true if and only if the string is valid UTF-16LE.
*/
validate_utf16le :: (buf: *u16, len: u64) -> bool #foreign libsimdutf "?validate_utf16le@simdutf@@YA_NPEB_S_K@Z";

/**
* Validate the UTF-16BE string. This function may be best when you expect
* the input to be almost always valid. Otherwise, consider using
* validate_utf16be_with_errors.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-16BE string to validate.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @return true if and only if the string is valid UTF-16BE.
*/
validate_utf16be :: (buf: *u16, len: u64) -> bool #foreign libsimdutf "?validate_utf16be@simdutf@@YA_NPEB_S_K@Z";

/**
* Using native endianness; Validate the UTF-16 string and stop on error.
* It might be faster than validate_utf16 when an error is expected to occur
* early.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-16 string to validate.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of code units validated if
* successful.
*/
validate_utf16_with_errors :: (buf: *u16, len: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?validate_utf16_with_errors@simdutf@@YA?AUresult@1@PEB_S_K@Z";

/**
* Validate the UTF-16LE string and stop on error. It might be faster than
* validate_utf16le when an error is expected to occur early.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-16LE string to validate.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of code units validated if
* successful.
*/
validate_utf16le_with_errors :: (buf: *u16, len: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?validate_utf16le_with_errors@simdutf@@YA?AUresult@1@PEB_S_K@Z";

/**
* Validate the UTF-16BE string and stop on error. It might be faster than
* validate_utf16be when an error is expected to occur early.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-16BE string to validate.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of code units validated if
* successful.
*/
validate_utf16be_with_errors :: (buf: *u16, len: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?validate_utf16be_with_errors@simdutf@@YA?AUresult@1@PEB_S_K@Z";

/**
* Fixes an ill-formed UTF-16LE string by replacing mismatched surrogates with
* the Unicode replacement character U+FFFD. If input and output points to
* different memory areas, the procedure copies string, and it's expected that
* output memory is at least as big as the input. It's also possible to set
* input equal output, that makes replacements an in-place operation.
*
* @param input the UTF-16LE string to correct.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @param output the output buffer.
*/
to_well_formed_utf16le :: (input: *u16, len: u64, output: *u16) -> void #foreign libsimdutf "?to_well_formed_utf16le@simdutf@@YAXPEB_S_KPEA_S@Z";

/**
* Fixes an ill-formed UTF-16BE string by replacing mismatched surrogates with
* the Unicode replacement character U+FFFD. If input and output points to
* different memory areas, the procedure copies string, and it's expected that
* output memory is at least as big as the input. It's also possible to set
* input equal output, that makes replacements an in-place operation.
*
* @param input the UTF-16BE string to correct.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @param output the output buffer.
*/
to_well_formed_utf16be :: (input: *u16, len: u64, output: *u16) -> void #foreign libsimdutf "?to_well_formed_utf16be@simdutf@@YAXPEB_S_KPEA_S@Z";

/**
* Fixes an ill-formed UTF-16 string by replacing mismatched surrogates with the
* Unicode replacement character U+FFFD. If input and output points to different
* memory areas, the procedure copies string, and it's expected that output
* memory is at least as big as the input. It's also possible to set input equal
* output, that makes replacements an in-place operation.
*
* @param input the UTF-16 string to correct.
* @param len the length of the string in number of 2-byte code units
* (char16_t).
* @param output the output buffer.
*/
to_well_formed_utf16 :: (input: *u16, len: u64, output: *u16) -> void #foreign libsimdutf "?to_well_formed_utf16@simdutf@@YAXPEB_S_KPEA_S@Z";

/**
* Validate the UTF-32 string. This function may be best when you expect
* the input to be almost always valid. Otherwise, consider using
* validate_utf32_with_errors.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-32 string to validate.
* @param len the length of the string in number of 4-byte code units
* (char32_t).
* @return true if and only if the string is valid UTF-32.
*/
validate_utf32 :: (buf: *u32, len: u64) -> bool #foreign libsimdutf "?validate_utf32@simdutf@@YA_NPEB_U_K@Z";

/**
* Validate the UTF-32 string and stop on error. It might be faster than
* validate_utf32 when an error is expected to occur early.
*
* Overridden by each implementation.
*
* This function is not BOM-aware.
*
* @param buf the UTF-32 string to validate.
* @param len the length of the string in number of 4-byte code units
* (char32_t).
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of code units validated if
* successful.
*/
validate_utf32_with_errors :: (buf: *u32, len: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?validate_utf32_with_errors@simdutf@@YA?AUresult@1@PEB_U_K@Z";

/**
* Convert Latin1 string into UTF-8 string.
*
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the Latin1 string to convert
* @param length        the length of the string in bytes
* @param utf8_output   the pointer to buffer that can hold conversion result
* @return the number of written char; 0 if conversion is not possible
*/
convert_latin1_to_utf8 :: (input: *u8, length: u64, utf8_output: *u8) -> u64 #foreign libsimdutf "?convert_latin1_to_utf8@simdutf@@YA_KPEBD_KPEAD@Z";

/**
* Convert Latin1 string into UTF-8 string with output limit.
*
* This function is suitable to work with inputs from untrusted sources.
*
* We write as many characters as possible.
*
* @param input         the Latin1 string to convert
* @param length        the length of the string in bytes
* @param utf8_output  	the pointer to buffer that can hold conversion result
* @param utf8_len      the maximum output length
* @return the number of written char; 0 if conversion is not possible
*/
convert_latin1_to_utf8_safe :: (input: *u8, length: u64, utf8_output: *u8, utf8_len: u64) -> u64 #foreign libsimdutf "?convert_latin1_to_utf8_safe@simdutf@@YA_KPEBD_KPEAD1@Z";

/**
* Convert possibly Latin1 string into UTF-16LE string.
*
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the Latin1 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t; 0 if conversion is not possible
*/
convert_latin1_to_utf16le :: (input: *u8, length: u64, utf16_output: *u16) -> u64 #foreign libsimdutf "?convert_latin1_to_utf16le@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Convert Latin1 string into UTF-16BE string.
*
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the Latin1 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t; 0 if conversion is not possible
*/
convert_latin1_to_utf16be :: (input: *u8, length: u64, utf16_output: *u16) -> u64 #foreign libsimdutf "?convert_latin1_to_utf16be@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Compute the number of bytes that this UTF-16 string would require in Latin1
* format.
*
* @param length        the length of the string in Latin1 code units (char)
* @return the length of the string in Latin1 code units (char) required to
* encode the UTF-16 string as Latin1
*/
latin1_length_from_utf16 :: (length: u64) -> u64 #foreign libsimdutf "?latin1_length_from_utf16@simdutf@@YA_K_K@Z";

/**
* Compute the number of code units that this Latin1 string would require in
* UTF-16 format.
*
* @param length        the length of the string in Latin1 code units (char)
* @return the length of the string in 2-byte code units (char16_t) required to
* encode the Latin1 string as UTF-16
*/
utf16_length_from_latin1 :: (length: u64) -> u64 #foreign libsimdutf "?utf16_length_from_latin1@simdutf@@YA_K_K@Z";

/**
* Convert Latin1 string into UTF-32 string.
*
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the Latin1 string to convert
* @param length        the length of the string in bytes
* @param utf32_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char32_t; 0 if conversion is not possible
*/
convert_latin1_to_utf32 :: (input: *u8, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_latin1_to_utf32@simdutf@@YA_KPEBD_KPEA_U@Z";

/**
* Convert possibly broken UTF-8 string into latin1 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param latin1_output  the pointer to buffer that can hold conversion result
* @return the number of written char; 0 if the input was not valid UTF-8 string
* or if it cannot be represented as Latin1
*/
convert_utf8_to_latin1 :: (input: *u8, length: u64, latin1_output: *u8) -> u64 #foreign libsimdutf "?convert_utf8_to_latin1@simdutf@@YA_KPEBD_KPEAD@Z";

/**
* Using native endianness, convert possibly broken UTF-8 string into a UTF-16
* string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t; 0 if the input was not valid UTF-8
* string
*/
convert_utf8_to_utf16 :: (input: *u8, length: u64, utf16_output: *u16) -> u64 #foreign libsimdutf "?convert_utf8_to_utf16@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Compute the number of bytes that this UTF-16LE string would require in UTF-8
* format even when the UTF-16LE content contains mismatched surrogates
* that have to be replaced by the replacement character (0xFFFD).
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) where the count is the number of bytes required to
* encode the UTF-16LE string as UTF-8, and the error code is either SUCCESS or
* SURROGATE. The count is correct regardless of the error field.
* When SURROGATE is returned, it does not indicate an error in the case of this
* function: it indicates that at least one surrogate has been encountered: the
* surrogates may be matched or not (thus this function does not validate). If
* the returned error code is SUCCESS, then the input contains no surrogate, is
* in the Basic Multilingual Plane, and is necessarily valid.
*/
utf8_length_from_utf16le_with_replacement :: (input: *u16, length: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?utf8_length_from_utf16le_with_replacement@simdutf@@YA?AUresult@1@PEB_S_K@Z";

/**
* Compute the number of bytes that this UTF-16BE string would require in UTF-8
* format even when the UTF-16BE content contains mismatched surrogates
* that have to be replaced by the replacement character (0xFFFD).
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) where the count is the number of bytes required to
* encode the UTF-16BE string as UTF-8, and the error code is either SUCCESS or
* SURROGATE. The count is correct regardless of the error field.
* When SURROGATE is returned, it does not indicate an error in the case of this
* function: it indicates that at least one surrogate has been encountered: the
* surrogates may be matched or not (thus this function does not validate). If
* the returned error code is SUCCESS, then the input contains no surrogate, is
* in the Basic Multilingual Plane, and is necessarily valid.
*/
utf8_length_from_utf16be_with_replacement :: (input: *u16, length: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?utf8_length_from_utf16be_with_replacement@simdutf@@YA?AUresult@1@PEB_S_K@Z";

/**
* Using native endianness, convert a Latin1 string into a UTF-16 string.
*
* @param input         the Latin1 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t.
*/
convert_latin1_to_utf16 :: (input: *u8, length: u64, utf16_output: *u16) -> u64 #foreign libsimdutf "?convert_latin1_to_utf16@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Convert possibly broken UTF-8 string into UTF-16LE string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t; 0 if the input was not valid UTF-8
* string
*/
convert_utf8_to_utf16le :: (input: *u8, length: u64, utf16_output: *u16) -> u64 #foreign libsimdutf "?convert_utf8_to_utf16le@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Convert possibly broken UTF-8 string into UTF-16BE string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t; 0 if the input was not valid UTF-8
* string
*/
convert_utf8_to_utf16be :: (input: *u8, length: u64, utf16_output: *u16) -> u64 #foreign libsimdutf "?convert_utf8_to_utf16be@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Convert possibly broken UTF-8 string into latin1 string with errors.
* If the string cannot be represented as Latin1, an error
* code is returned.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param latin1_output  the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of code units validated if
* successful.
*/
convert_utf8_to_latin1_with_errors :: (input: *u8, length: u64, latin1_output: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf8_to_latin1_with_errors@simdutf@@YA?AUresult@1@PEBD_KPEAD@Z";

/**
* Using native endianness, convert possibly broken UTF-8 string into UTF-16
* string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char16_t written if
* successful.
*/
convert_utf8_to_utf16_with_errors :: (input: *u8, length: u64, utf16_output: *u16) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf8_to_utf16_with_errors@simdutf@@YA?AUresult@1@PEBD_KPEA_S@Z";

/**
* Convert possibly broken UTF-8 string into UTF-16LE string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char16_t written if
* successful.
*/
convert_utf8_to_utf16le_with_errors :: (input: *u8, length: u64, utf16_output: *u16) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf8_to_utf16le_with_errors@simdutf@@YA?AUresult@1@PEBD_KPEA_S@Z";

/**
* Convert possibly broken UTF-8 string into UTF-16BE string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char16_t written if
* successful.
*/
convert_utf8_to_utf16be_with_errors :: (input: *u8, length: u64, utf16_output: *u16) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf8_to_utf16be_with_errors@simdutf@@YA?AUresult@1@PEBD_KPEA_S@Z";

/**
* Convert possibly broken UTF-8 string into UTF-32 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf32_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char32_t; 0 if the input was not valid UTF-8
* string
*/
convert_utf8_to_utf32 :: (input: *u8, length: u64, utf32_output: *u32) -> u64 #foreign libsimdutf "?convert_utf8_to_utf32@simdutf@@YA_KPEBD_KPEA_U@Z";

/**
* Convert possibly broken UTF-8 string into UTF-32 string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf32_buffer  the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char32_t written if
* successful.
*/
convert_utf8_to_utf32_with_errors :: (input: *u8, length: u64, utf32_output: *u32) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf8_to_utf32_with_errors@simdutf@@YA?AUresult@1@PEBD_KPEA_U@Z";

/**
* Convert valid UTF-8 string into latin1 string.
*
* This function assumes that the input string is valid UTF-8 and that it can be
* represented as Latin1. If you violate this assumption, the result is
* implementation defined and may include system-dependent behavior such as
* crashes.
*
* This function is for expert users only and not part of our public API. Use
* convert_utf8_to_latin1 instead. The function may be removed from the library
* in the future.
*
* This function is not BOM-aware.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param latin1_output  the pointer to buffer that can hold conversion result
* @return the number of written char; 0 if the input was not valid UTF-8 string
*/
convert_valid_utf8_to_latin1 :: (input: *u8, length: u64, latin1_output: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf8_to_latin1@simdutf@@YA_KPEBD_KPEAD@Z";

/**
* Using native endianness, convert valid UTF-8 string into a UTF-16 string.
*
* This function assumes that the input string is valid UTF-8.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t
*/
convert_valid_utf8_to_utf16 :: (input: *u8, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_valid_utf8_to_utf16@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Convert valid UTF-8 string into UTF-16LE string.
*
* This function assumes that the input string is valid UTF-8.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t
*/
convert_valid_utf8_to_utf16le :: (input: *u8, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_valid_utf8_to_utf16le@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Convert valid UTF-8 string into UTF-16BE string.
*
* This function assumes that the input string is valid UTF-8.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf16_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char16_t
*/
convert_valid_utf8_to_utf16be :: (input: *u8, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_valid_utf8_to_utf16be@simdutf@@YA_KPEBD_KPEA_S@Z";

/**
* Convert valid UTF-8 string into UTF-32 string.
*
* This function assumes that the input string is valid UTF-8.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in bytes
* @param utf32_buffer  the pointer to buffer that can hold conversion result
* @return the number of written char32_t
*/
convert_valid_utf8_to_utf32 :: (input: *u8, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_valid_utf8_to_utf32@simdutf@@YA_KPEBD_KPEA_U@Z";

/**
* Return the number of bytes that this Latin1 string would require in UTF-8
* format.
*
* @param input         the Latin1 string to convert
* @param length        the length of the string bytes
* @return the number of bytes required to encode the Latin1 string as UTF-8
*/
utf8_length_from_latin1 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf "?utf8_length_from_latin1@simdutf@@YA_KPEBD_K@Z";

/**
* Compute the number of bytes that this UTF-8 string would require in Latin1
* format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-8 strings but in such cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-8 string to convert
* @param length        the length of the string in byte
* @return the number of bytes required to encode the UTF-8 string as Latin1
*/
latin1_length_from_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf "?latin1_length_from_utf8@simdutf@@YA_KPEBD_K@Z";

/**
* Compute the number of 2-byte code units that this UTF-8 string would require
* in UTF-16LE format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-8 strings but in such cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-8 string to process
* @param length        the length of the string in bytes
* @return the number of char16_t code units required to encode the UTF-8 string
* as UTF-16LE
*/
utf16_length_from_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf "?utf16_length_from_utf8@simdutf@@YA_KPEBD_K@Z";

/**
* Compute the number of 4-byte code units that this UTF-8 string would require
* in UTF-32 format.
*
* This function is equivalent to count_utf8
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-8 strings but in such cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-8 string to process
* @param length        the length of the string in bytes
* @return the number of char32_t code units required to encode the UTF-8 string
* as UTF-32
*/
utf32_length_from_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf "?utf32_length_from_utf8@simdutf@@YA_KPEBD_K@Z";

/**
* Using native endianness, convert possibly broken UTF-16 string into UTF-8
* string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16LE
* string
*/
convert_utf16_to_utf8 :: (input: *u16, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf16_to_utf8@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Using native endianness, convert possibly broken UTF-16 string into UTF-8
* string with output limit.
*
* We write as many characters as possible into the output buffer,
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 16-bit code units (char16_t)
* @param utf8_output  	the pointer to buffer that can hold conversion result
* @param utf8_len      the maximum output length
* @return the number of written char; 0 if conversion is not possible
*/
convert_utf16_to_utf8_safe :: (input: *u16, length: u64, utf8_output: *u8, utf8_len: u64) -> u64 #foreign libsimdutf "?convert_utf16_to_utf8_safe@simdutf@@YA_KPEB_S_KPEAD1@Z";

/**
* Using native endianness, convert possibly broken UTF-16 string into Latin1
* string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16 string
* or if it cannot be represented as Latin1
*/
convert_utf16_to_latin1 :: (input: *u16, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf16_to_latin1@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16LE string into Latin1 string.
* If the string cannot be represented as Latin1, an error
* is returned.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16LE
* string or if it cannot be represented as Latin1
*/
convert_utf16le_to_latin1 :: (input: *u16, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf16le_to_latin1@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16BE string into Latin1 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16BE
* string or if it cannot be represented as Latin1
*/
convert_utf16be_to_latin1 :: (input: *u16, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf16be_to_latin1@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16LE string into UTF-8 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16LE
* string
*/
convert_utf16le_to_utf8 :: (input: *u16, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf16le_to_utf8@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16BE string into UTF-8 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16LE
* string
*/
convert_utf16be_to_utf8 :: (input: *u16, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf16be_to_utf8@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Using native endianness, convert possibly broken UTF-16 string into Latin1
* string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf16_to_latin1_with_errors :: (input: *u16, length: u64, latin1_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16_to_latin1_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16LE string into Latin1 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf16le_to_latin1_with_errors :: (input: *u16, length: u64, latin1_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16le_to_latin1_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16BE string into Latin1 string.
* If the string cannot be represented as Latin1, an error
* is returned.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf16be_to_latin1_with_errors :: (input: *u16, length: u64, latin1_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16be_to_latin1_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEAD@Z";

/**
* Using native endianness, convert possibly broken UTF-16 string into UTF-8
* string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf16_to_utf8_with_errors :: (input: *u16, length: u64, utf8_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16_to_utf8_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16LE string into UTF-8 string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf16le_to_utf8_with_errors :: (input: *u16, length: u64, utf8_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16le_to_utf8_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEAD@Z";

/**
* Convert possibly broken UTF-16BE string into UTF-8 string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf16be_to_utf8_with_errors :: (input: *u16, length: u64, utf8_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16be_to_utf8_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEAD@Z";

/**
* Using native endianness, convert valid UTF-16 string into UTF-8 string.
*
* This function assumes that the input string is valid UTF-16LE.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16_to_utf8 :: (input: *u16, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf16_to_utf8@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Using native endianness, convert UTF-16 string into Latin1 string.
*
* This function assumes that the input string is valid UTF-16 and that it can
* be represented as Latin1. If you violate this assumption, the result is
* implementation defined and may include system-dependent behavior such as
* crashes.
*
* This function is for expert users only and not part of our public API. Use
* convert_utf16_to_latin1 instead. The function may be removed from the library
* in the future.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16_to_latin1 :: (input: *u16, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf16_to_latin1@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert valid UTF-16LE string into Latin1 string.
*
* This function assumes that the input string is valid UTF-16LE and that it can
* be represented as Latin1. If you violate this assumption, the result is
* implementation defined and may include system-dependent behavior such as
* crashes.
*
* This function is for expert users only and not part of our public API. Use
* convert_utf16le_to_latin1 instead. The function may be removed from the
* library in the future.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16le_to_latin1 :: (input: *u16, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf16le_to_latin1@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert valid UTF-16BE string into Latin1 string.
*
* This function assumes that the input string is valid UTF-16BE and that it can
* be represented as Latin1. If you violate this assumption, the result is
* implementation defined and may include system-dependent behavior such as
* crashes.
*
* This function is for expert users only and not part of our public API. Use
* convert_utf16be_to_latin1 instead. The function may be removed from the
* library in the future.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16be_to_latin1 :: (input: *u16, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf16be_to_latin1@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert valid UTF-16LE string into UTF-8 string.
*
* This function assumes that the input string is valid UTF-16LE and that it can
* be represented as Latin1.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16le_to_utf8 :: (input: *u16, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf16le_to_utf8@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Convert valid UTF-16BE string into UTF-8 string.
*
* This function assumes that the input string is valid UTF-16BE.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf8_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16be_to_utf8 :: (input: *u16, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf16be_to_utf8@simdutf@@YA_KPEB_S_KPEAD@Z";

/**
* Using native endianness, convert possibly broken UTF-16 string into UTF-32
* string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16LE
* string
*/
convert_utf16_to_utf32 :: (input: *u16, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_utf16_to_utf32@simdutf@@YA_KPEB_S_KPEA_U@Z";

/**
* Convert possibly broken UTF-16LE string into UTF-32 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16LE
* string
*/
convert_utf16le_to_utf32 :: (input: *u16, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_utf16le_to_utf32@simdutf@@YA_KPEB_S_KPEA_U@Z";

/**
* Convert possibly broken UTF-16BE string into UTF-32 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-16LE
* string
*/
convert_utf16be_to_utf32 :: (input: *u16, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_utf16be_to_utf32@simdutf@@YA_KPEB_S_KPEA_U@Z";

/**
* Using native endianness, convert possibly broken UTF-16 string into
* UTF-32 string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char32_t written if
* successful.
*/
convert_utf16_to_utf32_with_errors :: (input: *u16, length: u64, utf32_buffer: *u32) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16_to_utf32_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEA_U@Z";

/**
* Convert possibly broken UTF-16LE string into UTF-32 string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char32_t written if
* successful.
*/
convert_utf16le_to_utf32_with_errors :: (input: *u16, length: u64, utf32_buffer: *u32) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16le_to_utf32_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEA_U@Z";

/**
* Convert possibly broken UTF-16BE string into UTF-32 string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char32_t written if
* successful.
*/
convert_utf16be_to_utf32_with_errors :: (input: *u16, length: u64, utf32_buffer: *u32) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf16be_to_utf32_with_errors@simdutf@@YA?AUresult@1@PEB_S_KPEA_U@Z";

/**
* Using native endianness, convert valid UTF-16 string into UTF-32 string.
*
* This function assumes that the input string is valid UTF-16 (native
* endianness).
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16_to_utf32 :: (input: *u16, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_valid_utf16_to_utf32@simdutf@@YA_KPEB_S_KPEA_U@Z";

/**
* Convert valid UTF-16LE string into UTF-32 string.
*
* This function assumes that the input string is valid UTF-16LE.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16le_to_utf32 :: (input: *u16, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_valid_utf16le_to_utf32@simdutf@@YA_KPEB_S_KPEA_U@Z";

/**
* Convert valid UTF-16BE string into UTF-32 string.
*
* This function assumes that the input string is valid UTF-16LE.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @param utf32_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf16be_to_utf32 :: (input: *u16, length: u64, utf32_buffer: *u32) -> u64 #foreign libsimdutf "?convert_valid_utf16be_to_utf32@simdutf@@YA_KPEB_S_KPEA_U@Z";

/**
* Using native endianness; Compute the number of bytes that this UTF-16
* string would require in UTF-8 format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-16 strings but in such cases the result is implementation defined.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return the number of bytes required to encode the UTF-16LE string as UTF-8
*/
utf8_length_from_utf16 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?utf8_length_from_utf16@simdutf@@YA_KPEB_S_K@Z";

/**
* Using native endianness; compute the number of bytes that this UTF-16
* string would require in UTF-8 format even when the UTF-16LE content contains
* mismatched surrogates that have to be replaced by the replacement character
* (0xFFFD).
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) where the count is the number of bytes required to
* encode the UTF-16 string as UTF-8, and the error code is either SUCCESS or
* SURROGATE. The count is correct regardless of the error field.
* When SURROGATE is returned, it does not indicate an error in the case of this
* function: it indicates that at least one surrogate has been encountered: the
* surrogates may be matched or not (thus this function does not validate). If
* the returned error code is SUCCESS, then the input contains no surrogate, is
* in the Basic Multilingual Plane, and is necessarily valid.
*/
utf8_length_from_utf16_with_replacement :: (input: *u16, length: u64) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?utf8_length_from_utf16_with_replacement@simdutf@@YA?AUresult@1@PEB_S_K@Z";

/**
* Compute the number of bytes that this UTF-16LE string would require in UTF-8
* format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-16 strings but in such cases the result is implementation defined.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return the number of bytes required to encode the UTF-16LE string as UTF-8
*/
utf8_length_from_utf16le :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?utf8_length_from_utf16le@simdutf@@YA_KPEB_S_K@Z";

/**
* Compute the number of bytes that this UTF-16BE string would require in UTF-8
* format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-16 strings but in such cases the result is implementation defined.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return the number of bytes required to encode the UTF-16BE string as UTF-8
*/
utf8_length_from_utf16be :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?utf8_length_from_utf16be@simdutf@@YA_KPEB_S_K@Z";

/**
* Convert possibly broken UTF-32 string into UTF-8 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-32 string
*/
convert_utf32_to_utf8 :: (input: *u32, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf32_to_utf8@simdutf@@YA_KPEB_U_KPEAD@Z";

/**
* Convert possibly broken UTF-32 string into UTF-8 string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf8_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf32_to_utf8_with_errors :: (input: *u32, length: u64, utf8_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf32_to_utf8_with_errors@simdutf@@YA?AUresult@1@PEB_U_KPEAD@Z";

/**
* Convert valid UTF-32 string into UTF-8 string.
*
* This function assumes that the input string is valid UTF-32.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf8_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf32_to_utf8 :: (input: *u32, length: u64, utf8_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf32_to_utf8@simdutf@@YA_KPEB_U_KPEAD@Z";

/**
* Using native endianness, convert possibly broken UTF-32 string into a UTF-16
* string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-32 string
*/
convert_utf32_to_utf16 :: (input: *u32, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_utf32_to_utf16@simdutf@@YA_KPEB_U_KPEA_S@Z";

/**
* Convert possibly broken UTF-32 string into UTF-16LE string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-32 string
*/
convert_utf32_to_utf16le :: (input: *u32, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_utf32_to_utf16le@simdutf@@YA_KPEB_U_KPEA_S@Z";

/**
* Convert possibly broken UTF-32 string into Latin1 string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-32 string
* or if it cannot be represented as Latin1
*/
convert_utf32_to_latin1 :: (input: *u32, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_utf32_to_latin1@simdutf@@YA_KPEB_U_KPEAD@Z";

/**
* Convert possibly broken UTF-32 string into Latin1 string and stop on error.
* If the string cannot be represented as Latin1, an error is returned.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param latin1_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char written if
* successful.
*/
convert_utf32_to_latin1_with_errors :: (input: *u32, length: u64, latin1_buffer: *u8) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf32_to_latin1_with_errors@simdutf@@YA?AUresult@1@PEB_U_KPEAD@Z";

/**
* Convert valid UTF-32 string into Latin1 string.
*
* This function assumes that the input string is valid UTF-32 and that it can
* be represented as Latin1. If you violate this assumption, the result is
* implementation defined and may include system-dependent behavior such as
* crashes.
*
* This function is for expert users only and not part of our public API. Use
* convert_utf32_to_latin1 instead. The function may be removed from the library
* in the future.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param latin1_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf32_to_latin1 :: (input: *u32, length: u64, latin1_buffer: *u8) -> u64 #foreign libsimdutf "?convert_valid_utf32_to_latin1@simdutf@@YA_KPEB_U_KPEAD@Z";

/**
* Compute the number of bytes that this UTF-32 string would require in Latin1
* format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-32 strings but in such cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param length        the length of the string in 4-byte code units (char32_t)
* @return the number of bytes required to encode the UTF-32 string as Latin1
*/
latin1_length_from_utf32 :: (length: u64) -> u64 #foreign libsimdutf "?latin1_length_from_utf32@simdutf@@YA_K_K@Z";

/**
* Compute the number of bytes that this Latin1 string would require in UTF-32
* format.
*
* @param length        the length of the string in Latin1 code units (char)
* @return the length of the string in 4-byte code units (char32_t) required to
* encode the Latin1 string as UTF-32
*/
utf32_length_from_latin1 :: (length: u64) -> u64 #foreign libsimdutf "?utf32_length_from_latin1@simdutf@@YA_K_K@Z";

/**
* Convert possibly broken UTF-32 string into UTF-16BE string.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to buffer that can hold conversion result
* @return number of written code units; 0 if input is not a valid UTF-32 string
*/
convert_utf32_to_utf16be :: (input: *u32, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_utf32_to_utf16be@simdutf@@YA_KPEB_U_KPEA_S@Z";

/**
* Using native endianness, convert possibly broken UTF-32 string into UTF-16
* string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char16_t written if
* successful.
*/
convert_utf32_to_utf16_with_errors :: (input: *u32, length: u64, utf16_buffer: *u16) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf32_to_utf16_with_errors@simdutf@@YA?AUresult@1@PEB_U_KPEA_S@Z";

/**
* Convert possibly broken UTF-32 string into UTF-16LE string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char16_t written if
* successful.
*/
convert_utf32_to_utf16le_with_errors :: (input: *u32, length: u64, utf16_buffer: *u16) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf32_to_utf16le_with_errors@simdutf@@YA?AUresult@1@PEB_U_KPEA_S@Z";

/**
* Convert possibly broken UTF-32 string into UTF-16BE string and stop on error.
*
* During the conversion also validation of the input string is done.
* This function is suitable to work with inputs from untrusted sources.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to buffer that can hold conversion result
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in code units) if any, or the number of char16_t written if
* successful.
*/
convert_utf32_to_utf16be_with_errors :: (input: *u32, length: u64, utf16_buffer: *u16) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?convert_utf32_to_utf16be_with_errors@simdutf@@YA?AUresult@1@PEB_U_KPEA_S@Z";

/**
* Using native endianness, convert valid UTF-32 string into a UTF-16 string.
*
* This function assumes that the input string is valid UTF-32.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf32_to_utf16 :: (input: *u32, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_valid_utf32_to_utf16@simdutf@@YA_KPEB_U_KPEA_S@Z";

/**
* Convert valid UTF-32 string into UTF-16LE string.
*
* This function assumes that the input string is valid UTF-32.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf32_to_utf16le :: (input: *u32, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_valid_utf32_to_utf16le@simdutf@@YA_KPEB_U_KPEA_S@Z";

/**
* Convert valid UTF-32 string into UTF-16BE string.
*
* This function assumes that the input string is valid UTF-32.
*
* This function is not BOM-aware.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @param utf16_buffer   the pointer to a buffer that can hold the conversion
* result
* @return number of written code units; 0 if conversion is not possible
*/
convert_valid_utf32_to_utf16be :: (input: *u32, length: u64, utf16_buffer: *u16) -> u64 #foreign libsimdutf "?convert_valid_utf32_to_utf16be@simdutf@@YA_KPEB_U_KPEA_S@Z";

/**
* Change the endianness of the input. Can be used to go from UTF-16LE to
* UTF-16BE or from UTF-16BE to UTF-16LE.
*
* This function does not validate the input.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to process
* @param length        the length of the string in 2-byte code units (char16_t)
* @param output        the pointer to a buffer that can hold the conversion
* result
*/
change_endianness_utf16 :: (input: *u16, length: u64, output: *u16) -> void #foreign libsimdutf "?change_endianness_utf16@simdutf@@YAXPEB_S_KPEA_S@Z";

/**
* Compute the number of bytes that this UTF-32 string would require in UTF-8
* format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-32 strings but in such cases the result is implementation defined.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @return the number of bytes required to encode the UTF-32 string as UTF-8
*/
utf8_length_from_utf32 :: (input: *u32, length: u64) -> u64 #foreign libsimdutf "?utf8_length_from_utf32@simdutf@@YA_KPEB_U_K@Z";

/**
* Compute the number of two-byte code units that this UTF-32 string would
* require in UTF-16 format.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-32 strings but in such cases the result is implementation defined.
*
* @param input         the UTF-32 string to convert
* @param length        the length of the string in 4-byte code units (char32_t)
* @return the number of bytes required to encode the UTF-32 string as UTF-16
*/
utf16_length_from_utf32 :: (input: *u32, length: u64) -> u64 #foreign libsimdutf "?utf16_length_from_utf32@simdutf@@YA_KPEB_U_K@Z";

/**
* Using native endianness; Compute the number of bytes that this UTF-16
* string would require in UTF-32 format.
*
* This function is equivalent to count_utf16.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-16 strings but in such cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return the number of bytes required to encode the UTF-16LE string as UTF-32
*/
utf32_length_from_utf16 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?utf32_length_from_utf16@simdutf@@YA_KPEB_S_K@Z";

/**
* Compute the number of bytes that this UTF-16LE string would require in UTF-32
* format.
*
* This function is equivalent to count_utf16le.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-16 strings but in such cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return the number of bytes required to encode the UTF-16LE string as UTF-32
*/
utf32_length_from_utf16le :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?utf32_length_from_utf16le@simdutf@@YA_KPEB_S_K@Z";

/**
* Compute the number of bytes that this UTF-16BE string would require in UTF-32
* format.
*
* This function is equivalent to count_utf16be.
*
* This function does not validate the input. It is acceptable to pass invalid
* UTF-16 strings but in such cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to convert
* @param length        the length of the string in 2-byte code units (char16_t)
* @return the number of bytes required to encode the UTF-16BE string as UTF-32
*/
utf32_length_from_utf16be :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?utf32_length_from_utf16be@simdutf@@YA_KPEB_S_K@Z";

/**
* Count the number of code points (characters) in the string assuming that
* it is valid.
*
* This function assumes that the input string is valid UTF-16 (native
* endianness). It is acceptable to pass invalid UTF-16 strings but in such
* cases the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16 string to process
* @param length        the length of the string in 2-byte code units (char16_t)
* @return number of code points
*/
count_utf16 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?count_utf16@simdutf@@YA_KPEB_S_K@Z";

/**
* Count the number of code points (characters) in the string assuming that
* it is valid.
*
* This function assumes that the input string is valid UTF-16LE.
* It is acceptable to pass invalid UTF-16 strings but in such cases
* the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16LE string to process
* @param length        the length of the string in 2-byte code units (char16_t)
* @return number of code points
*/
count_utf16le :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?count_utf16le@simdutf@@YA_KPEB_S_K@Z";

/**
* Count the number of code points (characters) in the string assuming that
* it is valid.
*
* This function assumes that the input string is valid UTF-16BE.
* It is acceptable to pass invalid UTF-16 strings but in such cases
* the result is implementation defined.
*
* This function is not BOM-aware.
*
* @param input         the UTF-16BE string to process
* @param length        the length of the string in 2-byte code units (char16_t)
* @return number of code points
*/
count_utf16be :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?count_utf16be@simdutf@@YA_KPEB_S_K@Z";

/**
* Count the number of code points (characters) in the string assuming that
* it is valid.
*
* This function assumes that the input string is valid UTF-8.
* It is acceptable to pass invalid UTF-8 strings but in such cases
* the result is implementation defined.
*
* @param input         the UTF-8 string to process
* @param length        the length of the string in bytes
* @return number of code points
*/
count_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf "?count_utf8@simdutf@@YA_KPEBD_K@Z";

/**
* Given a valid UTF-8 string having a possibly truncated last character,
* this function checks the end of string. If the last character is truncated
* (or partial), then it returns a shorter length (shorter by 1 to 3 bytes) so
* that the short UTF-8 strings only contain complete characters. If there is no
* truncated character, the original length is returned.
*
* This function assumes that the input string is valid UTF-8, but possibly
* truncated.
*
* @param input         the UTF-8 string to process
* @param length        the length of the string in bytes
* @return the length of the string in bytes, possibly shorter by 1 to 3 bytes
*/
trim_partial_utf8 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf "?trim_partial_utf8@simdutf@@YA_KPEBD_K@Z";

/**
* Given a valid UTF-16BE string having a possibly truncated last character,
* this function checks the end of string. If the last character is truncated
* (or partial), then it returns a shorter length (shorter by 1 unit) so that
* the short UTF-16BE strings only contain complete characters. If there is no
* truncated character, the original length is returned.
*
* This function assumes that the input string is valid UTF-16BE, but possibly
* truncated.
*
* @param input         the UTF-16BE string to process
* @param length        the length of the string in bytes
* @return the length of the string in bytes, possibly shorter by 1 unit
*/
trim_partial_utf16be :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?trim_partial_utf16be@simdutf@@YA_KPEB_S_K@Z";

/**
* Given a valid UTF-16LE string having a possibly truncated last character,
* this function checks the end of string. If the last character is truncated
* (or partial), then it returns a shorter length (shorter by 1 unit) so that
* the short UTF-16LE strings only contain complete characters. If there is no
* truncated character, the original length is returned.
*
* This function assumes that the input string is valid UTF-16LE, but possibly
* truncated.
*
* @param input         the UTF-16LE string to process
* @param length        the length of the string in bytes
* @return the length of the string in unit, possibly shorter by 1 unit
*/
trim_partial_utf16le :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?trim_partial_utf16le@simdutf@@YA_KPEB_S_K@Z";

/**
* Given a valid UTF-16 string having a possibly truncated last character,
* this function checks the end of string. If the last character is truncated
* (or partial), then it returns a shorter length (shorter by 1 unit) so that
* the short UTF-16 strings only contain complete characters. If there is no
* truncated character, the original length is returned.
*
* This function assumes that the input string is valid UTF-16, but possibly
* truncated. We use the native endianness.
*
* @param input         the UTF-16 string to process
* @param length        the length of the string in bytes
* @return the length of the string in unit, possibly shorter by 1 unit
*/
trim_partial_utf16 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?trim_partial_utf16@simdutf@@YA_KPEB_S_K@Z";

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

is_partial :: (options: last_chunk_handling_options) -> bool #foreign libsimdutf "?is_partial@simdutf@@YA_NW4last_chunk_handling_options@1@@Z";

/**
* Provide the maximal binary length in bytes given the base64 input.
* In general, if the input contains ASCII spaces, the result will be less than
* the maximum length.
*
* @param input         the base64 input to process
* @param length        the length of the base64 input in bytes
* @return maximum number of binary bytes
*/
maximal_binary_length_from_base64 :: (input: *u8, length: u64) -> u64 #foreign libsimdutf "?maximal_binary_length_from_base64@simdutf@@YA_KPEBD_K@Z";

/**
* Provide the maximal binary length in bytes given the base64 input.
* In general, if the input contains ASCII spaces, the result will be less than
* the maximum length.
*
* @param input         the base64 input to process, in ASCII stored as 16-bit
* units
* @param length        the length of the base64 input in 16-bit units
* @return maximal number of binary bytes
*/
maximal_binary_length_from_base64 :: (input: *u16, length: u64) -> u64 #foreign libsimdutf "?maximal_binary_length_from_base64@simdutf@@YA_KPEB_S_K@Z";

/**
* Convert a base64 input to a binary output.
*
* This function follows the WHATWG forgiving-base64 format, which means that it
* will ignore any ASCII spaces in the input. You may provide a padded input
* (with one or two equal signs at the end) or an unpadded input (without any
* equal signs at the end).
*
* See https://infra.spec.whatwg.org/#forgiving-base64-decode
*
* This function will fail in case of invalid input. When last_chunk_options =
* loose, there are two possible reasons for failure: the input contains a
* number of base64 characters that when divided by 4, leaves a single remainder
* character (BASE64_INPUT_REMAINDER), or the input contains a character that is
* not a valid base64 character (INVALID_BASE64_CHARACTER).
*
* When the error is INVALID_BASE64_CHARACTER, r.count contains the index in the
* input where the invalid character was found. When the error is
* BASE64_INPUT_REMAINDER, then r.count contains the number of bytes decoded.
*
* The default option (simdutf::base64_default) expects the characters `+` and
* `/` as part of its alphabet. The URL option (simdutf::base64_url) expects the
* characters `-` and `_` as part of its alphabet.
*
* The padding (`=`) is validated if present. There may be at most two padding
* characters at the end of the input. If there are any padding characters, the
* total number of characters (excluding spaces but including padding
* characters) must be divisible by four.
*
* You should call this function with a buffer that is at least
* maximal_binary_length_from_base64(input, length) bytes long. If you fail to
* provide that much space, the function may cause a buffer overflow.
*
* Advanced users may want to tailor how the last chunk is handled. By default,
* we use a loose (forgiving) approach but we also support a strict approach
* as well as a stop_before_partial approach, as per the following proposal:
*
* https://tc39.es/proposal-arraybuffer-base64/spec/#sec-frombase64
*
* @param input         the base64 string to process
* @param length        the length of the string in bytes
* @param output        the pointer to a buffer that can hold the conversion
* result (should be at least maximal_binary_length_from_base64(input, length)
* bytes long).
* @param options       the base64 options to use, usually base64_default or
* base64_url, and base64_default by default.
* @param last_chunk_options the last chunk handling options,
* last_chunk_handling_options::loose by default
* but can also be last_chunk_handling_options::strict or
* last_chunk_handling_options::stop_before_partial.
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and either position of the error
* (in the input in bytes) if any, or the number of bytes written if successful.
*/
base64_to_binary :: (input: *u8, length: u64, output: *u8, options: base64_options = .default, last_chunk_options: last_chunk_handling_options = .loose) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?base64_to_binary@simdutf@@YA?AUresult@1@PEBD_KPEADW4base64_options@1@W4last_chunk_handling_options@1@@Z";

/**
* Provide the base64 length in bytes given the length of a binary input.
*
* @param length        the length of the input in bytes
* @return number of base64 bytes
*/
base64_length_from_binary :: (length: u64, options: base64_options = .default) -> u64 #foreign libsimdutf "?base64_length_from_binary@simdutf@@YA_K_KW4base64_options@1@@Z";

/**
* Provide the base64 length in bytes given the length of a binary input,
* taking into account line breaks.
*
* @param length        the length of the input in bytes
* @param line_length   the length of lines, must be at least 4 (otherwise it is
* interpreted as 4),
* @return number of base64 bytes
*/
base64_length_from_binary_with_lines :: (length: u64, options: base64_options = .default, line_length: u64 = default_line_length) -> u64 #foreign libsimdutf "?base64_length_from_binary_with_lines@simdutf@@YA_K_KW4base64_options@1@0@Z";

/**
* Convert a binary input to a base64 output.
*
* The default option (simdutf::base64_default) uses the characters `+` and `/`
* as part of its alphabet. Further, it adds padding (`=`) at the end of the
* output to ensure that the output length is a multiple of four.
*
* The URL option (simdutf::base64_url) uses the characters `-` and `_` as part
* of its alphabet. No padding is added at the end of the output.
*
* This function always succeeds.
*
* @param input         the binary to process
* @param length        the length of the input in bytes
* @param output        the pointer to a buffer that can hold the conversion
* result (should be at least base64_length_from_binary(length) bytes long)
* @param options       the base64 options to use, can be base64_default or
* base64_url, is base64_default by default.
* @return number of written bytes, will be equal to
* base64_length_from_binary(length, options)
*/
binary_to_base64 :: (input: *u8, length: u64, output: *u8, options: base64_options = .default) -> u64 #foreign libsimdutf "?binary_to_base64@simdutf@@YA_KPEBD_KPEADW4base64_options@1@@Z";

/**
* Convert a binary input to a base64 output with line breaks.
*
* The default option (simdutf::base64_default) uses the characters `+` and `/`
* as part of its alphabet. Further, it adds padding (`=`) at the end of the
* output to ensure that the output length is a multiple of four.
*
* The URL option (simdutf::base64_url) uses the characters `-` and `_` as part
* of its alphabet. No padding is added at the end of the output.
*
* This function always succeeds.
*
* @param input         the binary to process
* @param length        the length of the input in bytes
* @param output        the pointer to a buffer that can hold the conversion
* result (should be at least base64_length_from_binary_with_lines(length,
* options, line_length) bytes long)
* @param line_length   the length of lines, must be at least 4 (otherwise it is
* interpreted as 4),
* @param options       the base64 options to use, can be base64_default or
* base64_url, is base64_default by default.
* @return number of written bytes, will be equal to
* base64_length_from_binary_with_lines(length, options)
*/
binary_to_base64_with_lines :: (input: *u8, length: u64, output: *u8, line_length: u64 = default_line_length, options: base64_options = .default) -> u64 #foreign libsimdutf "?binary_to_base64_with_lines@simdutf@@YA_KPEBD_KPEAD1W4base64_options@1@@Z";

/**
* Convert a base64 input to a binary output.
*
* This function follows the WHATWG forgiving-base64 format, which means that it
* will ignore any ASCII spaces in the input. You may provide a padded input
* (with one or two equal signs at the end) or an unpadded input (without any
* equal signs at the end).
*
* See https://infra.spec.whatwg.org/#forgiving-base64-decode
*
* This function will fail in case of invalid input. When last_chunk_options =
* loose, there are two possible reasons for failure: the input contains a
* number of base64 characters that when divided by 4, leaves a single remainder
* character (BASE64_INPUT_REMAINDER), or the input contains a character that is
* not a valid base64 character (INVALID_BASE64_CHARACTER).
*
* When the error is INVALID_BASE64_CHARACTER, r.count contains the index in the
* input where the invalid character was found. When the error is
* BASE64_INPUT_REMAINDER, then r.count contains the number of bytes decoded.
*
* The default option (simdutf::base64_default) expects the characters `+` and
* `/` as part of its alphabet. The URL option (simdutf::base64_url) expects the
* characters `-` and `_` as part of its alphabet.
*
* The padding (`=`) is validated if present. There may be at most two padding
* characters at the end of the input. If there are any padding characters, the
* total number of characters (excluding spaces but including padding
* characters) must be divisible by four.
*
* You should call this function with a buffer that is at least
* maximal_binary_length_from_base64(input, length) bytes long. If you fail
* to provide that much space, the function may cause a buffer overflow.
*
* Advanced users may want to tailor how the last chunk is handled. By default,
* we use a loose (forgiving) approach but we also support a strict approach
* as well as a stop_before_partial approach, as per the following proposal:
*
* https://tc39.es/proposal-arraybuffer-base64/spec/#sec-frombase64
*
* @param input         the base64 string to process, in ASCII stored as 16-bit
* units
* @param length        the length of the string in 16-bit units
* @param output        the pointer to a buffer that can hold the conversion
* result (should be at least maximal_binary_length_from_base64(input, length)
* bytes long).
* @param options       the base64 options to use, can be base64_default or
* base64_url, is base64_default by default.
* @param last_chunk_options the last chunk handling options,
* last_chunk_handling_options::loose by default
* but can also be last_chunk_handling_options::strict or
* last_chunk_handling_options::stop_before_partial.
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and position of the
* INVALID_BASE64_CHARACTER error (in the input in units) if any, or the number
* of bytes written if successful.
*/
base64_to_binary :: (input: *u16, length: u64, output: *u8, options: base64_options = .default, last_chunk_options: last_chunk_handling_options = .loose) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?base64_to_binary@simdutf@@YA?AUresult@1@PEB_S_KPEADW4base64_options@1@W4last_chunk_handling_options@1@@Z";

/**
* Check if a character is an ignorabl base64 character.
* Checking a large input, character by character, is not computationally
* efficient.
*
* @param input         the character to check
* @param options       the base64 options to use, is base64_default by default.
* @return true if the character is an ignorablee base64 character, false
* otherwise.
*/
base64_ignorable :: (input: u8, options: base64_options = .default) -> bool #foreign libsimdutf "?base64_ignorable@simdutf@@YA_NDW4base64_options@1@@Z";

base64_ignorable :: (input: u16, options: base64_options = .default) -> bool #foreign libsimdutf "?base64_ignorable@simdutf@@YA_N_SW4base64_options@1@@Z";

/**
* Check if a character is a valid base64 character.
* Checking a large input, character by character, is not computationally
* efficient.
* Note that padding characters are not considered valid base64 characters in
* this context, nor are spaces.
*
* @param input         the character to check
* @param options       the base64 options to use, is base64_default by default.
* @return true if the character is a base64 character, false otherwise.
*/
base64_valid :: (input: u8, options: base64_options = .default) -> bool #foreign libsimdutf "?base64_valid@simdutf@@YA_NDW4base64_options@1@@Z";

base64_valid :: (input: u16, options: base64_options = .default) -> bool #foreign libsimdutf "?base64_valid@simdutf@@YA_N_SW4base64_options@1@@Z";

/**
* Check if a character is a valid base64 character or the padding character
* ('='). Checking a large input, character by character, is not computationally
* efficient.
*
* @param input         the character to check
* @param options       the base64 options to use, is base64_default by default.
* @return true if the character is a base64 character, false otherwise.
*/
base64_valid_or_padding :: (input: u8, options: base64_options = .default) -> bool #foreign libsimdutf "?base64_valid_or_padding@simdutf@@YA_NDW4base64_options@1@@Z";

base64_valid_or_padding :: (input: u16, options: base64_options = .default) -> bool #foreign libsimdutf "?base64_valid_or_padding@simdutf@@YA_N_SW4base64_options@1@@Z";

/**
* Convert a base64 input to a binary output.
*
* This function follows the WHATWG forgiving-base64 format, which means that it
* will ignore any ASCII spaces in the input. You may provide a padded input
* (with one or two equal signs at the end) or an unpadded input (without any
* equal signs at the end).
*
* See https://infra.spec.whatwg.org/#forgiving-base64-decode
*
* This function will fail in case of invalid input. When last_chunk_options =
* loose, there are three possible reasons for failure: the input contains a
* number of base64 characters that when divided by 4, leaves a single remainder
* character (BASE64_INPUT_REMAINDER), the input contains a character that is
* not a valid base64 character (INVALID_BASE64_CHARACTER), or the output buffer
* is too small (OUTPUT_BUFFER_TOO_SMALL).
*
* When OUTPUT_BUFFER_TOO_SMALL, we return both the number of bytes written
* and the number of units processed, see description of the parameters and
* returned value.
*
* When the error is INVALID_BASE64_CHARACTER, r.count contains the index in the
* input where the invalid character was found. When the error is
* BASE64_INPUT_REMAINDER, then r.count contains the number of bytes decoded.
*
* The default option (simdutf::base64_default) expects the characters `+` and
* `/` as part of its alphabet. The URL option (simdutf::base64_url) expects the
* characters `-` and `_` as part of its alphabet.
*
* The padding (`=`) is validated if present. There may be at most two padding
* characters at the end of the input. If there are any padding characters, the
* total number of characters (excluding spaces but including padding
* characters) must be divisible by four.
*
* The INVALID_BASE64_CHARACTER cases are considered fatal and you are expected
* to discard the output unless the parameter decode_up_to_bad_char is set to
* true. In that case, the function will decode up to the first invalid
* character. Extra padding characters ('=') are considered invalid characters.
*
* Advanced users may want to tailor how the last chunk is handled. By default,
* we use a loose (forgiving) approach but we also support a strict approach
* as well as a stop_before_partial approach, as per the following proposal:
*
* https://tc39.es/proposal-arraybuffer-base64/spec/#sec-frombase64
*
* @param input         the base64 string to process, in ASCII stored as 8-bit
* or 16-bit units
* @param length        the length of the string in 8-bit or 16-bit units.
* @param output        the pointer to a buffer that can hold the conversion
* result.
* @param outlen        the number of bytes that can be written in the output
* buffer. Upon return, it is modified to reflect how many bytes were written.
* @param options       the base64 options to use, can be base64_default or
* base64_url, is base64_default by default.
* @param last_chunk_options the last chunk handling options,
* last_chunk_handling_options::loose by default
* but can also be last_chunk_handling_options::strict or
* last_chunk_handling_options::stop_before_partial.
* @param decode_up_to_bad_char if true, the function will decode up to the
* first invalid character. By default (false), it is assumed that the output
* buffer is to be discarded. When there are multiple errors in the input,
* using decode_up_to_bad_char might trigger a different error.
* @return a result pair struct (of type simdutf::result containing the two
* fields error and count) with an error code and position of the
* INVALID_BASE64_CHARACTER error (in the input in units) if any, or the number
* of units processed if successful.
*/
base64_to_binary_safe :: (input: *u8, length: u64, output: *u8, outlen: *u64, options: base64_options = .default, last_chunk_options: last_chunk_handling_options = .loose, decode_up_to_bad_char := false) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?base64_to_binary_safe@simdutf@@YA?AUresult@1@PEBD_KPEADAEA_KW4base64_options@1@W4last_chunk_handling_options@1@_N@Z";

base64_to_binary_safe :: (input: *u16, length: u64, output: *u8, outlen: *u64, options: base64_options = .default, last_chunk_options: last_chunk_handling_options = .loose, decode_up_to_bad_char := false) -> result #cpp_return_type_is_non_pod #foreign libsimdutf "?base64_to_binary_safe@simdutf@@YA?AUresult@1@PEB_S_KPEADAEA_KW4base64_options@1@W4last_chunk_handling_options@1@_N@Z";

/**
* Find the first occurrence of a character in a string. If the character is
* not found, return a pointer to the end of the string.
* @param start        the start of the string
* @param end          the end of the string
* @param character    the character to find
* @return a pointer to the first occurrence of the character in the string,
* or a pointer to the end of the string if the character is not found.
*
*/
find :: (start: *u8, end: *u8, character: u8) -> *u8 #foreign libsimdutf "?find@simdutf@@YAPEBDPEBD0D@Z";

find :: (start: *u16, end: *u16, character: u16) -> *u16 #foreign libsimdutf "?find@simdutf@@YAPEB_SPEB_S0_S@Z";

anon_namespace_1 :: struct {
    tables :: struct {
        base64 :: struct {
            base64_default :: struct {
                e0: [256] u8;

                e1: [256] u8;

                e2: [256] u8;

                d0: [256] u32;

                d1: [256] u32;

                d2: [256] u32;

                d3: [256] u32;
            }

            base64_url :: struct {
                e0: [256] u8;

                e1: [256] u8;

                e2: [256] u8;

                d0: [256] u32;

                d1: [256] u32;

                d2: [256] u32;

                d3: [256] u32;
            }

            base64_default_or_url :: struct {
                d0: [256] u32;

                d1: [256] u32;

                d2: [256] u32;

                d3: [256] u32;
            }

            thintable_epi8: [256] u64;

            pshufb_combine_table: [272] u8;

            BitsSetTable256mul2: [256] u8;

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

icelake :: struct {
    anon_namespace_2 :: struct {
        simd :: struct {
            /* begin file src/simdutf/icelake/simd16-inl.h */
            simd16 :: struct(T: Type) {
                using,except(T) simd16__raw:            simd16__RAW(T);
                #if size_of(simd16__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd16 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd16
            simd16__RAW :: struct(T: Type) {}

            /* end file src/simdutf/icelake/simd16-inl.h */
            /* begin file src/simdutf/icelake/simd32-inl.h */
            simd32 :: struct(T: Type) {
                using,except(T) simd32__raw:            simd32__RAW(T);
                #if size_of(simd32__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd32 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd32
            simd32__RAW :: struct(T: Type) {}
        }

        /* begin file src/icelake/icelake_utf8_common.inl.cpp */
        // Common procedures for both validating and non-validating conversions from
        // UTF-8.
        block_processing_mode :: enum s32 {
            FULL :: 0;
            TAIL :: 1;
            SIMDUTF_FULL :: FULL;
            SIMDUTF_TAIL :: TAIL;
        }

        avx512_utf8_checker :: struct {}

        /* begin file src/icelake/icelake_base64.inl.cpp */
        // file included directly
        /**
        * References and further reading:
        *
        * Wojciech Muła, Daniel Lemire, Base64 encoding and decoding at almost the
        * speed of a memory copy, Software: Practice and Experience 50 (2), 2020.
        * https://arxiv.org/abs/1910.05109
        *
        * Wojciech Muła, Daniel Lemire, Faster Base64 Encoding and Decoding using AVX2
        * Instructions, ACM Transactions on the Web 12 (3), 2018.
        * https://arxiv.org/abs/1704.00605
        *
        * Simon Josefsson. 2006. The Base16, Base32, and Base64 Data Encodings.
        * https://tools.ietf.org/html/rfc4648. (2006). Internet Engineering Task Force,
        * Request for Comments: 4648.
        *
        * Alfred Klomp. 2014a. Fast Base64 encoding/decoding with SSE vectorization.
        * http://www.alfredklomp.com/programming/sse-base64/. (2014).
        *
        * Alfred Klomp. 2014b. Fast Base64 stream encoder/decoder in C99, with SIMD
        * acceleration. https://github.com/aklomp/base64. (2014).
        *
        * Hanson Char. 2014. A Fast and Correct Base 64 Codec. (2014).
        * https://aws.amazon.com/blogs/developer/a-fast-and-correct-base-64-codec/
        *
        * Nick Kopp. 2013. Base64 Encoding on a GPU.
        * https://www.codeproject.com/Articles/276993/Base-Encoding-on-a-GPU. (2013).
        */
        block64 :: struct {}
    }
}

/**
* Implementation for Haswell (Intel AVX2).
*/
haswell :: struct {
    anon_namespace_3 :: struct {
        simd :: struct {
            // Forward-declared so they can be used by splat and friends.
            base :: struct(Child: Type) {
                using,except(Child) base__raw:              base__RAW(Child);
                #if size_of(base__RAW(Child)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // base without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base
            base__RAW :: struct(Child: Type) {}

            // Forward-declared so they can be used by splat and friends.
            simd8 :: struct(T: Type) {
                using,except(T) simd8__raw:             simd8__RAW(T);
                #if size_of(simd8__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd8 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd8
            simd8__RAW :: struct(T: Type) {}

            base8 :: struct(T: Type, Mask: Type = simd8) {
                using,except(T, Mask) base8__raw:             base8__RAW(T, Mask);
                #if size_of(base8__RAW(T, Mask)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base__raw; #as base: base(simd8(T)); // Support cast to base
            }
                        // base8 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base8
            base8__RAW :: struct(T: Type, Mask: Type = simd8) {
                using base__raw: base__RAW(simd8(T));
            }

            base8_numeric :: struct(T: Type) {
                using,except(T) base8_numeric__raw:     base8_numeric__RAW(T);
                #if size_of(base8_numeric__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base8__raw; #as base8: base8(T); // Support cast to base8
            }
                        // base8_numeric without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base8_numeric
            base8_numeric__RAW :: struct(T: Type) {
                using,except(T) base8__raw: base8__RAW(T);
            }

            simd8x64 :: struct(T: Type) {
                using,except(T) simd8x64__raw:          simd8x64__RAW(T);
                #if size_of(simd8x64__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd8x64 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd8x64
            simd8x64__RAW :: struct(T: Type) {}

            simd16 :: struct(T: Type) {
                using,except(T) simd16__raw:            simd16__RAW(T);
                #if size_of(simd16__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd16 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd16
            simd16__RAW :: struct(T: Type) {}

            base16 :: struct(T: Type, Mask: Type = simd16) {
                using,except(T, Mask) base16__raw:            base16__RAW(T, Mask);
                #if size_of(base16__RAW(T, Mask)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base__raw; #as base: base(simd16(T)); // Support cast to base
            }
                        // base16 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base16
            base16__RAW :: struct(T: Type, Mask: Type = simd16) {
                using base__raw: base__RAW(simd16(T));
                bitmask_type :: u32;
            }

            base16_numeric :: struct(T: Type) {
                using,except(T) base16_numeric__raw:    base16_numeric__RAW(T);
                #if size_of(base16_numeric__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base16__raw; #as base16: base16(T); // Support cast to base16
            }
                        // base16_numeric without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base16_numeric
            base16_numeric__RAW :: struct(T: Type) {
                using,except(T) base16__raw: base16__RAW(T);
            }

            simd16x32 :: struct(T: Type) {
                using,except(T) simd16x32__raw:         simd16x32__RAW(T);
                #if size_of(simd16x32__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd16x32 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd16x32
            simd16x32__RAW :: struct(T: Type) {}

            /* end file src/simdutf/haswell/simd16-inl.h */
            /* begin file src/simdutf/haswell/simd32-inl.h */
            simd32 :: struct(T: Type) {
                using,except(T) simd32__raw:            simd32__RAW(T);
                #if size_of(simd32__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd32 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd32
            simd32__RAW :: struct(T: Type) {}

            /* end file src/simdutf/haswell/simd32-inl.h */
            /* begin file src/simdutf/haswell/simd64-inl.h */
            simd64 :: struct(T: Type) {
                using,except(T) simd64__raw:            simd64__RAW(T);
                #if size_of(simd64__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd64 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd64
            simd64__RAW :: struct(T: Type) {}
        }

        // --- decoding - base64 class --------------------------------
        block64 :: struct {}

        // Walks through a buffer in block-sized increments, loading the last part with
        // spaces
        buf_block_reader :: struct(STEP_SIZE: u64) {
            buf: *u8;

            idx: u64;
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

/**
* Implementation for Westmere (Intel SSE4.2).
*/
westmere :: struct {
    anon_namespace_4 :: struct {
        simd :: struct {
            base :: struct(Child: Type) {
                using,except(Child) base__raw:              base__RAW(Child);
                #if size_of(base__RAW(Child)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // base without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base
            base__RAW :: struct(Child: Type) {}

            // Forward-declared so they can be used by splat and friends.
            simd8 :: struct(T: Type) {
                using,except(T) simd8__raw:             simd8__RAW(T);
                #if size_of(simd8__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd8 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd8
            simd8__RAW :: struct(T: Type) {}

            base8 :: struct(T: Type, Mask: Type = simd8) {
                using,except(T, Mask) base8__raw:             base8__RAW(T, Mask);
                #if size_of(base8__RAW(T, Mask)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base__raw; #as base: base(simd8(T)); // Support cast to base
            }
                        // base8 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base8
            base8__RAW :: struct(T: Type, Mask: Type = simd8) {
                using base__raw: base__RAW(simd8(T));
                bitmask_t :: u16;
                bitmask2_t :: u32;
            }

            base8_numeric :: struct(T: Type) {
                using,except(T) base8_numeric__raw:     base8_numeric__RAW(T);
                #if size_of(base8_numeric__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base8__raw; #as base8: base8(T); // Support cast to base8
            }
                        // base8_numeric without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base8_numeric
            base8_numeric__RAW :: struct(T: Type) {
                using,except(T) base8__raw: base8__RAW(T);
            }

            simd8x64 :: struct(T: Type) {
                using,except(T) simd8x64__raw:          simd8x64__RAW(T);
                #if size_of(simd8x64__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd8x64 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd8x64
            simd8x64__RAW :: struct(T: Type) {}

            /* begin file src/simdutf/westmere/simd16-inl.h */
            simd16 :: struct(T: Type) {
                using,except(T) simd16__raw:            simd16__RAW(T);
                #if size_of(simd16__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd16 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd16
            simd16__RAW :: struct(T: Type) {}

            base16 :: struct(T: Type, Mask: Type = simd16) {
                using,except(T, Mask) base16__raw:            base16__RAW(T, Mask);
                #if size_of(base16__RAW(T, Mask)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base__raw; #as base: base(simd16(T)); // Support cast to base
            }
                        // base16 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base16
            base16__RAW :: struct(T: Type, Mask: Type = simd16) {
                using base__raw: base__RAW(simd16(T));
            }

            base16_numeric :: struct(T: Type) {
                using,except(T) base16_numeric__raw:    base16_numeric__RAW(T);
                #if size_of(base16_numeric__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
                #place base16__raw; #as base16: base16(T); // Support cast to base16
            }
                        // base16_numeric without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from base16_numeric
            base16_numeric__RAW :: struct(T: Type) {
                using,except(T) base16__raw: base16__RAW(T);
            }

            simd16x32 :: struct(T: Type) {
                using,except(T) simd16x32__raw:         simd16x32__RAW(T);
                #if size_of(simd16x32__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd16x32 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd16x32
            simd16x32__RAW :: struct(T: Type) {}

            /* end file src/simdutf/westmere/simd16-inl.h */
            /* begin file src/simdutf/westmere/simd32-inl.h */
            simd32 :: struct(T: Type) {
                using,except(T) simd32__raw:            simd32__RAW(T);
                #if size_of(simd32__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd32 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd32
            simd32__RAW :: struct(T: Type) {}

            /* end file src/simdutf/westmere/simd32-inl.h */
            /* begin file src/simdutf/westmere/simd64-inl.h */
            simd64 :: struct(T: Type) {
                using,except(T) simd64__raw:            simd64__RAW(T);
                #if size_of(simd64__RAW(T)) == 0 {
                    __empty_struct_padding: u8; // C++ makes empty structs have length 1
                }
            }
                        // simd64 without empty struct padding. Needed to generate a C++-equivalent struct layout when "inheriting" from simd64
            simd64__RAW :: struct(T: Type) {}
        }

        /* begin file src/westmere/sse_convert_utf32_to_utf16.cpp */
        expansion_result_t :: struct {
            u16count: u64;
            #place u16count; expansion_result_t_alignment: u8 #align 16;
        }

        // --- decoding - base64 class --------------------------------
        block64 :: struct {}

        // Walks through a buffer in block-sized increments, loading the last part with
        // spaces
        buf_block_reader :: struct(STEP_SIZE: u64) {
            buf: *u8;

            idx: u64;
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

scalar :: struct {
    u16_swap_bytes :: (word: u16) -> u16 #foreign libsimdutf "?u16_swap_bytes@scalar@simdutf@@YAGG@Z";

    u32_swap_bytes :: (word: u32) -> u32 #foreign libsimdutf "?u32_swap_bytes@scalar@simdutf@@YAII@Z";

    anon_namespace_6 :: struct {
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

#scope_file

libsimdutf :: #library,no_dll "bin/x64/libsimdutf";
