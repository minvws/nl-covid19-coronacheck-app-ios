/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

#import "OpenSSL.h"
#import <openssl/err.h>
#import <openssl/pem.h>
#import <openssl/pkcs7.h>
#import <openssl/safestack.h>
#import <openssl/x509.h>
#import <openssl/x509v3.h>
#import <openssl/x509_vfy.h>
#import <Security/Security.h>

#define __DEBUG

#ifdef __DEBUG
#warning "Warning: DEBUGing compiled in"
#define EOUT(args...) { \
fprintf(stderr,"%s\n\t%d %s",  __FILE__,  __LINE__, __PRETTY_FUNCTION__);\
fprintf(stderr,args); \
fprintf(stderr,"\n"); \
}
#define EXITOUT(args...) { EOUT(args); goto errit; }
#define MAX_LENGTH 1024

void print_certificate(X509* cert) {
    char subj[MAX_LENGTH+1] = "<none-set>";
    char issuer[MAX_LENGTH+1] = "<none-set>";
    
    X509_NAME * xn_subject = X509_get_subject_name(cert);
    if (xn_subject)
        X509_NAME_oneline(xn_subject, subj, MAX_LENGTH);

    
    X509_NAME * xn_issuer = X509_get_issuer_name(cert);
    if (xn_issuer)
        X509_NAME_oneline(xn_issuer, issuer, MAX_LENGTH);
    
    fprintf(stderr,"certificate: %s/%p\n", subj,xn_subject);
    fprintf(stderr,"\tissuer: %s\n", issuer);
    fprintf(stderr,"\tserial: %s\n", i2s_ASN1_INTEGER(NULL,X509_get_serialNumber(cert)));
}
void print_stack(STACK_OF(X509)* sk)
{
    unsigned len = sk_X509_num(sk);
    for(unsigned i=0; i<len; i++) {
        X509 *cert = sk_X509_value(sk, i);
        fprintf(stderr,"#%d\t:",i+1);
        print_certificate(cert);
    }
}
#else
#define EOUT(args...) { /* no output */ }
#define EXITOUT(args...) {goto errit; }
#endif

@implementation OpenSSL

- (nullable NSString *)getSubjectAlternativeName:(NSData *)certificateData {
	BIO *certificateBlob = NULL;
	X509 *certificate = NULL;

	if (NULL  == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
		EXITOUT("Cannot allocate certificateBlob");

	if (NULL == (certificate = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL)))
		EXITOUT("Cannot parse certificateData");

	int loc = X509_get_ext_by_NID(certificate, NID_subject_alt_name, -1);
	if (loc >= 0) {
		X509_EXTENSION * ext = X509_get_ext(certificate, loc);
		BUF_MEM *bptr = NULL;
		char *buf = NULL;
		BIO *bio = BIO_new(BIO_s_mem());
		if(!X509V3_EXT_print(bio, ext, 0, 0)){

			EXITOUT("Cannot parse EXT");
		}

		BIO_flush(bio);
		BIO_get_mem_ptr(bio, &bptr);

		// now bptr contains the strings of the key_usage, take
		// care that bptr->data is NOT NULL terminated, so
		// to print it well, let's do something..

		buf = (char *)malloc( (bptr->length + 1)*sizeof(char) );
		memcpy(buf, bptr->data, bptr->length);
		buf[bptr->length] = '\0';
		NSString *san = [NSString stringWithUTF8String:buf];
		if (buf) free(buf);
		return san;
	}

errit:
	BIO_free(certificateBlob);
	X509_free(certificate);

	return NULL;
}

- (BOOL)validateSerialNumber:(uint64_t)serialNumber forCertificateData:(NSData *)certificateData {
    BIO *certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length);
    
    if (certificateBlob == NULL) {
        return NO;
    }
    
    X509 *certificate = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL);
    BIO_free(certificateBlob); certificateBlob = NULL;
    
    if (certificate == NULL) {
        return NO;
    }
    
    ASN1_INTEGER *expectedSerial = ASN1_INTEGER_new();
    
    if (expectedSerial == NULL) {
        return NO;
    }
    
    if (ASN1_INTEGER_set_uint64(expectedSerial, serialNumber) != 1) {
        ASN1_INTEGER_free(expectedSerial); expectedSerial = NULL;
        
        return NO;
    }
    
    ASN1_INTEGER *certificateSerial = X509_get_serialNumber(certificate);
    if (certificateSerial == NULL) {
        return NO;
    }
    
    BOOL isMatch = ASN1_INTEGER_cmp(certificateSerial, expectedSerial) == 0;
    
    ASN1_INTEGER_free(expectedSerial); expectedSerial = NULL;
    
    return isMatch;
}

