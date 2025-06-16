#!/bin/sh

upstream="$1"
# Out directory for header files (openssl/ssl, openssl/crypto, openssl/internal)
include_out="$2"

old_wd=$(pwd)
# Build commands should be relative to the upstream (cloned) OpenSSL release.
# We will go back to $old_wd after building.
cd "$upstream"

# OpenSSL often uses perl to generate files at build time. This includes code
# files. This script will invoke perl to generate said files.
#
# See HOW.md for more details.

# Exit immediately when a command errors
set -e

# Since Zig might've cached an old build, we can use this to check and not 
# re-generate all the files. Just checking if the Makefile exists _should_ be
# enough, since cache invalidation isn't really possible.
#
# The user might get some nasty errors if they delete something that's not the
# Makefile in the Zig cache, though...
if [ ! -e "Makefile" ]; then
  perl Configure no-apps no-asm no-tests

  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" crypto/params_idx.c.in > crypto/params_idx.c
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/crypto/bn_conf.h.in > include/crypto/bn_conf.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/crypto/dso_conf.h.in > include/crypto/dso_conf.h
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" include/internal/param_names.h.in > include/internal/param_names.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/asn1.h.in > include/openssl/asn1.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/asn1t.h.in > include/openssl/asn1t.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/bio.h.in > include/openssl/bio.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/cmp.h.in > include/openssl/cmp.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/cms.h.in > include/openssl/cms.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/comp.h.in > include/openssl/comp.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/conf.h.in > include/openssl/conf.h
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" include/openssl/core_names.h.in > include/openssl/core_names.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/crmf.h.in > include/openssl/crmf.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/crypto.h.in > include/openssl/crypto.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/ct.h.in > include/openssl/ct.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/err.h.in > include/openssl/err.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/ess.h.in > include/openssl/ess.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/fipskey.h.in > include/openssl/fipskey.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/lhash.h.in > include/openssl/lhash.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/ocsp.h.in > include/openssl/ocsp.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/opensslv.h.in > include/openssl/opensslv.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/pkcs12.h.in > include/openssl/pkcs12.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/pkcs7.h.in > include/openssl/pkcs7.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/safestack.h.in > include/openssl/safestack.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/srp.h.in > include/openssl/srp.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/ssl.h.in > include/openssl/ssl.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/ui.h.in > include/openssl/ui.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/x509.h.in > include/openssl/x509.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/x509_acert.h.in > include/openssl/x509_acert.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/x509_vfy.h.in > include/openssl/x509_vfy.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/openssl/x509v3.h.in > include/openssl/x509v3.h
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_digests.h.in > providers/common/include/prov/der_digests.h
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_rsa.h.in > providers/common/include/prov/der_rsa.h
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Moids_to_c" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_wrap.h.in > providers/common/include/prov/der_wrap.h
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_digests_gen.c.in > providers/common/der/der_digests_gen.c
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_rsa_gen.c.in > providers/common/der/der_rsa_gen.c
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Moids_to_c" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_wrap_gen.c.in > providers/common/der/der_wrap_gen.c
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_sm2_gen.c.in > providers/common/der/der_sm2_gen.c
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_sm2.h.in > providers/common/include/prov/der_sm2.h
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_dsa_gen.c.in > providers/common/der/der_dsa_gen.c
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_dsa.h.in > providers/common/include/prov/der_dsa.h
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_ec_gen.c.in > providers/common/der/der_ec_gen.c
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_ec.h.in > providers/common/include/prov/der_ec.h
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_ecx_gen.c.in > providers/common/der/der_ecx_gen.c
  perl "-I." "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_ecx.h.in > providers/common/include/prov/der_ecx.h
fi

platform="$(grep PLATFORM= < Makefile)"
# We should generate a buildinf.h upon every build, since it includes
# meta-information related to the time of the build.
perl util/mkbuildinf.pl "TODO" "$platform" > crypto/buildinf.h

cd "$old_wd"
# Copy all include directories into the output directory.
cp -R "$upstream/include" "$include_out"

echo Files were successfully generated
