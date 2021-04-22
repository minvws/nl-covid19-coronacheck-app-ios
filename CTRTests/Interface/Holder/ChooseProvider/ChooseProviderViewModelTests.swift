/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble

class ChooseProviderViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: ChooseProviderViewModel!

	private var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var openIdManagerSpy: OpenIdManagerSpy!

	override func setUp() {

		super.setUp()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		openIdManagerSpy = OpenIdManagerSpy()
		sut = ChooseProviderViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			openIdManager: openIdManagerSpy
		)
	}

	// MARK: - Tests

	func test_content() throws {

		// Given

		// When

		// Then
		expect(self.sut.title) == .holderChooseProviderTitle
		expect(self.sut.header) == .holderChooseProviderHeader
		expect(self.sut.body) == .holderChooseProviderMessage
		expect(self.sut.image) == .create
		expect(self.sut.providers).to(haveCount(1), description: "There should only be 1 provider")
	}

	func test_commercialProviderChosen() {

		// Given

		// When
		sut.providerSelected(ProviderIdentifier.commercial, presentingViewController: nil)

		// Then
		expect(self.holderCoordinatorDelegateSpy.navigateToTokenOverviewCalled) == true
		expect(self.holderCoordinatorDelegateSpy.navigateToListResultsCalled) == false
	}

	func test_ggdProviderChosen_withoutViewController() {

		// Given
		openIdManagerSpy.stubbedRequestAccessTokenOnCompletionResult = ("testtoken", ())

		// When
		sut.providerSelected(ProviderIdentifier.ggd, presentingViewController: nil)

		// Then
		expect(self.holderCoordinatorDelegateSpy.navigateToTokenOverviewCalled) == false
		expect(self.holderCoordinatorDelegateSpy.navigateToListResultsCalled) == false
	}

	func test_ggdProviderChosen_withViewController_success() {

		// Given
		let viewController = UIViewController()
		openIdManagerSpy.stubbedRequestAccessTokenOnCompletionResult = ("testtoken", ())

		// When
		sut.providerSelected(ProviderIdentifier.ggd, presentingViewController: viewController)

		// Then
		expect(self.holderCoordinatorDelegateSpy.navigateToTokenOverviewCalled) == false
		expect(self.holderCoordinatorDelegateSpy.navigateToListResultsCalled) == true
	}

	func test_ggdProviderChosen_withViewController_error() {

		// Given
		let viewController = UIViewController()
		let error = NSError(
			domain: NSURLErrorDomain,
			code: URLError.notConnectedToInternet.rawValue
		)
		openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult = (error, ())

		// When
		sut.providerSelected(ProviderIdentifier.ggd, presentingViewController: viewController)

		// Then
		expect(self.holderCoordinatorDelegateSpy.navigateToTokenOverviewCalled) == false
		expect(self.holderCoordinatorDelegateSpy.navigateToListResultsCalled) == false
	}
}
