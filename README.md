# openssl-zig

`openssl-zig` is a Zig package for a compilation of
[OpenSSL](https://github.com/openssl/openssl) version 3.4.0 using Zig 0.13.0.
While there are other packages with a similar goal, I had trouble integrating
them into my own project, and even when I looked at the source code for their
build files, I didn't have a clue as to how to fix my issues. For this package,
I made it an effort to include _no_ quirks, weird workarounds, or compromises.

This is a **definitive, clean, and working** compilation of OpenSSL using Zig.

## Caveats

Right now, `openssl-zig` builds static libraries (`libssl.a` and `libcrypto.a`).
If you want to build dynamic or shared libraries, feel free to either fork the
repository or PR it into this repo. It should only take modifying/adding a few
lines of code.

Also, while this package has only been tested on macOS, but it is _expected_ to
work on other platforms. Make sure to submit an issue if that is not the case!

## Future Versions

In case this package ever becomes out of date or you wish to use an older
version of OpenSSL, I've written a guide for how I figured out how to write
[build.zig](./build.zig) that should help with that endeavor.

See [HOW.md](./HOW.md).

## Credits

The following two other packages gave me a good starting point for this project:

- https://github.com/glingy/openssl-zig/blob/zig-pkg/build.zig
- https://github.com/kassane/openssl-zig/blob/zig-pkg/build.zig

## License

This package is licensed under the [MIT license](./LICENSE). Note that OpenSSL
project itself has an Apache 2.0 license.
