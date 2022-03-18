#!/usr/bin/env sh
#
TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-/opt/homebrew/Cellar/openssl\@1.1/1.1.1m/bin/openssl}

# Create a 'staat der nederlanden' root certificate that looks like
# the real thing. 
#
if test -f ca.key; then
	echo You propably want to run this script only once.
	exit 1
fi

$OPENSSL req -x509 -days 365 -new \
	-out ca.pem -keyout ca.key -nodes \
	-subj '/CN=Staat der Nederlanden Root CA - G3/O=Staat der Nederlanden/C=NL'

cat > ext.cnf.$$ <<EOM
[ subca ]
keyUsage = cRLSign, keyCertSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:TRUE
EOM

# Create the chain to a normal PKI leaf cert
#
$OPENSSL req -new -keyout sub-ca.key -nodes \
	-subj '/C=NL/O=Staat der Nederlanden/CN=Staat der Nederlanden Organisatie - Services G3' |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions subca \
	-req -days 365 -CAkey ca.key -CA ca.pem -set_serial 1010 -out sub-ca.pem

rm ext.cnf.$$

cat ca.pem sub-ca.pem  > full-chain.pem 
cat sub-ca.pem  > chain.pem 

# Create the root cert to import into keychain - in all formats
#
openssl x509 -in ca.pem -out ca.crt -outform DER
openssl pkcs12 -export -out ca.pfx -in ca.pem -cacerts -nodes -nokeys -passout pass:corona2020
openssl crl2pkcs7 -nocrl -certfile ca.pem -certfile sub-ca.pem -out chain.p7b

hostname=${1:-client}

cat > ext.cnf.$$ <<EOM
[ leaf ]
nsComment = For testing only and no this is not the real thing. Duh.
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:FALSE
EOM

SUBJ="/C=NL/O=Ministerie van Volksgezondheid, Welzijn en Sport/OU=Corona Alerters/CN=$client.coronatester.nl"
$OPENSSL req -new -keyout client.key -nodes -subj "${SUBJ}" |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions leaf \
	-req -days 365 -CAkey sub-ca.key -CA sub-ca.pem -set_serial 0xdeadbeefdeadbeefc0de -out client.pub
rm ext.cnf.$$

cat client.key client.pub > client.crt
openssl pkcs12 -export -out client.pfx -in client.pub -inkey client.key -certfile full-chain.pem -nodes -passout pass:corona2020
