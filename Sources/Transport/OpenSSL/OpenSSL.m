/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

#import "OpenSSL.h"

#import <stdio.h>

#import <openssl/err.h>
#import <openssl/pem.h>
#import <openssl/pkcs7.h>
#import <openssl/cms.h>
#import <openssl/safestack.h>
#import <openssl/asn1.h>
#import <openssl/x509.h>
#import <openssl/x509v3.h>
#import <openssl/x509_vfy.h>

#import <Security/Security.h>

//#define __DEBUG

#ifdef __DEBUG
#include <openssl/asn1.h>
#include <openssl/bn.h>
#warning "Warning: DEBUGing compiled in"
#define DEBUGOUT(args...) { \
fprintf(stderr,"%s\n\t%d %s",  __FILE__,  __LINE__, __PRETTY_FUNCTION__);\
fprintf(stderr,args); \
fprintf(stderr,"\n"); \
}
#define EXITOUT(args...) { DEBUGOUT(args); goto errit; }
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
	
	fprintf(stderr,"\n");
	fprintf(stderr," certificate: %s/%p\n", subj,xn_subject);
	fprintf(stderr,"      issuer: %s\n", issuer);
	fprintf(stderr,"      serial: %s\n", i2s_ASN1_INTEGER(NULL,X509_get_serialNumber(cert)));
}

void print_stack(STACK_OF(X509)* sk) {
	unsigned len = sk_X509_num(sk);
	for(unsigned i=0; i<len; i++) {
		X509 *cert = sk_X509_value(sk, i);
		fprintf(stderr,"#%d\t:",i+1);
		print_certificate(cert);
	}
}

void print_octed_as_hex(const ASN1_OCTET_STRING * str) {
	for(int i = 0; i < str->length; i++) {
		fprintf(stderr,"%s%02x",i ? ":" : "", str->data[i]);
	}
	fprintf(stderr,"\n");
}

void print_pkey_as_hex(EVP_PKEY *pkey) {
	
	char pkr[64*1024] = {0};
	size_t len = sizeof(pkr);
	if (!EVP_PKEY_get_raw_public_key(pkey, (unsigned char*)pkr, &len)) {
		fprintf(stderr,"Failed to map public key to raw\n");
		return;
	}
	for(int i = 0; i < len; i++) {
		fprintf(stderr,"%s%02x",i ? ":" : "", pkr[i]);
	}
	fprintf(stderr,"\n");
}
#else
#define DEBUGOUT(args...) { /* no output */ }
#define EXITOUT(args...) {goto errit; }
#endif

@implementation OpenSSL

- (NSArray *)getSubjectAlternativeDNSNames:(NSData *)certificateData {
	NSMutableArray * results = [[NSMutableArray alloc] initWithCapacity:4];
	STACK_OF(GENERAL_NAME) *gens = NULL;
	
	X509 *certificate = [self getX509:certificateData];
	if (certificate == NULL) {
		return results;
	}
	
	gens = X509_get_ext_d2i(certificate, NID_subject_alt_name, NULL, NULL);
	if (gens) {
		for (int i=0; (i < sk_GENERAL_NAME_num(gens)); i++) {
			GENERAL_NAME *name = sk_GENERAL_NAME_value(gens, i);
			// Note - we intentionally ignore GEN_IPADD (IP:..) voor raw
			// IPv4 and IPv6 addresses at this point. Even though they could
			// be in valid URLs (such as https://127.0.0.1/.)
			if (name && name->type == GEN_DNS) {
				char *dns_name = (char *) ASN1_STRING_get0_data(name->d.dNSName);
				[results addObject:[NSString stringWithCString:dns_name encoding:NSASCIIStringEncoding]];
			}
		}
	}

	sk_GENERAL_NAME_pop_free(gens, GENERAL_NAME_free);
	X509_free(certificate); certificate = NULL;
	return results;
}

- (BOOL)validateSubjectAlternativeDNSName:(NSString *)host forCertificateData:(NSData *)certificateData {
	if (host == NULL)
		return false;
	
	NSArray * sans = [self getSubjectAlternativeDNSNames:certificateData];
	for(NSString * object in sans) {
		if ([[object lowercaseString] isEqual: [host lowercaseString]])
			return true;
	}
	return false;
}

