/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

@testable import CTR

class MappingManagerSpy: MappingManaging {

	required init(remoteConfigManager: RemoteConfigManaging) {}

	var invokedSetEventProviders = false
	var invokedSetEventProvidersCount = 0
	var invokedSetEventProvidersParameters: (providers: [EventFlow.EventProvider], Void)?
	var invokedSetEventProvidersParametersList = [(providers: [EventFlow.EventProvider], Void)]()

	func setEventProviders(_ providers: [EventFlow.EventProvider]) {
		invokedSetEventProviders = true
		invokedSetEventProvidersCount += 1
		invokedSetEventProvidersParameters = (providers, ())
		invokedSetEventProvidersParametersList.append((providers, ()))
	}

	var invokedGetProviderIdentifierMapping = false
	var invokedGetProviderIdentifierMappingCount = 0
	var invokedGetProviderIdentifierMappingParameters: (code: String?, Void)?
	var invokedGetProviderIdentifierMappingParametersList = [(code: String?, Void)]()
	var stubbedGetProviderIdentifierMappingResult: String!

	func getProviderIdentifierMapping(_ code: String? ) -> String? {
		invokedGetProviderIdentifierMapping = true
		invokedGetProviderIdentifierMappingCount += 1
		invokedGetProviderIdentifierMappingParameters = (code, ())
		invokedGetProviderIdentifierMappingParametersList.append((code, ()))
		return stubbedGetProviderIdentifierMappingResult
	}

	var invokedGetDisplayIssuer = false
	var invokedGetDisplayIssuerCount = 0
	var invokedGetDisplayIssuerParameters: (issuer: String, Void)?
	var invokedGetDisplayIssuerParametersList = [(issuer: String, Void)]()
	var stubbedGetDisplayIssuerResult: String! = ""

	func getDisplayIssuer(_ issuer: String) -> String {
		invokedGetDisplayIssuer = true
		invokedGetDisplayIssuerCount += 1
		invokedGetDisplayIssuerParameters = (issuer, ())
		invokedGetDisplayIssuerParametersList.append((issuer, ()))
		return stubbedGetDisplayIssuerResult
	}

	var invokedGetDisplayCountry = false
	var invokedGetDisplayCountryCount = 0
	var invokedGetDisplayCountryParameters: (country: String, Void)?
	var invokedGetDisplayCountryParametersList = [(country: String, Void)]()
	var stubbedGetDisplayCountryResult: String! = ""

	func getDisplayCountry(_ country: String) -> String {
		invokedGetDisplayCountry = true
		invokedGetDisplayCountryCount += 1
		invokedGetDisplayCountryParameters = (country, ())
		invokedGetDisplayCountryParametersList.append((country, ()))
		return stubbedGetDisplayCountryResult
	}

	var invokedGetDisplayFacility = false
	var invokedGetDisplayFacilityCount = 0
	var invokedGetDisplayFacilityParameters: (facility: String, Void)?
	var invokedGetDisplayFacilityParametersList = [(facility: String, Void)]()
	var stubbedGetDisplayFacilityResult: String! = ""

	func getDisplayFacility(_ facility: String) -> String {
		invokedGetDisplayFacility = true
		invokedGetDisplayFacilityCount += 1
		invokedGetDisplayFacilityParameters = (facility, ())
		invokedGetDisplayFacilityParametersList.append((facility, ()))
		return stubbedGetDisplayFacilityResult
	}

	var invokedGetTestType = false
	var invokedGetTestTypeCount = 0
	var invokedGetTestTypeParameters: (code: String?, Void)?
	var invokedGetTestTypeParametersList = [(code: String?, Void)]()
	var stubbedGetTestTypeResult: String!

	func getTestType(_ code: String? ) -> String? {
		invokedGetTestType = true
		invokedGetTestTypeCount += 1
		invokedGetTestTypeParameters = (code, ())
		invokedGetTestTypeParametersList.append((code, ()))
		return stubbedGetTestTypeResult
	}

	var invokedGetTestName = false
	var invokedGetTestNameCount = 0
	var invokedGetTestNameParameters: (code: String?, Void)?
	var invokedGetTestNameParametersList = [(code: String?, Void)]()
	var stubbedGetTestNameResult: String!

	func getTestName(_ code: String? ) -> String? {
		invokedGetTestName = true
		invokedGetTestNameCount += 1
		invokedGetTestNameParameters = (code, ())
		invokedGetTestNameParametersList.append((code, ()))
		return stubbedGetTestNameResult
	}

