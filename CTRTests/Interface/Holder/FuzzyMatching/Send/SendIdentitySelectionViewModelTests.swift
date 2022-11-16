/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
import Nimble
@testable import Transport
@testable import CTR

final class SendIdentitySelectionViewModelTests: XCTestCase {

	private var sut: SendIdentitySelectionViewModel!

	private var coordinatorDelegateSpy: FuzzyMatchingCoordinatorDelegateSpy!
	private var dataSourceSpy: IdentitySelectionDataSourceSpy!
	private var environmentSpies: EnvironmentSpies!
	
	override func setUp() {
		super.setUp()

		coordinatorDelegateSpy = FuzzyMatchingCoordinatorDelegateSpy()
		dataSourceSpy = IdentitySelectionDataSourceSpy()
		environmentSpies = setupEnvironmentSpies()
	}
	
	func setupSut(matchingBlobIds: [[String]] = [], selectedBlobIds: [String] = []) {
		
		sut = SendIdentitySelectionViewModel(
			coordinatorDelegate: coordinatorDelegateSpy,
			dataSource: dataSourceSpy,
			matchingBlobIds: matchingBlobIds,
			selectedBlobIds: selectedBlobIds
		)
	}

	func test_viewDidAppear_withoutBlobs() {
		
		// Given
		setupSut()
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.content.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.content.body).toEventually(equal( L.holderErrorstateClientMessage("i 1310 000 101")))
	}
	
	func test_viewDidAppear_emptyMatchingBlobs() {
		
		// Given
		setupSut(matchingBlobIds: [], selectedBlobIds: ["123"])
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.content.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.content.body).toEventually(equal( L.holderErrorstateClientMessage("i 1310 000 101")))
	}
	
	func test_viewDidAppear_cantPersistName() {
		
		// Given
		setupSut(matchingBlobIds: [["123"], ["456"]], selectedBlobIds: ["123"])
		dataSourceSpy.stubbedGetIdentityResult = nil
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.content.title).toEventually(equal(L.holderErrorstateTitle()))
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.content.body).toEventually(equal( L.holderErrorstateClientMessage("i 1310 000 102")))
	}
	
	func test_viewDidAppear_greenCardLoader_success() {

		// Given
		setupSut(matchingBlobIds: [["123"], ["456"]], selectedBlobIds: ["123"])
		dataSourceSpy.stubbedGetIdentityResult = EventFlow.Identity(infix: "van", firstName: "Tester", lastName: "Test", birthDateString: "2022-10-12")
		environmentSpies.secureUserSettingsSpy.stubbedSelectedIdentity = "van Test, Tester"
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.success(RemoteGreenCards.Response.internationalVaccination), ())

		// When
		sut.viewDidAppear()

		// Then
		expect(self.coordinatorDelegateSpy.invokedUserWishesToSeeSuccess).toEventually(beTrue())
	}
	
	func test_viewDidAppear_greenCardLoader_noInternet() throws {
		
		// Given
		setupSut(matchingBlobIds: [["123"], ["456"]], selectedBlobIds: ["123"])
		dataSourceSpy.stubbedGetIdentityResult = EventFlow.Identity(infix: "van", firstName: "Tester", lastName: "Test", birthDateString: "2022-10-12")
		environmentSpies.secureUserSettingsSpy.stubbedSelectedIdentity = "van Test, Tester"
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: nil, error: .noInternetConnection))), ())
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedPresentError).toEventually(beFalse())
		expect(self.sut.alert.value?.title).toEventually(equal(L.generalErrorNointernetTitle()))
		expect(self.sut.alert.value?.subTitle).toEventually(equal(L.generalErrorNointernetText()))
	}
	
	func test_viewDidAppear_greenCardLoader_errorFailedToSaveGreenCards() {
		
		// Given
		setupSut(matchingBlobIds: [["123"], ["456"]], selectedBlobIds: ["123"])
		dataSourceSpy.stubbedGetIdentityResult = EventFlow.Identity(infix: "van", firstName: "Tester", lastName: "Test", birthDateString: "2022-10-12")
		environmentSpies.secureUserSettingsSpy.stubbedSelectedIdentity = "van Test, Tester"
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToSaveGreenCards), ())
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedPresentError).toEventually(beTrue())
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.0.title) == L.holderErrorstateTitle()
		expect(self.coordinatorDelegateSpy.invokedPresentErrorParameters?.0.body) == L.holderErrorstateClientMessage("i 1390 000 055")
	}
	
	func test_viewDidAppear_greenCardLoader_error_primaryAction() {
		
		// Given
		setupSut(matchingBlobIds: [["123"], ["456"]], selectedBlobIds: ["123"])
		dataSourceSpy.stubbedGetIdentityResult = EventFlow.Identity(infix: "van", firstName: "Tester", lastName: "Test", birthDateString: "2022-10-12")
		environmentSpies.secureUserSettingsSpy.stubbedSelectedIdentity = "van Test, Tester"
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult = (.failure(GreenCardLoader.Error.failedToSaveGreenCards), ())
		sut.viewDidAppear()
		
		// When
		expect(self.coordinatorDelegateSpy.invokedPresentError).toEventually(beTrue())
		let params = self.coordinatorDelegateSpy.invokedPresentErrorParameters
		params?.0.primaryAction?()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedUserHasStoppedTheFlow).toEventually(beTrue())
	}
	
	func test_viewDidAppear_greenCardLoader_errorFuzzyMatching() {
		
		// Given
		setupSut(matchingBlobIds: [["123"], ["456"]], selectedBlobIds: ["123"])
		dataSourceSpy.stubbedGetIdentityResult = EventFlow.Identity(infix: "van", firstName: "Tester", lastName: "Test", birthDateString: "2022-10-12")
		environmentSpies.secureUserSettingsSpy.stubbedSelectedIdentity = "van Test, Tester"
		let serverResponse = ServerResponse(status: "error", code: 99790, context: ServerResponseContext(matchingBlobIds: [["123"]]))
		environmentSpies.greenCardLoaderSpy.stubbedSignTheEventsIntoGreenCardsAndCredentialsCompletionResult =
		(.failure(GreenCardLoader.Error.credentials(.error(statusCode: nil, response: serverResponse, error: .serverError))), ())
		
		// When
		sut.viewDidAppear()
		
		// Then
		expect(self.coordinatorDelegateSpy.invokedRestartFlow).toEventually(beTrue())
	}
}
