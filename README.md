# jai-simdutf

Jai bindings for the [simdutf](https://github.com/simdutf/simdutf) library v7.7.0.

Generate bindings using `jai generate.jai`, and compile static libraries with `jai generate.jai - -compile`.

While we have static libraries for both Windows and Linux, we aren't able to generate bindings for Linux yet.

As such, only `Windows` is currently supported.

PRs welcome.

## Notes

For some reason, while generating bindings (as of jai beta 0.2.021) we get a lot of errors. Luckily bindings still compile and work.

Not sure what the issue is, but that's a problem for the future...
