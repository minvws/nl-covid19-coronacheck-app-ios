/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CoreData
import Reachability

/// All the actions that the user can trigger by interacting with the Dashboard cards
protocol HolderDashboardCardUserActionHandling: AnyObject {
	func didTapAddCertificate()
	func didTapCloseExpiredQR(expiredQR: HolderDashboardViewModel.ExpiredQR)
	func didTapCompleteYourVaccinationAssessmentMoreInfo()
	func didTapConfigAlmostOutOfDateCTA()
	func didTapDeviceHasClockDeviationMoreInfo()
	func didTapExpiredDomesticVaccinationQRMoreInfo()
	func didTapOriginNotValidInThisRegionMoreInfo(originType: QRCodeOriginType, validityRegion: QRCodeValidityRegion)
	func didTapRecommendedUpdate()
	func didTapRetryLoadQRCards()
	func didTapShowQR(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?)
	func didTapVaccinationAssessmentInvalidOutsideNLMoreInfo()
	func didTapDisclosurePolicyInformation1GBannerMoreInformation()
	func didTapDisclosurePolicyInformation3GBannerMoreInformation()
	func didTapDisclosurePolicyInformation1GWith3GBannerMoreInformation()
	func didTapDisclosurePolicyInformation0GBannerMoreInformation()
	func didTapDisclosurePolicyInformation1GBannerClose()
	func didTapDisclosurePolicyInformation3GBannerClose()
	func didTapDisclosurePolicyInformation1GWith3GBannerClose()
	func didTapDisclosurePolicyInformation0GBannerClose()
}