	var invokedGetTestManufacturer = false
	var invokedGetTestManufacturerCount = 0
	var invokedGetTestManufacturerParameters: (code: String?, Void)?
	var invokedGetTestManufacturerParametersList = [(code: String?, Void)]()
	var stubbedGetTestManufacturerResult: String!

	func getTestManufacturer(_ code: String? ) -> String? {
		invokedGetTestManufacturer = true
		invokedGetTestManufacturerCount += 1
		invokedGetTestManufacturerParameters = (code, ())
		invokedGetTestManufacturerParametersList.append((code, ()))
		return stubbedGetTestManufacturerResult
	}

	var invokedIsRatTest = false
	var invokedIsRatTestCount = 0
	var invokedIsRatTestParameters: (code: String?, Void)?
	var invokedIsRatTestParametersList = [(code: String?, Void)]()
	var stubbedIsRatTestResult: Bool! = false

	func isRatTest(_ code: String?) -> Bool {
		invokedIsRatTest = true
		invokedIsRatTestCount += 1
		invokedIsRatTestParameters = (code, ())
		invokedIsRatTestParametersList.append((code, ()))
		return stubbedIsRatTestResult
	}

	var invokedGetHpkData = false
	var invokedGetHpkDataCount = 0
	var invokedGetHpkDataParameters: (code: String?, Void)?
	var invokedGetHpkDataParametersList = [(code: String?, Void)]()
	var stubbedGetHpkDataResult: HPKData!

	func getHpkData(_ code: String? ) -> HPKData? {
		invokedGetHpkData = true
		invokedGetHpkDataCount += 1
		invokedGetHpkDataParameters = (code, ())
		invokedGetHpkDataParametersList.append((code, ()))
		return stubbedGetHpkDataResult
	}

	var invokedGetVaccinationBrand = false
	var invokedGetVaccinationBrandCount = 0
	var invokedGetVaccinationBrandParameters: (code: String?, Void)?
	var invokedGetVaccinationBrandParametersList = [(code: String?, Void)]()
	var stubbedGetVaccinationBrandResult: String!

	func getVaccinationBrand(_ code: String? ) -> String? {
		invokedGetVaccinationBrand = true
		invokedGetVaccinationBrandCount += 1
		invokedGetVaccinationBrandParameters = (code, ())
		invokedGetVaccinationBrandParametersList.append((code, ()))
		return stubbedGetVaccinationBrandResult
	}

	var invokedGetVaccinationType = false
	var invokedGetVaccinationTypeCount = 0
	var invokedGetVaccinationTypeParameters: (code: String?, Void)?
	var invokedGetVaccinationTypeParametersList = [(code: String?, Void)]()
	var stubbedGetVaccinationTypeResult: String!

	func getVaccinationType(_ code: String? ) -> String? {
		invokedGetVaccinationType = true
		invokedGetVaccinationTypeCount += 1
		invokedGetVaccinationTypeParameters = (code, ())
		invokedGetVaccinationTypeParametersList.append((code, ()))
		return stubbedGetVaccinationTypeResult
	}

	var invokedGetVaccinationManufacturerMapping = false
	var invokedGetVaccinationManufacturerMappingCount = 0
	var invokedGetVaccinationManufacturerMappingParameters: (code: String?, Void)?
	var invokedGetVaccinationManufacturerMappingParametersList = [(code: String?, Void)]()
	var stubbedGetVaccinationManufacturerMappingResult: String!

	func getVaccinationManufacturer(_ code: String? ) -> String? {
		invokedGetVaccinationManufacturerMapping = true
		invokedGetVaccinationManufacturerMappingCount += 1
		invokedGetVaccinationManufacturerMappingParameters = (code, ())
		invokedGetVaccinationManufacturerMappingParametersList.append((code, ()))
		return stubbedGetVaccinationManufacturerMappingResult
	}

	var invokedGetNlTestType = false
	var invokedGetNlTestTypeCount = 0
	var invokedGetNlTestTypeParameters: (code: String?, Void)?
	var invokedGetNlTestTypeParametersList = [(code: String?, Void)]()
	var stubbedGetNlTestTypeResult: String!

	func getNlTestType(_ code: String? ) -> String? {
		invokedGetNlTestType = true
		invokedGetNlTestTypeCount += 1
		invokedGetNlTestTypeParameters = (code, ())
		invokedGetNlTestTypeParametersList.append((code, ()))
		return stubbedGetNlTestTypeResult
	}
}