- (BOOL)compare:(NSData *)certificateData withTrustedCertificate:(NSData *)trustedCertificateData {

	BOOL subjectKeyMatches = [self compareSubjectKeyIdentifier:certificateData with:trustedCertificateData];
	BOOL serialNumbersMatches = [self compareSerialNumber:certificateData with:trustedCertificateData];
	return subjectKeyMatches && serialNumbersMatches;
}

- (BOOL)compareSubjectKeyIdentifier:(NSData *)certificateData with:(NSData *)trustedCertificateData {

	const ASN1_OCTET_STRING *trustedCertificateSubjectKeyIdentifier = NULL;
	const ASN1_OCTET_STRING *certificateSubjectKeyIdentifier = NULL;
	BIO *certificateBlob = NULL;
	X509 *certificate = NULL;
	BIO *trustedCertificateBlob = NULL;
	X509 *trustedCertificate = NULL;
	BOOL isMatch = NO;

	if (NULL  == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
		EXITOUT("Cannot allocate certificateBlob");

	if (NULL == (certificate = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL)))
		EXITOUT("Cannot parse certificateData");

	if (NULL  == (trustedCertificateBlob = BIO_new_mem_buf(trustedCertificateData.bytes, (int)trustedCertificateData.length)))
		EXITOUT("Cannot allocate trustedCertificateBlob");

	if (NULL == (trustedCertificate = PEM_read_bio_X509(trustedCertificateBlob, NULL, 0, NULL)))
		EXITOUT("Cannot parse trustedCertificate");

	if (NULL == (trustedCertificateSubjectKeyIdentifier = X509_get0_subject_key_id(trustedCertificate)))
		EXITOUT("Cannot extract trustedCertificateSubjectKeyIdentifier");

	if (NULL == (certificateSubjectKeyIdentifier = X509_get0_subject_key_id(certificate)))
		EXITOUT("Cannot extract certificateSubjectKeyIdentifier");

	isMatch = ASN1_OCTET_STRING_cmp(trustedCertificateSubjectKeyIdentifier, certificateSubjectKeyIdentifier) == 0;

errit:
	BIO_free(certificateBlob);
	BIO_free(trustedCertificateBlob);
	X509_free(certificate);
	X509_free(trustedCertificate);

	return isMatch;
}

- (BOOL)compareSerialNumber:(NSData *)certificateData with:(NSData *)trustedCertificateData {

	BIO *certificateBlob = NULL;
	X509 *certificate = NULL;
	BIO *trustedCertificateBlob = NULL;
	X509 *trustedCertificate = NULL;
	ASN1_INTEGER *certificateSerial = NULL;
	ASN1_INTEGER *trustedCertificateSerial = NULL;
	BOOL isMatch = NO;

	if (NULL  == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
		EXITOUT("Cannot allocate certificateBlob");

	if (NULL == (certificate = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL)))
		EXITOUT("Cannot parse certificate");

	if (NULL  == (trustedCertificateBlob = BIO_new_mem_buf(trustedCertificateData.bytes, (int)trustedCertificateData.length)))
		EXITOUT("Cannot allocate trustedCertificateBlob");

	if (NULL == (trustedCertificate = PEM_read_bio_X509(trustedCertificateBlob, NULL, 0, NULL)))
		EXITOUT("Cannot parse trustedCertificate");

	if (NULL == (certificateSerial = X509_get_serialNumber(certificate)))
		EXITOUT("Cannot parse certificateSerial");

	if (NULL == (trustedCertificateSerial = X509_get_serialNumber(trustedCertificate)))
		EXITOUT("Cannot parse trustedCertificateSerial");

	isMatch = ASN1_INTEGER_cmp(certificateSerial, trustedCertificateSerial) == 0;

errit:
	if (certificateBlob) BIO_free(certificateBlob);
	if (trustedCertificateBlob) BIO_free(trustedCertificateBlob);
	if (certificate) X509_free(certificate);
	if (trustedCertificate) X509_free(trustedCertificate);

	return isMatch;
}

