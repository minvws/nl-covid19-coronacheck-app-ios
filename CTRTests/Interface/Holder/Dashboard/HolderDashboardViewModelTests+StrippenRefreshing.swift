/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import XCTest
@testable import CTR
import Nimble
import CoreData

extension HolderDashboardViewModelTests {
	
	// MARK: - Strippen Loading

	func test_strippen_stopsLoading_shouldTriggerDatasourceReload() {
		
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

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
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

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

		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
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
		expect(self.sut.domesticCards.value).toEventually(haveCount(4))
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

		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
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
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
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
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard())
		expect(self.sut.domesticCards.value[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard())
		expect(self.sut.internationalCards.value[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
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
		expect(self.sut.domesticCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value).toEventually(haveCount(3))
	}

	// MARK: - Strippen Alerts

	func test_strippen_expired_noInternetError_shouldPresentError() {
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expired,
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, newStrippenState)

		expect(self.sut.currentlyPresentedAlert.value?.title) == L.holderDashboardStrippenExpiredNointernetAlertTitle()
		expect(self.sut.currentlyPresentedAlert.value?.subTitle) == L.holderDashboardStrippenExpiredNointernetAlertMessage()
		expect(self.sut.currentlyPresentedAlert.value?.cancelTitle) == L.generalClose()
		expect(self.sut.currentlyPresentedAlert.value?.okTitle) == L.generalRetry()

		self.sut.currentlyPresentedAlert.value?.cancelAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedUserDismissedALoadingError) == true

		self.sut.currentlyPresentedAlert.value?.okAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedLoad) == true
	}

	func test_strippenkaart_noInternet_expired_previouslyDismissed_shouldDisplayError() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

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
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards.value[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterNointernet()
		}))
	}

	func test_strippen_noInternet_expiring_shouldPresentErrorAlert() {
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

		let newStrippenState = DashboardStrippenRefresher.State(
			loadingState: .noInternet,
			now: { now },
			greencardsCredentialExpiryState: .expiring(deadline: now.addingTimeInterval(3 * hours * fromNow)),
			userHasPreviouslyDismissedALoadingError: false,
			hasLoadingEverFailed: false,
			errorOccurenceCount: 0
		)
		strippenRefresherSpy.invokedDidUpdate?(nil, newStrippenState)

		expect(self.sut.currentlyPresentedAlert.value?.title) == L.holderDashboardStrippenExpiringNointernetAlertTitle()
		expect(self.sut.currentlyPresentedAlert.value?.subTitle) == L.holderDashboardStrippenExpiringNointernetAlertMessage("3 uur")
		expect(self.sut.currentlyPresentedAlert.value?.cancelTitle) == L.generalClose()
		expect(self.sut.currentlyPresentedAlert.value?.okTitle) == L.generalRetry()

		self.sut.currentlyPresentedAlert.value?.cancelAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedUserDismissedALoadingError) == true

		self.sut.currentlyPresentedAlert.value?.okAction?(UIAlertAction())
		expect(self.strippenRefresherSpy.invokedLoad) == true
	}

	func test_strippenkaart_noInternet_expiring_hasPreviouslyDismissed_shouldDoNothing() {

		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

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
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.currentlyPresentedAlert.value).to(beNil())
	}

	func test_strippenkaart_serverError_expiring_shouldDoNothing() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
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
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.internationalCards.value).toEventually(haveCount(2))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.currentlyPresentedAlert.value).to(beNil())
	}

	func test_strippen_expired_serverError_firstTime_shouldDisplayErrorWithRetry() {
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

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

		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards.value[1]).toEventually(beDisclosurePolicyInformationCard())
		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards.value[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
	}

	func test_strippen_expired_serverError_secondTime_shouldDisplayErrorWithHelpdesk() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
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
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards.value[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	func test_strippen_domesticandinternational_expired_serverError_firstTime_shouldDisplayError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
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
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))

		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle).to(beNil())
		}))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard())
		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard())

		expect(self.sut.domesticCards.value[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
		expect(self.sut.internationalCards.value[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)
		}))
	}

	func test_strippen_domestic_expired_serverError_thirdTime_shouldDisplayHelpdeskError() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])
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
		expect(self.sut.domesticCards.value).toEventually(haveCount(5))
		expect(self.sut.domesticCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holder_dashboard_intro_domestic_only3Gaccess()
			expect(buttonTitle).to(beNil())
		}))

		expect(self.sut.domesticCards.value[2]).toEventually(beDomesticQRCard())

		expect(self.sut.domesticCards.value[3]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
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
		expect(self.sut.internationalCards.value).toEventually(haveCount(4))
		expect(self.sut.internationalCards.value[0]).toEventually(beHeaderMessageCard(test: { message, buttonTitle in
			expect(message) == L.holderDashboardIntroInternational()
			expect(buttonTitle) == L.holderDashboardIntroInternationalButton()
		}))

		expect(self.sut.internationalCards.value[1]).toEventually(beEuropeanUnionQRCard())

		expect(self.sut.internationalCards.value[2]).toEventually(beErrorMessageCard(test: { message, didTapTryAgain in
			expect(message) == L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
		}))
	}

	func test_strippenkaart_noActionNeeded_shouldDoNothing() {
		// Arrange
		sut = vendSut(dashboardRegionToggleValue: .domestic, activeDisclosurePolicies: [.policy3G])

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
		expect(self.sut.domesticCards.value).toEventually(haveCount(3))
		expect(self.sut.domesticCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.domesticCards.value[2]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.internationalCards.value).toEventually(haveCount(2))
		expect(self.sut.internationalCards.value[0]).toEventually(beEmptyStateDescription())
		expect(self.sut.internationalCards.value[1]).toEventually(beEmptyStatePlaceholderImage())

		expect(self.sut.currentlyPresentedAlert.value).to(beNil())
	}
}
