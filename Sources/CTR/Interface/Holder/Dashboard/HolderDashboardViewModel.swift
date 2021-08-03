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
	typealias Datasource = HolderDashboardDatasource

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

	// MARK: - Private types

	/// Wrapper around some state variables
	/// that allows us to use a `didSet{}` to
	/// get a callback if any of them are mutated.
	fileprivate struct State {
		var myQRCards: [MyQRCard]
		var expiredGreenCards: [ExpiredQR]
		var showCreateCard: Bool
		var isRefreshingStrippen: Bool

		// Related to strippen refreshing.
		// When there's an error with the refreshing process,
		// we show an error message on each QR card that lacks credentials.
		// This does not discriminate between domestic/EU.
		var errorForQRCardsMissingCredentials: String?
	}

	// MARK: - Private properties

	private weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?
	private weak var cryptoManager: CryptoManaging?
	private weak var proofManager: ProofManaging?
	private var configuration: ConfigurationGeneralProtocol
	private var notificationCenter: NotificationCenterProtocol = NotificationCenter.default
	private var userSettings: UserSettingsProtocol

	var dashboardRegionToggleValue: QRCodeValidityRegion {
		get {
			userSettings.dashboardRegionToggleValue
		}
		set {
			DispatchQueue.global().async {
				self.userSettings.dashboardRegionToggleValue = newValue
			}
		}
	}

	private var state: State {
		didSet {
			guard let coordinator = coordinator else { return }

			(domesticCards, internationalCards) = HolderDashboardViewModel.assembleCards(
				state: state,
				didTapCloseExpiredQR: { expiredQR in
					self.state.expiredGreenCards.removeAll(where: { $0.id == expiredQR.id })
				},
				coordinatorDelegate: coordinator,
				strippenRefresher: strippenRefresher,
				now: self.now()
			)
			
			hasAddCertificateMode = state.myQRCards.isEmpty
		}
	}

	private let datasource: HolderDashboardDatasourceProtocol
	private let strippenRefresher: DashboardStrippenRefreshing

	private let now: () -> Date

	// MARK: - Initializer
	init(
		coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol),
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol,
		datasource: HolderDashboardDatasourceProtocol,
		strippenRefresher: DashboardStrippenRefreshing,
		userSettings: UserSettingsProtocol,
		now: @escaping () -> Date
	) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.configuration = configuration
		self.datasource = datasource
		self.strippenRefresher = strippenRefresher
		self.userSettings = userSettings
		self.now = now

		self.state = State(
			myQRCards: [],
			expiredGreenCards: [],
			showCreateCard: true,
			isRefreshingStrippen: false
		)

		self.datasource.didUpdate = { [weak self] (qrCardDataItems: [MyQRCard], expiredGreenCards: [ExpiredQR]) in
			DispatchQueue.main.async {
				self?.state.myQRCards = qrCardDataItems
				self?.state.expiredGreenCards += expiredGreenCards
			}
		}

		// Map RefresherState to State:
		self.strippenRefresher.didUpdate = { [weak self] oldValue, newValue in
			self?.strippenRefresherDidUpdate(oldRefresherState: oldValue, refresherState: newValue)
		}
		strippenRefresher.load()

		self.setupNotificationListeners()
		
//		#if DEBUG
//		DispatchQueue.main.asyncAfter(deadline: .now()) {
//			self.injectSampleData(dataStoreManager: Services.dataStoreManager)
//			self.datasource.reload()
//		}
//		#endif
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func viewWillAppear() {
		datasource.reload()
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

			case (.failed, .expired, true):
				logDebug("StrippenRefresh: Need refreshing now, but server error. Showing in UI.")

				state.errorForQRCardsMissingCredentials = refresherState.errorOccurenceCount > 1
					? L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk(AppAction.tryAgain)
					: L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)

			case (.failed(error: let error), .expired, false):
				logDebug("StrippenRefresh: Need refreshing now, but server error. Presenting alert.")
				currentlyPresentedAlert = AlertContent.strippenExpiringServerError(strippenRefresher: strippenRefresher, error: error)

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
		now: Date
	) -> (domestic: [HolderDashboardViewController.Card], international: [HolderDashboardViewController.Card]) {

		let domesticCards = assembleCards(
			forValidityRegion: .domestic,
			state: state,
			didTapCloseExpiredQR: didTapCloseExpiredQR,
			coordinatorDelegate: coordinatorDelegate,
			strippenRefresher: strippenRefresher,
			now: now)

		let internationalCards = assembleCards(
			forValidityRegion: .europeanUnion,
			state: state,
			didTapCloseExpiredQR: didTapCloseExpiredQR,
			coordinatorDelegate: coordinatorDelegate,
			strippenRefresher: strippenRefresher,
			now: now)

		return (domestic: domesticCards, international: internationalCards)
	}

	private static func assembleCards(
		forValidityRegion validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		didTapCloseExpiredQR: @escaping (ExpiredQR) -> Void,
		coordinatorDelegate: HolderCoordinatorDelegate,
		strippenRefresher: DashboardStrippenRefreshing,
		now: Date
	) -> [HolderDashboardViewController.Card] {

		let allQRCards = state.myQRCards
		let regionFilteredMyQRCards = state.myQRCards.filter { (myQRCard: MyQRCard) in
			switch (myQRCard, validityRegion) {
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
				.headerMessage(message: {
					switch validityRegion {
						case .domestic: return L.holderDashboardIntroDomestic()
						case .europeanUnion: return L.holderDashboardIntroInternational()
					}
				}())
			]
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
								image: I.empty_Dashboard_Domestic(),
								title: L.holderDashboardEmptyDomesticTitle(),
								message: L.holderDashboardEmptyDomesticMessage()
							)
						case .europeanUnion:
							return HolderDashboardViewController.Card.emptyState(
								image: I.empty_Dashboard_International(),
								title: L.holderDashboardEmptyInternationalTitle(),
								message: L.holderDashboardEmptyInternationalMessage()
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
				return .originNotValidInThisRegion(message: message) {
					coordinatorDelegate.userWishesMoreInfoAboutUnavailableQR(
						originType: originType,
						currentRegion: validityRegion,
						availableRegion: validityRegion.opposite)
				}
			}

		// Map a `MyQRCard` to a `VC.Card`:
		viewControllerCards += regionFilteredMyQRCards
			.flatMap { (qrcardDataItem: HolderDashboardViewModel.MyQRCard) -> [HolderDashboardViewController.Card] in
				qrcardDataItem.toViewControllerCards(
					state: state,
					coordinatorDelegate: coordinatorDelegate,
					strippenRefresher: strippenRefresher,
					now: now
				)
			}

		return viewControllerCards
	}
}

