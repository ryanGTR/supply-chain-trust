#!/usr/bin/env bash
# Appendix A, example 2: build once, promote the SAME bytes, verify at every gate.
#
# Companion to Chapter 7 (artifact signing). Everything runs locally with
# coreutils + openssl; no network access, no long-lived keys (workdir is a
# throwaway temp directory, cleaned up on exit).
#
# Model: build -> record digest -> sign the digest -> "promote" (copy) the
# artifact through test/uat/prod -> re-verify digest+signature at each gate ->
# tamper in prod and watch the gate reject -> rebuild and watch digests differ.
#
# Predict before you run:
#   1. After promoting (copying) the artifact, does the signature made at
#      build time still verify, or must each environment re-sign?
#   2. Rebuilding from the exact same source: same digest, or different?
set -euo pipefail

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT
cd "$workdir"

echo "== 1. 'Source code' and a build step =="
mkdir -p src registry test uat prod
printf 'int main(void) { return 42; }\n' > src/app.c
build() {
	# simulate a real-world build: package the source, then append build
	# metadata (a nanosecond timestamp) -- the typical source of
	# NON-reproducibility in real build systems
	tar -cf "$1" -C src app.c
	printf 'built-at: %s\n' "$(date +%s%N)" >> "$1"
}
build registry/app.tar
echo "artifact built: registry/app.tar"

echo "== 2. Record the digest (content-addressed identity) =="
digest=$(sha256sum registry/app.tar | cut -d' ' -f1)
printf '%s\n' "$digest" > registry/app.digest
echo "digest: $digest"

echo "== 3. Sign the DIGEST at build time (Chapter 2 pattern, one signature) =="
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out private.pem 2>/dev/null
openssl pkey -in private.pem -pubout -out public.pem
openssl dgst -sha256 -sign private.pem -out registry/app.digest.sig registry/app.digest
echo "signed once, at build time; environments get artifact + digest + signature"

# The deploy gate every environment runs: recompute digest, compare with the
# recorded one, then verify the signature over the digest record. Fail-closed.
gate() {
	local env="$1"
	local actual
	actual=$(sha256sum "$env/app.tar" | cut -d' ' -f1)
	if [ "$actual" != "$(cat "$env/app.digest")" ]; then
		echo "[$env] REJECTED: digest mismatch (expected $(cat "$env/app.digest"), got $actual)"
		return 1
	fi
	if ! openssl dgst -sha256 -verify public.pem \
			-signature "$env/app.digest.sig" "$env/app.digest" >/dev/null 2>&1; then
		echo "[$env] REJECTED: signature over digest record does not verify"
		return 1
	fi
	echo "[$env] PASS: digest matches and signature verifies -- deploy allowed"
}

echo "== 4. Promote: copy the same bytes through test -> uat -> prod =="
for env in test uat prod; do
	cp registry/app.tar registry/app.digest registry/app.digest.sig "$env/"
	gate "$env"
done
echo "three environments, ONE digest, ONE build-time signature -- no re-signing"

echo "== 5. Tamper in prod: flip one byte, the gate must catch it =="
printf 'X' | dd of=prod/app.tar bs=1 seek=20 conv=notrunc status=none
if gate prod; then
	echo "UNEXPECTED: gate passed on tampered artifact" >&2
	exit 1
else
	echo "one flipped byte in prod broke the digest -- promotion chain is intact"
fi

echo "== 6. Anti-pattern: 'just rebuild it in prod' instead of promoting =="
build registry/app-rebuild.tar
digest2=$(sha256sum registry/app-rebuild.tar | cut -d' ' -f1)
echo "original build: $digest"
echo "rebuild:        $digest2"
if [ "$digest" = "$digest2" ]; then
	echo "UNEXPECTED: rebuild reproduced the same digest" >&2
	exit 1
else
	echo "same source, different digest: what you tested is NOT what you would ship"
fi

# Answers to the predictions:
#   1. STILL VERIFIES. The signature covers the digest, and the digest is
#      determined only by the bytes. Copying preserves the bytes, so one
#      build-time signature is valid at every gate -- no per-env re-signing.
#   2. DIFFERENT. Build metadata (timestamps etc.) makes rebuilds produce
#      different bytes, hence different digests. That is exactly why you
#      promote the artifact instead of rebuilding it per environment.
echo "== done =="
