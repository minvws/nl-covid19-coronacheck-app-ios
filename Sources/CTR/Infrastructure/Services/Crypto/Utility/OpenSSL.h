/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenSSL : NSObject

- (BOOL)validateSerialNumber:(uint64_t)serialNumber forCertificateData:(NSData *)certificateData;
- (BOOL)validateSubjectKeyIdentifier:(NSData *)subjectKeyIdentifier forCertificateData:(NSData *)certificateData;
- (BOOL)validateSubjectAlternativeDNSName:(NSString *)host forCertificateData:(NSData *)certificateData;

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
                   contentData:(NSData *)contentData
               certificateData:(NSData *)certificateData
        authorityKeyIdentifier:(NSData *)expectedAuthorityKeyIdentifierData
     requiredCommonNameContent:(NSString *)requiredCommonNameContent
      requiredCommonNameSuffix:(NSString *)requiredCommonNameSuffix;

- (BOOL)validatePKCS7Signature:(NSData *)signatureData
				   contentData:(NSData *)contentData
			   certificateData:(NSData *)certificateData;

- (BOOL)compare:(NSData *)certificateData withTrustedCertificate:(NSData *)trustedCertificateData;

// Avoid using this method - as it cannot cope with mutiple Subject Alternative Names,
// which is rather common.
//
- (nullable NSString *)getSubjectAlternativeName:(NSData *)certificateData __deprecated;
- (NSArray *)getSubjectAlternativeDNSNames:(NSData *)certificateData;

- (BOOL)inSystemTrustRoots:(NSData *)certData;
@end

NS_ASSUME_NONNULL_END
