#run build();
build :: () {

    set_build_options_dc(.{do_output=false});

	options := get_build_options();
    args := options.compile_time_command_line;

    if !generate_bindings(args) {
        compiler_set_workspace_status(.FAILED);
        return;
    }
}

// Current sources are from simdutf v9.9.0
BINDINGS_SRC_PATH :: "src/simdutf/src/simdutf.cpp";
BINDINGS_INCLUDE_DIRS :: string.["src/simdutf/include"];

BUILD_SRC_PATH :: "src/simdutf/src/simdutf.cpp";
BUILD_INCLUDE_DIRS :: string.["src/simdutf/include"];

DECLARATIONS_TO_OMIT :: string.[
    // Remove internal, and all the problems it causes
    "internal",

    // Remove implementation (the parent class?) and it's problems
    "implementation",

    // Those reference types in internal or implementation
    "builtin_implementation",
    "get_available_implementations",
    "get_active_implementation",
    "get_default_implementation",

    // Those (or their fields) reference std.string
    "to_string",
    "virtual_name",
    "virtual_description",
    "implementation_VTable",
    "implementation_name",
    "implementation_description",

    // Those reference std.pair
    "utf8_to_utf16_result",
    "utf8_to_utf32_result",
];

ENUMS_TO_OMIT :: string.[
];

generate_bindings :: (args: []string) -> bool {

    compile := array_find(args, "-compile");

    if compile {
        success := compile_simdutf();
        if !success return false;
    }

    output_filename: string;
    opts: Generate_Bindings_Options;

    array_add(*opts.flatten_namespaces, "simdutf");
    array_add(*opts.source_files, BINDINGS_SRC_PATH);
    array_add(*opts.include_paths, ..BINDINGS_INCLUDE_DIRS);
    array_add(*opts.libraries, .{filename="libsimdutf"});

    #if OS == .WINDOWS {

        #if CPU != .X64 {
            assert("CPU=% isn't currently supported. You might be able to add support for it though!", CPU);
        }

        output_filename = "windows/windows.jai";
        array_add(*opts.library_search_paths, "windows/bin/x64");

        opts.footer = FOOTER_WIN;
        opts.generate_library_declarations = false;

    } else #if OS == .LINUX {

        defer print("\n\n>>> Linux bindings don't currently get generated due to clang issues. Perhaps you can fix it and send a PR!\n");

        #if CPU != .X64 {
            assert("CPU=% isn't currently supported. You might be able to add support for it though!", CPU);
        }

        output_filename = "linux/linux.jai";
        array_add(*opts.library_search_paths, "linux/bin/x64");

        array_add(*opts.system_include_paths, ..get_default_system_include_paths());

        opts.footer = FOOTER_LINUX;
        opts.generate_library_declarations = false;

    } else #if OS == .MACOS {
        output_filename = "macos/macos.jai";

        array_add(*opts.library_search_paths, "macos/bin/arm64");

        opts.footer = FOOTER_MAC;
        opts.generate_library_declarations = false;

    } else {
        assert(false, "this OS is currently unsupported. You might be able to add support for it though!");
    }

    opts.visitor = simdutf_visitor;
    opts.generate_compile_time_struct_checks = false;

    // The order matters! c++ must be before C includes.
    array_add(*opts.system_include_paths,
        "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include/c++/v1",
        "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk/usr/include",
    );
    jai_clang_include_paths := get_default_system_include_paths();
    array_add(*opts.system_include_paths, ..jai_clang_include_paths);

    array_add(*opts.extra_clang_arguments, "-x", "c++", "-std=c++17");

    #if CPU == .X64 {
        array_add(*opts.extra_clang_arguments, "-march=haswell");
    } else #if CPU == .ARM64 {
        array_add(*opts.extra_clang_arguments, "-march=armv8-a");
    }

    ok := generate_bindings(opts, output_filename);
    if !ok return false;

    return true;
}