- (BOOL)validateSubjectKeyIdentifier:(NSData *)subjectKeyIdentifier forCertificateData:(NSData *)certificateData {
    const ASN1_OCTET_STRING *certificateSubjectKeyIdentifier = NULL;
    ASN1_OCTET_STRING *expectedSubjectKeyIdentifier = NULL;
    BIO *certificateBlob = NULL;
    X509 *certificate = NULL;
    BOOL isMatch = NO;

    if (NULL  == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
        EXITOUT("Cannot allocate certificateBlob");
    
    if (NULL == (certificate = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL)))
        EXITOUT("Cannot parse certificateData")
    
    const unsigned char *bytes = subjectKeyIdentifier.bytes;
    if (NULL == (expectedSubjectKeyIdentifier = d2i_ASN1_OCTET_STRING(NULL, &bytes, (int)subjectKeyIdentifier.length)))
        EXITOUT("Cannot extract expectedSubjectKeyIdentifier");
    
    if (NULL == (certificateSubjectKeyIdentifier = X509_get0_subject_key_id(certificate)))
        EXITOUT("Cannot extract certificateSubjectKeyIdentifier");

    isMatch = ASN1_OCTET_STRING_cmp(expectedSubjectKeyIdentifier, certificateSubjectKeyIdentifier) == 0;

errit:
	if (certificateBlob) BIO_free(certificateBlob);
	if (certificate)  X509_free(certificate);
	ASN1_OCTET_STRING_free(expectedSubjectKeyIdentifier);

	return isMatch;
}

