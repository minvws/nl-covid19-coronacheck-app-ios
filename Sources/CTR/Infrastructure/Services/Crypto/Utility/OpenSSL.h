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
	 requiredCommonNameContent:(NSString *)requiredCommonNameContent;

/// Compare two certificates, return TRUE if they match
/// @param certificateData the certificate to examine
/// @param trustedCertificateData the trusted certificate
- (BOOL)compare:(NSData *)certificateData withTrustedCertificate:(NSData *)trustedCertificateData;

/// Get the Subject Alternative DSN entries
/// @param certificateData data of the certificate
- (NSArray *)getSubjectAlternativeDNSNames:(NSData *)certificateData;

/// Get the common name from a (X509) certificate
/// @param certificateData the certificate to examine
- (nullable NSString *)getCommonNameForCertificate:(NSData *)certificateData;

/// Get the authority key identifier from a (X509) certificate
/// @param certificateData the certificate to examine
- (nullable NSData *)getAuthorityKeyIdentifierData:(NSData *)certificateData;

@end

NS_ASSUME_NONNULL_END
