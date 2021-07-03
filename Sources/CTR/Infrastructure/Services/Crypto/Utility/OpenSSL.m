/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
void print_stack(STACK_OF(X509)* sk)
{
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
    BIO *certificateBlob = NULL;
    X509 *certificate = NULL;
    
    if (NULL  == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
        EXITOUT("Cannot allocate certificateBlob");
    
    if (NULL == (certificate = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL)))
        EXITOUT("Cannot parse certificateData");
    
    gens = X509_get_ext_d2i(certificate, NID_subject_alt_name, NULL, NULL);
    if (gens) {
        for (int i=0; (i < sk_GENERAL_NAME_num(gens)); i++) {
            GENERAL_NAME *name = sk_GENERAL_NAME_value(gens, i);
            if (name && name->type == GEN_DNS) {
                char *dns_name = (char *) ASN1_STRING_get0_data(name->d.dNSName);
                [results addObject:[NSString stringWithCString:dns_name encoding:NSASCIIStringEncoding]];
            }
        }
    }
errit:
    sk_GENERAL_NAME_pop_free(gens, GENERAL_NAME_free);
    BIO_free(certificateBlob);
    X509_free(certificate);
    return results;
}

- (nullable NSString *)getSubjectAlternativeName:(NSData *)certificateData {
    NSArray * sans = [self getSubjectAlternativeDNSNames:certificateData];

    if ([sans count] == 1)
        return [sans firstObject];
    
    NSLog(@"ERROR - getSubjectAlternativeName with mutiple options - returning none.");
    return NULL;
}

