/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckUI
import XCTest
@testable import CTR
@testable import Transport
import Nimble
import SnapshotTesting
import TestingShared

class StoredEventDetailsViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: StoredEventDetailsViewController!
	private var viewModel: RemoteEventDetailsViewModel!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		environmentSpies = setupEnvironmentSpies()
		window = UIWindow()
	}

	var window = UIWindow()

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content_negativeTest() {

		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.negativeTestEvent
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "testNegativeTestGenerator"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"
		let details = NegativeTestDetailsGenerator.getDetails(identity: identity, event: event)
		viewModel = RemoteEventDetailsViewModel(
			title: L.general_negativeTest().capitalizingFirstLetter(),
			details: details,
			footer: nil
		)
		sut = StoredEventDetailsViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.general_negativeTest().capitalizingFirstLetter()

		sut.assertImage(containedInNavigationController: true)
	}

	func test_content_negativeTest_dcc() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccTest = EuCredentialAttributes.TestEntry.negativeTest
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "testDCCNegativeTestGenerator"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"
		let details = DCCTestDetailsGenerator.getDetails(identity: identity, test: dccTest)
		viewModel = RemoteEventDetailsViewModel(
			title: L.general_negativeTest().capitalizingFirstLetter(),
			details: details,
			footer: nil
		)
		sut = StoredEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.general_negativeTest().capitalizingFirstLetter()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_positiveTest() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.positiveTestEvent
		environmentSpies.mappingManagerSpy.stubbedGetTestManufacturerResult = "testPositiveTestGenerator"
		environmentSpies.mappingManagerSpy.stubbedGetTestTypeResult = "Sneltest (RAT)"
		let details = PositiveTestDetailsGenerator.getDetails(identity: identity, event: event)
		viewModel = RemoteEventDetailsViewModel(
			title: L.general_positiveTest().capitalizingFirstLetter(),
			details: details,
			footer: nil
		)
		sut = StoredEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.general_positiveTest().capitalizingFirstLetter()
		
		sut.assertImage(containedInNavigationController: true)
	}

	func test_content_recovery() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.recoveryEvent
		let details = RecoveryDetailsGenerator.getDetails(identity: identity, event: event)
		viewModel = RemoteEventDetailsViewModel(
			title: L.general_recoverycertificate().capitalizingFirstLetter(),
			details: details,
			footer: nil
		)
		sut = StoredEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.general_recoverycertificate().capitalizingFirstLetter()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_recovery_dcc() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccRecovery = EuCredentialAttributes.RecoveryEntry.recovery
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"
		let details = DCCRecoveryDetailsGenerator.getDetails(identity: identity, recovery: dccRecovery)
		viewModel = RemoteEventDetailsViewModel(
			title: L.general_recoverycertificate().capitalizingFirstLetter(),
			details: details,
			footer: nil
		)
		sut = StoredEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.general_recoverycertificate().capitalizingFirstLetter()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_vaccination() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationEvent
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Comirnaty (Pfizer)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		let details = VaccinationDetailsGenerator.getDetails(identity: identity, event: event, providerIdentifier: "CC")
		viewModel = RemoteEventDetailsViewModel(
			title: L.general_vaccination().capitalizingFirstLetter(),
			details: details,
			footer: nil
		)
		sut = StoredEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.general_vaccination().capitalizingFirstLetter()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_vaccination_dcc() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let dccVaccination = EuCredentialAttributes.Vaccination.vaccination
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Comirnaty (Pfizer)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayIssuerResult = "Facility approved by the State of The Netherlands"
		let details = DCCVaccinationDetailsGenerator.getDetails(identity: identity, vaccination: dccVaccination)
		viewModel = RemoteEventDetailsViewModel(
			title: L.general_vaccination().capitalizingFirstLetter(),
			details: details,
			footer: nil
		)
		sut = StoredEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.general_vaccination().capitalizingFirstLetter()
		
		sut.assertImage(containedInNavigationController: true)
	}
}