// swiftlint:disable:next type_body_length
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
	
	@Bindable private(set) var shouldShowAddCertificateFooter: Bool = false

	@Bindable private(set) var currentlyPresentedAlert: AlertContent?
	
	@Bindable private(set) var selectedTab: DashboardTab = .domestic

	@Bindable private(set) var shouldShowTabBar: Bool = false
	
	@Bindable private(set) var shouldShowOnlyInternationalPane: Bool = false

	// MARK: - Private types

	/// Wrapper around some state variables
	/// that allows us to use a `didSet{}` to
	/// get a callback if any of them are mutated.
	struct State: Equatable {
		var qrCards: [QRCard]
		var expiredGreenCards: [ExpiredQR]
		var isRefreshingStrippen: Bool

		// Related to strippen refreshing.
		// When there's an error with the refreshing process,
		// we show an error message on each QR card that lacks credentials.
		// This does not discriminate between domestic/EU.
		var errorForQRCardsMissingCredentials: String?

		var deviceHasClockDeviation: Bool = false

		var shouldShowConfigurationIsAlmostOutOfDateBanner: Bool = false
	
		var shouldShowRecommendedUpdateBanner: Bool = false
		
		var shouldShowCompleteYourVaccinationAssessmentBanner: Bool = false
		
		var shouldShowAddCertificateFooter: Bool {
			(qrCards.isEmpty || (shouldShowOnlyInternationalPane && !dashboardHasInternationalQRCards())) && !shouldShowCompleteYourVaccinationAssessmentBanner
		}
		
		var shouldShowTabBar: Bool {
			activeDisclosurePolicyMode != .zeroG
		}
		
		var shouldShowOnlyInternationalPane: Bool {
			activeDisclosurePolicyMode == .zeroG
		}
		
		var shouldShowRecommendCoronaMelderCard: Bool {
			Current.featureFlagManager.shouldShowCoronaMelderRecommendation()
		}
		
		var shouldShow3GOnlyDisclosurePolicyBecameActiveBanner: Bool = false
		var shouldShow1GOnlyDisclosurePolicyBecameActiveBanner: Bool = false
		var shouldShow3GWith1GDisclosurePolicyBecameActiveBanner: Bool = false
		var shouldShow0GDisclosurePolicyBecameActiveBanner: Bool = false
		var activeDisclosurePolicyMode: DisclosurePolicyMode
		
		// Has QR Cards or expired QR Cards
		func dashboardHasQRCards(for validityRegion: QRCodeValidityRegion) -> Bool {
			!qrCards.isEmpty || !regionFilteredExpiredCards(validityRegion: validityRegion).isEmpty
		}
		
		func dashboardHasInternationalQRCards() -> Bool {
			!qrCards.filter({ $0.isOfRegion(region: .europeanUnion) }).isEmpty || !regionFilteredExpiredCards(validityRegion: .europeanUnion).isEmpty
		}
		
		func dashboardHasEmptyState(for validityRegion: QRCodeValidityRegion) -> Bool {
			
			if validityRegion == .europeanUnion && activeDisclosurePolicyMode == .zeroG {
				return !dashboardHasInternationalQRCards()
			} else {
				return !dashboardHasQRCards(for: validityRegion)
			}
		}
		
		func shouldShowCompleteYourVaccinationAssessmentBanner(for validityRegion: QRCodeValidityRegion) -> Bool {
			guard validityRegion == .domestic else {
				return false
			}
			return shouldShowCompleteYourVaccinationAssessmentBanner
		}
		
		func shouldShowVaccinationAssessmentInvalidOutsideNLBanner(for validityRegion: QRCodeValidityRegion) -> Bool {
			guard validityRegion == .europeanUnion else {
				return false
			}
			return shouldShowCompleteYourVaccinationAssessmentBanner
		}
		
		func regionFilteredQRCards(validityRegion: QRCodeValidityRegion) -> [QRCard] {
			qrCards.filter { (qrCard: QRCard) in
				switch (qrCard.region, validityRegion) {
					case (.netherlands, .domestic): return true
					case (.europeanUnion, .europeanUnion): return true
					default: return false
				}
			}
		}
		
		func regionFilteredExpiredCards(validityRegion: QRCodeValidityRegion) -> [HolderDashboardViewModel.ExpiredQR] {
			expiredGreenCards.filter { $0.region == validityRegion }
		}
 	}

	// MARK: - Private properties

	var dashboardRegionToggleValue: QRCodeValidityRegion {
		didSet {
			DispatchQueue.global().async {
				Current.userSettings.dashboardRegionToggleValue = self.dashboardRegionToggleValue
			}
		}
	}

	private var state: State {
		didSet {
			didUpdate(oldState: oldValue, newState: state)
		}
	}
	
	func selectTab(newTab: DashboardTab) {
		guard state.activeDisclosurePolicyMode != .zeroG else { return }
		
		// Handle new value:
		dashboardRegionToggleValue = newTab.isDomestic ? .domestic : .europeanUnion
		selectedTab = newTab
	}

	private let datasource: HolderDashboardQRCardDatasourceProtocol

	// Observation tokens:
	private var remoteConfigUpdateObserverToken: Observatory.ObserverToken?
	private var clockDeviationObserverToken: Observatory.ObserverToken?
	private var remoteConfigUpdatesConfigurationWarningToken: Observatory.ObserverToken?
	private var remoteConfigManagerUpdateObserverToken: Observatory.ObserverToken?
	private var disclosurePolicyUpdateObserverToken: Observatory.ObserverToken?
	private var configurationAlmostOutOfDateObserverToken: Observatory.ObserverToken?
	
	// Dependencies:
	private weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?
	private let notificationCenter: NotificationCenterProtocol = NotificationCenter.default
	private let strippenRefresher: DashboardStrippenRefreshing
	private var configurationNotificationManager: ConfigurationNotificationManagerProtocol
	private var vaccinationAssessmentNotificationManager: VaccinationAssessmentNotificationManagerProtocol
	private var versionSupplier: AppVersionSupplierProtocol?

	// MARK: - Initializer
	init(
		coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol),
		datasource: HolderDashboardQRCardDatasourceProtocol,
		strippenRefresher: DashboardStrippenRefreshing,
		configurationNotificationManager: ConfigurationNotificationManagerProtocol,
		vaccinationAssessmentNotificationManager: VaccinationAssessmentNotificationManagerProtocol,
		versionSupplier: AppVersionSupplierProtocol?
	) {

		self.coordinator = coordinator
		self.datasource = datasource
		self.strippenRefresher = strippenRefresher
		self.dashboardRegionToggleValue = Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() ? .europeanUnion : Current.userSettings.dashboardRegionToggleValue
		self.configurationNotificationManager = configurationNotificationManager
		self.vaccinationAssessmentNotificationManager = vaccinationAssessmentNotificationManager
		self.versionSupplier = versionSupplier

		self.state = State(
			qrCards: [],
			expiredGreenCards: [],
			isRefreshingStrippen: false,
			deviceHasClockDeviation: Current.clockDeviationManager.hasSignificantDeviation ?? false,
			shouldShowConfigurationIsAlmostOutOfDateBanner: configurationNotificationManager.shouldShowAlmostOutOfDateBanner,
			shouldShowCompleteYourVaccinationAssessmentBanner: vaccinationAssessmentNotificationManager.hasVaccinationAssessmentEventButNoOrigin(now: Current.now()),
			activeDisclosurePolicyMode: {
				if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
					return .combined1gAnd3g
				} else if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
					return .exclusive1G
				} else if Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() {
					return .zeroG
				} else {
					return .exclusive3G
				}
			}()
		)

		setupDatasource()
		setupStrippenRefresher()
		setupNotificationListeners()
		setupConfigNotificationManager()
		setupRecommendedVersion()
		recalculateActiveDisclosurePolicyMode()
		recalculateDisclosureBannerState()
		setupObservers()

		didUpdate(oldState: nil, newState: state)
	}
	
	private func setupObservers() {
	
		// Observers
		clockDeviationObserverToken = Current.clockDeviationManager.observatory.append { [weak self] hasClockDeviation in
			self?.state.deviceHasClockDeviation = hasClockDeviation
			self?.datasource.reload() // this could cause some QR code states to change, so reload.
		}
		
		// If the config ever changes, reload dependencies:
		remoteConfigUpdateObserverToken = Current.remoteConfigManager.observatoryForUpdates.append { [weak self] _, _, _ in
			self?.strippenRefresher.load()
		}

		disclosurePolicyUpdateObserverToken = Current.disclosurePolicyManager.observatory.append { [weak self] in
			// Disclosure Policy has been updated
			// - Reset any dismissed banners
			Current.userSettings.lastDismissedDisclosurePolicy = []
			// - Update the active disclosure policy
			self?.recalculateActiveDisclosurePolicyMode()
			// - Update the disclosure policy information banners
			self?.recalculateDisclosureBannerState()
		}
		
		configurationAlmostOutOfDateObserverToken = configurationNotificationManager.almostOutOfDateObservatory.append { [weak self] configIsAlmostOutOfDate in
			guard let self = self else { return }
			self.state.shouldShowConfigurationIsAlmostOutOfDateBanner = configIsAlmostOutOfDate
		}
	}

	deinit {
		notificationCenter.removeObserver(self)
		clockDeviationObserverToken.map(Current.clockDeviationManager.observatory.remove)
		disclosurePolicyUpdateObserverToken.map(Current.disclosurePolicyManager.observatory.remove)
		remoteConfigUpdateObserverToken.map(Current.remoteConfigManager.observatoryForUpdates.remove)
		remoteConfigUpdatesConfigurationWarningToken.map(Current.remoteConfigManager.observatoryForReloads.remove)
	}

	// MARK: - Setup

	private func setupDatasource() {
		datasource.didUpdate = { [weak self] (qrCardDataItems: [QRCard], expiredGreenCards: [ExpiredQR]) in
			guard let self = self else { return }
			
			DispatchQueue.main.async {
				var state = self.state
				state.qrCards = qrCardDataItems
				state.expiredGreenCards += expiredGreenCards
				state.shouldShowCompleteYourVaccinationAssessmentBanner = self.vaccinationAssessmentNotificationManager.hasVaccinationAssessmentEventButNoOrigin(now: Current.now())
				self.state = state
			}
		}
	}

	private func setupStrippenRefresher() {
		// Map RefresherState to State:
		strippenRefresher.didUpdate = { [weak self] oldValue, newValue in
			self?.strippenRefresherDidUpdate(oldRefresherState: oldValue, refresherState: newValue)
		}
		strippenRefresher.load()
	}

	func setupConfigNotificationManager() {

		remoteConfigUpdatesConfigurationWarningToken = Current.remoteConfigManager.observatoryForReloads.append { [weak self] result in
			guard let self = self, case .success = result else { return }
			self.setupRecommendedVersion()
		}
	}

	// MARK: - View Lifecycle callbacks:

	func viewWillAppear() {
		datasource.reload()
		recalculateActiveDisclosurePolicyMode()
	}

	// MARK: - Receive Updates

	/// Don't call directly, apart from within `init` and from within `var state: State { didSet { ... } }`
	fileprivate func didUpdate(oldState: State?, newState: State) {
		guard state != oldState // save recomputation effort if `==`
		else { return }
		
		if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
			// 1G-only
			domesticCards = HolderDashboardViewModel.assemble1gOnlyCards(
				forValidityRegion: .domestic,
				state: state,
				actionHandler: self,
				remoteConfigManager: Current.remoteConfigManager,
				now: Current.now()
			)
		} else if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
			// 3G + 1G
			domesticCards = HolderDashboardViewModel.assemble3gWith1GCards(
				forValidityRegion: .domestic,
				state: state,
				actionHandler: self,
				remoteConfigManager: Current.remoteConfigManager,
				now: Current.now()
			)
		} else if state.shouldShowOnlyInternationalPane {
			// 0G
			domesticCards = []
		} else {
			// 3G-only fallback
			domesticCards = HolderDashboardViewModel.assemble3gOnlyCards(
				forValidityRegion: .domestic,
				state: state,
				actionHandler: self,
				remoteConfigManager: Current.remoteConfigManager,
				now: Current.now()
			)
		}

		internationalCards = HolderDashboardViewModel.assembleInternationalCards(
			forValidityRegion: .europeanUnion,
			state: state,
			actionHandler: self,
			remoteConfigManager: Current.remoteConfigManager,
			now: Current.now()
		)

		shouldShowAddCertificateFooter = state.shouldShowAddCertificateFooter
		shouldShowTabBar = state.shouldShowTabBar
		shouldShowOnlyInternationalPane = state.shouldShowOnlyInternationalPane
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
				currentlyPresentedAlert = AlertContent.strippenExpiringWithNoInternet(expiryDate: expiryDate, strippenRefresher: strippenRefresher, now: Current.now())

			// ❤️‍🩹 NETWORK ERRORS: Refresher has entered a failed state (i.e. Server Error)

			case (.failed, .expired, _):
				logDebug("StrippenRefresh: Need refreshing now, but server error. Showing in UI.")

				state.errorForQRCardsMissingCredentials = refresherState.errorOccurenceCount > 1
					? L.holderDashboardStrippenExpiredErrorfooterServerHelpdesk()
					: L.holderDashboardStrippenExpiredErrorfooterServerTryagain(AppAction.tryAgain)

			case (.failed, .expiring, _):
				// In this case we just swallow the server errors.
				// We do handle "no internet" though - see above.
				logDebug("StrippenRefresh: Swallowing server error because can refresh later.")

			case (.serverResponseHasNoChanges, _, _) :
				// This is a special case, and is caused by the user putting their system time
				// so far into the future that it forces a strippen refresh, .. however the server time
				// remains unchanged, so what it sends back does not resolve the `.expiring` or `.expired`
				// state which the StrippenRefresher is currently in.
				logDebug("StrippenRefresh: .serverResponseHasNoChanges. Stopping.")
				
			case (.completed, _, _):
				// The strippen were successfully renewed.
				break
			
			case (.loading, _, _), (.idle, _, _):
				break
		}
	}
	
	fileprivate func setupRecommendedVersion() {
		
		let recommendedVersion = Current.remoteConfigManager.storedConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
		let currentVersion = versionSupplier?.getCurrentVersion().fullVersionString() ?? "1.0.0"
		self.state.shouldShowRecommendedUpdateBanner = recommendedVersion.compare(currentVersion, options: .numeric) == .orderedDescending
	}
	
	fileprivate func recalculateDisclosureBannerState() {

		let lastDismissedDisclosurePolicy = Current.userSettings.lastDismissedDisclosurePolicy
		state.shouldShow1GOnlyDisclosurePolicyBecameActiveBanner = lastDismissedDisclosurePolicy != [DisclosurePolicy.policy1G]
		state.shouldShow3GOnlyDisclosurePolicyBecameActiveBanner = lastDismissedDisclosurePolicy != [DisclosurePolicy.policy3G]
		state.shouldShow3GWith1GDisclosurePolicyBecameActiveBanner = !(lastDismissedDisclosurePolicy.contains(DisclosurePolicy.policy1G) && lastDismissedDisclosurePolicy.contains(DisclosurePolicy.policy3G))
		
		state.shouldShow0GDisclosurePolicyBecameActiveBanner = !Current.userSettings.hasDismissedZeroGPolicy
	}
	
	fileprivate func recalculateActiveDisclosurePolicyMode() {
		
		if Current.featureFlagManager.areBothDisclosurePoliciesEnabled() {
			state.activeDisclosurePolicyMode = .combined1gAnd3g
		} else if Current.featureFlagManager.is1GExclusiveDisclosurePolicyEnabled() {
			state.activeDisclosurePolicyMode = .exclusive1G
		} else if Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() {
			state.activeDisclosurePolicyMode = .zeroG
		} else {
			state.activeDisclosurePolicyMode = .exclusive3G
		}
	}
	
	// MARK: - NSNotification
	
	fileprivate func setupNotificationListeners() {

		notificationCenter.addObserver(
			self,
			selector: #selector(receiveDidBecomeActiveNotification),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)

		notificationCenter.addObserver(
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
			self.recalculateActiveDisclosurePolicyMode()
		}
	}

	// MARK: Capture User input:

	@objc func addCertificateFooterTapped() {
		
		coordinator?.userWishesToCreateAQR()
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
	
	@objc func userTappedMenuButton() {
		
		coordinator?.userWishesToOpenTheMenu()
	}
	 
	// MARK: - Static Methods
	
	private static func assemble3gOnlyCards(
		forValidityRegion validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging,
		now: Date
	) -> [HolderDashboardViewController.Card] {
		typealias VCCard = HolderDashboardViewController.Card
		
		var cards = [VCCard]()
		cards += VCCard.makeEmptyStateDescriptionCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeHeaderMessageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeDeviceHasClockDeviationCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeConfigAlmostOutOfDateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendedUpdateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeCompleteYourVaccinationAssessmentCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeVaccinationAssessmentInvalidOutsideNLCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeExpiredQRCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeDisclosurePolicyInformation3GBanner(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeOriginNotValidInThisRegionCard(validityRegion: validityRegion, state: state, now: now, actionHandler: actionHandler)
		cards += VCCard.makeEmptyStatePlaceholderImageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeQRCards(
			validityRegion: validityRegion,
			state: state,
			localDisclosurePolicy: .policy3G,
			actionHandler: actionHandler,
			remoteConfigManager: remoteConfigManager
		)
		cards += VCCard.makeAddCertificateCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendCoronaMelderCard(validityRegion: validityRegion, state: state)
		return cards
	}
	
	private static func assemble1gOnlyCards(
		forValidityRegion validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging,
		now: Date
	) -> [HolderDashboardViewController.Card] {
		typealias VCCard = HolderDashboardViewController.Card
		
		var cards = [VCCard]()
		cards += VCCard.makeEmptyStateDescriptionCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeHeaderMessageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeDeviceHasClockDeviationCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeConfigAlmostOutOfDateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendedUpdateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeCompleteYourVaccinationAssessmentCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeVaccinationAssessmentInvalidOutsideNLCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeExpiredQRCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeDisclosurePolicyInformation1GBanner(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeOriginNotValidInThisRegionCard(validityRegion: validityRegion, state: state, now: now, actionHandler: actionHandler)
		cards += VCCard.makeEmptyStatePlaceholderImageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeQRCards(
			validityRegion: validityRegion,
			state: state,
			localDisclosurePolicy: .policy1G,
			actionHandler: actionHandler,
			remoteConfigManager: remoteConfigManager
		)
		cards += VCCard.makeQRCards(
			validityRegion: validityRegion,
			state: state,
			localDisclosurePolicy: .policy3G,
			actionHandler: actionHandler,
			remoteConfigManager: remoteConfigManager
		)
		cards += VCCard.makeAddCertificateCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendCoronaMelderCard(validityRegion: validityRegion, state: state)
		return cards
	}
	
	private static func assemble3gWith1GCards(
		forValidityRegion validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging,
		now: Date
	) -> [HolderDashboardViewController.Card] {
		typealias VCCard = HolderDashboardViewController.Card
		
		var cards = [VCCard]()
		cards += VCCard.makeEmptyStateDescriptionCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeHeaderMessageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeDeviceHasClockDeviationCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeConfigAlmostOutOfDateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendedUpdateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeCompleteYourVaccinationAssessmentCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeVaccinationAssessmentInvalidOutsideNLCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeExpiredQRCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeDisclosurePolicyInformation1GWith3GBanner(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeOriginNotValidInThisRegionCard(validityRegion: validityRegion, state: state, now: now, actionHandler: actionHandler)
		cards += VCCard.makeEmptyStatePlaceholderImageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeQRCards(
			validityRegion: validityRegion,
			state: state,
			localDisclosurePolicy: .policy3G,
			actionHandler: actionHandler,
			remoteConfigManager: remoteConfigManager
		)
		cards += VCCard.makeQRCards(
			validityRegion: validityRegion,
			state: state,
			localDisclosurePolicy: .policy1G,
			actionHandler: actionHandler,
			remoteConfigManager: remoteConfigManager
		)
		cards += VCCard.makeAddCertificateCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendCoronaMelderCard(validityRegion: validityRegion, state: state)
		return cards
	}
	
	private static func assembleInternationalCards(
		forValidityRegion validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling,
		remoteConfigManager: RemoteConfigManaging,
		now: Date
	) -> [HolderDashboardViewController.Card] {
		
		typealias VCCard = HolderDashboardViewController.Card
		
		var cards = [VCCard]()
		cards += VCCard.makeEmptyStateDescriptionCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeHeaderMessageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeDeviceHasClockDeviationCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeConfigAlmostOutOfDateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendedUpdateCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeCompleteYourVaccinationAssessmentCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeVaccinationAssessmentInvalidOutsideNLCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeExpiredQRCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeDisclosurePolicyInformation3GBanner(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		
		if state.activeDisclosurePolicyMode == .zeroG {
			cards += VCCard.makeDisclosurePolicyInformation0GBanner(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		} else {
			cards += VCCard.makeOriginNotValidInThisRegionCard(validityRegion: validityRegion, state: state, now: now, actionHandler: actionHandler)
		}
		
		cards += VCCard.makeEmptyStatePlaceholderImageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeQRCards(
			validityRegion: validityRegion,
			state: state,
			localDisclosurePolicy: .policy3G,
			actionHandler: actionHandler,
			remoteConfigManager: remoteConfigManager
		)
		cards += VCCard.makeAddCertificateCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeRecommendCoronaMelderCard(validityRegion: validityRegion, state: state)
		return cards
	}
	
}

// MARK: - HolderDashboardCardUserActionHandling

extension HolderDashboardViewModel: HolderDashboardCardUserActionHandling {
	
	func didTapConfigAlmostOutOfDateCTA() {
		guard let configFetchedTimestamp = Current.userSettings.configFetchedTimestamp,
			  let timeToLive = Current.remoteConfigManager.storedConfiguration.configTTL else { return }
		
		let configValidUntilDate = Date(timeIntervalSince1970: configFetchedTimestamp + TimeInterval(timeToLive))
		let configValidUntilDateString = DateFormatter.Format.dayMonthWithTime.string(from: configValidUntilDate)
		coordinator?.userWishesMoreInfoAboutOutdatedConfig(validUntil: configValidUntilDateString)
	}
	
	func didTapAddCertificate() {
		coordinator?.userWishesToCreateAQR()
	}
	
	func didTapCloseExpiredQR(expiredQR: ExpiredQR) {
		state.expiredGreenCards.removeAll(where: { $0.id == expiredQR.id })
	}
	
	func didTapExpiredDomesticVaccinationQRMoreInfo() {
		coordinator?.userWishesMoreInfoAboutExpiredDomesticVaccination()
	}
	
	func didTapOriginNotValidInThisRegionMoreInfo(originType: QRCodeOriginType, validityRegion: QRCodeValidityRegion) {
		switch (originType, validityRegion) {
			// special case, has it's own screen:
			case (.vaccination, .domestic):
				coordinator?.userWishesMoreInfoAboutIncompleteDutchVaccination()
				
			default:
				coordinator?.userWishesMoreInfoAboutUnavailableQR(
					originType: originType,
					currentRegion: validityRegion,
					availableRegion: validityRegion.opposite)
		}
	}
	
	func didTapDeviceHasClockDeviationMoreInfo() {
		coordinator?.userWishesMoreInfoAboutClockDeviation()
	}
	
	func didTapShowQR(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?) {
		coordinator?.userWishesToViewQRs(greenCardObjectIDs: greenCardObjectIDs, disclosurePolicy: disclosurePolicy)
	}
	
	func didTapRetryLoadQRCards() {
		strippenRefresher.load()
	}
	
	func didTapRecommendedUpdate() {
		
		guard let url = Current.remoteConfigManager.storedConfiguration.appStoreURL else {
			return
		}
		openUrl(url)
	}
	
	func didTapCompleteYourVaccinationAssessmentMoreInfo() {
		
		coordinator?.userWishesMoreInfoAboutCompletingVaccinationAssessment()
	}
	
	func didTapVaccinationAssessmentInvalidOutsideNLMoreInfo() {
		
		coordinator?.userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL()
	}
		
	func didTapExpiredVaccinationQRMoreInfo() {
		coordinator?.userWishesMoreInfoAboutExpiredDomesticVaccination()
	}
	
	func didTapDisclosurePolicyInformation1GBannerMoreInformation() {

		guard let url = URL(string: L.holder_dashboard_only1GaccessBanner_link()) else { return }
		openUrl(url)
	}
	
	func didTapDisclosurePolicyInformation3GBannerMoreInformation() {

		guard let url = URL(string: L.holder_dashboard_only3GaccessBanner_link()) else { return }
		openUrl(url)
	}
	
	func didTapDisclosurePolicyInformation1GWith3GBannerMoreInformation() {

		guard let url = URL(string: L.holder_dashboard_3Gand1GaccessBanner_link()) else { return }
		openUrl(url)
	}
	
	func didTapDisclosurePolicyInformation0GBannerMoreInformation() {
		
		guard let url = URL(string: L.holder_dashboard_noDomesticCertificatesBanner_url()) else { return }
		openUrl(url)
	}
	
	func didTapDisclosurePolicyInformation1GBannerClose() {

		Current.userSettings.lastDismissedDisclosurePolicy = [DisclosurePolicy.policy1G]
		recalculateDisclosureBannerState()
	}
	
	func didTapDisclosurePolicyInformation3GBannerClose() {

		Current.userSettings.lastDismissedDisclosurePolicy = [DisclosurePolicy.policy3G]
		recalculateDisclosureBannerState()
	}
	
	func didTapDisclosurePolicyInformation1GWith3GBannerClose() {

		Current.userSettings.lastDismissedDisclosurePolicy = [DisclosurePolicy.policy1G, DisclosurePolicy.policy3G]
		recalculateDisclosureBannerState()
	}
	
	func didTapDisclosurePolicyInformation0GBannerClose() {
		Current.userSettings.hasDismissedZeroGPolicy = true
		Current.userSettings.lastDismissedDisclosurePolicy = []
		recalculateDisclosureBannerState()
	}
}