- (BOOL)validateSerialNumber:(uint64_t)serialNumber forCertificateData:(NSData *)certificateData {
	
	X509 *certificate = [self getX509:certificateData];
	if (certificate == NULL) {
		return NO;
	}
	
	ASN1_INTEGER *expectedSerial = ASN1_INTEGER_new();
	
	if (expectedSerial == NULL) {
		X509_free(certificate); certificate = NULL;
		return NO;
	}
	
	if (ASN1_INTEGER_set_uint64(expectedSerial, serialNumber) != 1) {
		ASN1_INTEGER_free(expectedSerial); expectedSerial = NULL;
		X509_free(certificate); certificate = NULL;
		
		return NO;
	}
	
	ASN1_INTEGER *certificateSerial = X509_get_serialNumber(certificate);
	if (certificateSerial == NULL) {
		X509_free(certificate); certificate = NULL;
		return NO;
	}
	
	BOOL isMatch = ASN1_INTEGER_cmp(certificateSerial, expectedSerial) == 0;
	
	ASN1_INTEGER_free(expectedSerial); expectedSerial = NULL;
	X509_free(certificate); certificate = NULL;
	
	return isMatch;
}

- (BOOL)validateSubjectKeyIdentifier:(NSData *)subjectKeyIdentifier
				  forCertificateData:(NSData *)certificateData {
	
	const ASN1_OCTET_STRING *certificateSubjectKeyIdentifier = NULL;
	ASN1_OCTET_STRING *expectedSubjectKeyIdentifier = NULL;
	BOOL isMatch = NO;
	
	X509 *certificate = [self getX509:certificateData];
	if (certificate == NULL) {
		return NO;
	}
	
	@try {
		const unsigned char *bytes = subjectKeyIdentifier.bytes;
		if (NULL == (expectedSubjectKeyIdentifier = d2i_ASN1_OCTET_STRING(NULL, &bytes, (int)subjectKeyIdentifier.length))) {
			EXITOUT("Cannot extract expectedSubjectKeyIdentifier");
		}
		if (NULL == (certificateSubjectKeyIdentifier = X509_get0_subject_key_id(certificate))) {
			EXITOUT("Cannot extract certificateSubjectKeyIdentifier");
		}
	} @catch (NSException *exception) {
		EXITOUT("Cannot extract certificateSubjectKeyIdentifier");
	} @finally {
		
	}
	
	isMatch = ASN1_OCTET_STRING_cmp(expectedSubjectKeyIdentifier, certificateSubjectKeyIdentifier) == 0;
	
errit:
	X509_free(certificate); certificate = NULL;
	ASN1_OCTET_STRING_free(expectedSubjectKeyIdentifier); expectedSubjectKeyIdentifier = NULL;
	
	return isMatch;
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
#ifdef __DEBUG
	NSLog(@"validateAuthorityKeyIdentifierData OK.");
	print_octed_as_hex(expectedAuthorityKeyIdentifier);
#endif
	ASN1_OCTET_STRING_free(expectedAuthorityKeyIdentifier);
	return isMatch;
}

- (BOOL)validateCommonNameForCertificate:(X509 *)certificate
						 requiredContent:(NSString *)requiredContent {
	
	// Get subject from certificate
	X509_NAME *certificateSubjectName = X509_get_subject_name(certificate);
	
	// Get Common Name from certificate subject
	char certificateCommonName[256];
	if (-1 == X509_NAME_get_text_by_NID(certificateSubjectName, NID_commonName, certificateCommonName, sizeof(certificateCommonName))) {
		NSLog(@"X509_NAME_get_text_by_NID failed.");
		return false;
	}
	NSString *cnString = [NSString stringWithUTF8String:certificateCommonName];
	
	// Compare Common Name to required content
	BOOL hasCorrectEnding = [cnString hasSuffix:requiredContent];
	
	certificateSubjectName = NULL;
#ifdef __DEBUG
	NSLog(@"validateCommonNameForCertificate: %@ -> %d\n", requiredContent, hasCorrectEnding);
#endif
	return hasCorrectEnding;
}

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
				   contentData:(NSData *)contentData
			   certificateData:(NSData *)certificateData
		authorityKeyIdentifier:(nullable NSData *)expectedAuthorityKeyIdentifierDataOrNil
	 requiredCommonNameContent:(NSString *)requiredCommonNameContentOrNil {
	
	bool result = NO;
	BIO *signatureBlob = NULL, *contentBlob = NULL, *certificateBlob = NULL,*cmsBlob = NULL;
	X509_VERIFY_PARAM *verifyParameters = NULL;
	CMS_ContentInfo * cms = NULL;
	STACK_OF(X509) *signers = NULL;
	X509_STORE *store = NULL;
	X509 *signingCert = NULL;
	int cnt = 0;
	
	if (NULL == (signatureBlob = BIO_new_mem_buf(signatureData.bytes, (int)signatureData.length))) {
		EXITOUT("invalid signatureBlob");
	}
	if (NULL == (contentBlob = BIO_new_mem_buf(contentData.bytes, (int)contentData.length))) {
		EXITOUT("invalid contentBlob");
	}
	if (NULL == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length))) {
		EXITOUT("invalid certificateBlob");
	}
	if (NULL == (cmsBlob = BIO_new_mem_buf(signatureData.bytes, (int)signatureData.length))) {
		EXITOUT("Could not create cms Blob");
	}
	@try {
		cms = d2i_CMS_bio(cmsBlob, NULL);
		if (NULL == cms) {
			EXITOUT("Could not create CMS structure from PKCS#7");
		}
	} @catch (NSException *exception) {
		EXITOUT("d2i_CMS_bio crashed");
	} @finally {}

	if ((NULL == (store = X509_STORE_new()))) {
		EXITOUT("store");
	}

