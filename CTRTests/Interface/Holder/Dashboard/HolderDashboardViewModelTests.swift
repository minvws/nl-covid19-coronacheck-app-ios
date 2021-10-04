/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length file_length

import XCTest
@testable import CTR
import Nimble
import CoreData

class HolderDashboardViewModelTests: XCTestCase {

	/// Subject under test
	private var sut: HolderDashboardViewModel!
	private var configSpy: ConfigurationGeneralSpy!
	private var cryptoManagerSpy: CryptoManagerSpy!
	private var dataStoreManager: DataStoreManager!
	private var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var datasourceSpy: HolderDashboardDatasourceSpy!
	private var strippenRefresherSpy: DashboardStrippenRefresherSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var sampleGreencardObjectID: NSManagedObjectID!
	private var remoteConfigSpy: RemoteConfigManagingSpy!
	
	private static var initialTimeZone: TimeZone?

	override class func setUp() {
		super.setUp()
		initialTimeZone = NSTimeZone.default
		NSTimeZone.default = TimeZone(abbreviation: "CEST")!
	}

	override class func tearDown() {
		super.tearDown()

		if let timeZone = initialTimeZone {
			NSTimeZone.default = timeZone
		}
	}

	override func setUp() {
		super.setUp()

		configSpy = ConfigurationGeneralSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		dataStoreManager = DataStoreManager(.inMemory)
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		datasourceSpy = HolderDashboardDatasourceSpy()
		strippenRefresherSpy = DashboardStrippenRefresherSpy()
		userSettingsSpy = UserSettingsSpy()
		remoteConfigSpy = RemoteConfigManagingSpy(networkManager: NetworkSpy())
		remoteConfigSpy.stubbedGetConfigurationResult = RemoteConfiguration.default

		Services.use(cryptoManagerSpy)
		Services.use(remoteConfigSpy)
		
		sampleGreencardObjectID = NSManagedObjectID()
	}

