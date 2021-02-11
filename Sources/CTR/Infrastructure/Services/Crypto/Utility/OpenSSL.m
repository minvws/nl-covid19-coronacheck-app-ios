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
    printf("\tcertificate: %s/%p\n", subj,xn_subject);
    printf("\tserial: %s\n", i2s_ASN1_INTEGER(NULL,X509_get_serialNumber(cert)));
    
    X509_NAME * xn_issuer = X509_get_issuer_name(cert);
    if (xn_issuer)
        X509_NAME_oneline(xn_issuer, issuer, MAX_LENGTH);
    
    fprintf(stderr,"\tissuer: %s\n\n", issuer);
}
void print_stack(STACK_OF(X509)* sk)
{
    unsigned len = sk_X509_num(sk);
    for(unsigned i=0; i<len; i++) {
        X509 *cert = sk_X509_value(sk, i);
        print_certificate(cert);
    }
}
#else
#define EOUT(args...) { /* no output */ }
#define EXITOUT(args...) {goto errit; }
#endif

@implementation OpenSSL

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

- (BOOL)validateSubjectKeyIdentifier:(NSData *)subjectKeyIdentifier forCertificateData:(NSData *)certificateData {
    BIO *certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length);
    
    if (certificateBlob == NULL) {
        return NO;
    }
    
    X509 *certificate = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL);
    BIO_free(certificateBlob); certificateBlob = NULL;
    
    if (certificate == NULL) {
        return NO;
    }
    
    const unsigned char *bytes = subjectKeyIdentifier.bytes;
    ASN1_OCTET_STRING *expectedSubjectKeyIdentifier = d2i_ASN1_OCTET_STRING(NULL, &bytes, (int)subjectKeyIdentifier.length);
    
    if (expectedSubjectKeyIdentifier == NULL) {
        return NO;
    }
    
    const ASN1_OCTET_STRING *certificateSubjectKeyIdentifier = X509_get0_subject_key_id(certificate);
    if (certificateSubjectKeyIdentifier == NULL) {
        return NO;
    }
    
    BOOL isMatch = ASN1_OCTET_STRING_cmp(expectedSubjectKeyIdentifier, certificateSubjectKeyIdentifier) == 0;
    
    X509_free(certificate); certificate = NULL;
    ASN1_OCTET_STRING_free(expectedSubjectKeyIdentifier); expectedSubjectKeyIdentifier = NULL;
    
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
    
    X509_NAME_free(certificateSubjectName);
    certificateSubjectName = NULL;
    
    return hasCorrectSuffix && containsRequiredContent;
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
    X509 *cert = NULL;
    
    if (NULL == (signatureBlob = BIO_new_mem_buf(signatureData.bytes, (int)signatureData.length)))
        EXITOUT("invalid  signatureBlob");
    
    if (NULL == (contentBlob = BIO_new_mem_buf(contentData.bytes, (int)contentData.length)))
        EXITOUT("invalid  contentBlob");
    
    if (NULL == (certificateBlob = BIO_new_mem_buf(certificateData.bytes, (int)certificateData.length)))
        EXITOUT("invalid certificateBlob");
    
    if (NULL == (p7 = d2i_PKCS7_bio(signatureBlob, NULL)))
        EXITOUT("invalid PKCS#7 structure in signatureBlob");
    
    if ((NULL == (signers = PKCS7_get0_signers(p7, NULL, 0))) || (sk_X509_num(signers) == 0))
        EXITOUT("No signer in PCKS#7 signatureBlob");
    
    signingCert = sk_X509_value(signers, 0);
    
    BOOL isAuthorityKeyIdentifierValid = [self validateAuthorityKeyIdentifierData:expectedAuthorityKeyIdentifierData signingCertificate:signingCert];
    
    BOOL isCommonNameValid = [self validateCommonNameForCertificate:signingCert
                                                    requiredContent:requiredCommonNameContent
                                                     requiredSuffix:requiredCommonNameSuffix];
    
    if (!isAuthorityKeyIdentifierValid || !isCommonNameValid) {
        if (!isAuthorityKeyIdentifierValid)
            EXITOUT("invalids isAuthorityKeyIdentifierValid");
        EXITOUT("invalids isCommonNameValid");
    }
    
    if ((NULL == (store = X509_STORE_new())))
        EXITOUT("store");
    
    int cnt = 0;
#ifdef __DEBUG
    printf("Chain:");
#endif
    for(;;cnt++) {
        cert = PEM_read_bio_X509(certificateBlob, NULL, 0, NULL);
        
        if (cert == NULL)
            break;
        
        if (X509_STORE_add_cert(store, cert) != 1)
            EXITOUT("Could not add chain cert %d",1+cnt);
        
#ifdef __DEBUG
        print_certificate(cert);
#endif
        
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
    
#ifdef __DEBUG
    {
        BUF_MEM *bptr;
        BIO_get_mem_ptr(contentBlob, &bptr);
        bptr->data[ bptr->length] = 0;
        printf("Blob <%s>\n", bptr->data);
    }
#endif
    
    if( 1 != (result = PKCS7_verify(p7, NULL, store, contentBlob, NULL, PKCS7_BINARY))) {
#ifdef __DEBUG
        char buff[1024];
        EXITOUT("PKCS7_verify fail (%d.%s", result,ERR_error_string(ERR_get_error(), buff));
#endif
    };
    
#ifdef __DEBUG
    printf("=== signature is valid ===\n");
#endif
    
errit:
    X509_VERIFY_PARAM_free(verifyParameters); verifyParameters = NULL;
    
    BIO_free(signatureBlob); signatureBlob = NULL;
    BIO_free(certificateBlob); certificateBlob = NULL;
    BIO_free(contentBlob); contentBlob = NULL;
    
    X509_STORE_free(store); store = NULL;
    
    X509_free(cert); cert = NULL;
//    PKCS7_free(p7); p7 = NULL;
    
    return result == 1;
}

- (BOOL)validateAuthorityKeyIdentifierData:(NSData *)expectedAuthorityKeyIdentifierData
                        signingCertificate:(X509 *)signingCert {
    
    if (expectedAuthorityKeyIdentifierData == NULL) {
        EOUT("No expectedAuthorityKeyIdentifierData");
        return NO;
    }
    
    const unsigned char * bytes = expectedAuthorityKeyIdentifierData.bytes;
    ASN1_OCTET_STRING *expectedAuthorityKeyIdentifier = d2i_ASN1_OCTET_STRING(NULL,
                                                                              &bytes,
                                                                              (int)expectedAuthorityKeyIdentifierData.length);
    
    if (expectedAuthorityKeyIdentifier == NULL) {
        EOUT("No expectedAuthorityKeyIdentifier (%lu bytes)", (unsigned long)expectedAuthorityKeyIdentifierData.length);
        return NO;
    }
    
    const ASN1_OCTET_STRING * authorityKeyIdentifier = X509_get0_authority_key_id(signingCert);
    
    if (authorityKeyIdentifier == NULL) {
        ASN1_OCTET_STRING_free(expectedAuthorityKeyIdentifier); expectedAuthorityKeyIdentifier = NULL;
        return NO;
    }
    
    BOOL isMatch = ASN1_OCTET_STRING_cmp(authorityKeyIdentifier, expectedAuthorityKeyIdentifier) == 0;
    
    if (!isMatch) {
        EOUT("validateAuthorityKeyIdentifierData mismatch");
    }
    ASN1_OCTET_STRING_free(expectedAuthorityKeyIdentifier); expectedAuthorityKeyIdentifier = NULL;
    return isMatch;
}
@end
