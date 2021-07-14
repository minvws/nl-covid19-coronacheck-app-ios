//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
import SnapshotTesting
@testable import CTR

class DCCTokenEntryViewModelTests: XCTestCase {

	var sut: DCCTokenEntryViewModel!
	var coordinatorDelegateSpy: HolderCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		sut = DCCTokenEntryViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_initialState() {
		expect(self.sut.title) == L.holderDcctokenentryTitle()
		expect(self.sut.header) == L.holderDcctokenentryHeader()
		expect(self.sut.tokenEntryFieldTitle) == L.holderDcctokenentryTitle()
		expect(self.sut.tokenEntryFieldPlaceholder) == L.holderDcctokenentryTokenFieldPlaceholder()
		expect(self.sut.nextButtonTitle) == L.holderDcctokenentryNext()
		expect(self.sut.fieldErrorMessage).to(beNil())
		expect(self.sut.userNeedsATokenButtonTitle) == L.holderDcctokenentryButtonNotoken()

		DCCTokenEntryViewController(viewModel: sut).assertImage()
	}

	func test_inputtingShortValue_doesntShowError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "a")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
	}

	func test_inputtingValidValue_doesNothing(){
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdef")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
	}

	func test_inputtingLongValue_doesNothing(){
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdefg")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
	}

	func test_tappingSubmit_withShortValue_showsError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "a")
		sut.nextButtonTapped()

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderDcctokenentryErrorCodewrongformat()
	}

	func test_tappingSubmit_withLongValue_showsError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdefg")
		sut.nextButtonTapped()

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderDcctokenentryErrorCodewrongformat()
	}

	func test_tappingSubmit_withIllegalCharacters_showsError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abc$eg")
		sut.nextButtonTapped()

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderDcctokenentryErrorCodenotfound()
	}

	func test_changingValueAfterPressingSubmitClearsErrorMessage() {
		// Arrange
		sut.userDidUpdateTokenField(rawTokenInput: "abc$eg")
		sut.nextButtonTapped()

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abc")

		// Assert
		expect(self.sut.fieldErrorMessage).to(beNil())
	}

	// TODO: complete
	func test_tappingSubmit_withValidValue_doesSomething() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdef")
		sut.nextButtonTapped()

		// Assert

	}

	// TODO: complete
	func test_tappingSubmit_withValidLowercaseValue_submitsUppercasedValue() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdef")
		sut.nextButtonTapped()

		// Assert

	}
}
