#import "Basic";
#import,file "../module.jai";

main :: () {

    test_string := "Hello there, friend!";

    is_valid := simdutf_validate_utf8(test_string.data, test_string.count.(u64));
    assert(is_valid);

    encoding_type := simdutf_autodetect_encoding(test_string.data, test_string.count.(u64));
    assert(encoding_type == .UTF8);

    required_utf16_chars := simdutf_utf16_length_from_utf8(test_string.data, test_string.count.(u64)).(s64);
    assert(required_utf16_chars == test_string.count);

    utf16_string: [..]u16;
    array_reserve(*utf16_string, required_utf16_chars);

    utf16_bytes_written := simdutf_convert_utf8_to_utf16(test_string.data, test_string.count.(u64), utf16_string.data).(s64);
    assert(utf16_bytes_written == required_utf16_chars);

    is_valid = simdutf_validate_utf16(utf16_string.data, utf16_string.count.(u64));
    assert(is_valid);

    print("All tests passed!\n");
}