#ifdef __DEBUG
	fprintf(stderr, "Chain:\n");
#endif
	for(X509 *cert = NULL;;cnt++) {
		if (NULL == (cert = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL))) {
			break;
		}
		if (X509_STORE_add_cert(store, cert) != 1) {
			EXITOUT("Could not add cert %d to chain.",1+cnt);
		}

#ifdef __DEBUG
		fprintf(stderr,"#%d\t",cnt+1);
		print_certificate(cert);
#endif
		X509_free(cert); cert = NULL;
	};
	ERR_clear_error(); // as we have a feof() bio read error.

	if (cnt == 0) {
		EXITOUT("no trust chain of any length");
	}
	if (NULL == (verifyParameters = X509_VERIFY_PARAM_new())) {
		EXITOUT("Could create verifyParameters");
	}
	if (X509_VERIFY_PARAM_set_flags(verifyParameters, X509_V_FLAG_CRL_CHECK_ALL | X509_V_FLAG_POLICY_CHECK) != 1) {
		EXITOUT("Could not set CRL/Policy check on verifyParameters");
	}
	if (X509_VERIFY_PARAM_set_purpose(verifyParameters, X509_PURPOSE_ANY) != 1) {
		EXITOUT("Could not set purpose on verifyParameters");
	}
	if (X509_STORE_set1_param(store, verifyParameters) != 1) {
		EXITOUT("Could not set verifyParameters on the store");
	}
	// It appears that the PKCS7 family of OpenSSL does not support all the forms
	// of paddings; including PSS padding (which is the SOGIS recommendation).
	// So we use the more modern CMS family of functions.
	//
	// result = PKCS7_verify(p7, NULL, store, contentBlob, NULL, PKCS7_BINARY);
	@try {
		if ( 1 != CMS_verify(cms, NULL, store, contentBlob, NULL, CMS_BINARY) ) {
#ifdef __DEBUG
			char buff[1024];
			EXITOUT("CMS_verify fail (%d.%s)!", result,ERR_error_string(ERR_get_error(), buff));
#endif
			EXITOUT("CMS_verify fail");
		}
	} @catch (NSException *exception) {
		EXITOUT("CMS_verify crashed");
	} @finally {
		
	}

#ifdef __DEBUG
	fprintf(stderr,"=== signature is valid (but not yet validated) ===\n");
#endif

	// Unlike its PKCS8_get0_signers#7 brethen - CMS_get0_signers needs to be called after
	// a (successful) CMS_verify. So we only look at the actual signer after having
	// verified the signature.
	//
	if (NULL == (signers = CMS_get0_signers(cms))) {
		EXITOUT("No signers in CMS signatureBlob");
	}

	if (sk_X509_num(signers) != 1) {
		sk_X509_pop_free(signers, X509_free);
		EXITOUT("Not exactly one signer in PCKS#7 signatureBlob");
	}

	signingCert = sk_X509_value(signers, 0);

