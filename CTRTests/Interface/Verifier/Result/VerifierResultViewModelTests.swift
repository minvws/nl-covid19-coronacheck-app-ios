/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class VerifierResultViewModelTests: XCTestCase {
	
	/// Subject under test
	var sut: VerifierResultViewModel!
	
	/// The coordinator spy
	var verifyCoordinatorDelegateSpy: VerifierCoordinatorDelegateSpy!
	
	/// Date parser
	private lazy var parseDateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		return dateFormatter
	}()
	
	override func setUp() {
		
		super.setUp()
		verifyCoordinatorDelegateSpy = VerifierCoordinatorDelegateSpy()
		
		sut = VerifierResultViewModel(
			coordinator: verifyCoordinatorDelegateSpy,
			cryptoResults: CryptoResult(
				attributes: Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "test",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
				errorMessage: nil
			),
			maxValidity: 48
		)
	}
	
	// MARK: - Tests
	
	func testDemo() {
		
		// Given
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40
		sut.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp40SecAgo)",
						testType: "pcr",
						specimen: "1",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp40SecAgo)
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .demo
		expect(self.sut.title) == .verifierResultDemoTitle
		expect(self.sut.message).to(beNil(), description: "Message should be nil")
	}
	
	func testDemoButFaultyTime() {
		
		// Given
		sut.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "pcr",
						specimen: "1",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == .verifierResultDeniedTitle
		expect(self.sut.message) == .verifierResultDeniedMessage
	}
	
	func testDenied() {
		
		// Given
		sut.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "test",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: 0
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == .verifierResultDeniedTitle
		expect(self.sut.message) == .verifierResultDeniedMessage
	}
	
	func testAllow() {
		
		// Given
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40
		sut.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp40SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp40SecAgo)
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified
		expect(self.sut.title) == .verifierResultAccessTitle
		expect(self.sut.message).to(beNil(), description: "Message should be nil")
	}
	
	func testAllowWithInGracePeriod() {
		
		// Given
		let timeStamp175SecFromNow = Date().timeIntervalSince1970 + 175 // QR Time
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40 // Sample Time
		sut.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp40SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp175SecFromNow)
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified
		expect(self.sut.title) == .verifierResultAccessTitle
		expect(self.sut.message).to(beNil(), description: "Message should be nil")
	}
	
	func testDeniedOutsideInGracePeriod() {
		
		// Given
		let timeStamp185SecFromNow = Date().timeIntervalSince1970 + 185 // QR Time
		let timeStamp40SecAgo = Date().timeIntervalSince1970 - 40 // Sample Time
		sut?.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp40SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp185SecFromNow)
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == .verifierResultDeniedTitle
		expect(self.sut.message) == .verifierResultDeniedMessage
	}
	
	func testExpiredTimeStamp() {
		
		// Given
		let timeStamp310SecAgo = Date().timeIntervalSince1970 - 310 // TTL is 300
		sut?.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp310SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "0"
					),
					unixTimeStamp: Int64(timeStamp310SecAgo)
				),
			errorMessage: nil
		)
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .denied
		expect(self.sut.title) == .verifierResultDeniedTitle
		expect(self.sut.message) == .verifierResultDeniedMessage
	}
	
	func testExpiredUnixTimeStampButPaperProof() {
		
		// Given
		let timeStamp310SecAgo = Date().timeIntervalSince1970 - 310 // TTL is 300
		sut?.cryptoResults = CryptoResult(
			attributes:
				Attributes(
					cryptoAttributes: CryptoAttributes(
						birthDay: nil,
						birthMonth: nil,
						firstNameInitial: nil,
						lastNameInitial: nil,
						sampleTime: "\(timeStamp310SecAgo)",
						testType: "pcr",
						specimen: "0",
						paperProof: "1"
					),
					unixTimeStamp: Int64(timeStamp310SecAgo)
				),
			errorMessage: nil
		)
		
		// When
		sut.checkAttributes()
		
		// Then
		expect(self.sut.allowAccess) == .verified
		expect(self.sut.title) == .verifierResultAccessTitle
		expect(self.sut.message).to(beNil(), description: "Message should be nil")
	}
	
	func testDismiss() {
		
		// Given
		
		// When
		sut.dismiss()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToVerifierWelcome) == true
	}
	
	func testScanAgain() {
		
		// Given
		
		// When
		sut.scanAgain()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedNavigateToScan) == true
	}
	
	func testLinkTappedDenied() {
		
		// Given
		sut.allowAccess = .denied
		
		// When
		sut.linkTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDisplayContent) == true
	}
	
	func testLinkTappedAllowed() {
		
		// Given
		sut.allowAccess = .verified
		
		// When
		sut.linkTapped()
		
		// Then
		expect(self.verifyCoordinatorDelegateSpy.invokedDisplayContent) == true
	}
}
