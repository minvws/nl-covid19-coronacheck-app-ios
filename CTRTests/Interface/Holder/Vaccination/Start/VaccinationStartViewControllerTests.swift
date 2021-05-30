/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting

class VaccinationStartViewControllerTests: XCTestCase {

	// MARK: Subject under test
	private var sut: VaccinationStartViewController!
	private var coordinatorSpy: VaccinationCoordinatorDelegateSpy!
	private var viewModel: VaccinationStartViewModel!

	var window = UIWindow()

	// MARK: Test lifecycle
	override func setUp() {

		super.setUp()
		coordinatorSpy = VaccinationCoordinatorDelegateSpy()
		viewModel = VaccinationStartViewModel(coordinator: coordinatorSpy)
		sut = VaccinationStartViewController(viewModel: viewModel)
		window = UIWindow()
	}

	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}

	// MARK: - Tests

	func test_content() {

		// Given

		// When
		loadView()

		// Then
		expect(self.sut.sceneView.title) ==  .holderVaccinationStartTitle
		expect(self.sut.sceneView.message) ==  .holderVaccinationStartMessage

		sut.assertImage(containedInNavigationController: true)
	}

	func test_backButtonTapped() {

		// Given
		loadView()

		// When
		sut.backButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinishParameters?.0) == .back
	}

	func test_primaryButtonTapped() {

		// Given
		loadView()

		// When
		sut.sceneView.primaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedVaccinationStartScreenDidFinishParameters?.0) == .continue(value: nil)
	}

	func test_secondaryButtonTapped() {

		// Given
		loadView()

		// When
		sut.sceneView.secondaryButtonTapped()

		// Then
		expect(self.coordinatorSpy.invokedOpenUrl) == true
		expect(self.coordinatorSpy.invokedOpenUrlParameters?.0) == URL(string: .holderVaccinationStartNoDigiDURL)
	}
}