#ifdef __DEBUG
	fprintf(stderr,"Signing certificate:\t");
	print_certificate(signingCert);
#endif

	if (expectedAuthorityKeyIdentifierDataOrNil.length) {
		if (![self validateAuthorityKeyIdentifierData: expectedAuthorityKeyIdentifierDataOrNil
								   signingCertificate: signingCert]) {
			sk_X509_pop_free(signers, X509_free);
			X509_free(signingCert);
			EXITOUT("invalid isAuthorityKeyIdentifierValid");
		}
	}
	if (requiredCommonNameContentOrNil.length) {
		if (![self validateCommonNameForCertificate: signingCert
									requiredContent: requiredCommonNameContentOrNil]) {
			sk_X509_pop_free(signers, X509_free);
			X509_free(signingCert);
			EXITOUT("invalid isCommonNameValid");
		}
	}

#ifdef __DEBUG
	fprintf(stderr,"=== signature is valid - and meets the rules ===\n");
#endif
	result = YES;

errit:
	X509_VERIFY_PARAM_free(verifyParameters); verifyParameters = NULL;
	X509_STORE_free(store); store = NULL;
	CMS_ContentInfo_free(cms); cms = NULL;
	BIO_free(cmsBlob); cmsBlob = NULL;
	BIO_free(signatureBlob); signatureBlob = NULL;
	BIO_free(contentBlob); contentBlob = NULL;
	BIO_free(certificateBlob); certificateBlob = NULL;
	signers = NULL;
	signingCert = NULL;

	return result;
}

- (BOOL)compareCerts:(NSData *)certificateData
				with:(NSData *)trustedCertificateData {
	
	BOOL isMatch = NO;
	
	X509 *certificate = [self getX509:certificateData];
	if (certificate == NULL) {
		return NO;
	}
	
	X509 *trustedCertificate = [self getX509:trustedCertificateData];
	if (trustedCertificate == NULL) {
		X509_free(certificate); certificate = NULL;
		return NO;
	}
	
	isMatch = (0 == X509_cmp(trustedCertificate, certificate)) ? YES : NO;
	
	// compare public keys too - as we'r not sure of above hash.
	//
	EVP_PKEY * ptc = X509_get0_pubkey(trustedCertificate);
	EVP_PKEY * tc = X509_get0_pubkey(certificate);
	
	isMatch = isMatch && ((1 == EVP_PKEY_cmp(ptc, tc)) ? YES : NO);
	
	X509_free(certificate); certificate = NULL;
	X509_free(trustedCertificate); trustedCertificate = NULL;
	
	return isMatch;
}

- (BOOL)compareSubjectKeyIdentifier:(NSData *)certificateData
							   with:(NSData *)trustedCertificateData {
	
	// Certificate
	X509 *certificate = [self getX509: certificateData];
	if (certificate == NULL) {
		return NO;
	}
	
	const ASN1_OCTET_STRING *certificateSubjectKeyIdentifier = X509_get0_subject_key_id(certificate);
	if (certificateSubjectKeyIdentifier == NULL) {
		X509_free(certificate); certificate = NULL;
		return NO;
	}
	
	// Trusted Certificate
	X509 *trustedCertificate = [self getX509: trustedCertificateData];
	if (trustedCertificate == NULL) {
		X509_free(certificate); certificate = NULL;
		return NO;
	}
	
	const ASN1_OCTET_STRING *trustedCertificateSubjectKeyIdentifier = X509_get0_subject_key_id(trustedCertificate);
	if (trustedCertificateSubjectKeyIdentifier == NULL) {
		X509_free(certificate); certificate = NULL;
		X509_free(trustedCertificate); trustedCertificate = NULL;
		return NO;
	}
	
	BOOL isMatch = ASN1_OCTET_STRING_cmp(trustedCertificateSubjectKeyIdentifier, certificateSubjectKeyIdentifier) == 0;
	
	X509_free(certificate); certificate = NULL;
	X509_free(trustedCertificate); trustedCertificate = NULL;
	return isMatch;
}

