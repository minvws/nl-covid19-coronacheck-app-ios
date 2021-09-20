/* Copyright (c) 2003-2006, 2012, 2021 Dirk-Willem van Gulik <dirkx(a)apache(dot)org>
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

#include <openssl/conf.h>
#include <openssl/ossl_typ.h>

#include <openssl/pem.h>
#include <openssl/bio.h>
#include <openssl/bn.h>

#include <openssl/asn1.h>
#include <openssl/rand.h>

#include <openssl/x509.h>
#include <openssl/x509v3.h>

#include <openssl/bnerr.h>
#include <openssl/err.h>

#include <unistd.h>
#include <string.h>


int verbose = 0;
const char * passwd = "1234";

const char * password_callback() {
	return passwd;
}

static int req_cb(int p, int n, BN_GENCB *cb)
        {
        char c='*';
        if (p == 0) c='.';
        if (p == 1) c='+';
        if (p == 2) c='*';
        if (p == 3) c='\n';
        // BIO_write(cb->arg,&c,1);
        // (void)BIO_flush(cb->arg);
        return 1;
        }

void usage(char * prog) {
	fprintf(stderr,"Syntax %s [-F] [-d <days>] [-K | -k <replacementKey>] [-v] [-p <password>] [CertToResign [CA [CAkey]]]\n" \
"\n" \
"	-F	Reset the fromdate to today (default is to leave as is).\n" \
"	-S	Do not change the issuer; leave as is (default is to change to subject of signing cert).\n" \
"	-s      Keep the subject key identifier the same\n" \
"	-i      Keep the identifier key identifier the same\n" \
"	-d num	Set the validity to <days> from now (default is 10).\n" \
"	-v 	Verbose.\n" \
"	-p	Use specific replacement key.\n" \
"	-K	Regenerate a pub/priv keypair to replace existing, and output private key (in the clear).\n" \
"	-p str	Password for the private key of the CA. (the default is '%s').\n" \
"\n" \
"	CertToResign\n" \
"	Certificate that will be resigned. May contain a key.\n"\
"\n"\
"	CA (optional)\n" \
"	Certificate used to resign above; when not present the CertToResign is\n"\
"	used (i.e. a self singed cert is created).\n" \
"\n"\
"	CAkey (optional)\n" \
"	CA key if not present in the CA file itself.\n" \
"\n"\
"	Use a '-' for stdin.\n" , prog, passwd);
	exit(1);
}

#define assertOrBail(x) { if (!(x)) { BIO_printf(err, "Fatal Error (%s:%d)\n",__FILE__,__LINE__); ERR_print_errors(err); exit(1); }; }

int main(int argc, char ** argv) {

	X509 * cert = NULL;
	X509 * ca = NULL;
	EVP_PKEY *pkey = NULL;
	EVP_PKEY *newkey = NULL;
	BIO *bio, * err, * ver;

        err=BIO_new(BIO_s_file());
	BIO_set_fp(err,stderr,BIO_NOCLOSE|BIO_FP_TEXT);

        ver=BIO_new(BIO_s_file());
	BIO_set_fp(ver,stderr,BIO_NOCLOSE|BIO_FP_TEXT);

        bio=BIO_new(BIO_s_file());
	ERR_load_crypto_strings();

	extern char *optarg;
	extern int optind, optopt;
	int c, regen = 0;
	char * rekeyfile = NULL;

	int ftime = 0;
	int days = 0;
	int subject = 1;
	int changeski = 1;
	int changeiid = 1;

    	while ((c = getopt(argc, argv, "d:FSvKk:p:si")) != -1) {
	 	switch(c) {
        	case 'F':
			ftime = 1;
			break;
        	case 'S':
			subject = 0;
			break;
        	case 's':
			changeski = 0;
			break;
        	case 'i':
			changeiid = 0;
			break;
        	case 'd':
			days = atoi(optarg);
			break;
        	case 'v':
			verbose++;
			break;
		case 'K':
			if (rekeyfile) usage(argv[0]);
			regen = 1;
			break;
		case 'k':
			rekeyfile = optarg;
			if (regen) usage(argv[0]);
			break;
		case 'p':
			passwd = optarg;
			break;
		default:
			usage(argv[0]);
			break;
		}
	};
			
	if (rekeyfile) {
		if (strcmp(rekeyfile,"-")) {
			if (BIO_read_filename(bio,rekeyfile)<0) {
				BIO_printf(err, "Error opening replacement key: %s\n", rekeyfile);
                       	 	ERR_print_errors(err);
				exit(1);
                 	};
			if (verbose)
				BIO_printf(ver,"Reading replacement key from %s\n", rekeyfile);
		} else {
                	BIO_set_fp(bio,stdin,BIO_NOCLOSE);
			if (verbose)
				BIO_printf(ver,"Reading replacement key from stdin\n");
		};
		if (!(PEM_read_bio_PrivateKey(bio, &newkey,(pem_password_cb *)password_callback, NULL))) {
			BIO_printf(err, "Error reading replacement key.\n");
               		ERR_print_errors(err);
               		exit(1);
		};
	}

	if (optind < argc && strcmp(argv[optind],"-")) {
		if (BIO_read_filename(bio,argv[optind])<0) {
			BIO_printf(err, "Error opening Cert: %s\n", argv[optind]);
                        ERR_print_errors(err);
			exit(1);
                };
		if(verbose)
			BIO_printf(ver,"Reading cert from %s.\n", argv[optind]);
		optind++;
	} else {
		if(verbose)
			BIO_printf(ver,"Reading cert from stdin.\n");
                BIO_set_fp(bio,stdin,BIO_NOCLOSE);
	};

	if (!(cert = PEM_read_bio_X509_AUX(bio, &cert, (pem_password_cb *)password_callback, NULL))) {
		BIO_printf(err, "Error reading %s\n", argv[1]);
                ERR_print_errors(err);
                exit(1);
	};

	if (regen) {
		EVP_PKEY * oldkey = X509_PUBKEY_get0(X509_get_X509_PUBKEY(cert));
		EVP_PKEY_CTX * pctx;

                assertOrBail(pctx = EVP_PKEY_CTX_new(oldkey,NULL));
                assertOrBail(newkey = EVP_PKEY_new());

		if (verbose) {
			ASN1_PCTX * actx= ASN1_PCTX_new();
			BIO_printf(ver,"Regenerating keypair - can take a bit. ot time\nSpecification:\n");
			EVP_PKEY_print_params(ver, oldkey, 4, actx);
			ASN1_PCTX_free(actx);
		};

		BN_GENCB * cb = BN_GENCB_new();
		BN_GENCB_set(cb, req_cb, err);
	
		char buff[PATH_MAX];
		const char * rndfile = RAND_file_name(buff,sizeof(buff));
		assertOrBail(RAND_load_file(rndfile,-1));

                if (!EVP_PKEY_keygen_init(pctx)) {
			BIO_printf(err, "Error EVP_PKEY_keyge_init: ");
               		ERR_print_errors(err);
               		exit(1);
		};

		/* if it is an RSA key - manually set the key length - as that does not seem to get copied.
		 */
		if(EVP_PKEY_id(oldkey)== EVP_PKEY_RSA) {
			RSA * rsa = EVP_PKEY_get0_RSA(oldkey);
			int bits = RSA_bits(rsa);
			if (verbose)
				BIO_printf(ver,"Forcing RSA size to %d bits\n", bits);
			assertOrBail(EVP_PKEY_CTX_set_rsa_keygen_bits(pctx, RSA_bits(rsa)));
		};
                if (!EVP_PKEY_keygen(pctx,&newkey)) {
			BIO_printf(err, "Error EVP_PKEY_keygen_gen: ");
               		ERR_print_errors(err);
               		exit(1);
		};
                BN_GENCB_free(cb);
                EVP_PKEY_CTX_free(pctx);

		assertOrBail(X509_set_pubkey(cert, newkey));
	};


	if (optind < argc) {
		bio=BIO_new(BIO_s_file());
		if (strcmp(argv[optind],"-")) {
			if (BIO_read_filename(bio,argv[optind])<0) {
				BIO_printf(err, "Error opening CA: %s\n", argv[optind]);
                       	 	ERR_print_errors(err);
				exit(1);
			};
			if (verbose)
				BIO_printf(ver,"Reading CA from %s.\n", argv[optind]);
		} else {
			if (verbose)
				BIO_printf(ver,"Reading CA from stdin.\n");
			BIO_set_fp(bio,stdin,BIO_NOCLOSE);
		}
		if (!(PEM_read_bio_X509_AUX(bio, &ca, (pem_password_cb *)password_callback, NULL))) {
			BIO_printf(err, "Error reading CA: %s\n", argv[optind]);
                	ERR_print_errors(err);
                	exit(1);
		};
		optind++;
	} else {
		if (verbose)
			BIO_printf(ver,"Using cert also as CA cert - creating selfsigned cert.\n");
		ca = X509_dup(cert);
	};

	if (optind < argc) {
		bio=BIO_new(BIO_s_file());
		if (strcmp(argv[optind],"-")) {
			if (BIO_read_filename(bio,argv[3])<0) {
				BIO_printf(err, "Error opening key: %s\n", argv[optind]);
                       	 	ERR_print_errors(err);
				exit(1);
			};
			if (verbose)
				BIO_printf(ver,"Reading CA key from %s.\n", argv[optind]);
		} else {
			if (verbose)
				BIO_printf(ver,"Reading CA key from stdin.\n");
			BIO_set_fp(bio,stdin,BIO_NOCLOSE);
		}
		optind++;
	}
	else if (!newkey) {
		if (verbose)
			BIO_printf(ver,"Reading CA key from same place.\n");
		BIO_seek(bio,0);
	} else {
		if (verbose)
			BIO_printf(ver,"Using generated key.\n");
		pkey = newkey;
	}

	if ((pkey == NULL) && (!(PEM_read_bio_PrivateKey(bio, &pkey,(pem_password_cb *)password_callback, NULL)))) {
			BIO_printf(err, "Error reading key.");
       	        	ERR_print_errors(err);
       	        	exit(1);
		};

	assertOrBail(cert);
	assertOrBail(ca);
	assertOrBail(pkey);

	if (newkey) {
		if (verbose)
			BIO_printf(ver,"Replacing certificate pub/priv pair.\n");
    		X509_set_pubkey(cert,newkey);

        	EVP_PKEY *key2 = X509_get_pubkey(cert);
		assertOrBail(EVP_PKEY_cmp(newkey,key2));
		assertOrBail(EVP_PKEY_missing_parameters(newkey) == 0);
	};

	if (ftime) {
		if (verbose)
			BIO_printf(ver,"Replacing fromDate to 'now'.\n");
    		assertOrBail(X509_gmtime_adj(X509_get_notBefore(cert),0L));
	} else {
		if (verbose)
			BIO_printf(ver,"Leaving fromDate as is.\n");
	}

	if (days) {
		if (verbose)
			BIO_printf(ver,"Setting validity to %d days from now.\n", days);
	    	assertOrBail(X509_gmtime_adj(X509_get_notAfter(cert),(long)(60*60*24*days)));
	} else {
		if (verbose)
			BIO_printf(ver,"Leaving endDate as is.\n");
	}

	if (subject) {
		assertOrBail(X509_set_issuer_name(cert,X509_get_subject_name(ca)));
	} else {
		if (verbose)
			BIO_printf(ver,"Leaving subject as is.\n");
	}

	const EVP_MD *digest=EVP_sha256();

	// check that pub/priv pairs match up.
	//
        EVP_PKEY *upkey = X509_get_pubkey(ca);
	assertOrBail(upkey);

	if (pkey != newkey && EVP_PKEY_cmp(pkey,upkey) == 0) {
		BIO_printf(err, "Error: CA and CAkey not made for each other\n");
		exit(1);
	};
	assertOrBail(EVP_PKEY_missing_parameters(pkey) == 0);

	// if we have subject identifier - we sort of assume it is a keyid
	// and therefore needs to be replaced. Not sure if this is strictly
	// true - as it may also be something else ?
	//
	int isubject = X509_get_ext_by_NID(cert, NID_subject_key_identifier, -1);
	if (changeski && isubject >= 0 && newkey) {
		if (verbose)
			BIO_printf(ver,"Replacing subjectKeyIdenitfier by the SHA1 of the new key.\n");
	        ASN1_OCTET_STRING *oct;
        	ASN1_BIT_STRING *pk;
		unsigned char pkey_dig[EVP_MAX_MD_SIZE];
		unsigned int diglen;

		// pk = cert->cert_info->key->public_key;
		//EVP_Digest(pk->data, pk->length, pkey_dig, &diglen, EVP_sha1(), NULL);

		const EVP_PKEY *pkey = X509_get_pubkey(cert);
		// pk = EVP_PKEY_get0_asn1(pkey);
		// assertOrBail(pk);

		unsigned char buff[32*1024];
		size_t len = sizeof(buff);
        	EVP_PKEY_get_raw_public_key(pkey, buff, &len);

		EVP_Digest(buff, len, pkey_dig, &diglen, EVP_sha1(), NULL);

		oct = ASN1_OCTET_STRING_new();
		ASN1_OCTET_STRING_set(oct, pkey_dig, diglen);

		X509_EXTENSION * nex = X509V3_EXT_i2d(NID_subject_key_identifier, 0, oct);

		X509_EXTENSION * ex = X509_get_ext(cert, isubject);
		X509_EXTENSION_set_data(ex, X509_EXTENSION_get_data(nex));
	}
	

	// If there is an authority key identifier - replace it by mine.
	//
	int ikeyid = X509_get_ext_by_NID(cert, NID_authority_key_identifier, -1);
	if (changeiid && ikeyid >= 0) {
		X509_EXTENSION * ex = X509_get_ext(cert, ikeyid);

		int iid = X509_get_ext_by_NID(ca, NID_subject_key_identifier, -1);
		if (iid < 0) {
			BIO_printf(ver,"Warning - we should be replacing the AuthorityKeyIdentifier; but the signing CA has no subjectKeyIdentifier. So we delete the former from the cert signed.\n");
			X509_delete_ext(cert,ikeyid);
		} else {
			if (verbose)
				BIO_printf(ver,"Replacing authorityKeyIdentifier by subjectKeyIdentifier of CA\n");

			X509_EXTENSION * cext = X509_get_ext(ca, iid);
			assertOrBail(cext);
	
			ASN1_OCTET_STRING * data = X509_EXTENSION_get_data(cext);
			assertOrBail(data);

			// now prefix the subject key identifier with what it is,
			// hardcoded to keyid as a type.
			//
			ASN1_OCTET_STRING * keyid = X509V3_EXT_d2i(cext);
			AUTHORITY_KEYID * akeyid = AUTHORITY_KEYID_new();
			akeyid->issuer = NULL;
			akeyid->serial = NULL;
			akeyid->keyid = keyid;
	
			X509_EXTENSION * nex = X509V3_EXT_i2d(NID_authority_key_identifier, 0, akeyid);
			X509_EXTENSION_set_data(ex, X509_EXTENSION_get_data(nex));
		}
	};

	if (!X509_sign(cert, pkey, digest)) {
		BIO_printf(err, "Error signing");
                ERR_print_errors(err);
                exit(1);
	};

	bio=BIO_new_fp(stdout,BIO_NOCLOSE);

	if (newkey)
		PEM_write_bio_PrivateKey(bio,newkey,NULL,NULL,0,NULL,NULL);

	PEM_write_bio_X509(bio,cert);
	exit(0);
}

