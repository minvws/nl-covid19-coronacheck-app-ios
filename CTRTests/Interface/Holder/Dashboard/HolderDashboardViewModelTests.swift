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
	private var proofManagerSpy: ProofManagingSpy!
	private var datasourceSpy: HolderDashboardDatasourceSpy!
	private var strippenRefresherSpy: DashboardStrippenRefresherSpy!
	private var userSettingsSpy: UserSettingsSpy!
	private var sampleGreencardObjectID: NSManagedObjectID!

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
		proofManagerSpy = ProofManagingSpy()
		datasourceSpy = HolderDashboardDatasourceSpy()
		strippenRefresherSpy = DashboardStrippenRefresherSpy()
		userSettingsSpy = UserSettingsSpy()

		sampleGreencardObjectID = NSManagedObjectID()
	}

	func vendSut(dashboardRegionToggleValue: QRCodeValidityRegion) -> HolderDashboardViewModel {

		userSettingsSpy.stubbedDashboardRegionToggleValue = dashboardRegionToggleValue

		return HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			datasource: datasourceSpy,
			strippenRefresher: strippenRefresherSpy,
			userSettings: userSettingsSpy,
			now: { now }
		)
	}

	// MARK: - Tests

	func test_initialState() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.sut.title) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle) == L.holderMenuProof()
		// expect(self.sut.hasAddCertificateMode) == true
		expect(self.sut.regionMode?.buttonTitle) == L.holderDashboardChangeregionButtonEu()
		expect(self.sut.regionMode?.currentLocationTitle) == L.holderDashboardChangeregionTitleNl()
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
		expect(self.sut.regionMode?.buttonTitle) == L.holderDashboardChangeregionButtonEu()
		expect(self.sut.regionMode?.currentLocationTitle) == L.holderDashboardChangeregionTitleNl()
		expect(self.sut.currentlyPresentedAlert).to(beNil())

		expect(self.sut.hasAddCertificateMode).toEventually(beTrue())
		expect(self.sut.domesticCards).toEventually(haveCount(1))
		expect(self.sut.internationalCards).toEventually(haveCount(1))

		expect(self.sut.domesticCards.first).to(beEmptyStateCard(test: { image, title, message in
			expect(image) == I.empty_Dashboard_Domestic()
			expect(title) == L.holderDashboardEmptyDomesticTitle()
			expect(message) == L.holderDashboardEmptyDomesticMessage()
		}))
		expect(self.sut.internationalCards.first).to(beEmptyStateCard(test: { image, title, message in
			expect(image) == I.empty_Dashboard_International()
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

	func test_didTapChangeRegion_callsCoordinator() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		holderCoordinatorDelegateSpy.stubbedUserWishesToChangeRegionCompletionResult = (.domestic, ())

		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToChangeRegion) == false

		// Act
		sut.didTapChangeRegion()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToChangeRegion) == true
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToChangeRegionParameters?.currentRegion) == .europeanUnion

		// The value should have now been changed to Domestic: 
		expect(self.userSettingsSpy.invokedDashboardRegionToggleValue) == .domestic
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

	func test_strippen_stopsLoading_shouldTriggerDatasourceReload() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		expect(self.datasourceSpy.invokedReload) == false

		let oldStrippenState = DashboardStrippenRefresher.State(
			loadingState: .loading(silently: true),
			greencardsCredentialExpiryState: .noActionNeeded,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .idle,
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
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
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
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
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
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
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
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
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
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest)

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
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

	func test_strippen_expired_serverError_firstTime_shouldPresentAlert() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest)
		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, newStrippenState)

		expect(self.sut.currentlyPresentedAlert?.title) == L.holderDashboardStrippenExpiredServererrorAlertTitle()
		expect(self.sut.currentlyPresentedAlert?.subTitle) == L.holderDashboardStrippenExpiredServererrorAlertMessage(error.localizedDescription)
		expect(self.sut.currentlyPresentedAlert?.cancelTitle) == L.generalClose()
		expect(self.sut.currentlyPresentedAlert?.okTitle) == L.generalRetry()

		self.sut.currentlyPresentedAlert?.cancelAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedUserDismissedALoadingError) == true

		self.sut.currentlyPresentedAlert?.okAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedLoad) == true
	}

	func test_strippen_expired_serverError_secondTime_shouldDisplayError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest)
		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: true,
			hasLoadingEverFailed: true,
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
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
	}

	func test_strippen_domesticandinternational_expired_serverError_secondTime_shouldDisplayError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest)
		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
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
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest)
		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
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
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk(AppAction.tryAgain)
		}))
	}

	func test_strippen_international_expired_serverError_thirdTime_shouldDisplayHelpdeskError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest)
		let qrCards = [
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: error),
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
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk(AppAction.tryAgain)
		}))
	}

	func test_strippenkaart_noActionNeeded_shouldDoNothing() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .idle,
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
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		let strippenState = DashboardStrippenRefresher.State(
			loadingState: .failed(error: DashboardStrippenRefresher.Error.networkError(error: .invalidRequest)),
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
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk("ctr.action:try_again")
		}))
	}

	// MARK: - Single, Currently Valid, Domestic

	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()],
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

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalVaccinationcertificate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .current
			expect(rows.first?.validityTextEvaluator(now).text) == "geldig t/m 18 juli 2021"
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow)).kind) == .current
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow)).text) == "geldig t/m 18 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 72 uur"
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticTest() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneHourAgo_test_expires23HoursFromNow()],
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
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalTestcertificate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .current
			expect(rows.first?.validityTextEvaluator(now).text) == "geldig t/m vrijdag 16 juli 16:02"

			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).kind) == .current
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).text) == "geldig t/m vrijdag 16 juli 16:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 23 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneHourAgo_recovery_expires300DaysFromNow()],
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
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalRecoverystatement().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .current
			expect(rows.first?.validityTextEvaluator(now).text) == "geldig t/m 11 mei 2022"

			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).kind) == .current
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).text) == "geldig t/m 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Single, Currently Valid, International

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneDayAgo_vaccination_expires3DaysFromNow()],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		// TODO: Also check Domestic?
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalVaccinationdate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .current
			expect(rows.first?.validityTextEvaluator(now).text) == "14 juli 2021"
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow)).kind) == .current
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow)).text) == "14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalTest() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		let qrCards = [
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneHourAgo_test_expires23HoursFromNow()],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		// TODO: Also check Domestic?
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalTestdate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .current
			expect(rows.first?.validityTextEvaluator(now).text) == "donderdag 15 juli 16:02"

			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).kind) == .current
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).text) == "donderdag 15 juli 16:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validOneHourAgo_recovery_expires300DaysFromNow()],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		// TODO: Also check Domestic?
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))
		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalRecoverydate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .current
			expect(rows.first?.validityTextEvaluator(now).text) == "15 juli 2021"

			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).kind) == .current
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow)).text) == "15 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Triple, Currently Valid, Domestic

	func test_datasourceupdate_tripleCurrentlyValidDomestic() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				],
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

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(3))

			let rowA = rows[0]
			expect(rowA.typeText) == L.generalVaccinationcertificate().capitalized

			let rowB = rows[1]
			expect(rowB.typeText) == L.generalTestcertificate().capitalized

			let rowC = rows[2]
			expect(rowC.typeText) == L.generalRecoverystatement().capitalized

			expect(expiryCountdownEvaluator?(now)).to(beNil())
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
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: vaccineGreenCardID,
				origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow()
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: recoveryGreenCardID,
				origins: [
					.validOneHourAgo_recovery_expires300DaysFromNow()
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: testGreenCardID,
				origins: [
					.validOneHourAgo_test_expires23HoursFromNow()
				],
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

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))

			let rowA = rows[0]
			expect(rowA.typeText) == L.generalVaccinationdate().capitalized

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.internationalCards[2]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))

			let rowA = rows[0]
			expect(rowA.typeText) == L.generalRecoverydate().capitalized

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.internationalCards[3]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))

			let rowA = rows[0]
			expect(rowA.typeText) == L.generalTestdate().capitalized

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		// This would never really happen, because the datasource would have really returned both
		// domestic and international entries. But just check that our assumptions are correct:
		expect(self.sut.domesticCards).toEventually(haveCount(1))
		expect(self.sut.domesticCards[1]).toEventually(beHeaderMessageCard())
	}

	// MARK: - Triple, Currently Valid, Domestic but viewing International Tab

	func test_datasourceupdate_tripleCurrentlyValidDomesticButViewingInternationalTab() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(),
					.validOneHourAgo_test_expires23HoursFromNow(),
					.validOneHourAgo_recovery_expires300DaysFromNow()
				],
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
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: vaccineGreenCardID,
				origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow()
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: recoveryGreenCardID,
				origins: [
					.validOneHourAgo_recovery_expires300DaysFromNow()
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: testGreenCardID,
				origins: [
					.validOneHourAgo_test_expires23HoursFromNow()
				],
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
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: vaccineGreenCardID,
				origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow()
				],
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
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validIn48Hours_vaccination_expires30DaysFromNow()],
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

		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalVaccinationcertificate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .future
			expect(rows.first?.validityTextEvaluator(now).text) == "wordt automatisch geldig over 2 dagen"
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).kind) == .future
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).text) == "wordt automatisch geldig over 12 uur"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleNotYetValidDomesticRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.netherlands(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validIn48Hours_recovery_expires300DaysFromNow()],
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
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalRecoverystatement().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .future
			expect(rows.first?.validityTextEvaluator(now).text) == "wordt automatisch geldig over 2 dagen"
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).kind) == .future
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).text) == "wordt automatisch geldig over 12 uur"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Single, Not Yet Valid, International

	func test_datasourceupdate_singleNotYetValidInternationalVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validIn48Hours_vaccination_expires30DaysFromNow()],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		// TODO: Also check Domestic?
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			// check rows
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalVaccinationdate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .future
			expect(rows.first?.validityTextEvaluator(now).text) == "wordt automatisch geldig over 2 dagen"
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).kind) == .future
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).text) == "wordt automatisch geldig over 12 uur"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	func test_datasourceupdate_singleNotYetValidInternationalRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.MyQRCard.europeanUnion(
				greenCardObjectID: sampleGreencardObjectID,
				origins: [.validIn48Hours_recovery_expires300DaysFromNow()],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		// TODO: Also check Domestic?
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message in
			expect(message) == L.holderDashboardIntroInternational()
		}))
		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { rows, isLoading, didTapViewQR, expiryCountdownEvaluator in
			expect(rows).to(haveCount(1))
			expect(rows.first?.typeText) == L.generalRecoverydate().capitalized

			// Exercise the validityTextEvaluator with different sample dates:
			expect(rows.first?.validityTextEvaluator(now).kind) == .future
			expect(rows.first?.validityTextEvaluator(now).text) == "wordt automatisch geldig over 2 dagen"
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).kind) == .future
			expect(rows.first?.validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow)).text) == "wordt automatisch geldig over 12 uur"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQR) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRParameters?.greenCardObjectID) === self.sampleGreencardObjectID

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

		expect(domesticCards[0]).toEventually(beHeaderMessageCard() { message in

		})
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
		// TODO: Also check Domestic?
		expect(self.sut.internationalCards).toEventually(haveCount(4))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard() { message in
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
		// TODO: Also check Domestic?
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

private func beDomesticQRCard(test: @escaping ([HolderDashboardViewController.Card.QRCardRow], Bool, () -> Void, ((Date) -> String?)?) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .domesticQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   // Skip buttonEnabledEvaluator because it always comes from the `HolderDashboardViewModel.MyQRCard` itself (which means it is stubbed in the test)
		   case let .domesticQR(rows, isLoading, didTapViewQR, _, expiryCountdownEvaluator) = actual {
			test(rows, isLoading, didTapViewQR, expiryCountdownEvaluator)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beEuropeanUnionQRCard(test: @escaping ([HolderDashboardViewController.Card.QRCardRow], Bool, () -> Void, ((Date) -> String?)?) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .europeanUnionQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .europeanUnionQR(rows, isLoading, didTapViewQR, _, expiryCountdownEvaluator) = actual {
			test(rows, isLoading, didTapViewQR, expiryCountdownEvaluator)
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
