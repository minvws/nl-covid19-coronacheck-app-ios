/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CoreData
import Reachability

final class HolderDashboardViewModel: Logging {
	typealias Datasource = HolderDashboardQRCardDatasource

	// MARK: - Public properties

	/// The logging category
	var loggingCategory: String = "HolderDashboardViewModel"

	/// The title of the scene
	@Bindable private(set) var title: String = L.holderDashboardTitle()

	@Bindable private(set) var domesticCards = [HolderDashboardViewController.Card]()
	@Bindable private(set) var internationalCards = [HolderDashboardViewController.Card]()
	
	@Bindable private(set) var primaryButtonTitle = L.holderMenuProof()
	
	@Bindable private(set) var hasAddCertificateMode: Bool = false

	@Bindable private(set) var currentlyPresentedAlert: AlertContent?
	
	@Bindable private(set) var selectedTab: DashboardTab = .domestic

	// MARK: - Private types

	/// Wrapper around some state variables
	/// that allows us to use a `didSet{}` to
	/// get a callback if any of them are mutated.
	fileprivate struct State: Equatable {
		var qrCards: [QRCard]
		var expiredGreenCards: [ExpiredQR]
		var isRefreshingStrippen: Bool

		// Related to strippen refreshing.
		// When there's an error with the refreshing process,
		// we show an error message on each QR card that lacks credentials.
		// This does not discriminate between domestic/EU.
		var errorForQRCardsMissingCredentials: String?

		var deviceHasClockDeviation: Bool = false

		var shouldShowEUVaccinationUpdateBanner: Bool = false

		var shouldShowEUVaccinationUpdateCompletedBanner: Bool = false
	}

	// MARK: - Private properties

	private weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?
	private weak var cryptoManager: CryptoManaging? = Services.cryptoManager
	private let remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager
	private let notificationCenter: NotificationCenterProtocol = NotificationCenter.default
	private var userSettings: UserSettingsProtocol

	var dashboardRegionToggleValue: QRCodeValidityRegion {
		didSet {
			DispatchQueue.global().async {
				self.userSettings.dashboardRegionToggleValue = self.dashboardRegionToggleValue
			}
		}
	}

	private var state: State {
		didSet {
			didUpdate(oldState: oldValue, newState: state)
		}
	}
	
	var selectTab: DashboardTab = .domestic {
		didSet {
			dashboardRegionToggleValue = selectedTab.isDomestic ? .domestic : .europeanUnion
			selectedTab = selectTab
		}
	}

	private let datasource: HolderDashboardQRCardDatasourceProtocol
	private let strippenRefresher: DashboardStrippenRefreshing
	private var dccMigrationNotificationManager: DCCMigrationNotificationManagerProtocol
	private var clockDeviationObserverToken: ClockDeviationManager.ObserverToken?
	private let now: () -> Date