	func vendSut(dashboardRegionToggleValue: QRCodeValidityRegion) -> HolderDashboardViewModel {

		userSettingsSpy.stubbedDashboardRegionToggleValue = dashboardRegionToggleValue

		return HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			datasource: datasourceSpy,
			strippenRefresher: strippenRefresherSpy,
			userSettings: userSettingsSpy,
			now: { now }
		)
	}

	// MARK: -

	func test_initialState() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.sut.title) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle) == L.holderMenuProof()
		expect(self.sut.hasAddCertificateMode) == false
		expect(self.sut.currentlyPresentedAlert).to(beNil())
		expect(self.sut.domesticCards).to(beEmpty())
		expect(self.sut.internationalCards).to(beEmpty())
	}

	func test_initialStateAfterFirstEmptyLoad() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		datasourceSpy.invokedDidUpdate?([], [])

		// Assert
		expect(self.sut.title) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle) == L.holderMenuProof()
		expect(self.sut.currentlyPresentedAlert).to(beNil())

		expect(self.sut.hasAddCertificateMode).toEventually(beTrue())
		expect(self.sut.domesticCards).toEventually(haveCount(1))
		expect(self.sut.internationalCards).toEventually(haveCount(1))

		expect(self.sut.domesticCards.first).to(beEmptyStateCard(test: { image, title, message in
			expect(image) == I.dashboard.domestic()
			expect(title) == L.holderDashboardEmptyDomesticTitle()
			expect(message) == L.holderDashboardEmptyDomesticMessage()
		}))
		expect(self.sut.internationalCards.first).to(beEmptyStateCard(test: { image, title, message in
			expect(image) == I.dashboard.international()
			expect(title) == L.holderDashboardEmptyInternationalTitle()
			expect(message) == L.holderDashboardEmptyInternationalMessage()
		}))
	}

	func test_viewWillAppear_triggersDatasourceReload() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.datasourceSpy.invokedReload) == false

		// Act
		sut.viewWillAppear()

		// Assert
		expect(self.datasourceSpy.invokedReload) == true
	}

	func test_didBecomeActiveNotification_triggersDatasourceReload() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.datasourceSpy.invokedReload) == false

		// Act
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

		// Assert
		expect(self.datasourceSpy.invokedReload) == true
	}

	func test_addProofTapped_callsCoordinator() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAQR) == false

		// Act
		sut.addProofTapped()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAQR) == true
	}

	func test_openURL_callsCoordinator() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false

		// Act
		sut.openUrl(URL(fileURLWithPath: ""))

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}

	// MARK: - Strippen Loading

	func test_strippen_stopsLoading_shouldTriggerDatasourceReload() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		expect(self.datasourceSpy.invokedReload) == false

		let oldStrippenState = DashboardStrippenRefresher.State(
			loadingState: .loading(silently: true),
			now: { now },
			greencardsCredentialExpiryState: .noActionNeeded,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .idle,
			now: { now },
			greencardsCredentialExpiryState: .noActionNeeded,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(oldStrippenState, newStrippenState)

		expect(self.datasourceSpy.invokedReload) == true
	}

	func test_strippen_domestic_startLoading_shouldClearError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))

		// Act
		// Apply loading state:
		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .loading(silently: false),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(strippenState, newStrippenState)

		// Assert
		// Error Message should now be gone:
		expect(self.sut.domesticCards).toEventually(haveCount(2))
	}

	func test_strippen_international_startLoading_shouldClearError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))

		// Act
		// Apply loading state:
		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .loading(silently: false),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(strippenState, newStrippenState)

		// Assert
		// Error Message should now be gone:
		expect(self.sut.internationalCards).toEventually(haveCount(2))
	}
	func test_strippen_domesticandinternational_startLoading_shouldClearError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))

		// Act
		// Apply loading state:
		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .loading(silently: false),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(strippenState, newStrippenState)

		// Assert
		// Error Message should now be gone:
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards).toEventually(haveCount(2))
	}

	// MARK: - Strippen Alerts

	func test_strippen_expired_noInternetError_shouldPresentError() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, newStrippenState)

		expect(self.sut.currentlyPresentedAlert?.title) == L.holderDashboardStrippenExpiredNointernetAlertTitle()
		expect(self.sut.currentlyPresentedAlert?.subTitle) == L.holderDashboardStrippenExpiredNointernetAlertMessage()
		expect(self.sut.currentlyPresentedAlert?.cancelTitle) == L.generalClose()
		expect(self.sut.currentlyPresentedAlert?.okTitle) == L.generalRetry()

		self.sut.currentlyPresentedAlert?.cancelAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedUserDismissedALoadingError) == true

		self.sut.currentlyPresentedAlert?.okAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedLoad) == true
	}

	func test_strippenkaart_noInternet_expired_previouslyDismissed_shouldDisplayError() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))
	}

	func test_strippen_noInternet_expiring_shouldPresentErrorAlert() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expiring(deadline: now.addingTimeInterval(3 * hours * fromNow)),
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, newStrippenState)

		expect(self.sut.currentlyPresentedAlert?.title) == L.holderDashboardStrippenExpiringNointernetAlertTitle()
		expect(self.sut.currentlyPresentedAlert?.subTitle) == L.holderDashboardStrippenExpiringNointernetAlertMessage("3 uur")
		expect(self.sut.currentlyPresentedAlert?.cancelTitle) == L.generalClose()
		expect(self.sut.currentlyPresentedAlert?.okTitle) == L.generalRetry()

		self.sut.currentlyPresentedAlert?.cancelAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedUserDismissedALoadingError) == true

		self.sut.currentlyPresentedAlert?.okAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedLoad) == true
	}

	func test_strippenkaart_noInternet_expiring_hasPreviouslyDismissed_shouldDoNothing() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expiring(deadline: now.addingTimeInterval(1 * hour * ago)),
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(1))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateCard())

		expect(self.sut.currentlyPresentedAlert).to(beNil())
	}

	func test_strippenkaart_serverError_expiring_shouldDoNothing() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			now: { now },
			greencardsCredentialExpiryState: .expiring(deadline: now.addingTimeInterval(2 * days * fromNow)),
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(1))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateCard())
		expect(self.sut.internationalCards).toEventually(haveCount(1))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateCard())

		expect(self.sut.currentlyPresentedAlert).to(beNil())
	}

	func test_strippen_expired_serverError_firstTime_shouldDisplayErrorWithRetry() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 1
		)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		strippenRefresherSpy.invokedDidUpdate?(nil, newStrippenState)

		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
	}

	func test_strippen_expired_serverError_secondTime_shouldDisplayErrorWithHelpdesk() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: true,
			errorOccurenceCount: 2
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	func test_strippen_domesticandinternational_expired_serverError_firstTime_shouldDisplayError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: true,
			errorOccurenceCount: 1
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards).toEventually(haveCount(3))

		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard())
		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard())

		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
		expect(self.sut.internationalCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
	}

	func test_strippen_domestic_expired_serverError_thirdTime_shouldDisplayHelpdeskError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: true,
			errorOccurenceCount: 2
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	func test_strippen_international_expired_serverError_thirdTime_shouldDisplayHelpdeskError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: true,
			errorOccurenceCount: 2
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard())

		expect(self.sut.internationalCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	func test_strippenkaart_noActionNeeded_shouldDoNothing() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .idle,
			now: { now },
			greencardsCredentialExpiryState: .noActionNeeded,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(1))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateCard())
		expect(self.sut.internationalCards).toEventually(haveCount(1))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateCard())

		expect(self.sut.currentlyPresentedAlert).to(beNil())
	}

	// MARK: Datasource Updating

	func test_datasourceupdate_mutliplefailures_shouldShowHelpDeskErrorBeneathCard() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: DashboardStrippenRefresher.Error.networkError(error: .invalidRequest, timestamp: now)),
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: true,
			errorOccurenceCount: 3
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, strippenState)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard())
		expect(self.sut.domesticCards[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	// MARK: - Single, Currently Valid, Domestic

	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_expiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 15 juni 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .past
			expect(futureValidityTexts[0].lines).to(beEmpty())

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 1 minuut"
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticTest() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Single, Currently Valid, International

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_1_of_2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { (date: Date) -> EuCredentialAttributes.DigitalCovidCertificate? in
					return .sampleWithVaccine(doseNumber: 1, totalDose: 2)
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Vaccinatiebewijs: dosis 1 van 2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Vaccinatiebewijs: dosis 1 van 2"
			expect(futureValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_ExpiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { (date: Date) -> EuCredentialAttributes.DigitalCovidCertificate? in
					return .sampleWithVaccine(doseNumber: 1, totalDose: 2)
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Vaccinatiebewijs: dosis 1 van 2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 15 juni 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * minutes * fromNow))
			expect(futureValidityTexts[0].kind) == .past
			expect(futureValidityTexts[0].lines).to(beEmpty())

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_0_of_2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { (date: Date) -> EuCredentialAttributes.DigitalCovidCertificate? in
					return .sampleWithVaccine(doseNumber: 0, totalDose: 2)
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Vaccinatiebewijs: dosis 0 van 2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_nil_of_2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { (date: Date) -> EuCredentialAttributes.DigitalCovidCertificate? in
					return .sampleWithVaccine(doseNumber: nil, totalDose: 2)
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// Here we've got an invalid `EuCredentialAttributes.DigitalCovidCertificate` (nil of 2)
			// So we fallback to default `localizedDateExplanation` for an EU origin:

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Vaccinatiebewijs:"
			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalTest() {
		remoteConfigSpy.stubbedGetConfigurationResult = .default
		remoteConfigSpy.stubbedGetConfigurationResult.euTestTypes = [
			.init(code: "LP6464-4", name: "PCR (NAAT)")
		]

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in .sampleWithTest() }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Testbewijs: PCR (NAAT)"
			expect(nowValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Testbewijs: PCR (NAAT)"
			expect(futureValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))
		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Multiple, One Valid, One not yet Valid, Domestic

	func test_datasourceupdate_oneNotYetValid_oneCurrentlyValid_domestic() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(),
					.validIn48Hours_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[1].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[1].lines[1]) == "geldig vanaf 17 juli 17:02 t/m 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			expect(futureValidityTexts[1].kind) == .current
			expect(futureValidityTexts[1].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(futureValidityTexts[1].lines[1]) == "geldig tot 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Triple, Currently Valid, Domestic

	func test_datasourceupdate_tripleCurrentlyValidDomestic() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(
			test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

				// check isLoading
				expect(isLoading) == false

				let nowValidityTexts = validityTextEvaluator(now)
				expect(nowValidityTexts).to(haveCount(3))
				expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
				expect(nowValidityTexts[1].lines[0]) == L.generalTestcertificate().capitalized + ":"
				expect(nowValidityTexts[2].lines[0]) == L.generalRecoverystatement().capitalized + ":"

				expect(expiryCountdownEvaluator?(now)).to(beNil())
			}
		))
	}

	func test_datasourceupdate_tripleCurrentlyValidDomestic_oneExpiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.valid30DaysAgo_vaccination_expires60SecondsFromNow(),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(3))
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[1].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(nowValidityTexts[2].lines[0]) == L.generalRecoverystatement().capitalized + ":"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_tripleCurrentlyValidDomestic_allExpiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.valid30DaysAgo_vaccination_expires60SecondsFromNow(),
					.validOneDayAgo_test_expires5MinutesFromNow(),
					.validOneMonthAgo_recovery_expires2HoursFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(3))
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[1].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(nowValidityTexts[2].lines[0]) == L.generalRecoverystatement().capitalized + ":"

			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 2 uur"
		}))
	}

	// MARK: - Triple, Currently Valid, International

	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let vaccineGreenCardID = NSManagedObjectID()
		let testGreenCardID = NSManagedObjectID()
		let recoveryGreenCardID = NSManagedObjectID()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(4))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.internationalCards[2]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 11 mei 2022"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.internationalCards[3]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot donderdag 15 juli 16:02"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Triple, Currently Valid, Domestic but viewing International Tab

	func test_datasourceupdate_tripleCurrentlyValidDomesticButViewingInternationalTab() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(4))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.generalVaccinationcertificate())
		}))

		expect(self.sut.internationalCards[2]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.generalRecoverystatement())
		}))

		expect(self.sut.internationalCards[3]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.generalTestcertificate())
		}))
	}

	// MARK: - Triple, Currently Valid, International

	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccinationButViewingDomesticTab() {

		// Arrange
		userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let vaccineGreenCardID = NSManagedObjectID()
		let testGreenCardID = NSManagedObjectID()
		let recoveryGreenCardID = NSManagedObjectID()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.generalVaccinationcertificate())
		}))

		expect(self.sut.domesticCards[2]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.generalRecoverystatement())
		}))

		expect(self.sut.domesticCards[3]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.generalTestcertificate())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccinationButViewingDomesticTab_tappingMoreInfo() {

		// Arrange
		userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let vaccineGreenCardID = NSManagedObjectID()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())

		expect(self.sut.domesticCards[1]).toEventually(beOriginNotValidInThisRegionCard(test: { _, didTapMoreInfo in
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQR) == false
			didTapMoreInfo()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRParameters?.availableRegion) == .europeanUnion
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRParameters?.currentRegion) == .domestic
		}))
	}

	// MARK: - Single, Not Yet Valid, Domestic

	func test_datasourceupdate_singleNotYetValidDomesticVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleNotYetValidDomesticRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands,
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 t/m 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 t/m 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Single, Not Yet Valid, International

	// This shouldn't happen because DCC Vaccines are immediately valid
	// But the test can at least track the behaviour in case it does.
	func test_datasourceupdate_singleNotYetValidInternationalVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "wordt automatisch geldig over 17 juli 17:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleNotYetValidInternationalRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateDCC: { _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))
		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 t/m 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 t/m 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Expired cards

	func test_datasourceupdate_domesticExpired() {

		// Arrange
		userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery),
			.init(region: .domestic, type: .test),
			.init(region: .domestic, type: .vaccination)
		]

		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroDomestic()
		}))
		expect(self.sut.domesticCards[1]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holderDashboardQrExpired()
		}))
		expect(self.sut.domesticCards[2]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holderDashboardQrExpired()
		}))
		expect(self.sut.domesticCards[3]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holderDashboardQrExpired()
		}))
	}

	func test_datasourceupdate_domesticExpired_tapForMoreInfo() {

		// Arrange
		userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery)
		]

		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))

		// At this point cache the domestic cards value, because `didTapClose()` mutates it:
		let domesticCards = sut.domesticCards

		expect(domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(domesticCards[1]).toEventually(beExpiredQRCard(test: { message, didTapClose in
			expect(message) == L.holderDashboardQrExpired()
			didTapClose()

			// Check the non-cached value now to check that the Expired QR row was removed:
			expect(self.sut.domesticCards).to(haveCount(1))
			expect(self.sut.domesticCards[0]).to(beEmptyStateCard())
		}))
	}

	func test_datasourceupdate_internationalExpired() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .europeanUnion, type: .recovery),
			.init(region: .europeanUnion, type: .test),
			.init(region: .europeanUnion, type: .vaccination)
		]

		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(4))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard { message in
			expect(message) == L.holderDashboardIntroInternational()
		})
		expect(self.sut.internationalCards[1]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holderDashboardQrExpired()
		}))
		expect(self.sut.internationalCards[2]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holderDashboardQrExpired()
		}))
		expect(self.sut.internationalCards[3]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holderDashboardQrExpired()
		}))
	}

	func test_datasourceupdate_domesticExpiredButOnInternationalTab() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery),
			.init(region: .domestic, type: .test),
			.init(region: .domestic, type: .vaccination)
		]

		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(1))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateCard())
	}
}

