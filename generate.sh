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
# last updated for OpenSSL 3.6.0

# Exit immediately when a command errors
set -e

# Since Zig might've cached an old build, we can use this to check and not
# re-generate all the files. Just checking if the generated ssl.h exists _should_ be
# enough, since cache invalidation isn't really possible.
#
# The user might get some nasty errors if they delete something that's not a
# generated file in the Zig cache, though...
if [ ! -e "include/openssl/ssl.h" ]; then
  # First run Configure if Makefile doesn't exist
  if [ ! -e "Makefile" ]; then
    perl Configure no-apps no-asm no-tests
  fi

  # Now generate the header files and source files from .in templates.

  # Generate include/crypto headers
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/crypto/bn_conf.h.in > include/crypto/bn_conf.h
  perl "-I." "-Mconfigdata" "util/dofile.pl" "-oMakefile" include/crypto/dso_conf.h.in > include/crypto/dso_conf.h

  # Generate include/openssl headers
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

  # Generate providers/common/der source files
  # Note: -Iutil/perl is needed for OpenSSL::OID which is used by oids_to_c.pm
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_digests_gen.c.in > providers/common/der/der_digests_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_dsa_gen.c.in > providers/common/der/der_dsa_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_ec_gen.c.in > providers/common/der/der_ec_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_ecx_gen.c.in > providers/common/der/der_ecx_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_hkdf_gen.c.in > providers/common/der/der_hkdf_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_ml_dsa_gen.c.in > providers/common/der/der_ml_dsa_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_rsa_gen.c.in > providers/common/der/der_rsa_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_slh_dsa_gen.c.in > providers/common/der/der_slh_dsa_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Moids_to_c" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_wrap_gen.c.in > providers/common/der/der_wrap_gen.c
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/der/der_sm2_gen.c.in > providers/common/der/der_sm2_gen.c

  # Generate providers/implementations/include/prov headers
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/include/prov/blake2_params.inc.in > providers/implementations/include/prov/blake2_params.inc

  # Generate providers/common/include/prov headers
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_digests.h.in > providers/common/include/prov/der_digests.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_dsa.h.in > providers/common/include/prov/der_dsa.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_ec.h.in > providers/common/include/prov/der_ec.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_ecx.h.in > providers/common/include/prov/der_ecx.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_hkdf.h.in > providers/common/include/prov/der_hkdf.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_ml_dsa.h.in > providers/common/include/prov/der_ml_dsa.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_rsa.h.in > providers/common/include/prov/der_rsa.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_slh_dsa.h.in > providers/common/include/prov/der_slh_dsa.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Moids_to_c" "-Moids_to_c" "-Mconfigdata" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_wrap.h.in > providers/common/include/prov/der_wrap.h
  perl "-I." "-Iutil/perl" "-Iproviders/common/der" "-Mconfigdata" "-Mconfigdata" "-Moids_to_c" "util/dofile.pl" "-oMakefile" providers/common/include/prov/der_sm2.h.in > providers/common/include/prov/der_sm2.h

  # Generate providers/implementations source files that have .in templates
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/asymciphers/rsa_enc.c.in > providers/implementations/asymciphers/rsa_enc.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/asymciphers/sm2_enc.c.in > providers/implementations/asymciphers/sm2_enc.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/ciphers/cipher_chacha20_poly1305.c.in > providers/implementations/ciphers/cipher_chacha20_poly1305.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/ciphers/ciphercommon.c.in > providers/implementations/ciphers/ciphercommon.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/ciphers/ciphercommon_ccm.c.in > providers/implementations/ciphers/ciphercommon_ccm.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/ciphers/ciphercommon_gcm.c.in > providers/implementations/ciphers/ciphercommon_gcm.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/digests/blake2_prov.c.in > providers/implementations/digests/blake2_prov.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/digests/digestcommon.c.in > providers/implementations/digests/digestcommon.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/digests/sha3_prov.c.in > providers/implementations/digests/sha3_prov.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/encode_decode/decode_der2key.c.in > providers/implementations/encode_decode/decode_der2key.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/encode_decode/decode_epki2pki.c.in > providers/implementations/encode_decode/decode_epki2pki.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/encode_decode/decode_pem2der.c.in > providers/implementations/encode_decode/decode_pem2der.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/encode_decode/decode_pvk2key.c.in > providers/implementations/encode_decode/decode_pvk2key.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/encode_decode/decode_spki2typespki.c.in > providers/implementations/encode_decode/decode_spki2typespki.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/encode_decode/encode_key2any.c.in > providers/implementations/encode_decode/encode_key2any.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/encode_decode/encode_key2ms.c.in > providers/implementations/encode_decode/encode_key2ms.c

  # Generate providers/implementations/exchange source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/exchange/dh_exch.c.in > providers/implementations/exchange/dh_exch.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/exchange/ecdh_exch.c.in > providers/implementations/exchange/ecdh_exch.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/exchange/ecx_exch.c.in > providers/implementations/exchange/ecx_exch.c

  # Generate providers/implementations/kdfs source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/argon2.c.in > providers/implementations/kdfs/argon2.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/hkdf.c.in > providers/implementations/kdfs/hkdf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/hmacdrbg_kdf.c.in > providers/implementations/kdfs/hmacdrbg_kdf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/kbkdf.c.in > providers/implementations/kdfs/kbkdf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/krb5kdf.c.in > providers/implementations/kdfs/krb5kdf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/pbkdf2.c.in > providers/implementations/kdfs/pbkdf2.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/pkcs12kdf.c.in > providers/implementations/kdfs/pkcs12kdf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/scrypt.c.in > providers/implementations/kdfs/scrypt.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/sshkdf.c.in > providers/implementations/kdfs/sshkdf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/sskdf.c.in > providers/implementations/kdfs/sskdf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/tls1_prf.c.in > providers/implementations/kdfs/tls1_prf.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kdfs/x942kdf.c.in > providers/implementations/kdfs/x942kdf.c

  # Generate providers/implementations/kem source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kem/ec_kem.c.in > providers/implementations/kem/ec_kem.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kem/ecx_kem.c.in > providers/implementations/kem/ecx_kem.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kem/ml_kem_kem.c.in > providers/implementations/kem/ml_kem_kem.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/kem/rsa_kem.c.in > providers/implementations/kem/rsa_kem.c

  # Generate providers/implementations/keymgmt source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/keymgmt/ecx_kmgmt.c.in > providers/implementations/keymgmt/ecx_kmgmt.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/keymgmt/ml_dsa_kmgmt.c.in > providers/implementations/keymgmt/ml_dsa_kmgmt.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/keymgmt/ml_kem_kmgmt.c.in > providers/implementations/keymgmt/ml_kem_kmgmt.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/keymgmt/slh_dsa_kmgmt.c.in > providers/implementations/keymgmt/slh_dsa_kmgmt.c

  # Generate providers/implementations/macs source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/macs/cmac_prov.c.in > providers/implementations/macs/cmac_prov.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/macs/gmac_prov.c.in > providers/implementations/macs/gmac_prov.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/macs/hmac_prov.c.in > providers/implementations/macs/hmac_prov.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/macs/kmac_prov.c.in > providers/implementations/macs/kmac_prov.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/macs/poly1305_prov.c.in > providers/implementations/macs/poly1305_prov.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/macs/siphash_prov.c.in > providers/implementations/macs/siphash_prov.c

  # Generate providers/implementations/rands source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/rands/drbg_ctr.c.in > providers/implementations/rands/drbg_ctr.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/rands/drbg_hash.c.in > providers/implementations/rands/drbg_hash.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/rands/drbg_hmac.c.in > providers/implementations/rands/drbg_hmac.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/rands/seed_src.c.in > providers/implementations/rands/seed_src.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/rands/seed_src_jitter.c.in > providers/implementations/rands/seed_src_jitter.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/rands/test_rng.c.in > providers/implementations/rands/test_rng.c

  # Generate providers/implementations/signature source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/signature/dsa_sig.c.in > providers/implementations/signature/dsa_sig.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/signature/ecdsa_sig.c.in > providers/implementations/signature/ecdsa_sig.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/signature/eddsa_sig.c.in > providers/implementations/signature/eddsa_sig.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/signature/ml_dsa_sig.c.in > providers/implementations/signature/ml_dsa_sig.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/signature/rsa_sig.c.in > providers/implementations/signature/rsa_sig.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/signature/slh_dsa_sig.c.in > providers/implementations/signature/slh_dsa_sig.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/signature/sm2_sig.c.in > providers/implementations/signature/sm2_sig.c

  # Generate providers/implementations/storemgmt source files
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/storemgmt/file_store.c.in > providers/implementations/storemgmt/file_store.c
  perl "-I." "-Iutil/perl" "-Mconfigdata" "-MOpenSSL::paramnames" "util/dofile.pl" "-oMakefile" providers/implementations/storemgmt/file_store_any2obj.c.in > providers/implementations/storemgmt/file_store_any2obj.c
fi

platform="$(grep PLATFORM= < Makefile)"
# We should generate a buildinf.h upon every build, since it includes
# meta-information related to the time of the build.
perl util/mkbuildinf.pl "TODO" "$platform" > crypto/buildinf.h

cd "$old_wd"
# Copy all include directories into the output directory.
cp -R "$upstream/include" "$include_out"

echo Files were successfully generated
