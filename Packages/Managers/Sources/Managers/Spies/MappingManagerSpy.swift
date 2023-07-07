/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared

public class MappingManagerSpy: MappingManaging {
	
	public init() {}

	public var invokedGetProviderIdentifierMapping = false
	public var invokedGetProviderIdentifierMappingCount = 0
	public var invokedGetProviderIdentifierMappingParameters: (code: String?, Void)?
	public var invokedGetProviderIdentifierMappingParametersList = [(code: String?, Void)]()
	public var stubbedGetProviderIdentifierMappingResult: String!

	public func getProviderIdentifierMapping(_ code: String? ) -> String? {
		invokedGetProviderIdentifierMapping = true
		invokedGetProviderIdentifierMappingCount += 1
		invokedGetProviderIdentifierMappingParameters = (code, ())
		invokedGetProviderIdentifierMappingParametersList.append((code, ()))
		return stubbedGetProviderIdentifierMappingResult
	}

	public var invokedGetDisplayIssuer = false
	public var invokedGetDisplayIssuerCount = 0
	public var invokedGetDisplayIssuerParameters: (issuer: String, country: String)?
	public var invokedGetDisplayIssuerParametersList = [(issuer: String, country: String)]()
	public var stubbedGetDisplayIssuerResult: String! = ""

	public func getDisplayIssuer(_ issuer: String, country: String) -> String {
		invokedGetDisplayIssuer = true
		invokedGetDisplayIssuerCount += 1
		invokedGetDisplayIssuerParameters = (issuer, country)
		invokedGetDisplayIssuerParametersList.append((issuer, country))
		return stubbedGetDisplayIssuerResult
	}

	public var invokedGetBilingualDisplayCountry = false
	public var invokedGetBilingualDisplayCountryCount = 0
	public var invokedGetBilingualDisplayCountryParameters: (country: String, languageCode: String?)?
	public var invokedGetBilingualDisplayCountryParametersList = [(country: String, languageCode: String?)]()
	public var stubbedGetBilingualDisplayCountryResult: String! = ""

	public func getBilingualDisplayCountry(_ country: String, languageCode: String?) -> String {
		invokedGetBilingualDisplayCountry = true
		invokedGetBilingualDisplayCountryCount += 1
		invokedGetBilingualDisplayCountryParameters = (country, languageCode)
		invokedGetBilingualDisplayCountryParametersList.append((country, languageCode))
		return stubbedGetBilingualDisplayCountryResult
	}

	public var invokedGetDisplayCountry = false
	public var invokedGetDisplayCountryCount = 0
	public var invokedGetDisplayCountryParameters: (country: String, Void)?
	public var invokedGetDisplayCountryParametersList = [(country: String, Void)]()
	public var stubbedGetDisplayCountryResult: String! = ""

	public func getDisplayCountry(_ country: String) -> String {
		invokedGetDisplayCountry = true
		invokedGetDisplayCountryCount += 1
		invokedGetDisplayCountryParameters = (country, ())
		invokedGetDisplayCountryParametersList.append((country, ()))
		return stubbedGetDisplayCountryResult
	}

	public var invokedGetDisplayFacility = false
	public var invokedGetDisplayFacilityCount = 0
	public var invokedGetDisplayFacilityParameters: (facility: String, Void)?
	public var invokedGetDisplayFacilityParametersList = [(facility: String, Void)]()
	public var stubbedGetDisplayFacilityResult: String! = ""

	public func getDisplayFacility(_ facility: String) -> String {
		invokedGetDisplayFacility = true
		invokedGetDisplayFacilityCount += 1
		invokedGetDisplayFacilityParameters = (facility, ())
		invokedGetDisplayFacilityParametersList.append((facility, ()))
		return stubbedGetDisplayFacilityResult
	}

	public var invokedGetTestType = false
	public var invokedGetTestTypeCount = 0
	public var invokedGetTestTypeParameters: (code: String?, Void)?
	public var invokedGetTestTypeParametersList = [(code: String?, Void)]()
	public var stubbedGetTestTypeResult: String!

	public func getTestType(_ code: String? ) -> String? {
		invokedGetTestType = true
		invokedGetTestTypeCount += 1
		invokedGetTestTypeParameters = (code, ())
		invokedGetTestTypeParametersList.append((code, ()))
		return stubbedGetTestTypeResult
	}