	// MARK: - Initializer
	init(
		coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol),
		datasource: HolderDashboardQRCardDatasourceProtocol,
		strippenRefresher: DashboardStrippenRefreshing,
		userSettings: UserSettingsProtocol,
		dccMigrationNotificationManager: DCCMigrationNotificationManagerProtocol,
		now: @escaping () -> Date
	) {

		self.coordinator = coordinator
		self.datasource = datasource
		self.strippenRefresher = strippenRefresher
		self.userSettings = userSettings
		self.now = now
		self.dashboardRegionToggleValue = userSettings.dashboardRegionToggleValue
		self.dccMigrationNotificationManager = dccMigrationNotificationManager

		self.state = State(
			qrCards: [],
			expiredGreenCards: [],
			isRefreshingStrippen: false,
			deviceHasClockDeviation: Services.clockDeviationManager.hasSignificantDeviation ?? false
		)

		didUpdate(oldState: nil, newState: state)

		self.datasource.didUpdate = { [weak self] (qrCardDataItems: [QRCard], expiredGreenCards: [ExpiredQR]) in
			DispatchQueue.main.async {
				self?.state.qrCards = qrCardDataItems
				self?.state.expiredGreenCards += expiredGreenCards

				self?.dccMigrationNotificationManager.reload()
			}
		}

		// Map RefresherState to State:
		self.strippenRefresher.didUpdate = { [weak self] oldValue, newValue in
			self?.strippenRefresherDidUpdate(oldRefresherState: oldValue, refresherState: newValue)
		}
		strippenRefresher.load()

		self.setupNotificationListeners()

		clockDeviationObserverToken = Services.clockDeviationManager.appendDeviationChangeObserver { [weak self] hasClockDeviation in
			self?.state.deviceHasClockDeviation = hasClockDeviation
			self?.datasource.reload() // this could cause some QR code states to change, so reload.
		}

		// Setup the dcc
		self.dccMigrationNotificationManager.showMigrationAvailableBanner = { [weak self] in
			self?.state.shouldShowEUVaccinationUpdateBanner = true
		}
		self.dccMigrationNotificationManager.showMigrationCompletedBanner = { [weak self] in
			guard var state = self?.state else { return }
			state.shouldShowEUVaccinationUpdateBanner = false
			state.shouldShowEUVaccinationUpdateCompletedBanner = true
			self?.state = state
		}
		dccMigrationNotificationManager.reload()

//		#if DEBUG
//		DispatchQueue.main.asyncAfter(deadline: .now()) {
//			self.injectSampleData(dataStoreManager: Services.dataStoreManager)
//			self.datasource.reload()
//		}
//		#endif
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		clockDeviationObserverToken.map(Services.clockDeviationManager.removeDeviationChangeObserver)
	}

	func viewWillAppear() {
		datasource.reload()
	}

	/// Don't call directly, apart from within `init` and from within `var state: State { didSet { ... } }`
	fileprivate func didUpdate(oldState: State?, newState: State) {
		guard let coordinator = coordinator, state != oldState // save recomputation effort if `==`
		else { return }

		(domesticCards, internationalCards) = HolderDashboardViewModel.assembleCards(
			state: state,
			didTapCloseExpiredQR: { expiredQR in
				self.state.expiredGreenCards.removeAll(where: { $0.id == expiredQR.id })
			},
			coordinatorDelegate: coordinator,
			strippenRefresher: strippenRefresher,
			remoteConfigManager: remoteConfigManager,
			now: self.now(),
			userSettings: userSettings
		)

		hasAddCertificateMode = state.qrCards.isEmpty
	}

	fileprivate func strippenRefresherDidUpdate(oldRefresherState: DashboardStrippenRefresher.State?, refresherState: DashboardStrippenRefresher.State) {
		guard refresherState != oldRefresherState else { return }

		state.isRefreshingStrippen = refresherState.isNonsilentlyLoading

		// If we reload, clear the UI's error message.
		if refresherState.loadingState.isLoading {
			state.errorForQRCardsMissingCredentials = nil
		}

		// If we just stopped loading, reload data.
		if !refresherState.loadingState.isLoading && (oldRefresherState?.loadingState.isLoading ?? false) {
			datasource.reload()
		}

		// Handle combination of Loading State + Expiry State + Error presentation:
		switch (refresherState.loadingState, refresherState.greencardsCredentialExpiryState, refresherState.userHasPreviouslyDismissedALoadingError) {
			case (_, .noActionNeeded, _):
				logDebug("StrippenRefresh: No action needed.")

			// 🔌 NO INTERNET: Refresher has no internet and wants to know what to do next

			case (.noInternet, .expired, false):
				logDebug("StrippenRefresh: Need refreshing now, but no internet. Presenting alert.")
				currentlyPresentedAlert = AlertContent.strippenExpiredWithNoInternet(strippenRefresher: strippenRefresher)

			case (.noInternet, .expired, true):
				logDebug("StrippenRefresh: Need refreshing now, but no internet. Showing in UI.")
				state.errorForQRCardsMissingCredentials = L.holderDashboardStrippenExpiredErrorfooterNointernet()

			case (.noInternet, .expiring, true):
				// Do nothing
				logDebug("StrippenRefresh: Need refreshing soon, but no internet. Do nothing.")

			case (.noInternet, .expiring(let expiryDate), false):
				logDebug("StrippenRefresh: Need refreshing soon, but no internet. Presenting alert.")
				currentlyPresentedAlert = AlertContent.strippenExpiringWithNoInternet(expiryDate: expiryDate, strippenRefresher: strippenRefresher, now: now())

			// ❤️‍🩹 NETWORK ERROR: Refresher has entered a failed state (i.e. Server Error)

			case (.failed, .expired, _):
				logDebug("StrippenRefresh: Need refreshing now, but server error. Showing in UI.")

				state.errorForQRCardsMissingCredentials = refresherState.errorOccurenceCount > 1
					? L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
					: L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)

			case (.failed, .expiring, _):
				// In this case we just swallow the server errors.
				// We do handle "no internet" though - see above.
				logDebug("StrippenRefresh: Swallowing server error because can refresh later.")

			case (.loading, _, _), (.idle, _, _), (.completed, _, _):
				break
		}
	}

	// MARK: Capture User input:

	@objc func addProofTapped() {
		coordinator?.userWishesToCreateAQR()
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	// MARK: - Static Methods

	private static func assembleCards(
		state: HolderDashboardViewModel.State,
		didTapCloseExpiredQR: @escaping (ExpiredQR) -> Void,
		coordinatorDelegate: (HolderCoordinatorDelegate),
		strippenRefresher: DashboardStrippenRefreshing,
		remoteConfigManager: RemoteConfigManaging,
		now: Date,
		userSettings: UserSettingsProtocol
	) -> (domestic: [HolderDashboardViewController.Card], international: [HolderDashboardViewController.Card]) {

		let domesticCards = assembleCards(
			forValidityRegion: .domestic,
			state: state,
			didTapCloseExpiredQR: didTapCloseExpiredQR,
			coordinatorDelegate: coordinatorDelegate,
			strippenRefresher: strippenRefresher,
			remoteConfigManager: remoteConfigManager,
			now: now,
			userSettings: userSettings)

		let internationalCards = assembleCards(
			forValidityRegion: .europeanUnion,
			state: state,
			didTapCloseExpiredQR: didTapCloseExpiredQR,
			coordinatorDelegate: coordinatorDelegate,
			strippenRefresher: strippenRefresher,
			remoteConfigManager: remoteConfigManager,
			now: now,
			userSettings: userSettings)

		return (domestic: domesticCards, international: internationalCards)
	}

	// Temporary swiftlint disable.. 
	// swiftlint:disable:next function_parameter_count
	private static func assembleCards(
		forValidityRegion validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		didTapCloseExpiredQR: @escaping (ExpiredQR) -> Void,
		coordinatorDelegate: HolderCoordinatorDelegate,
		strippenRefresher: DashboardStrippenRefreshing,
		remoteConfigManager: RemoteConfigManaging,
		now: Date,
		userSettings: UserSettingsProtocol
	) -> [HolderDashboardViewController.Card] {

		let allQRCards = state.qrCards
		let regionFilteredMyQRCards = state.qrCards.filter { (qrCard: QRCard) in
			switch (qrCard.region, validityRegion) {
				case (.netherlands, .domestic): return true
				case (.europeanUnion, .europeanUnion): return true
				default: return false
			}
		}

		let regionFilteredExpiredCards = state.expiredGreenCards.filter { $0.region == validityRegion }

		// We'll add to this:
		var viewControllerCards = [HolderDashboardViewController.Card]()

		if !allQRCards.isEmpty || !regionFilteredExpiredCards.isEmpty {
			viewControllerCards += [
				{
					switch validityRegion {
						case .domestic:
							return .headerMessage(message: L.holderDashboardIntroDomestic(),
												  buttonTitle: nil)
						case .europeanUnion:
							return .headerMessage(message: L.holderDashboardIntroInternational(),
												  buttonTitle: L.holderDashboardEmptyInternationalButton())
					}
				}()
			]
		}

		if state.deviceHasClockDeviation && !allQRCards.isEmpty {
			viewControllerCards += [
				.deviceHasClockDeviation(
					message: L.holderDashboardClockDeviationDetectedMessage(),
					callToActionButtonText: L.generalReadmore(),
					didTapCallToAction: {
						coordinatorDelegate.userWishesMoreInfoAboutClockDeviation()
					}
				)
			]
		}

		// Multiple DCC migration banners:

		if validityRegion == .europeanUnion {
			if state.shouldShowEUVaccinationUpdateBanner {
				viewControllerCards += [
					.migrateYourInternationalVaccinationCertificate(
						message: L.holderDashboardCardUpgradeeuvaccinationMessage(),
						callToActionButtonText: L.generalReadmore(),
						didTapCallToAction: { [weak coordinatorDelegate] in
							coordinatorDelegate?.userWishesMoreInfoAboutUpgradingEUVaccinations()
						}
					)
				]
			} else if state.shouldShowEUVaccinationUpdateCompletedBanner {
				viewControllerCards += [
					.migratingYourInternationalVaccinationCertificateDidComplete(
						message: L.holderDashboardCardEuvaccinationswereupgradedMessage(),
						callToActionButtonText: L.generalReadmore(),
						didTapCallToAction: { [weak coordinatorDelegate] in
							coordinatorDelegate?.presentInformationPage(
								title: L.holderEuvaccinationswereupgradedTitle(),
								body: L.holderEuvaccinationswereupgradedMessage(),
								hideBodyForScreenCapture: false,
								openURLsInApp: true)
						},
						didTapClose: {
							userSettings.didDismissEUVaccinationMigrationSuccessBanner = true
						}
					)
				]
			}
		}

		viewControllerCards += regionFilteredExpiredCards
			.compactMap { expiredQR -> HolderDashboardViewController.Card? in
				let message = String.holderDashboardQRExpired(
					localizedRegion: expiredQR.region.localizedAdjective,
					localizedOriginType: expiredQR.type.localizedProof
				)

				return .expiredQR(message: message, didTapClose: {
					didTapCloseExpiredQR(expiredQR)
				})
		}

		if allQRCards.isEmpty && regionFilteredExpiredCards.isEmpty {
			viewControllerCards += [
				{
					switch validityRegion {
						case .domestic:
							return HolderDashboardViewController.Card.emptyState(
								image: I.dashboard.domestic(),
								title: L.holderDashboardEmptyDomesticTitle(),
								message: L.holderDashboardEmptyDomesticMessage(),
								buttonTitle: nil
							)
						case .europeanUnion:
							return HolderDashboardViewController.Card.emptyState(
								image: I.dashboard.international(),
								title: L.holderDashboardEmptyInternationalTitle(),
								message: L.holderDashboardEmptyInternationalMessage(),
								buttonTitle: L.holderDashboardEmptyInternationalButton()
							)
					}
				}()
			]
		}

		// for each origin which is in the other region but not in this one, add a new MessageCard to explain.
		// e.g. "Je vaccinatie is niet geldig in Europa. Je hebt alleen een Nederlandse QR-code."
		viewControllerCards += localizedOriginsValidOnlyInOtherRegionsMessages(state: state, thisRegion: validityRegion, now: now)
			.sorted(by: { $0.originType.customSortIndex < $1.originType.customSortIndex })
			.map { originType, message in
				return .originNotValidInThisRegion(
					message: message,
					callToActionButtonText: L.generalReadmore()) {
						coordinatorDelegate.userWishesMoreInfoAboutUnavailableQR(
							originType: originType,
							currentRegion: validityRegion,
							availableRegion: validityRegion.opposite)
					}
			}

		// Map a `QRCard` to a `VC.Card`:
		viewControllerCards += regionFilteredMyQRCards
			.flatMap { (qrcardDataItem: HolderDashboardViewModel.QRCard) -> [HolderDashboardViewController.Card] in
				qrcardDataItem.toViewControllerCards(
					state: state,
					coordinatorDelegate: coordinatorDelegate,
					strippenRefresher: strippenRefresher,
					remoteConfigManager: remoteConfigManager,
					now: now
				)
			}

		return viewControllerCards
	}
}

