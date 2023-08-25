/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
import Nimble
@testable import Managers
@testable import Models
@testable import Shared
@testable import Resources

class NewFeaturesManagerTests: XCTestCase {
	
	// MARK: - Setup
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (NewFeaturesManager, SecureUserSettingsSpy, FeatureFlagManagerSpy) {
			
		// The direct dependencies of Managers are still injected in the init:
		let secureUserSettingsSpy = SecureUserSettingsSpy()
		secureUserSettingsSpy.stubbedForcedInformationData = .empty
		let sut = NewFeaturesManager(secureUserSettings: secureUserSettingsSpy)
		let featureFlagManagerSpy = FeatureFlagManagerSpy()
		featureFlagManagerSpy.stubbedIsInArchiveModeResult = false
		sut.factory = HolderNewFeaturesFactory(featureFlagManager: featureFlagManagerSpy)

		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, secureUserSettingsSpy, featureFlagManagerSpy)
	}
	
	// MARK: - Tests
	
	/// Test needs updating
	func testGetNeedsUpdating() {
		
		// Given
		let (sut, _, _) = makeSUT()
		sut.wipePersistedData()
		
		// When
		
		// Then
		expect(sut.needsUpdating) == true
	}
	
	/// Test needs updating
	func testGetNeedsUpdating_verifier_disabled() {
		
		// Given
		let (sut, _, _) = makeSUT()
		sut.factory = VerifierNewFeaturesFactory()
		sut.wipePersistedData()
		
		// When
		
		// Then
		expect(sut.needsUpdating) == false
	}
	
	func testUserHasViewedNewFeatureIntro() {
		
		// Given
		let (sut, secureUserSettingsSpy, _) = makeSUT()
		
		// When
		sut.userHasViewedNewFeatureIntro()
		
		// Then
		expect(secureUserSettingsSpy.invokedForcedInformationData?.lastSeenVersion) == sut.factory?.information.version
	}
	
	func test_getUpdatePage_holder() {
		
		// Given
		let (sut, _, _) = makeSUT()
		let expectedPage = PagedAnnoucementItem(
			title: L.holder_newintheapp_foreignproofs_title(),
			content: L.holder_newintheapp_foreignproofs_body(),
			image: I.newInTheApp.paperDCC(),
			imageBackgroundColor: C.white(),
			tagline: L.general_newintheapp(),
			step: 0
		)
		
		// When
		let actualPage = sut.pagedAnnouncementItems()
		
		// Then
		expect(actualPage) == [expectedPage]
	}
	
	func test_getUpdatePage_holder_archiveMode() {
		
		// Given
		let (sut, _, featureFlagManagerSpy) = makeSUT()
		featureFlagManagerSpy.stubbedIsInArchiveModeResult = true
		let expectedPage = PagedAnnoucementItem(
			title: L.holder_newintheapp_archiveMode_title(),
			content: L.holder_newintheapp_archiveMode_body(),
			image: I.newInTheApp.archiveMode(),
			imageBackgroundColor: C.white(),
			tagline: L.general_newintheapp(),
			step: 0
		)
		
		// When
		let actualPage = sut.pagedAnnouncementItems()
		
		// Then
		expect(actualPage) == [expectedPage]
	}
	
	func test_getUpdatePage_verifier() {
		
		// Given
		let (sut, _, _) = makeSUT()
		let expectedPage = PagedAnnoucementItem(
			title: L.new_in_app_risksetting_title(),
			content: L.new_in_app_risksetting_subtitle(),
			image: I.onboarding.tabbarNL(),
			imageBackgroundColor: C.forcedInformationImage(),
			tagline: L.new_in_app_subtitle(),
			step: 0
		)
		sut.factory = VerifierNewFeaturesFactory()
		
		// When
		let actualPage = sut.pagedAnnouncementItems()
		
		// Then
		expect(actualPage) == [expectedPage]
	}
}
