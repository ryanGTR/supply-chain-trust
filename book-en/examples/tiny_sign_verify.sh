#!/usr/bin/env bash
# Appendix A, example 1: sign a file, flip ONE byte, watch verification fail.
#
# Companion to Chapter 2 (digital signature). Everything runs locally with
# openssl; no network access, no long-lived keys (workdir is a throwaway
# temp directory, cleaned up on exit).
#
# Predict before you run:
#   1. After flipping a single byte, does verification fail SOMETIMES or ALWAYS?
#   2. Will the error message tell you WHICH byte was changed?
set -euo pipefail

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"

echo "== 1. Generate an RSA key pair (private + public) =="
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out private.pem 2>/dev/null
openssl pkey -in private.pem -pubout -out public.pem

echo "== 2. Create a document and sign it (SHA-256 digest, then RSA) =="
printf 'transfer 100 dollars to account B\n' > doc.txt
# "-sha256 -sign" = hash first, then sign the digest with the PRIVATE key
# (this is the SHA256withRSA pattern from Chapter 2)
openssl dgst -sha256 -sign private.pem -out doc.sig doc.txt

echo "== 3. Verify with the PUBLIC key (should succeed) =="
openssl dgst -sha256 -verify public.pem -signature doc.sig doc.txt

echo "== 4. Flip ONE byte: change amount '100' -> '900' =="
# byte offset 9 is the character '1' in '100'; overwrite it with '9'
printf '9' | dd of=doc.txt bs=1 seek=9 conv=notrunc status=none
echo "tampered document: $(cat doc.txt)"

echo "== 5. Verify again (should FAIL) =="
if openssl dgst -sha256 -verify public.pem -signature doc.sig doc.txt; then
        echo "UNEXPECTED: verification passed on tampered data" >&2
        exit 1
else
        echo "verification failed as expected: one flipped byte broke the signature"
fi

# Answers to the predictions:
#   1. ALWAYS. Hash avalanche effect: one changed bit produces a completely
#      different SHA-256 digest, which cannot match the signed digest.
#   2. NO. Verification is all-or-nothing -- it says "Failure", never where.
#      A signature tells you THAT the content changed, not WHERE.
echo "== done =="
