#if OS == .WINDOWS {
    #load "windows/windows.jai";
    msvcprt :: #library,system,no_dll,link_always "msvcprt"; // Required for simdutf or we get string related linker error
} else #if OS == .MACOS {
    #load "macos/macos.jai";
} else {
    #assert false "we don't currently have bindings for this OS, but you might be able to add them. Check the README for information.";
}