- (BOOL)compareSerialNumber:(NSData *)certificateData
					   with:(NSData *)trustedCertificateData {
	
	// Certificate
	X509 *certificate = [self getX509: certificateData];
	if (certificate == NULL) {
		return NO;
	}
	
	ASN1_INTEGER *certificateSerial = X509_get_serialNumber(certificate);
	if (certificateSerial == NULL) {
		X509_free(certificate); certificate = NULL;
		return NO;
	}
	
	// Trusted Certificate
	X509 *trustedCertificate = [self getX509: trustedCertificateData];
	if (trustedCertificate == NULL) {
		X509_free(certificate); certificate = NULL;
		return NO;
	}
	
	ASN1_INTEGER *trustedCertificateSerial = X509_get_serialNumber(trustedCertificate);
	if (trustedCertificateSerial == NULL) {
		X509_free(certificate); certificate = NULL;
		X509_free(trustedCertificate); trustedCertificate = NULL;
		return NO;
	}
	
	BOOL isMatch = ASN1_INTEGER_cmp(certificateSerial, trustedCertificateSerial) == 0;
	
#ifdef __DEBUG
	char *cs = BN_bn2hex(ASN1_INTEGER_to_BN(certificateSerial, NULL));
	char *ts = BN_bn2hex(ASN1_INTEGER_to_BN(trustedCertificateSerial, NULL));
	print_certificate(certificate);
	print_certificate(trustedCertificate);
	NSLog(@"compareSerialNumber %s == %s", cs, ts);
#endif
	
	X509_free(certificate); certificate = NULL;
	X509_free(trustedCertificate); trustedCertificate = NULL;
	return isMatch;
}

/// Extract the X509 from a certificate, returns null if failed.
/// @param certificateData the data of the certificate
- (nullable X509*) getX509: (NSData *) certificateData {
	
	if (certificateData == NULL || certificateData.length == 0) {
		return NULL;
	}
	
	BIO *blob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length);
	if (blob == NULL) {
		NSLog(@"Can not create bio blob");
		return NULL;
	}
	
	X509 *x509 = PEM_read_bio_X509(blob, NULL, 0, NULL);
	if (x509 == NULL) {
		NSLog(@"Can not read bio to create x509");
		BIO_free(blob); blob = NULL;
		return NULL;
	}
	BIO_free(blob); blob = NULL;
	return x509;
}

- (BOOL)compare:(NSData *)certificateData withTrustedCertificate:(NSData *)trustedCertificateData {
	
	if (![self compareSubjectKeyIdentifier:certificateData with:trustedCertificateData]) {
		DEBUGOUT("compareSubjectKeyIdentifier failed");
		return false;
	}
	if (![self compareSerialNumber:certificateData with:trustedCertificateData]) {
		DEBUGOUT("compareSerialNumber failed");
		return false;
	}
	if (![self compareCerts:certificateData with:trustedCertificateData]) {
		DEBUGOUT("compareCerts failed");
		return false;
	}
	DEBUGOUT("all 3 good");
	return true;
}

- (nullable NSString *) getCommonNameForCertificate: (NSData *) certificateData {
	
	X509 *certificate = [self getX509: certificateData];
	if (certificate == NULL) {
		return nil;
	}
	
	// Get subject from certificate
	X509_NAME *certificateSubjectName = X509_get_subject_name(certificate);
	
	// Get Common Name from certificate subject
	char certificateCommonName[256];
	if (-1 == X509_NAME_get_text_by_NID(certificateSubjectName, NID_commonName, certificateCommonName, sizeof(certificateCommonName))) {
		NSLog(@"X509_NAME_get_text_by_NID failed.");
		X509_free(certificate); certificate = NULL;
		return nil;
	}
	NSString *commonNameString = [NSString stringWithUTF8String:certificateCommonName];
	X509_free(certificate); certificate = NULL;
	return commonNameString;
}

- (nullable NSData *) getAuthorityKeyIdentifierForCertificate: (NSData *) certificateData {
	
	X509 *certificate = [self getX509: certificateData];
	if (certificate == NULL) {
		return nil;
	}

	const ASN1_OCTET_STRING * authorityKeyIdentifier = X509_get0_authority_key_id(certificate);
	if (authorityKeyIdentifier == NULL)
		return nil;

	NSData *authorityKey = [[NSData alloc] initWithBytes:authorityKeyIdentifier->data length:authorityKeyIdentifier->length];

	const unsigned char bytes[] = {0x04, 0x14};
	NSData *prefix = [NSData dataWithBytes:bytes length:2];
	
	NSMutableData *result = [prefix mutableCopy];
	[result appendData: authorityKey];

	X509_free(certificate); certificate = NULL;
	return result;
}

@end
