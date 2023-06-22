/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import CTR
import SnapshotTesting

final class ExportPDFiewControllerTests: XCTestCase {
	
	private var sut: PDFExportViewController!
	private var viewModel: PDFExportViewModel!
	private var window = UIWindow()
	private var environmentSpies: EnvironmentSpies!
	private var coordinatorSpy: PDFExportCoordinatorSpy!
	
	override func setUp() {
		super.setUp()
		
		coordinatorSpy = PDFExportCoordinatorSpy()
		environmentSpies = setupEnvironmentSpies()
		viewModel = PDFExportViewModel(coordinator: coordinatorSpy)
		sut = PDFExportViewController(viewModel: viewModel)
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_loadingState() {
		
		// Given
		viewModel.state.value = .loading
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_successState() {
		
		// Given
		viewModel.state.value = .success
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}
}
