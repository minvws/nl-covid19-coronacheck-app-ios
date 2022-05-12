/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
@testable import CTR
import XCTest
import SnapshotTesting
import Nimble

final class BottomSheetModalViewControllerTests: XCTestCase {
	
	/// Subject under test
	private var sut: BottomSheetModalViewController!
	
	private var window: UIWindow!
	
	override func setUp() {
		super.setUp()

		window = UIWindow()
		isRecording = false
	}
	
	func loadView() {

		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_content() {
		// Given
		createSut()

		// When
		loadView()

		// Then
		sut.assertImage()
	}
}

private extension BottomSheetModalViewControllerTests {
	
	func createSut() {
		let viewControllerToPresent = SnapshotViewController(viewModel: .init(flavor: .holder))
		let topMargin: CGFloat = 62
		viewControllerToPresent.view.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			viewControllerToPresent.view.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width),
			viewControllerToPresent.view.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height - topMargin)
		])
		
		sut = BottomSheetModalViewController(childViewController: viewControllerToPresent)
	}
}
