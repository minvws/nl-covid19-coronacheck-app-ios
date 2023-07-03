/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import XCTest
import SnapshotTesting
import Nimble
import Shared
@testable import ReusableViews
@testable import Resources

final class PageControlTests: XCTestCase {
	
	var sut: PageControl!
	var backgroundView: UIStackView!

	override class func setUp() {
		super.setUp()
		registerFonts()
	}
	
	override func setUp() {
		super.setUp()
		
		sut = PageControl()
		backgroundView = UIStackView()
		backgroundView.backgroundColor = C.white()
		backgroundView.addArrangedSubview(sut)
		backgroundView.frame = .init(origin: .zero, size: CGSize(width: 150, height: 80))
	}
	
	func test_numberOfPages() {
		// Given
		
		// When
		sut.numberOfPages = 5
		
		// Then
		
		backgroundView.assertImage()
	}
	
	func test_updateForPageIndex() {
		// Given
		sut.numberOfPages = 5
		
		// When
		sut.update(for: 4)
		
		// Then
		backgroundView.assertImage()
	}
	
	func test_accessibilityValue() {
		// Given
		sut.numberOfPages = 5
		
		// When
		sut.update(for: 4)
		
		// Then
		expect(self.sut.accessibilityValue) == "Pagina 5 van 5"
	}
}
