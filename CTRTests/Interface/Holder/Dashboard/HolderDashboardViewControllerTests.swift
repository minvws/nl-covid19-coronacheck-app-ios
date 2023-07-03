/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import XCTest
import SnapshotTesting
import CoreData
import Nimble
import Shared
@testable import CTR
@testable import Resources

class HolderDashboardViewControllerTests: XCTestCase {

	var viewModelSpy: HolderDashboardViewModelSpy!
	
	override func setUp() {
		super.setUp()
		viewModelSpy = HolderDashboardViewModelSpy()
		viewModelSpy.stubbedTitle = Observable(value: L.holderDashboardTitle())
		viewModelSpy.stubbedInternationalCards = Observable(value: [])
		viewModelSpy.stubbedPrimaryButtonTitle = Observable(value: L.holderMenuProof())
		viewModelSpy.stubbedCurrentlyPresentedAlert = Observable(value: nil)
		viewModelSpy.stubbedShouldShowAddCertificateFooter = Observable(value: false)
	}
	
	func test_footerButtonPrimaryButtonTap() {
		
		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		sut.viewDidLoad()
		
		// Act
		sut.sceneView.footerButtonView.primaryButtonTappedCommand?()
		
		// Assert
		expect(self.viewModelSpy.invokedAddCertificateFooterTapped) == true
	}
	
	func test_menuButtonTap() {
		
		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		sut.viewDidLoad()
		
		// Act
		sut.sceneView.tapMenuButtonHandler?()
		
		// Assert
		expect(self.viewModelSpy.invokedUserTappedMenuButton) == true
	}
	
	func test_viewWillAppear() {
		
		// Arrange
		let sut = HolderDashboardViewController(viewModel: viewModelSpy)
		sut.viewDidLoad()
		
		// Act
		sut.viewWillAppear(false)
		
		// Assert
		expect(self.viewModelSpy.invokedViewWillAppear) == true
	}
}
