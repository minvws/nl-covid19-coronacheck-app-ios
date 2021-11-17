#!/bin/sh
cat 1000.pem 1001.pem > chain.pem                    
echo
echo verify that the sever runs with
echo
echo "  false | openssl s_client -connect api-ct.bananenhalen.nl:4433 -showcerts -CAfile ca.pem"
echo
echo You should see a \"Verify return code: 0 \(ok\)\" near the end.
echo
openssl s_server -cert 1002.pem -cert_chain chain.pem -WWW