- (BOOL)validateCommonNameForCertificate:(X509 *)certificate
                         requiredContent:(NSString *)requiredContent
                          requiredSuffix:(NSString *)requiredSuffix {
    
    // Get subject from certificate
    X509_NAME *certificateSubjectName = X509_get_subject_name(certificate);
    
    // Get Common Name from certificate subject
    char certificateCommonName[256];
    X509_NAME_get_text_by_NID(certificateSubjectName, NID_commonName, certificateCommonName, 256);
    NSString *cnString = [NSString stringWithUTF8String:certificateCommonName];
    
    // Compare Common Name to required content and required suffix
    BOOL containsRequiredContent = [cnString rangeOfString:requiredContent options:NSCaseInsensitiveSearch].location != NSNotFound;
    BOOL hasCorrectSuffix = [cnString hasSuffix:requiredSuffix];
    
    certificateSubjectName = NULL;
    
    return hasCorrectSuffix && containsRequiredContent;
}

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
				   contentData:(NSData *)contentData
			   certificateData:(NSData *)certificateData {

	int result = NO;
	BIO *signatureBlob = NULL, *contentBlob = NULL, *certificateBlob = NULL;
	X509_VERIFY_PARAM *verifyParameters = NULL;
	STACK_OF(X509) *signers = NULL;
	X509_STORE *store = NULL;
	PKCS7 *p7 = NULL;

	if (NULL == (signatureBlob = BIO_new_mem_buf(signatureData.bytes, (int)signatureData.length)))
		EXITOUT("invalid  signatureBlob");

	if (NULL == (contentBlob = BIO_new_mem_buf(contentData.bytes, (int)contentData.length)))
		EXITOUT("invalid  contentBlob");

	if (NULL == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
		EXITOUT("invalid certificateBlob");

	if (NULL == (p7 = d2i_PKCS7_bio(signatureBlob, NULL)))
		EXITOUT("invalid PKCS#7 structure in signatureBlob");

	if (NULL == (signers = PKCS7_get0_signers(p7, NULL, 0)))
		EXITOUT("No signers in PCKS#7 signatureBlob");

	if (sk_X509_num(signers) != 1)
		EXITOUT("Not exactly one signer in PCKS#7 signatureBlob");

	if ((NULL == (store = X509_STORE_new())))
		EXITOUT("store");

	int cnt = 0;
#ifdef __DEBUG
	fprintf(stderr, "Chain:\n");
#endif
	for(X509 *cert = NULL;;cnt++) {
		if (NULL == (cert = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL)))
			break;

		if (X509_STORE_add_cert(store, cert) != 1)
			EXITOUT("Could not add cert %d to chain.",1+cnt);

#ifdef __DEBUG
		fprintf(stderr,"#%d\t",cnt+1);
		print_certificate(cert);
#endif
		X509_free(cert);
	};
	ERR_clear_error();

	if (cnt == 0)
		EXITOUT("no trust chain of any length");

	if (NULL == (verifyParameters = X509_VERIFY_PARAM_new()))
		EXITOUT("Could create verifyParameters");

	if (X509_VERIFY_PARAM_set_flags(verifyParameters, X509_V_FLAG_CRL_CHECK_ALL | X509_V_FLAG_POLICY_CHECK) != 1)
		EXITOUT("Could not set CRL/Policy check on verifyParameters");

	if (X509_VERIFY_PARAM_set_purpose(verifyParameters, X509_PURPOSE_ANY) != 1)
		EXITOUT("Could not set purpose on verifyParameters");

	if (X509_STORE_set1_param(store, verifyParameters) != 1)
		EXITOUT("Could not set verifyParameters on the store");

	if (/* DISABLES CODE */ (0)) {
		BUF_MEM *bptr;
		BIO_get_mem_ptr(contentBlob, &bptr);
		bptr->data[ bptr->length] = 0;
		printf("Blob <%s>\n", bptr->data);
	}

	result = PKCS7_verify(p7, NULL, store, contentBlob, NULL, PKCS7_BINARY);

#ifdef __DEBUG
	if (result != 1) {
		char buff[1024];
		EXITOUT("PKCS7_verify fail (%d.%s", result,ERR_error_string(ERR_get_error(), buff));
	};
#endif

#ifdef __DEBUG
	fprintf(stderr,"=== signature is valid ===\n");
#endif

errit:

	if (verifyParameters) X509_VERIFY_PARAM_free(verifyParameters);

	if (store) X509_STORE_free(store);
	if (p7) PKCS7_free(p7);

	if (signatureBlob) BIO_free(signatureBlob);
	if (contentBlob) BIO_free(contentBlob);
	if (certificateBlob) BIO_free(certificateBlob);

	return result == 1;
}

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
                   contentData:(NSData *)contentData
               certificateData:(NSData *)certificateData
        authorityKeyIdentifier:(NSData *)expectedAuthorityKeyIdentifierData
     requiredCommonNameContent:(NSString *)requiredCommonNameContent
      requiredCommonNameSuffix:(NSString *)requiredCommonNameSuffix {
    int result = NO;
    BIO *signatureBlob = NULL, *contentBlob = NULL, *certificateBlob = NULL;
    X509_VERIFY_PARAM *verifyParameters = NULL;
    STACK_OF(X509) *signers = NULL;
    X509_STORE *store = NULL;
    X509 *signingCert = NULL;
    PKCS7 *p7 = NULL;
    
    
    if (NULL == (signatureBlob = BIO_new_mem_buf(signatureData.bytes, (int)signatureData.length)))
        EXITOUT("invalid  signatureBlob");
    
    if (NULL == (contentBlob = BIO_new_mem_buf(contentData.bytes, (int)contentData.length)))
        EXITOUT("invalid  contentBlob");
    
    if (NULL == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
        EXITOUT("invalid certificateBlob");
    
    if (NULL == (p7 = d2i_PKCS7_bio(signatureBlob, NULL)))
        EXITOUT("invalid PKCS#7 structure in signatureBlob");

    if (NULL == (signers = PKCS7_get0_signers(p7, NULL, 0)))
        EXITOUT("No signers in PCKS#7 signatureBlob");

    if (sk_X509_num(signers) != 1)
        EXITOUT("Not exactly one signer in PCKS#7 signatureBlob");

    signingCert = sk_X509_value(signers, 0);
    if (![self validateAuthorityKeyIdentifierData:expectedAuthorityKeyIdentifierData
                                                               signingCertificate:signingCert])
        EXITOUT("invalids isAuthorityKeyIdentifierValid");

    if (![self validateCommonNameForCertificate:signingCert
                                                    requiredContent:requiredCommonNameContent
                                                     requiredSuffix:requiredCommonNameSuffix])
        EXITOUT("invalids isCommonNameValid");

    if ((NULL == (store = X509_STORE_new())))
        EXITOUT("store");
    
    int cnt = 0;
#ifdef __DEBUG
    fprintf(stderr, "Chain:\n");
#endif
    for(X509 *cert = NULL;;cnt++) {
        if (NULL == (cert = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL)))
            break;
        
        if (X509_STORE_add_cert(store, cert) != 1)
            EXITOUT("Could not add cert %d to chain.",1+cnt);
        
#ifdef __DEBUG
        fprintf(stderr,"#%d\t",cnt+1);
        print_certificate(cert);
#endif
        X509_free(cert);
    };
    ERR_clear_error();
    
    if (cnt == 0)
        EXITOUT("no trust chain of any length");
    
    if (NULL == (verifyParameters = X509_VERIFY_PARAM_new()))
        EXITOUT("Could create verifyParameters");
    
    if (X509_VERIFY_PARAM_set_flags(verifyParameters, X509_V_FLAG_CRL_CHECK_ALL | X509_V_FLAG_POLICY_CHECK) != 1)
        EXITOUT("Could not set CRL/Policy check on verifyParameters");
    
    if (X509_VERIFY_PARAM_set_purpose(verifyParameters, X509_PURPOSE_ANY) != 1)
        EXITOUT("Could not set purpose on verifyParameters");
    
    if (X509_STORE_set1_param(store, verifyParameters) != 1)
        EXITOUT("Could not set verifyParameters on the store");
    
    if (/* DISABLES CODE */ (0)) {
        BUF_MEM *bptr;
        BIO_get_mem_ptr(contentBlob, &bptr);
        bptr->data[ bptr->length] = 0;
        printf("Blob <%s>\n", bptr->data);
    }

    result = PKCS7_verify(p7, NULL, store, contentBlob, NULL, PKCS7_BINARY);
    
#ifdef __DEBUG
    if (result != 1) {
        char buff[1024];
        EXITOUT("PKCS7_verify fail (%d.%s", result,ERR_error_string(ERR_get_error(), buff));
    };
#endif
    
#ifdef __DEBUG
    fprintf(stderr,"=== signature is valid ===\n");
#endif
    
errit:

    if (verifyParameters) X509_VERIFY_PARAM_free(verifyParameters);
    
    if (store) X509_STORE_free(store);
    if (p7) PKCS7_free(p7);

    if (signatureBlob) BIO_free(signatureBlob);
    if (contentBlob) BIO_free(contentBlob);
    if (certificateBlob) BIO_free(certificateBlob);

    return result == 1;
}

