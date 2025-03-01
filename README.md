# openssl-zig

`openssl-zig` is a Zig package for a compilation of
[OpenSSL](https://github.com/openssl/openssl) version 3.4.0 using Zig 0.13.0.

While there are other packages that aim to do the same thing, my goal for this
project was to build OpenSSL is the cleanest way possible, without workarounds
or anything of that sort. Thus, I spent a long time studying OpenSSL's original
build method with the goal of recreating it as _closely as possible_ using Zig.

## Caveats

Right now, `openssl-zig` builds static libraries (`libssl.a` and `libcrypto.a`).
If you want to build dynamic or shared libraries, feel free to either fork the
repository or PR it into this repo. It should only take modifying/adding a few
lines of code.

Also, while this package has only been tested on macOS, but it is _expected_ to
work on other platforms. Make sure to submit an issue if that is not the case!

## Usage

Add this to your `build.zig.zon`:

```zig
.dependencies = .{
    .string = .{
        .url = "https://github.com/dzfrias/openssl-zig/archive/refs/heads/main.tar.gz",
        // The correct hash will be suggested after a compilation attempt
    }
}
```

Then, modify your `build.zig` to contain the following:

```zig
const openssl = b.dependency("openssl", .{ .target = target, .optimize = optimize });
exe.root_module.linkLibrary(openssl.artifact("ssl"));
exe.root_module.linkLibrary(openssl.artifact("crypto"));
```

This will link `libssl.a` and `libcrypto.a`, and they will then be usable in
source files using `@cImport`. For example:

```zig
const c = @cImport({
    @cInclude("openssl/ssl.h");
    @cInclude("openssl/err.h");
});
```

Note that Zig will _not_ translate all functions correctly. For instance, if you
try to use
[`SSL_library_init()`](https://docs.openssl.org/3.1/man3/SSL_library_init/), you
will get a compilation error that can't be fixed by this package (it is a bug in
the Zig compiler as of 0.14.0). Fortunately, for that specific case,
`SSL_library_init` has been superseded by
[`OPENSSL_init_ssl`](https://docs.openssl.org/master/man3/OPENSSL_init_ssl/),
which does compile correctly.

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
