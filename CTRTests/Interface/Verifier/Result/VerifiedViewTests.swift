/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import SnapshotTesting
@testable import CTR

final class VerifiedViewTests: XCTestCase {
	
	var sut: VerifiedView!
	
	var window = UIWindow()
	
	override func setUp() {
		super.setUp()
		sut = VerifiedView()
		sut.frame.size = UIScreen.main.bounds.size
	}
	
	func test_snapshot() {
		// When
		sut.title(L.verifierResultAccessTitle())
		
		// Then
		sut.assertImage()
	}
}