- (BOOL)validateAuthorityKeyIdentifierData:(NSData *)expectedAuthorityKeyIdentifierData
                        signingCertificate:(X509 *)signingCert {
    ASN1_OCTET_STRING *expectedAuthorityKeyIdentifier = NULL;
    BOOL isMatch = NO;
    
    if (expectedAuthorityKeyIdentifierData == NULL)
        EXITOUT("No expectedAuthorityKeyIdentifierData");
    
    const unsigned char * bytes = expectedAuthorityKeyIdentifierData.bytes;
   if (NULL == (expectedAuthorityKeyIdentifier = d2i_ASN1_OCTET_STRING(NULL,
                                                                              &bytes,
                                                                              (int)expectedAuthorityKeyIdentifierData.length)))
       EXITOUT("No expectedAuthorityKeyIdentifier (%lu bytes)", (unsigned long)expectedAuthorityKeyIdentifierData.length);

        
    const ASN1_OCTET_STRING * authorityKeyIdentifier = X509_get0_authority_key_id(signingCert);
    
    if (authorityKeyIdentifier == NULL)
        EXITOUT("No authorityKeyIdentifier");
    
    if (ASN1_OCTET_STRING_cmp(authorityKeyIdentifier, expectedAuthorityKeyIdentifier) != 0)
        EXITOUT("validateAuthorityKeyIdentifierData mismatch");
    
    isMatch = YES;
errit:
    ASN1_OCTET_STRING_free(expectedAuthorityKeyIdentifier); expectedAuthorityKeyIdentifier = NULL;
    return isMatch;
}

@end
