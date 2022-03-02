/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import XCTest
@testable import CTR
import Nimble
import SnapshotTesting

class LoginTVSViewControllerTests: XCTestCase {
	
	// MARK: Subject under test
	private var sut: LoginTVSViewController!
	private var coordinatorSpy: EventCoordinatorDelegateSpy!
	private var appAuthStateSpy: AppAuthStateSpy!
	private var environmentSpies: EnvironmentSpies!
	private var viewModel: LoginTVSViewModel!
	
	var window = UIWindow()
	
	// MARK: Test lifecycle
	override func setUp() {
		
		super.setUp()
		environmentSpies = setupEnvironmentSpies()
		coordinatorSpy = EventCoordinatorDelegateSpy()
		appAuthStateSpy = AppAuthStateSpy()
		viewModel = LoginTVSViewModel(
			coordinator: coordinatorSpy,
			eventMode: .vaccination
		)
		window = UIWindow()
	}
	
	func loadView() {
		
		window.addSubview(sut.view)
		RunLoop.current.run(until: Date())
	}
	
	// MARK: - Tests
	
	func test_content() {
		
		// Given
		sut = LoginTVSViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.sut.sceneView.title) == L.holder_fetchRemoteEvents_title()
		expect(self.sut.sceneView.message).to(beNil())
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_close() {
		
		// Given
		sut = LoginTVSViewController(viewModel: viewModel)
		loadView()
		
		// When
		sut.sceneView.primaryButtonTapped()
		
		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinishParameters?.0) == EventScreenResult.back(eventMode: .vaccination)
	}
	
	func test_login_success() {
		
		// Given
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnCompletionResult = (.test, ())
		sut = LoginTVSViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinishParameters?.0) == EventScreenResult.didLogin(token: .test, eventMode: .vaccination)
	}
	
	func test_login_error() throws {
		
		// Given
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
		(ServerError.error(statusCode: nil, response: nil, error: .serverUnreachableTimedOut), ())
		sut = LoginTVSViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		let params = try XCTUnwrap(coordinatorSpy.invokedLoginTVSScreenDidFinishParameters)
		if case let EventScreenResult.error(content: content, backAction: _) = params.0 {
			expect(content.title) == L.holderErrorstateTitle()
			expect(content.body) == L.generalErrorServerUnreachableErrorCode("i 210 000 004")
			expect(content.primaryAction).toNot(beNil())
			expect(content.primaryActionTitle) == L.general_toMyOverview()
			expect(content.secondaryAction).toNot(beNil())
			expect(content.secondaryActionTitle) == L.holderErrorstateMalfunctionsTitle()
		} else {
			fail("Invalid state")
		}
		
		sut.assertImage(containedInNavigationController: true)
	}
	
	func test_login_cancelled() throws {
		
		// Given
		environmentSpies.openIdManagerSpy.stubbedRequestAccessTokenOnErrorResult =
		(NSError(domain: "LoginTVS", code: 200, userInfo: [NSLocalizedDescriptionKey: "saml_authn_failed"]), ())
		sut = LoginTVSViewController(viewModel: viewModel)
		
		// When
		loadView()
		
		// Then
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinish) == true
		expect(self.coordinatorSpy.invokedLoginTVSScreenDidFinishParameters?.0) == EventScreenResult.errorRequiringRestart(eventMode: .vaccination)
	}
}