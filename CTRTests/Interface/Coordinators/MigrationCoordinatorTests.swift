/*
 * Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import CoronaCheckFoundation
import CoronaCheckTest
import CoronaCheckUI
@testable import CTR
@testable import DataMigration

class MigrationCoordinatorTests: XCTestCase {
	
	private func makeSUT(
		file: StaticString = #filePath,
		line: UInt = #line) -> (MigrationCoordinator, NavigationControllerSpy, MigrationFlowDelegateSpy, EnvironmentSpies) {
		
		let navigationSpy = NavigationControllerSpy()
		let delegateSpy = MigrationFlowDelegateSpy()
		let environmentSpies = setupEnvironmentSpies()
		let sut = MigrationCoordinator(navigationController: navigationSpy, delegate: delegateSpy)
		
		trackForMemoryLeak(instance: sut, file: file, line: line)
		
		return (sut, navigationSpy, delegateSpy, environmentSpies)
	}
	
	// MARK: - Tests
	
	func test_start() {
		
		// Given
		let (sut, navigationSpy, delegateSpy, _) = makeSUT()
		
		// When
		sut.start()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ContentWithImageViewController) == true
		expect((navigationSpy.viewControllers.first as? ContentWithImageViewController)?.viewModel)
			.to(beAnInstanceOf(MigrationStartViewModel.self))
		expect(delegateSpy.invokedDataMigrationCancelled) == false
		expect(delegateSpy.invokedDataMigrationBackAction) == false
	}
	
	func test_consume_redeemHolder() {
		
		// Given
		let (sut, _, _, _) = makeSUT()
		let universalLink = UniversalLink.redeemHolderToken(
			requestToken: RequestToken(
				token: "STXT2VF3389TJ2",
				protocolVersion: "3.0",
				providerIdentifier: "XXX"
			)
		)
		
		// When
		let consumed = sut.consume(universalLink: universalLink)
		
		// Then
		expect(consumed) == false
	}
	
	func test_userCompletedStart_withEvents() throws {
		
		// Given
		let (sut, navigationSpy, _, environmentSpies) = makeSUT()
		let eventGroup = try XCTUnwrap(EventGroup.fakeEventGroup(dataStoreManager: environmentSpies.dataStoreManager, type: .vaccination, expiryDate: .distantFuture))
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = [eventGroup]
		
		// When
		sut.userCompletedStart()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ListOptionsViewController) == true
		expect((navigationSpy.viewControllers.first as? ListOptionsViewController)?.viewModel)
			.to(beAnInstanceOf(MigrationTransferOptionsViewModel.self))
	}
	
	func test_userCompletedStart_noEvents() throws {
		
		// Given
		let (sut, navigationSpy, _, environmentSpies) = makeSUT()
		environmentSpies.walletManagerSpy.stubbedListEventGroupsResult = []
		
		// When
		sut.userCompletedStart()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		let pages = try XCTUnwrap((navigationSpy.viewControllers.first as? PagedAnnouncementViewController)?.viewModel.pages)
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toThisDevice_onboarding_step1_title()
		expect(pages.last?.title) == L.holder_startMigration_toThisDevice_onboarding_step2_title()
	}
	
	func test_userWishesToSeeToThisDeviceInstructions() throws {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		
		// When
		sut.userWishesToSeeToThisDeviceInstructions()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		let pages = try XCTUnwrap((navigationSpy.viewControllers.first as? PagedAnnouncementViewController)?.viewModel.pages)
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toThisDevice_onboarding_step1_title()
		expect(pages.last?.title) == L.holder_startMigration_toThisDevice_onboarding_step2_title()
	}
	
	func test_userWishesToSeeToOtherDeviceInstructions() throws {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		
		// When
		sut.userWishesToSeeToOtherDeviceInstructions()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is PagedAnnouncementViewController) == true
		let pages = try XCTUnwrap((navigationSpy.viewControllers.first as? PagedAnnouncementViewController)?.viewModel.pages)
		expect(pages).to(haveCount(2))
		expect(pages.first?.title) == L.holder_startMigration_toOtherDevice_onboarding_step1_title()
		expect(pages.last?.title) == L.holder_startMigration_toOtherDevice_onboarding_step2_title()
	}
	
	func test_userCompletedMigrationToOtherDevice() {
		
		// Given
		let (sut, _, delegateSpy, _) = makeSUT()
		
		// When
		sut.userCompletedMigrationToOtherDevice()
		
		// Then
		expect(delegateSpy.invokedDataMigrationExportCompleted) == true
	}
	
	func test_userWishesToStartMigrationToThisDevice() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		
		// When
		sut.userWishesToStartMigrationToThisDevice()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ImportViewController) == true
	}
	
	func test_userWishesToStartMigrationToOtherDevice() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		
		// When
		sut.userWishesToStartMigrationToOtherDevice()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ExportLoopViewController) == true
	}
	
	func test_didFinishOnboarding_toThisDevice() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.flow = .toThisDevice
		
		// When
		sut.didFinishPagedAnnouncement()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ImportViewController) == true
	}
	
	func test_didFinishOnboarding_toOtherDevice() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		sut.flow = .toOtherDevice
		
		// When
		sut.didFinishPagedAnnouncement()
		
		// Then
		expect(navigationSpy.viewControllers).to(haveCount(1))
		expect(navigationSpy.viewControllers.first is ExportLoopViewController) == true
	}
	
	func test_presentError_import() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		let errorCode = ErrorCode(flow: .migration, step: .import, clientCode: ErrorCode.ClientCode.compressionError)
		
		// When
		sut.presentError(errorCode)
		
		// Then
		expect(navigationSpy.viewControllers).toEventually(haveCount(1))
		expect(navigationSpy.viewControllers.first is ContentViewController) == true
		expect((navigationSpy.viewControllers.first as? ContentViewController)?.viewModel)
			.to(beAnInstanceOf(ContentViewModel.self))
		expect((navigationSpy.viewControllers.first as? ContentViewController)?.viewModel.content.value.body) == "<p>Er gaat iets mis met het importeren van je gegevens.</p><p><b>Foutcode:</b><br /> i 1410 000 110 </p>"
	}
	
	func test_presentError_export() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		let errorCode = ErrorCode(flow: .migration, step: .export, clientCode: ErrorCode.ClientCode.compressionError)
		
		// When
		sut.presentError(errorCode)
		
		// Then
		expect(navigationSpy.viewControllers).toEventually(haveCount(1))
		expect(navigationSpy.viewControllers.first is ContentViewController) == true
		expect((navigationSpy.viewControllers.first as? ContentViewController)?.viewModel)
			.to(beAnInstanceOf(ContentViewModel.self))
		expect((navigationSpy.viewControllers.first as? ContentViewController)?.viewModel.content.value.body) == "<p>Er gaat iets mis met het exporteren van je gegevens.</p><p><b>Foutcode:</b><br /> i 1420 000 110 </p>"
	}
	
	func test_userWishesToSeeScannedEvents() throws {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		let data = try XCTUnwrap("{\"couplingCode\":\"ZKGBKH\",\"credential\":\"HC1:NCFC20490T9WTWGVLKS79 1VYLTXZM8AVX*4FBBU42*70J+9DN03E54F3/Y1LOCY50.FK8ZKO/EZKEZ967L6C56GVC*JC1A6C%63W5Y96746TPCBEC7ZKW.CC9DCECS34$ CXKEW.CAWEV+A3+9K09GY8 JC2/DSN83LEQEDMPCG/DY-CB1A5IAVY87:EDOL9WEQDD+Q6TW6FA7C466KCN9E%961A6DL6FA7D46.JCP9EJY8L/5M/5546.96VF6.JCBECB1A-:8$966469L6OF6VX6FVCPD0KQEPD0LVC6JD846Y96*963W5.A6UPCBJCOT9+EDL8FHZ95/D QEALEN44:+C%69AECAWE:34: CJ.CZKE9440/D+34S9E5LEWJC0FD3%4AIA%G7ZM81G72A6J+9SG77N91R6E+9LCBMIBQCAYM8UIB51A9Y9AF6WA6I4817S6ZKH/C3*F*$GR4N2+5F8FM B$W6KU91A9WTO8S1QK87DBBMHDKFT*UMNCI3V$LS.QFWMF18W6TH5$9W+4QZLU71.5DB73000FGWU/0CRF\"}".data(using: .utf8))
		let parcel = EventGroupParcel(jsonData: data)
		
		// When
		sut.userWishesToSeeScannedEvents([parcel])
		
		// Then
		expect(sut.childCoordinators).to(haveCount(1))
		expect(sut.childCoordinators.first is EventCoordinator) == true
		expect(navigationSpy.viewControllers).toEventually(haveCount(1))
		expect(navigationSpy.viewControllers.first is ListRemoteEventsViewController) == true
	}
	
	// MARK: - EventFlowDelegate
	
	func test_eventFlowDidComplete() {
		
		// Given
		let (sut, navigationSpy, delegateSpy, _) = makeSUT()
		sut.childCoordinators = [EventCoordinator(navigationController: navigationSpy, delegate: sut)]
		
		// When
		sut.eventFlowDidComplete()
		
		// Then
		expect(delegateSpy.invokedDataMigrationImportCompleted) == true
		expect(sut.childCoordinators).to(beEmpty())
	}
	
	func test_eventFlowDidCancel() {
		
		// Given
		let (sut, navigationSpy, delegateSpy, _) = makeSUT()
		sut.childCoordinators = [EventCoordinator(navigationController: navigationSpy, delegate: sut)]
		navigationSpy.viewControllers = [
			PagedAnnouncementViewController(viewModel: PagedAnnouncementViewModel(delegate: sut, pages: [], itemsShouldShowWithFullWidthHeaderImage: false, shouldShowWithVWSRibbon: false), allowsPreviousPageButton: false, allowsCloseButton: false, allowsNextPageButton: false),
			ImportViewController(viewModel: ImportViewModel(coordinator: sut, dataImporter: DataImportSpy())),
			ExportLoopViewController(viewModel: ExportLoopViewModel(delegate: sut, dataExporter: DataExporterSpy(), screenBrightness: ScreenBrightnessProtocolSpy()))
		]
		
		// When
		sut.eventFlowDidCancel()
		
		// Then
		expect(delegateSpy.invokedDataMigrationImportCompleted) == false
		expect(sut.childCoordinators).to(beEmpty())
		expect(navigationSpy.viewControllers).toEventually(haveCount(2))
		expect(navigationSpy.viewControllers.last is ImportViewController).toEventually(beTrue())
	}
	
	func test_userWishesToGoBackToPreviousScreen() {
		
		// Given
		let (sut, navigationSpy, _, _) = makeSUT()
		navigationSpy.viewControllers = [
			PagedAnnouncementViewController(viewModel: PagedAnnouncementViewModel(delegate: sut, pages: [], itemsShouldShowWithFullWidthHeaderImage: false, shouldShowWithVWSRibbon: false), allowsPreviousPageButton: false, allowsCloseButton: false, allowsNextPageButton: false),
			ImportViewController(viewModel: ImportViewModel(coordinator: sut, dataImporter: DataImportSpy())),
			ExportLoopViewController(viewModel: ExportLoopViewModel(delegate: sut, dataExporter: DataExporterSpy(), screenBrightness: ScreenBrightnessProtocolSpy()))
		]
		
		// When
		sut.userWishesToGoBackToPreviousScreen()
		
		// Then
		expect(navigationSpy.invokedPopViewController) == true
		expect(navigationSpy.viewControllers).to(haveCount(2))
	}
}