- (BOOL)validateSubjectAlternativeDNSName:(NSString *)host forCertificateData:(NSData *)certificateData {
    if (host == NULL)
        return false;

    NSArray * sans = [self getSubjectAlternativeDNSNames:certificateData];
    for(NSString * object in sans) {
        if ([[object lowercaseString] isEqual:host])
            return true;
    }
    return false;
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

- (BOOL)validateSubjectKeyIdentifier:(NSData *)subjectKeyIdentifier
                  forCertificateData:(NSData *)certificateData {
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
    BIO_free(certificateBlob);
    X509_free(certificate);
    ASN1_OCTET_STRING_free(expectedSubjectKeyIdentifier);
    
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
    ASN1_OCTET_STRING_free(expectedAuthorityKeyIdentifier);
    return isMatch;
}

- (BOOL)validateCommonNameForCertificate:(X509 *)certificate
                         requiredContent:(NSString *)requiredContent
                          requiredSuffix:(NSString *)requiredSuffix {
    
    // Get subject from certificate
    X509_NAME *certificateSubjectName = X509_get_subject_name(certificate);
    
    // Get Common Name from certificate subject
    char certificateCommonName[256];
    if (-1 == X509_NAME_get_text_by_NID(certificateSubjectName, NID_commonName, certificateCommonName, sizeof(certificateCommonName))) {
        NSLog(@"X509_NAME_get_text_by_NID failed.");
        return false;
    }
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
    
    return [self validatePKCS7Signature:signatureData
                            contentData:contentData
                        certificateData:certificateData
                 authorityKeyIdentifier:nil
              requiredCommonNameContent:@""
               requiredCommonNameSuffix:@""];
}

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
                   contentData:(NSData *)contentData
               certificateData:(NSData *)certificateData
        authorityKeyIdentifier:(NSData *)expectedAuthorityKeyIdentifierDataOrNil
     requiredCommonNameContent:(NSString *)requiredCommonNameContentOrNil
      requiredCommonNameSuffix:(NSString *)requiredCommonNameSuffixOrNil {
    bool result = NO;
    BIO *signatureBlob = NULL, *contentBlob = NULL, *certificateBlob = NULL,*cmsBlob = NULL;
    X509_VERIFY_PARAM *verifyParameters = NULL;
    STACK_OF(X509) *signers = NULL;
    X509_STORE *store = NULL;
    X509 *signingCert = NULL;
    int cnt = 0;
    
    if (NULL == (signatureBlob = BIO_new_mem_buf(signatureData.bytes, (int)signatureData.length)))
        EXITOUT("invalid  signatureBlob");
    
    if (NULL == (contentBlob = BIO_new_mem_buf(contentData.bytes, (int)contentData.length)))
        EXITOUT("invalid  contentBlob");
    
    if (NULL == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
        EXITOUT("invalid certificateBlob");
    
    if (NULL == (cmsBlob = BIO_new_mem_buf(signatureData.bytes, (int)signatureData.length)))
        EXITOUT("Could not create cms Blob");
    
    CMS_ContentInfo * cms = d2i_CMS_bio(cmsBlob, NULL);
    if (NULL == cms)
        EXITOUT("Could not create CMS structure from PKCS#7");
    
    if ((NULL == (store = X509_STORE_new())))
        EXITOUT("store");
    
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
    ERR_clear_error(); // as we have a feof() bio read error.
    
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
    
    // It appears that the PKCS7 family of OpenSSL does not support all the forms
    // of paddings; including PSS padding (which is the SOGIS recommendation).
    // So we use the more modern CMS family of functions.
    //
    // result = PKCS7_verify(p7, NULL, store, contentBlob, NULL, PKCS7_BINARY);
    
    if ( 1 != CMS_verify(cms, NULL, store, contentBlob, NULL, CMS_BINARY) ) {
#ifdef __DEBUG
        char buff[1024];
        EXITOUT("CMS_verify fail (%d.%s)!", result,ERR_error_string(ERR_get_error(), buff));
#endif
        EXITOUT("CMS_verify fail");
    }
    
#ifdef __DEBUG
    fprintf(stderr,"=== signature is valid (but not yet validated) ===\n");
#endif
    
    // Unlike its PKCS8_get0_signers#7 brethen - CMS_get0_signers needs to be called after
    // a (successful) CMS_verify. So we only look at the actual signer after having
    // verified the signature.
    //
    if (NULL == (signers = CMS_get0_signers(cms)))
        EXITOUT("No signers in CMS signatureBlob");
    
    if (sk_X509_num(signers) != 1)
        EXITOUT("Not exactly one signer in PCKS#7 signatureBlob");
    
    signingCert = sk_X509_value(signers, 0);
    
#ifdef __DEBUG
    fprintf(stderr,"Signing certificate:\t");
    print_certificate(signingCert);
#endif
    
    if (expectedAuthorityKeyIdentifierDataOrNil.length)
        if (![self validateAuthorityKeyIdentifierData:expectedAuthorityKeyIdentifierDataOrNil
                                   signingCertificate:signingCert])
            EXITOUT("invalid isAuthorityKeyIdentifierValid");
    
    if ((requiredCommonNameSuffixOrNil.length) && (requiredCommonNameContentOrNil.length )) {
        if (![self validateCommonNameForCertificate:signingCert
                                    requiredContent:requiredCommonNameContentOrNil
                                     requiredSuffix:requiredCommonNameSuffixOrNil])
            EXITOUT("invalid isCommonNameValid");
    } else
        if ((requiredCommonNameSuffixOrNil.length) || (requiredCommonNameContentOrNil.length))
            EXITOUT("incomplete common fields to compare against");
    
#ifdef __DEBUG
    fprintf(stderr,"=== signature is valid - and meets the rules ===\n");
#endif
    result = YES;
    
errit:
    X509_VERIFY_PARAM_free(verifyParameters);
    
    X509_STORE_free(store);
    
    BIO_free(cmsBlob);
    BIO_free(signatureBlob);
    BIO_free(contentBlob);
    BIO_free(certificateBlob);
    
    return result == YES;
}



- (BOOL)compareCerts:(NSData *)certificateData with:(NSData *)trustedCertificateData {
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

    // basically a memcmp() of the hash (not sure if this is a sha1/md5
    // or something more modern).
    //
    isMatch = (0 == X509_cmp(trustedCertificate, certificate)) ? YES : NO;

    // compare public keys too - as we'r not sure of above hash.
    //
    EVP_PKEY * ptc = X509_get0_pubkey(trustedCertificate);
    EVP_PKEY * tc = X509_get0_pubkey(certificate);
    
    isMatch = isMatch && ((1 == EVP_PKEY_cmp(ptc, tc)) ? YES : NO);

errit:
    BIO_free(certificateBlob);
    BIO_free(trustedCertificateBlob);
    X509_free(certificate);
    X509_free(trustedCertificate);
    
    return isMatch;
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
    
#ifdef __DEBUG
    char *cs = BN_bn2hex(ASN1_INTEGER_to_BN(certificateSerial, NULL));
    char *ts = BN_bn2hex(ASN1_INTEGER_to_BN(trustedCertificateSerial, NULL));
    print_certificate(certificate);
    print_certificate(trustedCertificate);
    NSLog(@"compareSerialNumber %s == %s", cs, ts);
#endif
errit:
    BIO_free(certificateBlob);
    BIO_free(trustedCertificateBlob);
    X509_free(certificate);
    X509_free(trustedCertificate);
    
    return isMatch;
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
@end
