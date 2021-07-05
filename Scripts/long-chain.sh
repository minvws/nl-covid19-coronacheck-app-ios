#!/usr/bin/env sh
#
# Used to generate a very long chain for the test/example cases
#
#

TMPDIR=${TMPDIR:-/tmp}
set -e

OPENSSL=${OPENSSL:-openssl}
JSON=${1:-example.json}

S=0
$OPENSSL req -x509 -new \
	-out 0.pem -keyout 0.key -nodes \
	-subj '/CN=CA'

cat > ext.cnf.$$ <<EOM
[ subca ]
nsComment = For testing only and no this is not the real thing. Duh.
keyUsage = cRLSign, keyCertSign
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:TRUE
EOM

for ss in 1 2 3 4 5 6 7 8 9
do
$OPENSSL req -new -keyout $ss.key -nodes \
	-subj "/CN=$ss deep" |
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions subca \
	-req -CAkey $S.key -CA $S.pem -set_serial 1000$s -out $ss.pem
	S=$ss
done

rm ext.cnf.$$

cat [0123456789].pem  > chain.pem 
rm  [012345678].key
rm   [12345678].pem

cat > ext.cnf.$$ <<EOM
[ leaf ]
nsComment = For testing only and no this is not the real thing. Duh.
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer
basicConstraints = CA:FALSE
EOM

SUBJ="/CN=leaf"
$OPENSSL req -new -keyout client.key -nodes -subj "${SUBJ}" |\
$OPENSSL x509 \
	-extfile  ext.cnf.$$ -extensions leaf \
	-req -CAkey $S.key -CA $S.pem -set_serial 0xdeadbeefdeadbeefc0de -out client.pub
rm ext.cnf.$$

cat client.key client.pub > client.crt
rm client.key client.pub 9.pem 9.key

CA_B64=$(base64 0.pem)
JSON_B64=$(base64 "$JSON")

# We avoid using echo (shell and /bin echo behave differently) as to 
# get control over the trialing carriage return.

SIG_B64=$($OPENSSL cms -in "$JSON" -sign -outform DER -signer client.crt -certfile chain.pem -binary  -keyopt rsa_padding_mode:pss | base64)

KEYID=$(openssl x509 -in client.crt -ext authorityKeyIdentifier -noout | sed -e 's/.*Identifier://' -e 's/keyid/0x04, 0x14/g' -e 's/:/, 0x/g')

echo "trusted=\"$CA_B64\";"
echo "keyid=[$KEYID];"
echo "payload=\"$JSON_B64\";"
echo "signature=\"$SIG_B64\";"
