# Building OpenSSL with Zig

This guide will primarily focus on the steps to update
[build.zig](https://github.com/dzfrias/openssl-zig/blob/main/build.zig) to work
with other versions of OpenSSL (in the case files are added/removed, build
system changes slightly, etc.).

The goal is to get the `libssl.a` and `libcrypto.a` static libraries built using
the Zig. For the best understanding of what's going on, some familiarity with
the Zig build system and static libraries is recommended.

## The OpenSSL build system

First, I'll go over how OpenSSL is built from source using their tools (they go
over this in their
[INSTALL.md](https://github.com/openssl/openssl/blob/master/INSTALL.md#installation-steps-in-detail)):

1. Run the `Configure` script at the root of the repository (using
   [Perl](https://www.perl.org/), yikes…).
2. This will generate a Makefile, so now run `make`.
3. Before building any object files, their Makefile generates a lot of files
   using Perl. Any file ending in `.c.in` or `.h.in` is fed to Perl at build
   time and turned into a `.c` or `.h`.
4. Once all files are generated, it builds the static libraries.

You can pass arguments to `Configure`; this allows you to enable/disable certain
features that are
[listed here](https://github.com/openssl/openssl/blob/master/INSTALL.md#enable-and-disable-features).

For example, `./Configure no-tests` will generate a Makefile that excludes
tests.

## Using Zig

The first thing we do when building the project with Zig is run `Configure`.
This _does_ mean we depend on the person who's building to have `perl`
installed.

We also pass in `no-apps`, `no-asm`, and `no-tests` to save a bit of work. There
might be more features we can disable that I don't know of.

### Generating other files

So far, nothing has been different compared to the way OpenSSL does things. But
unfortunately, that has to change: we need to generate the rest of the files
needed for building. OpenSSL does this in their Makefile, which we can't use
because invoking `make` would trigger `libssl.a` and `libcrypto.a` to be built.

Instead, we run `generate.sh` (in this repository), which is just one big shell
script that invokes `perl` on all the files in the OpenSSL repository that need
to be generated.

If you took a look at the file, you might wonder how I came up with the commands
to generate the files. The answer is pretty simple: I just cloned OpenSSL onto
my machine and ran `make`. They've configured `make` to be verbose, so it will
output every command that it runs. Using this output, I grepped for all the
invocations of Perl, dug around a bit to find which ones were important, and
copied that into a shell script!

### Compiling

After we run `generate.sh`, we should be good to go to compile the static
libraries. The
[`libssl`](https://github.com/dzfrias/openssl-zig/blob/00df309f14222834195c35ecbad4e84314335f13/build.zig#L52)
and
[`libcrypto`](https://github.com/dzfrias/openssl-zig/blob/00df309f14222834195c35ecbad4e84314335f13/build.zig#L166)
functions in
[build.zig](https://github.com/dzfrias/openssl-zig/blob/main/build.zig) will
compile `libssl.a` and `libcrypto.a` respectively.

Besides linking libc and setting some basic compile parameters, we need to tell
Zig two things:

1. Where to find include headers
2. Where our C sources files are

We can find these things by looking at OpenSSL itself; after all, OpenSSL also
happens to need this information to compile their static libraries. If you clone
a copy of OpenSSL onto your machine, run `Configure`, and then run `make`,
you'll probably get a lot of output lines that look something like this:

```
cc  -I. -Iinclude -Iproviders/common/include -Iproviders/implementations/include  -DBSAES_ASM -DECP_NISTZ256_ASM -DECP_SM2P256_ASM -DKECCAK1600_ASM -DMD5_ASM -DOPENSSL_BN_ASM_MONT -DOPENSSL_CPUID_OBJ -DOPENSSL_SM3_ASM -DPOLY1305_ASM -DSHA1_ASM -DSHA256_ASM -DSHA512_ASM -DSM4_ASM -DVPAES_ASM -DVPSM4_ASM -fPIC -arch arm64 -O3 -Wall -DL_ENDIAN -DOPENSSL_PIC -DOPENSSLDIR="\"/usr/local/ssl\"" -DENGINESDIR="\"/usr/local/lib/engines-3\"" -DMODULESDIR="\"/usr/local/lib/ossl-modules\"" -D_REENTRANT -DOPENSSL_BUILDING_OPENSSL -DNDEBUG  -MMD -MF crypto/ct/libcrypto-lib-ct_b64.d.tmp -c -o crypto/ct/libcrypto-lib-ct_b64.o crypto/ct/ct_b64.c
```

Most of this information isn't that meaningful, but this command tells us how
the `crypto/ct/ct_b64.c` file was compiled. Taking a look at the `-I`
parameters, we can see which directories we included. The `libcrypto` function
in [build.zig](https://github.com/dzfrias/openssl-zig/blob/main/build.zig)
matches those include parameters.

Lastly, to find the C source files necessary to make `libssl.a`, we can look at
the Makefile itself. If you grep for `libssl.a`, one line that you find might
look something like this:

```
$(AR) $(ARFLAGS) libssl.a ssl/libssl-lib-bio_ssl.o ssl/libssl-lib-d1_lib.o ssl/libssl-lib-d1_msg.o ssl/libssl-lib-d1_srtp.o ...
```

This is a big list of object files that are used to make the static library (you
can ignore the `$(AR)` and `$(ARFLAGS)`). Notice how all files have the
`libssl-lib` prefix and have the object file extension. By removing the prefix
and replacing `.o` with `.c`, we can get the original C source file that was
used.

For example, `ssl/libssl-lib-bio_ssl.o` is actually `ssl/bio_ssl.c`. This is how
we get the source files list found in the `libssl` function.

## Wrap Up

Future versions of OpenSSL will most likely have changes, and the addition of a
file into the upstream OpenSSL source code will break this.
[build.zig.zon](https://github.com/dzfrias/openssl-zig/blob/main/build.zig.zon)
thus fixes our compilation to version `3.4.0` so that this will never break.

However, if you're looking to use `3.5.0` or something, you can use the ideas of
this guide to hopefully make it less painful of a process.