// MARK: HolderDashboardViewModel.QRCard extension

extension HolderDashboardViewModel.QRCard {

	fileprivate func toViewControllerCards(
		state: HolderDashboardViewModel.State,
		coordinatorDelegate: HolderCoordinatorDelegate,
		strippenRefresher: DashboardStrippenRefreshing,
		remoteConfigManager: RemoteConfigManaging,
		now: Date
	) -> [HolderDashboardViewController.Card] {

		switch self.region {
			case .netherlands:

				var cards = [HolderDashboardViewController.Card.domesticQR(
					title: L.holderDashboardQrTitle(),
					validityTexts: validityTextsGenerator(greencards: greencards, remoteConfigManager: remoteConfigManager),
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: { [weak coordinatorDelegate] in
						coordinatorDelegate?.userWishesToViewQRs(greenCardObjectIDs: greencards.compactMap { $0.id })
					},
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: { now in
						let mostDistantFutureExpiryDate = origins.reduce(now) { result, nextOrigin in
							nextOrigin.expirationTime > result ? nextOrigin.expirationTime : result
						}

						// if all origins will be expired in next six hours:
						let sixHours: TimeInterval = 6 * 60 * 60
						guard mostDistantFutureExpiryDate > now && mostDistantFutureExpiryDate < now.addingTimeInterval(sixHours)
						else { return nil }
 
						let fiveMinutes: TimeInterval = 5 * 60
						let formatter: DateComponentsFormatter = {
							if mostDistantFutureExpiryDate < now.addingTimeInterval(fiveMinutes) {
								// e.g. "4 minuten en 15 seconden"
								return HolderDashboardViewModel.hmsRelativeFormatter
							} else {
								// e.g. "5 uur 59 min"
								return HolderDashboardViewModel.hmRelativeFormatter
							}
						}()

						guard let relativeDateString = formatter.string(from: now, to: mostDistantFutureExpiryDate)
						else { return nil }

						return (L.holderDashboardQrExpiryDatePrefixExpiresIn() + " " + relativeDateString).trimmingCharacters(in: .whitespacesAndNewlines)
					}
				)]

				if let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard {
					cards += [HolderDashboardViewController.Card.errorMessage(message: error, didTapTryAgain: strippenRefresher.load)]
				}

				return cards

			case .europeanUnion:
				var cards = [HolderDashboardViewController.Card.europeanUnionQR(
					title: (self.origins.first?.type.localizedProof ?? L.holderDashboardQrTitle()).capitalized,
					stackSize: {
						let minStackSize = 1
						let maxStackSize = 3
						return min(maxStackSize, max(minStackSize, greencards.count))
					}(),
					validityTexts: validityTextsGenerator(greencards: greencards, remoteConfigManager: remoteConfigManager),
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: { [weak coordinatorDelegate] in
						coordinatorDelegate?.userWishesToViewQRs(greenCardObjectIDs: greencards.compactMap { $0.id })
					},
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: nil
				)]

				if let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard {
					cards += [HolderDashboardViewController.Card.errorMessage(message: error, didTapTryAgain: strippenRefresher.load)]
				}

				return cards
		}
	}

