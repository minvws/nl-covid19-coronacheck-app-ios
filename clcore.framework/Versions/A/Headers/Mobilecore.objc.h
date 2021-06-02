// Objective-C API for talking to github.com/minvws/nl-covid19-coronacheck-mobile-core Go package.
//   gobind -lang=objc github.com/minvws/nl-covid19-coronacheck-mobile-core
//
// File is generated by gobind. Do not edit.

#ifndef __Mobilecore_H__
#define __Mobilecore_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class MobilecoreAnnotatedPk;
@class MobilecoreDCC;
@class MobilecoreDCCName;
@class MobilecoreHCert;
@class MobilecoreResult;
@class MobilecoreVerificationResult;
@class MobilecoreVerifyResult;

@interface MobilecoreAnnotatedPk : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull id_;
@property (nonatomic) NSData* _Nullable pkXml;
@end

@interface MobilecoreDCC : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull dateOfBirth;
@property (nonatomic) MobilecoreDCCName* _Nullable name;
@end

@interface MobilecoreDCCName : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull givenName;
@property (nonatomic) NSString* _Nonnull familyName;
@end

@interface MobilecoreHCert : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) long credentialVersion;
@property (nonatomic) NSString* _Nonnull issuer;
@property (nonatomic) long issuedAt;
@property (nonatomic) long expirationTime;
@property (nonatomic) MobilecoreDCC* _Nullable dcc;
@end

@interface MobilecoreResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSData* _Nullable value;
@property (nonatomic) NSString* _Nonnull error;
@end

/**
 * Verification
FIXME: Mock implementation for now
 */
@interface MobilecoreVerificationResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull firstNameInitial;
@property (nonatomic) NSString* _Nonnull lastNameInitial;
@property (nonatomic) NSString* _Nonnull birthDay;
@property (nonatomic) NSString* _Nonnull birthMonth;
@end

/**
 * Temporary mocks for compatibility reasons while the app is being rewritten
 */
@interface MobilecoreVerifyResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSData* _Nullable attributesJson;
@property (nonatomic) int64_t unixTimeSeconds;
@property (nonatomic) NSString* _Nonnull error;
@end

@interface Mobilecore : NSObject
+ (BOOL) hasLoadedDomesticIssuerPks;
+ (void) setHasLoadedDomesticIssuerPks:(BOOL)v;

@end

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreCreateCommitmentMessage(NSData* _Nullable holderSkJson, NSData* _Nullable prepareIssueMessageJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreCreateCredentials(NSData* _Nullable ccmsJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreDisclose(NSData* _Nullable holderSkJson, NSData* _Nullable credJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreGenerateHolderSk(void);

FOUNDATION_EXPORT void MobilecoreInitializeVerifier(NSString* _Nullable configDirectoryPath);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreLoadDomesticIssuerPks(NSData* _Nullable annotatedPksJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreReadDomesticCredential(NSData* _Nullable credJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreReadEuropeanCredential(NSData* _Nullable proofPrefixed);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreVerify(NSData* _Nullable proofQREncoded);

FOUNDATION_EXPORT MobilecoreVerifyResult* _Nullable MobilecoreVerifyQREncoded(NSData* _Nullable proofQrEncodedAsn1);

#endif
