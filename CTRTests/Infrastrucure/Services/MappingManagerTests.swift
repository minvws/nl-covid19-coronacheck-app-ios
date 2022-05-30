/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

@testable import CTR
import XCTest
import Nimble

class MappingManagerTests: XCTestCase {
	
	private var sut: MappingManager!
	private var remoteConfigManagerSpy: RemoteConfigManagingSpy!
	
	override func setUp() {
		
		super.setUp()
		remoteConfigManagerSpy = RemoteConfigManagingSpy()
		remoteConfigManagerSpy.stubbedStoredConfiguration = .default
	}
	
	// MARK: getProviderIdentifierMapping

	func test_providerIdentifierMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.providerIdentifiers = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getProviderIdentifierMapping("Test")
		
		// Then
		expect(mapped) == "Test Corona Check"
	}
	
	func test_providerIdentifierMapping_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.providerIdentifiers = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getProviderIdentifierMapping("wrong")
		
		// Then
		expect(mapped).to(beNil())
	}
	
	// MARK: getDisplayIssuer
	
	func test_getDisplayIssuer() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayIssuer("Test", country: "NL")
		
		// Then
		expect(mapped) == "Test"
	}

	func test_getDisplayIssuer_translated_nl() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayIssuer("Ministry of Health Welfare and Sport", country: "NL")
		
		// Then
		expect(mapped) == "Ministerie van VWS / Ministry of Health, Welfare and Sport"
	}
	
	func test_getDisplayIssuer_translated_nld() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayIssuer("Ministry of Health Welfare and Sport", country: "NLD")
		
		// Then
		expect(mapped) == "Ministerie van VWS / Ministry of Health, Welfare and Sport"
	}
	
	func test_getDisplayIssuer_germanIssuer() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayIssuer("Ministry of Health Welfare and Sport", country: "DE")
		
		// Then
		expect(mapped) == "Ministry of Health Welfare and Sport"
	}
	
	// MARK: getBilingualDisplayCountry
	
	func test_getBilingualDisplayCountry_nl() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getBilingualDisplayCountry("NL")
		
		// Then
		expect(mapped) == "Nederland / The Netherlands"
	}
	
	func test_getBilingualDisplayCountry_nld() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getBilingualDisplayCountry("NLD")
		
		// Then
		expect(mapped) == "Nederland / The Netherlands"
	}
	
	func test_getBilingualDisplayCountry_germany() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getBilingualDisplayCountry("DE")
		
		// Then
		expect(mapped) == "Duitsland / Germany"
	}
	
	func test_getBilingualDisplayCountry_belgium() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getBilingualDisplayCountry("BE")
		
		// Then
		expect(mapped) == "België / Belgium"
	}
	
	// MARK: - getDisplayCountry
	
	func test_getDisplayCountry_nl() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayCountry("NL")
		
		// Then
		expect(mapped) == "Nederland"
	}
	
	func test_getDisplayCountry_nld() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayCountry("NLD")
		
		// Then
		expect(mapped) == "Nederland"
	}
	
	func test_getDisplayCountry_germany() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayCountry("DE")
		
		// Then
		expect(mapped) == "Duitsland"
	}
	
	func test_getDisplayCountry_belgium() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayCountry("BE")
		
		// Then
		expect(mapped) == "België"
	}
	
	// MARK: - getDisplayFacility
	
	func test_getDisplayFacility() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayFacility("Test")
		
		// Then
		expect(mapped) == "Test"
	}
	
	func test_getDisplayFacility_translated() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getDisplayFacility("Facility approved by the State of The Netherlands")
		
		// Then
		expect(mapped) == "Facility approved by the State of The Netherlands"
	}
	
	// MARK: - getTestType
	
	func test_getTestType() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euTestTypes = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getTestType("Test")
		
		// Then
		expect(mapped) == "Test Corona Check"
	}
	
	func test_getTestType_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euTestTypes = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getTestType("Wrong")
		
		// Then
		expect(mapped).to(beNil())
	}
	
	// MARK: - getTestName
	
	func test_getTestName() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euTestNames = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getTestName("Test")
		
		// Then
		expect(mapped) == "Test Corona Check"
	}
	
	func test_getTestName_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euTestNames = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getTestName("Wrong")
		
		// Then
		expect(mapped).to(beNil())
	}
	
	// MARK: - getTestManufacturer
	
	func test_getTestManufacturer() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euTestManufacturers = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getTestManufacturer("Test")
		
		// Then
		expect(mapped) == "Test Corona Check"
	}
	
	func test_getTestManufacturer_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euTestManufacturers = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getTestManufacturer("Wrong")
		
		// Then
		expect(mapped).to(beNil())
	}
	
	// MARK: isRatTest

	func test_isRatTest_rat() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.isRatTest("LP217198-3")
		
		// Then
		expect(mapped) == true
	}
	
	func test_isRatTest_naat() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.isRatTest("LP6464-4")
		
		// Then
		expect(mapped) == false
	}
	
	func test_isRatTest_other() {
		
		// Given
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.isRatTest("test")
		
		// Then
		expect(mapped) == false
	}
	
	// MARK: getHpkData
	
	func test_getHpkData() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.hpkCodes = [
			HPKData(code: "Test", name: "Test Corona Check", vp: "vp", mp: "mp", ma: "ma")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getHpkData("Test")
		
		// Then
		expect(mapped?.name) == "Test Corona Check"
		expect(mapped?.code) == "Test"
		expect(mapped?.vp) == "vp"
		expect(mapped?.mp) == "mp"
		expect(mapped?.ma) == "ma"
	}
	
	func test_getHpkData_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.hpkCodes = [
			HPKData(code: "Test", name: "Test Corona Check", vp: "vp", mp: "mp", ma: "ma")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getHpkData("Wrong")
		
		// Then
		expect(mapped).to(beNil())
	}

	// MARK: - getVaccinationBrand
	
	func test_getVaccinationBrand() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euBrands = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getVaccinationBrand("Test")
		
		// Then
		expect(mapped) == "Test Corona Check"
	}
	
	func test_getVaccinationBrand_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euBrands = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getVaccinationBrand("Wrong")
		
		// Then
		expect(mapped).to(beNil())
	}
	
	// MARK: - getVaccinationType
	
	func test_getVaccinationType() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euVaccinationTypes = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getVaccinationType("Test")
		
		// Then
		expect(mapped) == "Test Corona Check"
	}
	
	func test_getVaccinationType_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euVaccinationTypes = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getVaccinationType("Wrong")
		
		// Then
		expect(mapped).to(beNil())
	}
	
	// MARK: - getVaccinationManufacturer
	
	func test_getVaccinationManufacturer() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euManufacturers = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getVaccinationManufacturer("Test")
		
		// Then
		expect(mapped) == "Test Corona Check"
	}
	
	func test_getVaccinationManufacturer_missingMapping() {
		
		// Given
		remoteConfigManagerSpy.stubbedStoredConfiguration.euManufacturers = [
			Mapping(code: "Test", name: "Test Corona Check")
		]
		sut = MappingManager(remoteConfigManager: remoteConfigManagerSpy)
		
		// When
		let mapped = sut.getVaccinationManufacturer("Wrong")
		
		// Then
		expect(mapped).to(beNil())
	}
}