compile_simdutf :: () -> ok: bool {

    src_files: [..]string;
    array_add(*src_files, BUILD_SRC_PATH);

    success := false;

    #if OS == .WINDOWS {

        #if CPU != .X64 {
            assert("CPU=% isn't currently supported. You might be able to add support for it though!", CPU);
        }

        make_directory_if_it_does_not_exist("windows/bin/x64", recursive=true);

        success = build_cpp_static_lib("windows/bin/x64/libsimdutf", ..src_files, extra=.[
            tprint("/I%", BUILD_INCLUDE_DIRS[0]),
            "-std=c++17",
            "-std=c++17", // Required since simdutf 9.0.0

            // Remove c++ stdlib dependency
            "-nostdlib++",
            "-fno-rtti",
            "-fno-exceptions",
            "-DSIMDUTF_NO_LIBCXX=1",
        ]);

    } else #if OS == .LINUX {

        #if CPU != .X64 {
            assert("CPU=% isn't currently supported. You might be able to add support for it though!", CPU);
        }

        make_directory_if_it_does_not_exist("linux/bin/x64", recursive=true);

        success = build_cpp_static_lib("linux/bin/x64/libsimdutf", ..src_files, extra=.[
            tprint("-I%", BUILD_INCLUDE_DIRS[0]),
            "-std=c++17", // Required since simdutf 9.0.0

            // Remove c++ stdlib dependency
            "-nostdlib++",
            "-fno-rtti",
            "-fno-exceptions",
            "-DSIMDUTF_NO_LIBCXX=1",
        ]);

    } else #if OS == .MACOS {

        make_directory_if_it_does_not_exist("macos/bin/arm64", recursive=true);

        success = build_cpp_static_lib( "macos/bin/arm64/libsimdutf", ..src_files, extra=.[
            tprint("-I%", BUILD_INCLUDE_DIRS[0]),
            "-std=c++17", // Required since simdutf 9.0.0

            // Remove c++ stdlib dependency
            "-nostdlib++",
            "-fno-rtti",
            "-fno-exceptions",
            "-DSIMDUTF_NO_LIBCXX=1",
        ]);

    } else {
        assert(false, "this OS is currently unsupported. You might be able to add support for it though!");
    }

    return success;
}

simdutf_visitor :: (decl: *Declaration, parent_decl: *Declaration) -> Declaration_Visit_Result {

    if array_find(DECLARATIONS_TO_OMIT, decl.name) {
        decl.decl_flags |= .OMIT_FROM_OUTPUT;
        return .STOP;
    }

    // This parent is actually "implementation_VTable"

    if parent_decl {

        if parent_decl.name == "implementation" {

            if decl.name == {
                case "name"; #through;
                case "description";
                    decl.decl_flags |= .OMIT_FROM_OUTPUT;
                    return .RECURSE;
            }
        } else if parent_decl.name == "name" {

            if decl.name == "this" {
                decl.decl_flags |= .OMIT_FROM_OUTPUT;
                return .RECURSE;
            }
        } else if parent_decl.name == "description" {

            if decl.name == "this" {
                decl.decl_flags |= .OMIT_FROM_OUTPUT;
                return .RECURSE;
            }
        }
    }

    if decl.name == "SIMDUTF_VERSION" && decl.expression && decl.expression.kind == .LITERAL {
        decl.output_name = "SIMDUTF_VERSION_STRING";
    }

    return .RECURSE;
}

#scope_file

#import "String";
#import "Basic";
#import "Compiler";
#import "BuildCpp";
#import "Check";
#import "Bindings_Generator";
#import "File";
FOOTER_WIN :: #string END
libsimdutf :: #library,no_dll "bin/x64/libsimdutf";
END

FOOTER_LINUX :: #string END
libsimdutf :: #library,no_dll "bin/x64/libsimdutf";
END

FOOTER_MAC :: #string END
libsimdutf :: #library,no_dll "bin/arm64/libsimdutf";
END