	public var invokedGetTestName = false
	public var invokedGetTestNameCount = 0
	public var invokedGetTestNameParameters: (code: String?, Void)?
	public var invokedGetTestNameParametersList = [(code: String?, Void)]()
	public var stubbedGetTestNameResult: String!

	public func getTestName(_ code: String? ) -> String? {
		invokedGetTestName = true
		invokedGetTestNameCount += 1
		invokedGetTestNameParameters = (code, ())
		invokedGetTestNameParametersList.append((code, ()))
		return stubbedGetTestNameResult
	}

	public var invokedGetTestManufacturer = false
	public var invokedGetTestManufacturerCount = 0
	public var invokedGetTestManufacturerParameters: (code: String?, Void)?
	public var invokedGetTestManufacturerParametersList = [(code: String?, Void)]()
	public var stubbedGetTestManufacturerResult: String!

	public func getTestManufacturer(_ code: String? ) -> String? {
		invokedGetTestManufacturer = true
		invokedGetTestManufacturerCount += 1
		invokedGetTestManufacturerParameters = (code, ())
		invokedGetTestManufacturerParametersList.append((code, ()))
		return stubbedGetTestManufacturerResult
	}

	public var invokedIsRatTest = false
	public var invokedIsRatTestCount = 0
	public var invokedIsRatTestParameters: (code: String?, Void)?
	public var invokedIsRatTestParametersList = [(code: String?, Void)]()
	public var stubbedIsRatTestResult: Bool! = false

	public func isRatTest(_ code: String?) -> Bool {
		invokedIsRatTest = true
		invokedIsRatTestCount += 1
		invokedIsRatTestParameters = (code, ())
		invokedIsRatTestParametersList.append((code, ()))
		return stubbedIsRatTestResult
	}

	public var invokedGetHpkData = false
	public var invokedGetHpkDataCount = 0
	public var invokedGetHpkDataParameters: (code: String?, Void)?
	public var invokedGetHpkDataParametersList = [(code: String?, Void)]()
	public var stubbedGetHpkDataResult: HPKData!

	public func getHpkData(_ code: String? ) -> HPKData? {
		invokedGetHpkData = true
		invokedGetHpkDataCount += 1
		invokedGetHpkDataParameters = (code, ())
		invokedGetHpkDataParametersList.append((code, ()))
		return stubbedGetHpkDataResult
	}

	public var invokedGetVaccinationBrand = false
	public var invokedGetVaccinationBrandCount = 0
	public var invokedGetVaccinationBrandParameters: (code: String?, Void)?
	public var invokedGetVaccinationBrandParametersList = [(code: String?, Void)]()
	public var stubbedGetVaccinationBrandResult: String!

	public func getVaccinationBrand(_ code: String? ) -> String? {
		invokedGetVaccinationBrand = true
		invokedGetVaccinationBrandCount += 1
		invokedGetVaccinationBrandParameters = (code, ())
		invokedGetVaccinationBrandParametersList.append((code, ()))
		return stubbedGetVaccinationBrandResult
	}

	public var invokedGetVaccinationType = false
	public var invokedGetVaccinationTypeCount = 0
	public var invokedGetVaccinationTypeParameters: (code: String?, Void)?
	public var invokedGetVaccinationTypeParametersList = [(code: String?, Void)]()
	public var stubbedGetVaccinationTypeResult: String!

	public func getVaccinationType(_ code: String? ) -> String? {
		invokedGetVaccinationType = true
		invokedGetVaccinationTypeCount += 1
		invokedGetVaccinationTypeParameters = (code, ())
		invokedGetVaccinationTypeParametersList.append((code, ()))
		return stubbedGetVaccinationTypeResult
	}

	public var invokedGetVaccinationManufacturer = false
	public var invokedGetVaccinationManufacturerCount = 0
	public var invokedGetVaccinationManufacturerParameters: (code: String?, Void)?
	public var invokedGetVaccinationManufacturerParametersList = [(code: String?, Void)]()
	public var stubbedGetVaccinationManufacturerResult: String!

	public func getVaccinationManufacturer(_ code: String? ) -> String? {
		invokedGetVaccinationManufacturer = true
		invokedGetVaccinationManufacturerCount += 1
		invokedGetVaccinationManufacturerParameters = (code, ())
		invokedGetVaccinationManufacturerParametersList.append((code, ()))
		return stubbedGetVaccinationManufacturerResult
	}
}