	// Returns a closure that, given a Date, will return the groups of text ("ValidityText") that should be shown per-origin on the QR Card.
	private func validityTextsGenerator(greencards: [HolderDashboardViewModel.QRCard.GreenCard], remoteConfigManager: RemoteConfigManaging) -> (Date) -> [HolderDashboardViewController.ValidityText] {
		return { now in
			return greencards
				// Make a list of all origins paired with their greencard
				.flatMap { greencard in
					greencard.origins.map { (greencard, $0) }
				}
				// Sort by the customSortIndex, and then by origin eventDate (desc)
				.sorted { lhs, rhs in
					if lhs.1.customSortIndex == rhs.1.customSortIndex {
						return lhs.1.eventDate > rhs.1.eventDate
					}
					return lhs.1.customSortIndex < rhs.1.customSortIndex
				}
				// Map to the ValidityText
				.map { greencard, origin -> HolderDashboardViewController.ValidityText in
					let validityType = QRCard.ValidityType(expiration: origin.expirationTime, validFrom: origin.validFromDate, now: now)
					let first = validityType.text(qrCard: self, greencard: greencard, origin: origin, now: now, remoteConfigManager: remoteConfigManager)
					return first
				}
		}
	}
}

// MARK: - NSNotification

extension HolderDashboardViewModel {

