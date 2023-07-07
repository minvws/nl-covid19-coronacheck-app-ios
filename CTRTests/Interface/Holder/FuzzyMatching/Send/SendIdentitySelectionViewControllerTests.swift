/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckFoundation
import CoronaCheckTest
@testable import CTR
import ViewControllerPresentationSpy

final class SendIdentitySelectionViewControllerTests: XCTestCase {
		
	private var sut: SendIdentitySelectionViewController!
	private var window = UIWindow()
	
	private var coordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegateSpy!
	private var dataSourceSpy: IdentitySelectionDataSourceSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()
		
		coordinatorDelegateSpy = FuzzyMatchingCoordinatorDelegateSpy()
		dataSourceSpy = IdentitySelectionDataSourceSpy()
		environmentSpies = setupEnvironmentSpies()
		
		dataSourceSpy.stubbedGetIdentityResult = EventFlow.Identity(infix: "van", firstName: "Tester", lastName: "Test", birthDateString: "2022-10-12")
		environmentSpies.secureUserSettingsSpy.stubbedSelectedIdentity = "van Test, Tester"
		
		sut = SendIdentitySelectionViewController(
			viewModel: SendIdentitySelectionViewModel(
				coordinatorDelegate: coordinatorDelegateSpy,
				dataSource: dataSourceSpy,
				matchingBlobIds: [["123"], ["456"]],
				selectedBlobIds: ["123"]
			)
		)
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	func test_content() {
		
		// Given
		
		// When
		loadView()
		
		// Then
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_content_noInternet() {
		
		// Given
		let alertVerifier = AlertVerifier()
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .noInternetConnection))), ())
		
		// When
		loadView()
		
		// Then
		alertVerifier.verify(
			title: "Geen internetverbinding",
			message: "Je bent nu niet verbonden met het internet.",
			animated: true,
			actions: [
				.default("Probeer opnieuw"),
				.cancel("Sluiten")
			]
		)
	}
}
