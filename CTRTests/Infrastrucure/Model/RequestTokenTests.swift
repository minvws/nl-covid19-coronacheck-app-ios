/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import XCTest
@testable import CTR

class RequestTokenTests: XCTestCase {

    var tokenValidatorSpy: TokenValidatorSpy!

    override func setUp() {
        super.setUp()
        tokenValidatorSpy = TokenValidatorSpy()
    }

    func test_validParameters_areParsedCorrectly() {

        // Arrange
        let inputProvider = "XXX"
        let inputToken = "YYYYYYYYYYYY"
        let inputChecksum = "Z"
        let inputVersion = "2"
        let input = "\(inputProvider)-\(inputToken)-\(inputChecksum)\(inputVersion)"

        let expectedVersion = "\(inputVersion).0"

        tokenValidatorSpy.stubbedValidateResult = true

        // Act
        let sut = RequestToken(input: input, tokenValidator: tokenValidatorSpy)

        // Assert

        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.providerIdentifier, inputProvider)
        XCTAssertEqual(sut?.token, inputToken)
        XCTAssertNotEqual(sut?.protocolVersion, expectedVersion)
		XCTAssertEqual(sut?.protocolVersion, "3.0")

        // Should also have called the validator:
        XCTAssert(tokenValidatorSpy.invokedValidate)
        XCTAssertEqual(tokenValidatorSpy.invokedValidateParameters?.token, input)
    }

    func `test_falselyValidParameters_shouldNotCrash`() {
        // Arrange
        let input = "XXX" // not enough components

        tokenValidatorSpy.stubbedValidateResult = true // bug in validator! 🪳

        // Act
        let sut = RequestToken(input: input, tokenValidator: tokenValidatorSpy)

        // Assert
        XCTAssertNil(sut) // didn't crash but returned nil.
    }

    func test_invalidParameters_returnNil() {
        let tokenValidator = TokenValidator(isLuhnCheckEnabled: false) // use a real one for an integration test here
        XCTAssertNil(RequestToken(input: "XXX-YYYYYYYYYYYY-ZV", tokenValidator: tokenValidator))
        XCTAssertNil(RequestToken(input: "XXX-YYYY", tokenValidator: tokenValidator))
        XCTAssertNil(RequestToken(input: "XXX-YYYYYYYYYYYY-Z", tokenValidator: tokenValidator))
        XCTAssertNil(RequestToken(input: "XX-YYYYYYYYYYYY-Z2", tokenValidator: tokenValidator))
    }
}