// MARK: HolderDashboardViewModel.MyQRCard extension

extension HolderDashboardViewModel.MyQRCard {

	fileprivate func toViewControllerCards(state: HolderDashboardViewModel.State, coordinatorDelegate: HolderCoordinatorDelegate, strippenRefresher: DashboardStrippenRefreshing, now: Date) -> [HolderDashboardViewController.Card] {

		switch self {
			case let .netherlands(greenCardObjectID, origins, shouldShowErrorBeneathCard, evaluateEnabledState):

				let rows = origins.map { origin in
					HolderDashboardViewController.Card.QRCardRow(
						typeText: origin.type.localizedProof.capitalizingFirstLetter(),
						validityTextEvaluator: { now in
							localizedDateExplanation(forOrigin: origin, forNow: now)
						}
					)
				}

				var cards = [HolderDashboardViewController.Card.domesticQR(
					rows: rows,
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: { coordinatorDelegate.userWishesToViewQR(greenCardObjectID: greenCardObjectID) },
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: { now in
						let mostDistantFutureExpiryDate = origins.reduce(now) { result, nextOrigin in
							nextOrigin.expirationTime > result ? nextOrigin.expirationTime : result
						}

						// if all origins will be expired in next six hours:
						let sixHours: TimeInterval = 6 * 60 * 60
						guard mostDistantFutureExpiryDate > now && mostDistantFutureExpiryDate < Date(timeIntervalSinceNow: sixHours)
						else { return nil }

						// e.g. "5 uur 59 min"
						guard let relativeDateString = HolderDashboardViewModel.hmsRelativeFormatter.string(from: now, to: mostDistantFutureExpiryDate)
						else { return nil }

						return (L.holderDashboardQrExpiryDatePrefixExpiresIn() + " " + relativeDateString).trimmingCharacters(in: .whitespacesAndNewlines)
					}
				)]

				if let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard {
					cards += [.errorMessage(message: error, didTapTryAgain: strippenRefresher.load)]
				}

				return cards

			case let .europeanUnion(greenCardObjectID, origins, shouldShowErrorBeneathCard, evaluateEnabledState):
				let rows = origins.map { origin in
					HolderDashboardViewController.Card.QRCardRow(
						typeText: origin.type.localizedEvent.capitalizingFirstLetter(),
						validityTextEvaluator: { now in
							localizedDateExplanation(forOrigin: origin, forNow: now)
						}
					)
				}

				var cards = [HolderDashboardViewController.Card.europeanUnionQR(
					rows: rows,
					isLoading: state.isRefreshingStrippen,
					didTapViewQR: { coordinatorDelegate.userWishesToViewQR(greenCardObjectID: greenCardObjectID) },
					buttonEnabledEvaluator: evaluateEnabledState,
					expiryCountdownEvaluator: nil
				)]

				if let error = state.errorForQRCardsMissingCredentials, shouldShowErrorBeneathCard {
					cards += [.errorMessage(message: error, didTapTryAgain: strippenRefresher.load)]
				}

				return cards
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
	}

	@objc func receiveDidBecomeActiveNotification() {
		datasource.reload()
	}
}

// MARK: - Free Functions

private func localizedOriginsValidOnlyInOtherRegionsMessages(state: HolderDashboardViewModel.State, thisRegion: QRCodeValidityRegion, now: Date) -> [(originType: QRCodeOriginType, message: String)] {

	// Calculate origins which exist in the other region but are not in this region:
	let originTypesForCurrentRegion = Set(state.myQRCards
											.filter { $0.isOfRegion(region: thisRegion) }
											.flatMap { $0.origins }
											.filter {
												$0.isNotYetExpired(now: now)
											}
											.compactMap { $0.type }
	)

	let originTypesForOtherRegion = Set(state.myQRCards
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

	fileprivate static func strippenExpiringServerError(strippenRefresher: DashboardStrippenRefreshing, error: DashboardStrippenRefresher.Error) -> AlertContent {
		AlertContent(
			title: L.holderDashboardStrippenExpiredServererrorAlertTitle(),
			subTitle: L.holderDashboardStrippenExpiredServererrorAlertMessage(error.localizedDescription),
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
