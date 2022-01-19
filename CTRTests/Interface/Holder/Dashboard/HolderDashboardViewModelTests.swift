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
	private var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	private var datasourceSpy: HolderDashboardDatasourceSpy!
	private var strippenRefresherSpy: DashboardStrippenRefresherSpy!
	private var sampleGreencardObjectID: NSManagedObjectID!
	private var recoveryValidityExtensionManagerSpy: RecoveryValidityExtensionManagerProtocol!
	private var configurationNotificationManagerSpy: ConfigurationNotificationManagerSpy!
	private var vaccinationAssessmentNotificationManagerSpy: VaccinationAssessmentNotificationManagerSpy!
	private var environmentSpies: EnvironmentSpies!
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
		environmentSpies = setupEnvironmentSpies()

		configSpy = ConfigurationGeneralSpy()
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		datasourceSpy = HolderDashboardDatasourceSpy()
		strippenRefresherSpy = DashboardStrippenRefresherSpy()
		recoveryValidityExtensionManagerSpy = RecoveryValidityExtensionManagerSpy()
		configurationNotificationManagerSpy = ConfigurationNotificationManagerSpy()
		vaccinationAssessmentNotificationManagerSpy = VaccinationAssessmentNotificationManagerSpy()
		sampleGreencardObjectID = NSManagedObjectID()
	}

	func vendSut(dashboardRegionToggleValue: QRCodeValidityRegion, appVersion: String = "1.0.0") -> HolderDashboardViewModel {

		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = dashboardRegionToggleValue

		return HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			datasource: datasourceSpy,
			strippenRefresher: strippenRefresherSpy,
			recoveryValidityExtensionManager: recoveryValidityExtensionManagerSpy,
			configurationNotificationManager: configurationNotificationManagerSpy,
			vaccinationAssessmentNotificationManager: vaccinationAssessmentNotificationManagerSpy,
			versionSupplier: AppVersionSupplierSpy(version: appVersion)
		)
	}

	// MARK: -

	func test_initialState() {
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.sut.title) == L.holderDashboardTitle()
		expect(self.sut.primaryButtonTitle) == L.holderMenuProof()
		expect(self.sut.hasAddCertificateMode) == true
		expect(self.sut.currentlyPresentedAlert).to(beNil())

		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beEmptyStatePlaceholderImage())
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
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards).toEventually(haveCount(2))

		expect(self.sut.domesticCards[0]).to(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holderDashboardEmptyDomesticMessage()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).to(beEmptyStatePlaceholderImage(test: { image, title in
			expect(image) == I.dashboard.domestic()
			expect(title) == L.holderDashboardEmptyDomesticTitle()
		}))

		expect(self.sut.internationalCards[0]).to(beEmptyStateDescription(test: { message, buttonTitle in
			expect(message) == L.holderDashboardEmptyInternationalMessage()
			expect(buttonTitle) == L.holderDashboardEmptyInternationalButton()
		}))
		expect(self.sut.internationalCards[1]).to(beEmptyStatePlaceholderImage(test: { image, title in
			expect(image) == I.dashboard.international()
			expect(title) == L.holderDashboardEmptyInternationalTitle()
		}))
	}

	func test_viewWillAppear_triggersDatasourceReload() {
		// Arrange
		
		// remove this default value because otherwise this tangentially triggers a reload:
		environmentSpies.clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = nil
		
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		expect(self.datasourceSpy.invokedReload) == false

		// Act
		sut.viewWillAppear()

		// Assert
		expect(self.datasourceSpy.invokedReload) == true
	}

	func test_didBecomeActiveNotification_triggersDatasourceReload() {
		// Arrange
		
		// remove this default value because otherwise this tangentially triggers a reload:
		environmentSpies.clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = nil
		
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
		// remove this default value because otherwise this tangentially triggers a reload:
		environmentSpies.clockDeviationManagerSpy.stubbedAppendDeviationChangeObserverObserverResult = nil
		
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
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
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

		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
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
		expect(self.sut.domesticCards).toEventually(haveCount(3))
	}

	func test_strippen_international_startLoading_shouldClearError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
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
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())
		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))
		expect(self.sut.internationalCards).toEventually(haveCount(4))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.internationalCards[2]).toEventually(beEuropeanUnionQRCard())
		expect(self.sut.internationalCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
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
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards).toEventually(haveCount(3))
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
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
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
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())

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
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beEmptyStatePlaceholderImage())

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
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		strippenRefresherSpy.invokedDidUpdate?(nil, newStrippenState)

		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
	}

	func test_strippen_expired_serverError_secondTime_shouldDisplayErrorWithHelpdesk() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	func test_strippen_domesticandinternational_expired_serverError_firstTime_shouldDisplayError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneMonthAgo_vaccination_expired2DaysAgo()])],
				shouldShowErrorBeneathCard: true,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.internationalCards).toEventually(haveCount(4))

		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())
		expect(self.sut.internationalCards[2]).toEventually(beEuropeanUnionQRCard())

		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
		expect(self.sut.internationalCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
	}

	func test_strippen_domestic_expired_serverError_thirdTime_shouldDisplayHelpdeskError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	func test_strippen_international_expired_serverError_thirdTime_shouldDisplayHelpdeskError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		let error = DashboardStrippenRefresher.Error.networkError(error: NetworkError.invalidRequest, timestamp: now)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
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
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.currentlyPresentedAlert).to(beNil())
	}

	// MARK: Datasource Updating

	func test_datasourceupdate_mutliplefailures_shouldShowHelpDeskErrorBeneathCard() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())
		expect(self.sut.domesticCards[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	// MARK: - Single, Currently Valid, Domestic

	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(1 * years * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 20 augustus 2024"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())

		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.internationalCards[2]).toEventually(beOriginNotValidInThisRegionCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_newValidityBannerDisabled() {
		
		// Arrange
		environmentSpies.featureFlagManagerSpy.stubbedIsNewValidityInfoBannerEnabledResult = false
		environmentSpies.userSettingsSpy.hasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard = false
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(1 * years * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 20 augustus 2024"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
		
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.internationalCards[2]).toEventually(beOriginNotValidInThisRegionCard())
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_newValidityBannerEnabled() {

		// Arrange
		environmentSpies.featureFlagManagerSpy.stubbedIsNewValidityInfoBannerEnabledResult = true
		environmentSpies.userSettingsSpy.hasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard = false
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(5))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beNewValidityInfoForVaccinationAndRecoveriesCard(test: { message, buttonTitle, _, _ in
			expect(message) == L.holder_dashboard_newvaliditybanner_title()
			expect(buttonTitle) == L.holder_dashboard_newvaliditybanner_action()
		}))

		expect(self.sut.domesticCards[3]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(1 * years * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 20 augustus 2024"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.domesticCards[4]).toEventually(beRecommendCoronaMelderCard())

		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.internationalCards[2]).toEventually(beOriginNotValidInThisRegionCard())
	}
	
	func test_checkNewValidityBannerEnabled() {
		
		// Arrange
		environmentSpies.featureFlagManagerSpy.stubbedIsNewValidityInfoBannerEnabledResult = true
		environmentSpies.userSettingsSpy.hasDismissedNewValidityInfoForVaccinationsAndRecoveriesCard = false
		environmentSpies.userSettingsSpy.shouldCheckRecoveryGreenCardRevisedValidity = true

		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Assert
		expect(self.environmentSpies.userSettingsSpy.invokedShouldCheckRecoveryGreenCardRevisedValidity) == true
	}
	
	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_lessthan3years() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid5DaysAgo_vaccination_expires25DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 9 augustus 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot 9 augustus 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
		
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.internationalCards[2]).toEventually(beOriginNotValidInThisRegionCard())
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_secondDose() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 2)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticVaccination_expiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot 15 juli 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .past
			expect(futureValidityTexts[0].lines).to(beEmpty())

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now.addingTimeInterval(24 * hours * ago))).to(beNil())
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22 * hours * ago))) == "Verloopt over 22 uur en 1 minuut"
			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 1 minuut en 1 seconde"
		}))
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticTest() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in
					DomesticCredentialAttributes.sample(category: "3")
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beTestOnlyValidFor3GCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02 voor 3G-toegang"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig tot vrijdag 16 juli 16:02 voor 3G-toegang"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now.addingTimeInterval(17 * hours * fromNow))).to(beNil())
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(19 * hours * fromNow))) == "Verloopt over 4 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(25 * hours * fromNow))).to(beNil())
		}))
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticTest_verificationPolicyDisabled() {

		// Arrange
		environmentSpies.featureFlagManagerSpy.stubbedIsVerificationPolicyEnabledResult = false
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in
					DomesticCredentialAttributes.sample(category: "3")
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
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

			expect(expiryCountdownEvaluator?(now.addingTimeInterval(25 * hours * fromNow))).to(beNil())
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(22.5 * hours))) == "Verloopt over 30 minuten"
		}))
		expect(self.sut.domesticCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidDomesticRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

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
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(23 * hours))) == "Verloopt over 1 uur"
			expect(expiryCountdownEvaluator?(now.addingTimeInterval(299 * days * fromNow).addingTimeInterval(1 * hours))) == "Verloopt over 23 uur"
		}))
		expect(self.sut.domesticCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	// MARK: - Single, Currently Valid, International

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_1_of_2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					return EuCredentialAttributes.fakeVaccination()
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 1/2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Dosis 1/2"
			expect(futureValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_ExpiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date)  in
					return EuCredentialAttributes.fakeVaccination()
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 1/2"
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
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_0_of_2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 0, totalDose: 2))
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 0/2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccination_nil_of_2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: nil, totalDose: 2))
				}),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
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
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalTest() {
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration = .default
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.euTestTypes = [
			.init(code: "LP6464-4", name: "PCR (NAAT)")
		]

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in return EuCredentialAttributes.fake(dcc: .sampleWithTest()) }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Type test: PCR (NAAT)"
			expect(nowValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Type test: PCR (NAAT)"
			expect(futureValidityTexts[0].lines[1]) == "Testdatum: donderdag 15 juli 16:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(1))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(22 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	// MARK: - Multiple, One Valid, One not yet Valid, Domestic

	func test_datasourceupdate_oneNotYetValid_oneCurrentlyValid_domestic() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1),
					.validIn48Hours_recovery_expires300DaysFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[1].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[1].lines[1]) == "geldig vanaf 17 juli 17:02 tot 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(2 * days + 23 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .current
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
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

		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}

	// MARK: - Triple, Currently Valid, Domestic

	func test_datasourceupdate_tripleCurrentlyValidDomestic() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(
			test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

				// check isLoading
				expect(isLoading) == false

				let nowValidityTexts = validityTextEvaluator(now)
				expect(nowValidityTexts).to(haveCount(3))
				expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
				expect(nowValidityTexts[1].lines[0]) == L.generalRecoverystatement().capitalized + ":"
				expect(nowValidityTexts[2].lines[0]) == L.generalTestcertificate().capitalized + ":"

				expect(expiryCountdownEvaluator?(now)).to(beNil())
			}
		))

		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_tripleCurrentlyValidDomestic_oneExpiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(3))
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[1].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[2].lines[0]) == L.generalTestcertificate().capitalized + ":"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_tripleCurrentlyValidDomestic_allExpiringSoon() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
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
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(3))
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[1].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[2].lines[0]) == L.generalTestcertificate().capitalized + ":"

			expect(expiryCountdownEvaluator?(now)) == "Verloopt over 2 uur"
		}))
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
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
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(5))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "14 juli 2021"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.internationalCards[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 1
			expect(nowValidityTexts[0].lines[0]) == "Geldig tot 11 mei 2022"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))

		expect(self.sut.internationalCards[3]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts.count) == 1
			expect(nowValidityTexts[0].lines.count) == 2
			expect(nowValidityTexts[0].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot donderdag 15 juli 16:02"

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[4]).toEventually(beRecommendCoronaMelderCard())
	}

	// MARK: - Triple, Currently Valid, Domestic but viewing International Tab

	func test_datasourceupdate_tripleCurrentlyValidDomesticButViewingInternationalTab() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1),
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
		expect(self.sut.internationalCards).toEventually(haveCount(5))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.internationalCards[2]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.generalVaccinationcertificate())
		}))

		expect(self.sut.internationalCards[3]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.generalRecoverystatement())
		}))

		expect(self.sut.internationalCards[4]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(L.generalTestcertificate())
		}))
	}

	// MARK: - Triple, Currently Valid, International

	func test_datasourceupdate_tripleCurrentlyValidInternationalVaccinationButViewingDomesticTab() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let vaccineGreenCardID = NSManagedObjectID()
		let testGreenCardID = NSManagedObjectID()
		let recoveryGreenCardID = NSManagedObjectID()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: recoveryGreenCardID, origins: [.validOneHourAgo_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: testGreenCardID, origins: [.validOneHourAgo_test_expires23HoursFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards[1]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEUVaccination()
		}))

		expect(self.sut.domesticCards[2]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.generalRecoverystatement())
		}))

		expect(self.sut.domesticCards[3]).toEventually(beOriginNotValidInThisRegionCard(test: { message, _, _ in
			expect(message) == L.holderDashboardOriginNotValidInNetherlandsButIsInEU(L.generalTestcertificate())
		}))
	}

	func test_datasourceupdate_singleCurrentlyValidInternationalVaccinationButViewingDomesticTab_tappingMoreInfo() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let vaccineGreenCardID = NSManagedObjectID()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: vaccineGreenCardID, origins: [.validOneDayAgo_vaccination_expires3DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())

		expect(self.sut.domesticCards[1]).toEventually(beOriginNotValidInThisRegionCard(test: { _, _, didTapMoreInfo in
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQR) == false
			didTapMoreInfo()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutIncompleteDutchVaccination) == true
		}))
	}
	
	// MARK: - Valid VaccinationAssessment, Test expired
	
	func test_datasourceupdate_currentlyValidVaccinationAssessment_expiredTest_domesticTab() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.vaccinationassessment,
						eventDate: now.addingTimeInterval(72 * hours * ago),
						expirationTime: now.addingTimeInterval(11 * days * fromNow),
						validFromDate: now.addingTimeInterval(72 * hours * ago),
						doseNumber: nil
					),
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(12 * hours * ago),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			),
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: NSManagedObjectID(), origins: [
					.init(
						type: QRCodeOriginType.test,
						eventDate: now.addingTimeInterval(60 * hours * ago),
						expirationTime: now.addingTimeInterval(30 * days * fromNow),
						validFromDate: now.addingTimeInterval(60 * hours * ago),
						doseNumber: nil
					)
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { _, validityTextEvaluator, isLoading, _, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.general_visitorPass().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot maandag 26 juli 17:02"
			expect(nowValidityTexts[1].kind) == .past // the expired test (hidden in UI)
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.domesticCards[2]).toEventually(beRecommendCoronaMelderCard())
		
		expect(self.sut.internationalCards).toEventually(haveCount(4))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards[1]).toEventually(beOriginNotValidInThisRegionCard(test: { title, callToActionButtonText, _ in
			expect(title) == L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title()
			expect(callToActionButtonText) == L.generalReadmore()
		}))
		expect(self.sut.internationalCards[2]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, _, expiryCountdownEvaluator in
			// check isLoading
			expect(title) == L.generalTestcertificate().capitalized
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalTestcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig tot dinsdag 13 juli 05:02"
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
	}

	// MARK: - Single, Not Yet Valid, Domestic

	func test_datasourceupdate_singleNotYetValidDomesticVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expiresMoreThan3YearsFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}
	
	func test_datasourceupdate_singleNotYetValidDomesticVaccination_lessThan3Years() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		
		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false
			
			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"
			
			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (1 dosis)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"
			
			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID
			
			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}
	
	func test_datasourceupdate_singleNotYetValidDomesticVaccination_dose2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow(doseNumber: 2)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard())
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + " (2 doses)" + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 14 augustus 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleNotYetValidDomesticRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard(test: { title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == L.generalRecoverystatement().capitalized + ":"
			expect(futureValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 17:02 tot 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.domesticCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	// MARK: - Single, Not Yet Valid, International

	// This shouldn't happen because DCC Vaccines are immediately valid
	// But the test can at least track the behaviour in case it does.
	func test_datasourceupdate_singleNotYetValidInternationalVaccination() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_vaccination_expires30DaysFromNow(doseNumber: 1)])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == L.generalVaccinationcertificate().capitalized + ":"
			expect(nowValidityTexts[0].lines[1]) == "geldig vanaf 17 juli 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_singleNotYetValidInternationalRecovery() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [.validIn48Hours_recovery_expires300DaysFromNow()])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))
		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(1))
			expect(nowValidityTexts[0].lines).to(haveCount(1))
			expect(nowValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(nowValidityTexts[0].lines[0]) == "Geldig vanaf 17 juli 17:02 tot 11 mei 2022"

			// Exercise the validityText with different sample dates:
			let futureValidityTexts = validityTextEvaluator(now.addingTimeInterval(36 * hours * fromNow))
			expect(futureValidityTexts[0].kind) == .future(desiresToShowAutomaticallyBecomesValidFooter: true)
			expect(futureValidityTexts[0].lines[0]) == "Geldig vanaf 17 juli 17:02 tot 11 mei 2022"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs.first) === self.sampleGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	// MARK: - Expired cards

	func test_datasourceupdate_domesticExpired() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .domestic, type: .recovery),
			.init(region: .domestic, type: .test),
			.init(region: .domestic, type: .vaccination),
			.init(region: .domestic, type: .vaccinationassessment)
		]

		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)

		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(5))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroDomestic()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.domesticCards[1]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticRecovery_title()
		}))
		expect(self.sut.domesticCards[2]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticTest_title()
		}))
		expect(self.sut.domesticCards[3]).toEventually(beExpiredVaccinationQRCard(test: { message, callToActionButtonText, callToAction, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticVaccine_title()
			expect(callToActionButtonText) == L.generalReadmore()
			
			callToAction() // user taps..
			
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutExpiredDomesticVaccination) == true
		}))
		expect(self.sut.domesticCards[4]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_visitorPass_title()
		}))
	}

	func test_datasourceupdate_domesticExpired_tapForMoreInfo() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
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
			expect(message) == L.holder_dashboard_originExpiredBanner_domesticRecovery_title()
			didTapClose()

			// Check the non-cached value now to check that the Expired QR row was removed:
			expect(self.sut.domesticCards).to(haveCount(2))
			expect(self.sut.domesticCards[0]).to(beEmptyStateDescription())
			expect(self.sut.domesticCards[1]).to(beEmptyStatePlaceholderImage())

		}))
	}

	func test_datasourceupdate_internationalExpired() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let expiredCards: [HolderDashboardViewModel.ExpiredQR] = [
			.init(region: .europeanUnion, type: .recovery),
			.init(region: .europeanUnion, type: .test),
			.init(region: .europeanUnion, type: .vaccination),
			.init(region: .europeanUnion, type: .vaccinationassessment)
		]

		// Act
		datasourceSpy.invokedDidUpdate?([], expiredCards)

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(5))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		})
		expect(self.sut.internationalCards[1]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_internationalRecovery_title()
		}))
		expect(self.sut.internationalCards[2]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_internationalTest_title()
		}))
		expect(self.sut.internationalCards[3]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_internationalVaccine_title()
		}))
		expect(self.sut.internationalCards[4]).toEventually(beExpiredQRCard(test: { message, _ in
			expect(message) == L.holder_dashboard_originExpiredBanner_visitorPass_title()
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
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}

	func test_datasourceupdate_multipleDCC_1of2_2of2() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let oneOfTwoGreencardObjectID = NSManagedObjectID()
		let twoOfTwoGreencardObjectID = NSManagedObjectID()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					if greencard.id === oneOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 1, totalDose: 2))
					} else if greencard.id === twoOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 2, totalDose: 2))
					} else {
						fail("Unrecognised greencard received in closure")
						return nil
					}
				}),
				greencards: [
					.init(id: oneOfTwoGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()]),
					.init(id: twoOfTwoGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires30DaysFromNow()])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			expect(stackSize) == 2

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(2))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 2/2"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .current
			expect(nowValidityTexts[1].lines[0]) == "Dosis 1/2"
			expect(nowValidityTexts[1].lines[1]) == "Vaccinatiedatum: 15 juni 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[0]) === oneOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[1]) === twoOfTwoGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	func test_datasourceupdate_multipleDCC_1of2_2of2_3of2_3of3() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		let oneOfTwoGreencardObjectID = NSManagedObjectID()
		let twoOfTwoGreencardObjectID = NSManagedObjectID()
		let threeOfTwoGreencardObjectID = NSManagedObjectID()
		let threeOfThreeGreencardObjectID = NSManagedObjectID()

		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .europeanUnion(evaluateCredentialAttributes: { (greencard: QRCard.GreenCard, date: Date) in
					if greencard.id === oneOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 1, totalDose: 2))
					} else if greencard.id === twoOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 2, totalDose: 2))
					} else if greencard.id === threeOfTwoGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 3, totalDose: 2))
					} else if greencard.id === threeOfThreeGreencardObjectID {
						return EuCredentialAttributes.fakeVaccination(dcc: .sampleWithVaccine(doseNumber: 3, totalDose: 3))
					} else {
						fail("Unrecognised greencard received in closure")
						return nil
					}
				}),
				greencards: [
					.init(id: oneOfTwoGreencardObjectID, origins: [.valid30DaysAgo_vaccination_expires60SecondsFromNow()]),
					.init(id: twoOfTwoGreencardObjectID, origins: [.valid15DaysAgo_vaccination_expires14DaysFromNow()]),
					.init(id: threeOfTwoGreencardObjectID, origins: [.valid5DaysAgo_vaccination_expires25DaysFromNow()]),
					.init(id: threeOfThreeGreencardObjectID, origins: [.validOneDayAgo_vaccination_expires30DaysFromNow()])
				],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]

		// Act
		datasourceSpy.invokedDidUpdate?(qrCards, [])

		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(3))
		expect(self.sut.internationalCards[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards[1]).toEventually(beEuropeanUnionQRCard(test: { title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator in
			// check isLoading
			expect(isLoading) == false

			expect(stackSize) == 3 // max value here is 3 - shouldn't be 4.

			let nowValidityTexts = validityTextEvaluator(now)
			expect(nowValidityTexts).to(haveCount(4))
			expect(nowValidityTexts[0].lines).to(haveCount(2))
			expect(nowValidityTexts[0].kind) == .current
			expect(nowValidityTexts[0].lines[0]) == "Dosis 3/3"
			expect(nowValidityTexts[0].lines[1]) == "Vaccinatiedatum: 14 juli 2021"
			expect(nowValidityTexts[1].lines).to(haveCount(2))
			expect(nowValidityTexts[1].kind) == .current
			expect(nowValidityTexts[1].lines[0]) == "Dosis 3/2"
			expect(nowValidityTexts[1].lines[1]) == "Vaccinatiedatum: 10 juli 2021"
			expect(nowValidityTexts[2].lines).to(haveCount(2))
			expect(nowValidityTexts[2].kind) == .current
			expect(nowValidityTexts[2].lines[0]) == "Dosis 2/2"
			expect(nowValidityTexts[2].lines[1]) == "Vaccinatiedatum: 30 juni 2021"
			expect(nowValidityTexts[3].lines).to(haveCount(2))
			expect(nowValidityTexts[3].kind) == .current
			expect(nowValidityTexts[3].lines[0]) == "Dosis 1/2"
			expect(nowValidityTexts[3].lines[1]) == "Vaccinatiedatum: 15 juni 2021"

			// check didTapViewQR
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == false
			didTapViewQR()
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRs) == true
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[0]) === oneOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[1]) === twoOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[2]) === threeOfTwoGreencardObjectID
			expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs[3]) === threeOfThreeGreencardObjectID

			expect(expiryCountdownEvaluator?(now)).to(beNil())
		}))
		expect(self.sut.internationalCards[2]).toEventually(beRecommendCoronaMelderCard())
	}

	// MARK: - RemoteConfig changes

	func test_registersForRemoteConfigChanges_affectingStrippenRefresher() {

		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedAppendUpdateObserverObserverResult = (RemoteConfiguration.default, Data(), URLResponse())

		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Assert

		// First: during `.init`
		// Second: when it receives the `stubbedAppendUpdateObserverObserverResult` value above.
		expect(self.strippenRefresherSpy.invokedLoadCount) == 2
	}

	func test_configIsAlmostOutOfDate() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBannerResult = true

		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Assert
		expect(self.sut.domesticCards[1]).to(beConfigurationAlmostOutOfDateCard())
		expect(self.sut.internationalCards[1]).to(beConfigurationAlmostOutOfDateCard())

		// only during .init
		expect(self.configurationNotificationManagerSpy.invokedShouldShowAlmostOutOfDateBannerCount) == 2
	}

	func test_configIsAlmostOutOfDate_userTappedOnCard_domesticTab() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBannerResult = true
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		if case let .configAlmostOutOfDate(_, _, action) = sut.domesticCards[1] {
			action()
		}

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfig) == true
	}

	func test_configIsAlmostOutOfDate_userTappedOnCard_internationalTab() {

		// Arrange
		configurationNotificationManagerSpy.stubbedShouldShowAlmostOutOfDateBannerResult = true
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		// Act
		if case let .configAlmostOutOfDate(_, _, action) = sut.domesticCards[1] {
			action()
		}

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfig) == true
	}
	
	func test_recommendUpdate_recommendedVersion_higherActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.2.0"

		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, appVersion: "1.1.0")

		// Assert
		expect(self.sut.domesticCards[1]).toEventually(beRecommendedUpdateCard())
	}
	
	func test_recommendUpdate_recommendedVersion_lowerActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.0.0"
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, appVersion: "1.1.0")
		
		// Assert
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_recommendUpdate_recommendedVersion_equalActionVersion() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.recommendedVersion = "1.1.0"
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic, appVersion: "1.1.0")
		
		// Assert
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	// MARK: - Vaccination Assessment
	
	func test_vaccinationassessment_domestic_shouldShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = true
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beCompleteYourVaccinationAssessmentCard(test: { message, buttonTitle, _ in
			expect(message) == L.holder_dashboard_visitorpassincompletebanner_title()
			expect(buttonTitle) == L.holder_dashboard_visitorpassincompletebanner_button_makecomplete()
		}))
	}
	
	func test_vaccinationassessment_domestic_shouldNotShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = false
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Assert
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	func test_vaccinationassessment_international_shouldShow() {
	
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = true
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beVaccinationAssessmentInvalidOutsideNLCard(test: { message, buttonTitle, _ in
			expect(message) == L.holder_dashboard_visitorPassInvalidOutsideNLBanner_title()
			expect(buttonTitle) == L.generalReadmore()
		}))
	}
	
	func test_vaccinationassessment_international_shouldNotShow() {
		
		// Arrange
		vaccinationAssessmentNotificationManagerSpy.stubbedHasVaccinationAssessmentEventButNoOriginResult = false
		
		// Act
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Assert
		expect(self.sut.internationalCards).toEventually(haveCount(2))
		expect(self.sut.internationalCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}
	
	// MARK: - HolderDashboardCardUserActionHandling callbacks

	func test_actionhandling_didTapConfigAlmostOutOfDateCTA() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedConfigFetchedTimestamp = now.timeIntervalSince1970
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapConfigAlmostOutOfDateCTA()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfigCount) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutOutdatedConfigParameters?.validUntil) == "15 juli 18:02"
	}

	func test_actionhandling_didTapCloseExpiredQR() {

		// Arrange
		environmentSpies.userSettingsSpy.stubbedDashboardRegionToggleValue = .domestic
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		let expiredRecovery = HolderDashboardViewModel.ExpiredQR(region: .domestic, type: .recovery)
		let expiredTest = HolderDashboardViewModel.ExpiredQR(region: .domestic, type: .test)

		// Act & Assert
		datasourceSpy.invokedDidUpdate?([], [expiredRecovery, expiredTest])

		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beExpiredQRCard())
		expect(self.sut.domesticCards[2]).toEventually(beExpiredQRCard())

		// Close first expired QR:
		sut.didTapCloseExpiredQR(expiredQR: expiredRecovery)

		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beExpiredQRCard(test: { title, _ in
			// The expired test card should remain:
			expect(title) == L.holder_dashboard_originExpiredBanner_domesticTest_title()
		}))

		// Close second expired QR:
		sut.didTapCloseExpiredQR(expiredQR: expiredTest)
		expect(self.sut.domesticCards).toEventually(haveCount(2))
		expect(self.sut.domesticCards[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards[1]).toEventually(beEmptyStatePlaceholderImage())
	}

	func test_actionhandling_didTapOriginNotValidInThisRegionMoreInfo_vaccination_domestic() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapOriginNotValidInThisRegionMoreInfo(originType: .vaccination, validityRegion: .domestic)

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutIncompleteDutchVaccinationCount) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQR) == false
	}

	func test_actionhandling_didTapOriginNotValidInThisRegionMoreInfo() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)

		// Act
		sut.didTapOriginNotValidInThisRegionMoreInfo(originType: .vaccination, validityRegion: .europeanUnion)

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRCount) == 1
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRParameters?.originType) == .vaccination
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRParameters?.currentRegion) == .europeanUnion
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutUnavailableQRParameters?.availableRegion) == .domestic
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutIncompleteDutchVaccination) == false
	}

	func test_actionhandling_didTapDeviceHasClockDeviationMoreInfo() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapDeviceHasClockDeviationMoreInfo()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutClockDeviationCount) == 1
	}

	func test_actionhandling_didTapShowQR() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		let values = [NSManagedObjectID()]
		sut.didTapShowQR(greenCardObjectIDs: values)

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToViewQRsParameters?.greenCardObjectIDs) === values
	}

	func test_actionhandling_didTapRetryLoadQRCards() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapRetryLoadQRCards()

		// Assert
		expect(self.strippenRefresherSpy.invokedLoadCount) == 2
	}

	func test_actionhandling_didTapRecoveryValidityExtensionAvailableMoreInfo() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapRecoveryValidityExtensionAvailableMoreInfo()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCount) == 1
	}

	func test_actionhandling_didTapRecoveryValidityExtensionCompleteMoreInfo() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapRecoveryValidityExtensionCompleteMoreInfo()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutRecoveryValidityExtensionCompletedCount) == 1
	}

	func test_actionhandling_didTapRecoveryValidityExtensionCompleteClose() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapRecoveryValidityExtensionCompleteClose()

		// Assert
		expect(self.environmentSpies.userSettingsSpy.invokedHasDismissedRecoveryValidityExtensionCompletionCardSetter) == true
	}

	func test_actionhandling_didTapRecoveryValidityReinstationAvailableMoreInfo() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapRecoveryValidityReinstationAvailableMoreInfo()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCount) == 1
	}

	func test_actionhandling_didTapRecoveryValidityReinstationCompleteMoreInfo() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapRecoveryValidityReinstationCompleteMoreInfo()

		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutRecoveryValidityReinstationCompletedCount) == 1
	}

	func test_actionhandling_didTapRecoveryValidityReinstationCompleteClose() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)

		// Act
		sut.didTapRecoveryValidityReinstationCompleteClose()

		// Assert
		expect(self.environmentSpies.userSettingsSpy.invokedHasDismissedRecoveryValidityReinstationCompletionCardSetter) == true
	}
	
	func test_actionhandling_didTapRecommenedUpdate_noUrl() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Act
		sut.didTapRecommendedUpdate()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == false
	}
	
	func test_actionhandling_didTapRecommenedUpdate() {
		
		// Arrange
		environmentSpies.remoteConfigManagerSpy.stubbedStoredConfiguration.appStoreURL = URL(string: "https://apple.com")
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Act
		sut.didTapRecommendedUpdate()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedOpenUrl) == true
	}
	
	func test_actionhandling_didTapCompleteYourVaccinationAssessmentMoreInfo() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Act
		sut.didTapCompleteYourVaccinationAssessmentMoreInfo()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutCompletingVaccinationAssessment) == true
	}
	
	func test_actionhandling_didTapVaccinationAssessmentInvalidOutsideNLMoreInfo() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .europeanUnion)
		
		// Act
		sut.didTapVaccinationAssessmentInvalidOutsideNLMoreInfo()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL) == true
	}
	
	func test_actionhandling_didTapRecommendToAddYourBooster() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		// Act
		sut.didTapRecommendToAddYourBooster()
		
		// Assert
		expect(self.holderCoordinatorDelegateSpy.invokedUserWishesToCreateAVaccinationQR) == true
	}
	
	func test_actionhandling_didTapRecommendToAddYourBoosterClose() {
		
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic)
		
		let qrCards = [
			HolderDashboardViewModel.QRCard(
				region: .netherlands(evaluateCredentialAttributes: { _, _ in nil }),
				greencards: [.init(id: sampleGreencardObjectID, origins: [
					.valid30DaysAgo_vaccination_expires60SecondsFromNow()
				])],
				shouldShowErrorBeneathCard: false,
				evaluateEnabledState: { _ in true }
			)
		]
		datasourceSpy.invokedDidUpdate?(qrCards, [])
		
		expect(self.sut.domesticCards).toEventually(haveCount(4))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beRecommendToAddYourBoosterCard(test: { message, buttonTitle, _, _ in
			expect(message) == L.holder_dashboard_addBoosterBanner_title()
			expect(buttonTitle) == L.holder_dashboard_addBoosterBanner_button_addBooster()
		}))
		expect(self.sut.domesticCards[2]).toEventually(beDomesticQRCard())
		expect(self.sut.domesticCards[3]).toEventually(beRecommendCoronaMelderCard())
		
		// Act
		sut.didTapRecommendToAddYourBoosterClose()
		
		// Assert
		expect(self.environmentSpies.userSettingsSpy.invokedLastRecommendToAddYourBoosterDismissalDate) == now
		expect(self.sut.domesticCards).toEventually(haveCount(3))
		expect(self.sut.domesticCards[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards[1]).toEventually(beDomesticQRCard())
		expect(self.sut.domesticCards[2]).toEventually(beRecommendCoronaMelderCard())
	}
}

