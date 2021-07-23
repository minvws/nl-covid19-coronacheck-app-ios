/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenSSL : NSObject

- (BOOL)validateSerialNumber:(uint64_t)serialNumber forCertificateData:(NSData *)certificatePemData;
- (BOOL)validateSubjectKeyIdentifier:(NSData *)subjectKeyIdentifier forCertificateData:(NSData *)certificatePemData;
- (BOOL)validateSubjectAlternativeDNSName:(NSString *)host forCertificateData:(NSData *)certificatePemData;

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
                   contentData:(NSData *)contentData
               certificateData:(NSData *)certificateData
        authorityKeyIdentifier:(nullable NSData *)expectedAuthorityKeyIdentifierData
     requiredCommonNameContent:(NSString *)requiredCommonNameContent
      requiredCommonNameSuffix:(NSString *)requiredCommonNameSuffix;

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
				   contentData:(NSData *)contentData
			   certificateData:(NSData *)certificateData;

- (BOOL)compare:(NSData *)certificateData withTrustedCertificate:(NSData *)trustedCertificateData;

// Avoid using this method - as it cannot cope with multiple Subject Alternative Names,
// which is rather common. It will only return one entry if there is exactly one. Otherwise
// it will fail (return a NULL).
//
- (nullable NSString *)getSubjectAlternativeName:(NSData *)certificateData __deprecated;

// Get all DNS entries (skips IP addresses and anything 'else')
//
- (NSArray *)getSubjectAlternativeDNSNames:(NSData *)certificateData;

@end

NS_ASSUME_NONNULL_END
