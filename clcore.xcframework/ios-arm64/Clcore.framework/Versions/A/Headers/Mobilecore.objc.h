// Objective-C API for talking to github.com/minvws/nl-covid19-coronacheck-mobile-core Go package.
//   gobind -lang=objc github.com/minvws/nl-covid19-coronacheck-mobile-core
//
// File is generated by gobind. Do not edit.

#ifndef __Mobilecore_H__
#define __Mobilecore_H__

@import Foundation;
#include "ref.h"
#include "Universe.objc.h"


@class MobilecoreAnnotatedDomesticPk;
@class MobilecoreCreateCredentialResultValue;
@class MobilecorePublicKeysConfig;
@class MobilecoreResult;
@class MobilecoreVerificationDetails;
@class MobilecoreVerificationResult;

@interface MobilecoreAnnotatedDomesticPk : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSData* _Nullable pkXml;
// skipped field AnnotatedDomesticPk.LoadedPk with unsupported type: *github.com/privacybydesign/gabi.PublicKey

/**
 * DEPRECATED: Remove this field together with LegacyDomesticPks
 */
@property (nonatomic) NSString* _Nonnull kid;
@end

@interface MobilecoreCreateCredentialResultValue : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
// skipped field CreateCredentialResultValue.Credential with unsupported type: *github.com/privacybydesign/gabi.Credential

// skipped field CreateCredentialResultValue.Attributes with unsupported type: map[string]string

@end

@interface MobilecorePublicKeysConfig : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nullable instancetype)init:(NSString* _Nullable)pksPath;
// skipped field PublicKeysConfig.DomesticPks with unsupported type: github.com/minvws/nl-covid19-coronacheck-mobile-core.DomesticPksLookup

// skipped field PublicKeysConfig.EuropeanPks with unsupported type: github.com/minvws/nl-covid19-coronacheck-hcert/verifier.PksLookup

// skipped field PublicKeysConfig.LegacyDomesticPks with unsupported type: []*github.com/minvws/nl-covid19-coronacheck-mobile-core.AnnotatedDomesticPk

// skipped method PublicKeysConfig.FindAndCacheDomestic with unsupported parameter or return types

/**
 * DEPRECATED: Remove this legacy transformation together with LegacyDomesticPks
 */
- (void)transformLegacyDomesticPks;
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
 * VerificationDetails very much mimics the domestic verifier attributes, with only string type values,
 to minimize app-side changes. In the future, both should return properly typed values.
 */
@interface MobilecoreVerificationDetails : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) NSString* _Nonnull credentialVersion;
@property (nonatomic) NSString* _Nonnull isSpecimen;
@property (nonatomic) NSString* _Nonnull issuerCountryCode;
@property (nonatomic) NSString* _Nonnull firstNameInitial;
@property (nonatomic) NSString* _Nonnull lastNameInitial;
@property (nonatomic) NSString* _Nonnull birthDay;
@property (nonatomic) NSString* _Nonnull birthMonth;
@end

@interface MobilecoreVerificationResult : NSObject <goSeqRefInterface> {
}
@property(strong, readonly) _Nonnull id _ref;

- (nonnull instancetype)initWithRef:(_Nonnull id)ref;
- (nonnull instancetype)init;
@property (nonatomic) long status;
@property (nonatomic) MobilecoreVerificationDetails* _Nullable details;
@property (nonatomic) NSString* _Nonnull error;
@end

FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreCATEGORY_ATTRIBUTE_1G;
FOUNDATION_EXPORT const int64_t MobilecoreCREATE_CREDENTIAL_VERSION;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreDCC_DOMESTIC_ISSUER_COUNTRY_CODE;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreDCC_DOMESTIC_ISSUER_KEY_SAN;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreDISCLOSURE_POLICY_1G;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreDISCLOSURE_POLICY_3G;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreDISEASE_TARGETED_COVID_19;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreDOB_EMPTY_VALUE;
FOUNDATION_EXPORT const int64_t MobilecoreHCERT_SPECIMEN_EXPIRATION_TIME;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreHOLDER_CONFIG_FILENAME;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreHOLDER_PUBLIC_KEYS_FILENAME;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreTEST_RESULT_NOT_DETECTED;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreVACCINE_MEDICINAL_PRODUCT_JANSSEN;
FOUNDATION_EXPORT const int64_t MobilecoreVERIFICATION_FAILED_ERROR;
FOUNDATION_EXPORT const int64_t MobilecoreVERIFICATION_FAILED_IS_NL_DCC;
FOUNDATION_EXPORT const int64_t MobilecoreVERIFICATION_FAILED_UNRECOGNIZED_PREFIX;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreVERIFICATION_POLICY_1G;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreVERIFICATION_POLICY_3G;
FOUNDATION_EXPORT const int64_t MobilecoreVERIFICATION_SUCCESS;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreVERIFIER_CONFIG_FILENAME;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreVERIFIER_PUBLIC_KEYS_FILENAME;
FOUNDATION_EXPORT NSString* _Nonnull const MobilecoreYYYYMMDD_FORMAT;

@interface Mobilecore : NSObject
// skipped variable DATE_OF_BIRTH_REGEX with unsupported type: *regexp.Regexp

@end

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreCreateCommitmentMessage(NSData* _Nullable holderSkJson, NSData* _Nullable issueSpecificationMessageJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreCreateCredentials(NSData* _Nullable ccmsJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreDisclose(NSData* _Nullable holderSkJson, NSData* _Nullable credJson, NSString* _Nullable disclosurePolicy);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreDiscloseWithTime(NSData* _Nullable holderSkJson, NSData* _Nullable credJson, NSString* _Nullable disclosurePolicy, int64_t unixTimeSeconds);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreErrorResult(NSError* _Nullable err);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreGenerateHolderSk(void);

// skipped function GetVerifiersForCLI with unsupported parameter or return types


FOUNDATION_EXPORT BOOL MobilecoreHasDomesticPrefix(NSData* _Nullable proofQREncoded);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreInitializeHolder(NSString* _Nullable configDirectoryPath);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreInitializeVerifier(NSString* _Nullable configDirectoryPath);

FOUNDATION_EXPORT BOOL MobilecoreIsDCC(NSData* _Nullable proofQREncoded);

FOUNDATION_EXPORT BOOL MobilecoreIsForeignDCC(NSData* _Nullable proofQREncoded);

FOUNDATION_EXPORT MobilecorePublicKeysConfig* _Nullable MobilecoreNewPublicKeysConfig(NSString* _Nullable pksPath, NSError* _Nullable* _Nullable error);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreReadDomesticCredential(NSData* _Nullable credJson);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreReadEuropeanCredential(NSData* _Nullable proofQREncoded);

FOUNDATION_EXPORT MobilecoreVerificationResult* _Nullable MobilecoreVerify(NSData* _Nullable proofQREncoded, NSString* _Nullable verificationPolicy);

FOUNDATION_EXPORT MobilecoreVerificationResult* _Nullable MobilecoreVerifyWithTime(NSData* _Nullable proofQREncoded, NSString* _Nullable verificationPolicy, int64_t unixTimeSeconds);

FOUNDATION_EXPORT MobilecoreResult* _Nullable MobilecoreWrappedErrorResult(NSError* _Nullable err, NSString* _Nullable prefix);

#endif