// See: https://medium.com/@Tovkal/testing-enums-with-associated-values-using-nimble-839b0e53128
private func beEmptyStateCard(test: @escaping (UIImage?, String, String) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .emptyState with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .emptyState(image, title1, message1) = actual {
			test(image, title1, message1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beHeaderMessageCard(test: @escaping (String) -> Void = { _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .headerMessage with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .headerMessage(message1) = actual {
			test(message1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beDomesticQRCard(test: @escaping ((Date) -> [HolderDashboardViewController.ValidityText], Bool, () -> Void, ((Date) -> String?)?) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .domesticQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   // Skip buttonEnabledEvaluator because it always comes from the `HolderDashboardViewModel.MyQRCard` itself (which means it is stubbed in the test)
		   case let .domesticQR(validityTextEvaluator, isLoading, didTapViewQR, _, expiryCountdownEvaluator) = actual {
			test(validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beEuropeanUnionQRCard(test: @escaping ((Date) -> [HolderDashboardViewController.ValidityText], Bool, () -> Void, ((Date) -> String?)?) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .europeanUnionQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .europeanUnionQR(validityTextEvaluator, isLoading, didTapViewQR, _, expiryCountdownEvaluator) = actual {
			test(validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beErrorMessageCard(test: @escaping (String, () -> Void) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .errorMessage with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .errorMessage(message2, didTapTryAgain) = actual {
			test(message2, didTapTryAgain)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beExpiredQRCard(test: @escaping (String, () -> Void) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .expiredQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .expiredQR(message2, didTapClose) = actual {
			test(message2, didTapClose)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beOriginNotValidInThisRegionCard(test: @escaping (String, () -> Void) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .originNotValidInThisRegion with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .originNotValidInThisRegion(message2, didTapForMoreInfo) = actual {
			test(message2, didTapForMoreInfo)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
