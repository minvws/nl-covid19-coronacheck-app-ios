/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import ViewControllerPresentationSpy
@testable import CTR
import Nimble
import SnapshotTesting

class AboutThisAppViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	private var sut: AboutThisAppViewController!
	private var environmentSpies: EnvironmentSpies!
	private var outcomes: [AboutThisAppViewModel.Outcome]!
	
	var window: UIWindow!
	
	// MARK: Test lifecycle
	override func setUp() {
		super.setUp()
		environmentSpies = setupEnvironmentSpies()

		outcomes = [AboutThisAppViewModel.Outcome]()
		let viewModel = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.holder,
			outcomeHandler: { [unowned self] outcome in
				self.outcomes.append(outcome)
			}
		)
		
		sut = AboutThisAppViewController(viewModel: viewModel)
		window = UIWindow()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: Test
	
	func test_content_holder() {
		
		// Given
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.holderAboutTitle()
		expect(self.sut.sceneView.message) == L.holderAboutText()
		expect(self.sut.sceneView.menuStackView.arrangedSubviews)
			.to(haveCount(2))
		expect((self.sut.sceneView.menuStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews)
			.to(haveCount(7))
		expect((self.sut.sceneView.menuStackView.arrangedSubviews[1] as? UIStackView)?.arrangedSubviews)
			.to(haveCount(6))
		expect(self.sut.sceneView.appVersion).toNot(beNil())

		sut.assertImage()
	}
	
	func test_content_verifier_verificationPolicyEnabled() {
		
		// Given
		environmentSpies.featureFlagManagerSpy.stubbedAreMultipleVerificationPoliciesEnabledResult = true
		let viewModel = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { outcome in
				self.outcomes.append(outcome)
			}
		)
		sut = AboutThisAppViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.verifierAboutTitle()
		expect(self.sut.sceneView.message) == L.verifierAboutText()
		expect(self.sut.sceneView.menuStackView.arrangedSubviews)
			.to(haveCount(2))
		expect((self.sut.sceneView.menuStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews)
			.to(haveCount(5))
		expect((self.sut.sceneView.menuStackView.arrangedSubviews[1] as? UIStackView)?.arrangedSubviews)
			.to(haveCount(2))
		expect(self.sut.sceneView.appVersion).toNot(beNil())
		
		sut.assertImage()
	}
	
	func test_content_verifier_verificationPolicyDisabled() {
		
		// Given
		let viewModel = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { [unowned self] outcome in
				self.outcomes.append(outcome)
			}
		)
		sut = AboutThisAppViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.title) == L.verifierAboutTitle()
		expect(self.sut.sceneView.message) == L.verifierAboutText()
		expect(self.sut.sceneView.menuStackView.arrangedSubviews)
			.to(haveCount(1))
		expect((self.sut.sceneView.menuStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews)
			.to(haveCount(5))
		expect(self.sut.sceneView.appVersion).toNot(beNil())
		
		sut.assertImage()
	}
	
	func test_resetAlertDialog_verifier() {
		
		// Given
		let viewModel = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { [unowned self] outcome in
				self.outcomes.append(outcome)
			}
		)
		sut = AboutThisAppViewController(viewModel: viewModel)
		let alertVerifier = AlertVerifier()
		loadView()
		
		// When
		((sut.sceneView.menuStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews[4] as? SimpleDisclosureButton)?.primaryButtonTapped()
		
		// Then
		alertVerifier.verify(
			title: L.holderCleardataAlertTitle(),
			message: L.holderCleardataAlertSubtitle(),
			animated: true,
			actions: [
				.destructive(L.holderCleardataAlertRemove()),
				.cancel(L.general_cancel())
			]
		)
	}

	func test_resetData_holder() throws {
		
		// Given
		let alertVerifier = AlertVerifier()
		loadView()
		((sut.sceneView.menuStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews[5] as? SimpleDisclosureButton)?.primaryButtonTapped()
		
		// When
		try alertVerifier.executeAction(forButton: L.holderCleardataAlertRemove())
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == true
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == true
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.onboardingManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.newFeaturesManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.userSettingsSpy.invokedWipePersistedData) == true
		expect(self.outcomes).to(haveCount(1))
		expect(self.outcomes[0]) == .coordinatorShouldRestart
	}
	
	func test_resetData_verifier() throws {
		
		// Given
		let viewModel = AboutThisAppViewModel(
			versionSupplier: AppVersionSupplierSpy(version: "1.0.0"),
			flavor: AppFlavor.verifier,
			outcomeHandler: { [unowned self] outcome in
				self.outcomes.append(outcome)
			}
		)
		sut = AboutThisAppViewController(viewModel: viewModel)
		let alertVerifier = AlertVerifier()
		loadView()
		((sut.sceneView.menuStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews[4] as? SimpleDisclosureButton)?.primaryButtonTapped()
		
		// When
		try alertVerifier.executeAction(forButton: L.holderCleardataAlertRemove())
		
		// Then
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingGreenCards) == false
		expect(self.environmentSpies.walletManagerSpy.invokedRemoveExistingEventGroups) == false
		expect(self.environmentSpies.remoteConfigManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.cryptoLibUtilitySpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.onboardingManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.newFeaturesManagerSpy.invokedWipePersistedData) == true
		expect(self.environmentSpies.userSettingsSpy.invokedWipePersistedData) == true
		expect(self.outcomes).to(haveCount(1))
		expect(self.outcomes[0]) == .coordinatorShouldRestart
	}
	
	func test_storedEventsOptionTapped_forHolder() {
		
		// Given
		loadView()
		
		// When
		((sut.sceneView.menuStackView.arrangedSubviews[0] as? UIStackView)?.arrangedSubviews[4] as? SimpleDisclosureButton)?.primaryButtonTapped()
		
		// Then
		expect(self.outcomes).to(haveCount(1))
		expect(self.outcomes[0]) == .userWishesToSeeStoredEvents
	}
}
