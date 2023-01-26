/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
@testable import Transport
@testable import Shared
import Nimble
import SnapshotTesting
import TestingShared

class RemoteEventDetailsViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: RemoteEventDetailsViewController!
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
			title: L.holderEventAboutTitle(),
			details: details,
			footer: nil
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) == L.holderEventAboutTitle()
		expect(self.sut.sceneView.footer) == nil

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
			title: L.holderDccTestDetailsTitle(),
			details: details,
			footer: L.holderDccTestFooter()
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderDccRecoveryDetailsTitle()
		expect(self.sut.sceneView.footer) == L.holderDccRecoveryFooter()
		
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
			title: L.holderEventAboutTitle(),
			details: details,
			footer: nil
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderEventAboutTitle()
		expect(self.sut.sceneView.footer) == nil
		
		sut.assertImage(containedInNavigationController: true)
	}

	func test_content_recovery() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.recoveryEvent
		let details = RecoveryDetailsGenerator.getDetails(identity: identity, event: event)
		viewModel = RemoteEventDetailsViewModel(
			title: L.holderEventAboutTitle(),
			details: details,
			footer: nil
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderEventAboutTitle()
		expect(self.sut.sceneView.footer) == nil
		
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
			title: L.holderDccRecoveryDetailsTitle(),
			details: details,
			footer: L.holderDccRecoveryFooter()
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderDccRecoveryDetailsTitle()
		expect(self.sut.sceneView.footer) == L.holderDccRecoveryFooter()
		
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
			title: L.holderEventAboutTitle(),
			details: details,
			footer: nil
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderEventAboutTitle()
		expect(self.sut.sceneView.footer) == nil
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_vaccination_combined() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationEvent
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationBrandResult = "Comirnaty (Pfizer)"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationTypeResult = "SARS-CoV-2 mRNA vaccine"
		environmentSpies.mappingManagerSpy.stubbedGetVaccinationManufacturerResult = "Biontech"
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		var details = VaccinationDetailsGenerator.getDetails(identity: identity, event: event, providerIdentifier: "CC 1")
		details += [EventDetails(field: EventDetailsVaccination.separator, value: nil)]
		details += VaccinationDetailsGenerator.getDetails(identity: identity, event: event, providerIdentifier: "CC 2")
		viewModel = RemoteEventDetailsViewModel(
			title: L.holderEventAboutTitle(),
			details: details,
			footer: nil
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderEventAboutTitle()
		expect(self.sut.sceneView.footer) == nil
		
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
			title: L.holderDccVaccinationDetailsTitle(),
			details: details,
			footer: L.holderDccVaccinationFooter()
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderDccVaccinationDetailsTitle()
		expect(self.sut.sceneView.footer) == L.holderDccVaccinationFooter()
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_vaccinationAssessment() {
		
		// Given
		let identity = EventFlow.Identity.fakeIdentity
		let event = EventFlow.Event.vaccinationAssessmentEvent
		environmentSpies.mappingManagerSpy.stubbedGetDisplayCountryResult = "NL"
		let details = VaccinationAssessementDetailsGenerator.getDetails(identity: identity, event: event)
		viewModel = RemoteEventDetailsViewModel(
			title: L.holderEventAboutTitle(),
			details: details,
			footer: nil
		)
		sut = RemoteEventDetailsViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holderEventAboutTitle()
		expect(self.sut.sceneView.footer) == nil
		
		sut.assertImage(containedInNavigationController: true)
	}
}
