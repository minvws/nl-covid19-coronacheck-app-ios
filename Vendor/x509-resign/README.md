# Resign X.509 certificates 'in situ'

Utility to resign an existing x509 certificate 'as is' -- keeping as much of the metadata and X509v3 extensions the same. But change the Authority/Subject key identifiers, swap out the public key and resign. 

Useful for making test sets based on 'real' certificates taken from the wild.

Use with care.

## syntax

    Syntax resign [-f] [-d <days>] [-K | -k <replacementKey>] [-v] [-p <password>] [CertToResign [CA [CAkey]]]
    
      -d     Reset the fromdate to today (default is to leave as is).
      -S      Do not change the issuer; leave as is (default is to change to subject of signing cert).
      -d num  Set the validity to <days> from now (default is 10).
      -v      Verbose.
      -p      Use specific replacement key.
      -K      Regenerate a pub/priv keypair to replace existing, and output private key (in the clear).
      -p str  Password for the private key of the CA. The default is '1234'.
      -i,-s   Prevent any changes to the subjectKeyIdentifier or the issuerKeyIdentifier. Useful to check 
              if pinning is done correctly.

    CertToResign
        Certificate that will be resigned. May contain a key.

    CA (optional)
        Certificate used to resign above; when not present the CertToResign is
        used (i.e. a self singed cert is created).

    CAkey (optional)
        CA key if not present in the CA file itself.

    Use a '-' for stdin.

## Hi Profile / Dutch UZI passes

Part of this utility was developed as part of the HiProfile project of the European commission.
