/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
import Nimble
@testable import CTR

// swiftlint:disable:next type_name
class PaperProofInputCouplingCodeViewModelTests: XCTestCase {

	var sut: PaperProofInputCouplingCodeViewModel!
	var coordinatorDelegateSpy: PaperProofCoordinatorDelegateSpy!

	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = PaperProofCoordinatorDelegateSpy()
		sut = PaperProofInputCouplingCodeViewModel(coordinator: coordinatorDelegateSpy)
	}

	func test_initialState() {
		expect(self.sut.title) == L.holderDcctokenentryTitle()
		expect(self.sut.header) == L.holderDcctokenentryHeader()
		expect(self.sut.tokenEntryFieldTitle) == L.holderDcctokenentryTokenFieldTitle()
		expect(self.sut.tokenEntryFieldPlaceholder) == L.holderDcctokenentryTokenFieldPlaceholder()
		expect(self.sut.nextButtonTitle) == L.holderDcctokenentryNext()
		expect(self.sut.fieldErrorMessage) == nil
		expect(self.sut.userNeedsATokenButtonTitle) == L.holderDcctokenentryButtonNotoken()
	}

	func test_inputtingShortValue_doesntShowError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "a")

		// Assert
		expect(self.sut.fieldErrorMessage) == nil
	}

	func test_inputtingValidValue_doesNothing() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdef")

		// Assert
		expect(self.sut.fieldErrorMessage) == nil
	}

	func test_inputtingLongValue_doesNothing() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdefg")

		// Assert
		expect(self.sut.fieldErrorMessage) == nil
	}

	func test_tappingSubmit_withShortValue_showsError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "a")
		sut.nextButtonTapped()

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderDcctokenentryErrorInvalidcode()
	}

	func test_tappingSubmit_withLongValue_showsError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdefg")
		sut.nextButtonTapped()

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderDcctokenentryErrorInvalidcode()
	}

	func test_tappingSubmit_withIllegalCharacters_showsError() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abc$eg")
		sut.nextButtonTapped()

		// Assert
		expect(self.sut.fieldErrorMessage) == L.holderDcctokenentryErrorInvalidcode()
	}

	func test_changingValueAfterPressingSubmitClearsErrorMessage() {
		// Arrange
		sut.userDidUpdateTokenField(rawTokenInput: "abc$eg")
		sut.nextButtonTapped()

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abc")

		// Assert
		expect(self.sut.fieldErrorMessage) == nil
	}

	func test_validationOfToken() {
		expect(self.sut.validateInput(input: nil)) == true
		expect(self.sut.validateInput(input: "ABCDEF")) == true

		expect(self.sut.validateInput(input: "abcdef")) == false
		expect(self.sut.validateInput(input: "a c c")) == false
		expect(self.sut.validateInput(input: " ")) == false
		expect(self.sut.validateInput(input: "1234")) == false
		expect(self.sut.validateInput(input: "1234567")) == false
		expect(self.sut.validateInput(input: "@#(*&#")) == false
	}

	func test_tappingSubmit_withValidValue_doesSomething() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "ABCDEF")
		sut.nextButtonTapped()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserDidSubmitPaperProofToken) == true
		expect(self.coordinatorDelegateSpy.invokedUserDidSubmitPaperProofTokenParameters?.token) == "ABCDEF"
	}

	func test_tappingSubmit_withValidLowercaseValue_submitsUppercasedValue() {
		// Arrange

		// Act
		sut.userDidUpdateTokenField(rawTokenInput: "abcdef")
		sut.nextButtonTapped()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserDidSubmitPaperProofToken) == true
		expect(self.coordinatorDelegateSpy.invokedUserDidSubmitPaperProofTokenParameters?.token) == "ABCDEF"
	}

	func test_tappingNoTokenButton() {
		// Arrange

		// Act
		sut.userHasNoTokenButtonTapped()

		// Assert
		expect(self.coordinatorDelegateSpy.invokedUserWishesMoreInformationOnNoInputToken) == true
	}
}