	fileprivate func setupNotificationListeners() {

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(receiveDidBecomeActiveNotification),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(userDefaultsDidChange),
			name: Foundation.UserDefaults.didChangeNotification,
			object: nil
		)
	}

	@objc func receiveDidBecomeActiveNotification() {
		datasource.reload()
	}

	@objc func userDefaultsDidChange() {
		DispatchQueue.main.async {

			// If it's already presented and dismiss is not true, then continue to show it:
			self.state.shouldShowEUVaccinationUpdateCompletedBanner
				= self.state.shouldShowEUVaccinationUpdateCompletedBanner && !self.userSettings.didDismissEUVaccinationMigrationSuccessBanner
		}
	}
}

// MARK: - Free Functions

private func localizedOriginsValidOnlyInOtherRegionsMessages(state: HolderDashboardViewModel.State, thisRegion: QRCodeValidityRegion, now: Date) -> [(originType: QRCodeOriginType, message: String)] {

	// Calculate origins which exist in the other region but are not in this region:
	let originTypesForCurrentRegion = Set(state.qrCards
											.filter { $0.isOfRegion(region: thisRegion) }
											.flatMap { $0.origins }
											.filter {
												$0.isNotYetExpired(now: now)
											}
											.compactMap { $0.type }
	)

	let originTypesForOtherRegion = Set(state.qrCards
											.filter { !$0.isOfRegion(region: thisRegion) }
											.flatMap { $0.origins }
											.filter {
												$0.isNotYetExpired(now: now)
											}
											.compactMap { $0.type }
	)

	let originTypesOnlyInOtherRegion = originTypesForOtherRegion
		.subtracting(originTypesForCurrentRegion)

	// Map it to user messages:
	let userMessages = originTypesOnlyInOtherRegion.map { (originType: QRCodeOriginType) -> (originType: QRCodeOriginType, message: String) in
		switch thisRegion {
			case .domestic:
				return (originType, L.holderDashboardOriginNotValidInNetherlandsButIsInEU(originType.localizedProof))
			case .europeanUnion:
				return (originType, L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(originType.localizedProof))
		}
	}

	return userMessages
}

