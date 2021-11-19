#!/bin/sh

set -e

if [ $# -gt 2 ]; then
	echo "Syntax: $0 [example.json [client.crt]]"
	exit 1
fi
OPENSSL=${OPENSSL:-/usr/local/Cellar/openssl\@1.1/1.1.1l_1/bin/openssl}
JSON=${1:-example.json}
CERT=${2:-client.crt}

if $OPENSSL version | grep -q LibreSSL; then
	echo Sorry - OpenSSL is needed.
	exit 1
fi

if ! $OPENSSL version | grep -q 1\.; then
	echo Sorry - OpenSSL 1.0 or higher is needed.
	exit 1
fi

if [ $# -lt 2 -a ! -e client.crt ]; then
	. ./gen-fake-pki-overheid.sh
fi

JSON_B64=$(base64 "$JSON")

# We avoid using echo (shell and /bin echo behave differently) as to 
# get control over the trialing carriage return.

SIG_B64=$($OPENSSL cms -in "$JSON" -sign -outform DER -signer "$CERT" -certfile chain.pem -binary  -keyopt rsa_padding_mode:pss | base64)

cat <<EOM
{
	"payload": "$JSON_B64",
	"signature": "$SIG_B64"
}
EOM