// See: https://medium.com/@Tovkal/testing-enums-with-associated-values-using-nimble-839b0e53128
private func beEmptyStateDescription(test: @escaping (String, String?) -> Void = { _, _  in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .emptyStateDescription with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .emptyStateDescription(message1, buttonTitle1) = actual {
			test(message1, buttonTitle1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beEmptyStatePlaceholderImage(test: @escaping (UIImage?, String) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .emptyStatePlaceholderImage with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .emptyStatePlaceholderImage(image, title1) = actual {
			test(image, title1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beHeaderMessageCard(test: @escaping (String, String?) -> Void = { _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .headerMessage with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .headerMessage(message1, buttonTitle1) = actual {
			test(message1, buttonTitle1)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beDomesticQRCard(test: @escaping (String, (Date) -> [HolderDashboardViewController.ValidityText], Bool, () -> Void, ((Date) -> String?)?) -> Void = { _, _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .domesticQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   // Skip buttonEnabledEvaluator because it always comes from the `HolderDashboardViewModel.MyQRCard` itself (which means it is stubbed in the test)
		   case let .domesticQR(title, validityTextEvaluator, isLoading, didTapViewQR, _, expiryCountdownEvaluator) = actual {
			test(title, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beEuropeanUnionQRCard(test: @escaping (String, Int, (Date) -> [HolderDashboardViewController.ValidityText], Bool, () -> Void, ((Date) -> String?)?) -> Void = { _, _, _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .europeanUnionQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .europeanUnionQR(title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, _, expiryCountdownEvaluator) = actual {
			test(title, stackSize, validityTextEvaluator, isLoading, didTapViewQR, expiryCountdownEvaluator)
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

private func beExpiredVaccinationQRCard(test: @escaping (String, String, () -> Void, () -> Void) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .expiredVaccinationQR with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .expiredVaccinationQR(message2, callToActionButtonText2, didTapCallToAction2, didTapClose2) = actual {
			test(message2, callToActionButtonText2, didTapCallToAction2, didTapClose2)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beOriginNotValidInThisRegionCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .originNotValidInThisRegion with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .originNotValidInThisRegion(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beConfigurationAlmostOutOfDateCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .configAlmostOutOfDate with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .configAlmostOutOfDate(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beRecommendCoronaMelderCard() -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beRecommendCoronaMelderCard with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case .recommendCoronaMelder = actual {
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beTestOnlyValidFor3GCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beTestOnlyValidFor3GCard with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .testOnlyValidFor3G(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beRecommendedUpdateCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beRecommendedUpdateCard with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .recommendedUpdate(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beRecommendToAddYourBoosterCard(test: @escaping (String, String, () -> Void, () -> Void) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .recommendToAddYourBooster with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .recommendToAddYourBooster(message2, buttonText, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, buttonText, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beNewValidityInfoForVaccinationAndRecoveriesCard(test: @escaping (String, String, () -> Void, () -> Void) -> Void = { _, _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beNewValidityInfoForVaccinationAndRecoveriesCard with matching values") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .newValidityInfoForVaccinationAndRecoveries(message2, callToActionButtonText, didTapCallToAction, didTapToClose) = actual {
			test(message2, callToActionButtonText, didTapCallToAction, didTapToClose)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beCompleteYourVaccinationAssessmentCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beCompleteYourVaccinationAssessmentCard with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .completeYourVaccinationAssessment(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}

private func beVaccinationAssessmentInvalidOutsideNLCard(test: @escaping (String, String, () -> Void) -> Void = { _, _, _ in }) -> Predicate<HolderDashboardViewController.Card> {
	return Predicate.define("be .beVaccinationAssessmentInvalidOutsideNLCard with matching value") { expression, message in
		if let actual = try expression.evaluate(),
		   case let .vaccinationAssessmentInvalidOutsideNL(message2, callToActionButtonText, didTapCallToAction) = actual {
			test(message2, callToActionButtonText, didTapCallToAction)
			return PredicateResult(status: .matches, message: message)
		}
		return PredicateResult(status: .fail, message: message)
	}
}