extension AlertContent {

	fileprivate static func strippenExpiredWithNoInternet(strippenRefresher: DashboardStrippenRefreshing) -> AlertContent {
		AlertContent(
			title: L.holderDashboardStrippenExpiredNointernetAlertTitle(),
			subTitle: L.holderDashboardStrippenExpiredNointernetAlertMessage(),
			cancelAction: { _ in
				strippenRefresher.userDismissedALoadingError()
			},
			cancelTitle: L.generalClose(),
			okAction: { _ in
				strippenRefresher.load()
			},
			okTitle: L.generalRetry()
		)
	}

	fileprivate static func strippenExpiringWithNoInternet(expiryDate: Date, strippenRefresher: DashboardStrippenRefreshing, now: Date) -> AlertContent {

		let localizedTimeRemainingUntilExpiry: String = {
			if expiryDate > (now.addingTimeInterval(60 * 60 * 24)) { // > 1 day in future
				return HolderDashboardViewModel.daysRelativeFormatter.string(from: now, to: expiryDate) ?? "-"
			} else {
				return HolderDashboardViewModel.hmRelativeFormatter.string(from: now, to: expiryDate) ?? "-"
			}
		}()

		return AlertContent(
			title: L.holderDashboardStrippenExpiringNointernetAlertTitle(),
			subTitle: L.holderDashboardStrippenExpiringNointernetAlertMessage(localizedTimeRemainingUntilExpiry),
			cancelAction: { _ in
				strippenRefresher.userDismissedALoadingError()
			},
			cancelTitle: L.generalClose(),
			okAction: { _ in
				strippenRefresher.load()
			},
			okTitle: L.generalRetry()
		)
	}
}
