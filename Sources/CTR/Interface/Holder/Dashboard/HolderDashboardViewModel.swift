/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CoreData
import Reachability
import Shared
import ReusableViews
import Persistence
import Managers
import Models
import Resources

/// All the actions that the user can trigger by interacting with the Dashboard cards
protocol HolderDashboardCardUserActionHandling: AnyObject {
	func didTapAddCertificate()
	func didTapBlockedEventsDeletedMoreInfo(blockedEventItems: [RemovedEventItem])
	func didTapBlockedEventsDeletedDismiss(blockedEventItems: [RemovedEventItem])
	func didTapCloseExpiredQR(expiredQR: HolderDashboardViewModel.ExpiredQR)
	func didTapCompleteYourVaccinationAssessmentMoreInfo()
	func didTapConfigAlmostOutOfDateCTA()
	func didTapDeviceHasClockDeviationMoreInfo()
	func didTapMismatchedIdentityEventsDeletedMoreInfo(items: [RemovedEventItem])
	func didTapMismatchedIdentityEventsDeletedDismiss(items: [RemovedEventItem])
	func didTapRecommendedUpdate()
	func didTapRetryLoadQRCards()
	func didTapShowQR(greenCardObjectIDs: [NSManagedObjectID])
	func didTapVaccinationAssessmentInvalidOutsideNLMoreInfo()
	func didTapDisclosurePolicyInformation0GBannerMoreInformation()
	func didTapDisclosurePolicyInformation0GBannerClose()
	func openUrl(_ url: URL)
}

protocol HolderDashboardViewModelType: AnyObject {

	var title: Observable<String> { get }
	var internationalCards: Observable<[HolderDashboardViewController.Card]> { get }
	var primaryButtonTitle: Observable<String> { get }
	var shouldShowAddCertificateFooter: Observable<Bool> { get }
	var currentlyPresentedAlert: Observable<AlertContent?> { get }

	func selectTab(newTab: DashboardTab)
	func viewWillAppear()
	func addCertificateFooterTapped()
	func userTappedMenuButton()
	func openUrl(_ url: URL)
}

// swiftlint:disable:next type_body_length
final class HolderDashboardViewModel: HolderDashboardViewModelType {

	// MARK: - Public properties

	/// The title of the scene
	let title = Observable<String>(value: L.holderDashboardTitle())

	let internationalCards = Observable<[HolderDashboardViewController.Card]>(value: [])
	
	let primaryButtonTitle = Observable<String>(value: L.holderMenuProof())
	
	let shouldShowAddCertificateFooter = Observable<Bool>(value: false)

	let currentlyPresentedAlert = Observable<AlertContent?>(value: nil)

	// MARK: - Private types

	/// Wrapper around some state variables
	/// that allows us to use a `didSet{}` to
	/// get a callback if any of them are mutated.
	struct State: Equatable {
		enum StrippenRefresherFailMissingCredentialsError: Error { // swiftlint:disable:this type_name
			case noInternet
			case otherFailureFirstOccurence, otherFailureSubsequentOccurence
		}

		var qrCards: [QRCard]
		var expiredGreenCards: [ExpiredQR]
		var blockedEventItems: [RemovedEventItem]
		var mismatchedIdentityItems: [RemovedEventItem]
		var isRefreshingStrippen: Bool
		var lastKnownConfigHash: String?

		// Related to strippen refreshing.
		// When there's an error with the refreshing process,
		// we show an error message on each QR card that lacks credentials.
		// This does not discriminate between domestic/EU.
		var errorForQRCardsMissingCredentials: StrippenRefresherFailMissingCredentialsError?

		var deviceHasClockDeviation: Bool = false

		var shouldShowConfigurationIsAlmostOutOfDateBanner: Bool = false
	
		var shouldShowRecommendedUpdateBanner: Bool = false
		
		var shouldShowCompleteYourVaccinationAssessmentBanner: Bool = false
		
		var shouldShowAddCertificateFooter: Bool {
			(qrCards.isEmpty || (!dashboardHasInternationalQRCards())) && !shouldShowCompleteYourVaccinationAssessmentBanner
		}
		
		var shouldShow0GDisclosurePolicyBecameActiveBanner = false
		
		// Has QR Cards or expired QR Cards
		func dashboardHasQRCards(for validityRegion: QRCodeValidityRegion) -> Bool {
			!qrCards.isEmpty || !regionFilteredExpiredCards(validityRegion: validityRegion).isEmpty
		}
		
		func dashboardHasInternationalQRCards() -> Bool {
			qrCards.filter({ $0.isOfRegion(region: .europeanUnion) }).isNotEmpty || regionFilteredExpiredCards(validityRegion: .europeanUnion).isNotEmpty
		}
		
		func dashboardHasEmptyState(for validityRegion: QRCodeValidityRegion) -> Bool {
			
			return !dashboardHasInternationalQRCards()
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

	private var state: State {
		didSet {
			performUIUpdate {
				self.didUpdateState(fromOldState: oldValue)
			}
		}
	}
	
	func selectTab(newTab: DashboardTab) {
		return
	}

	private let qrcardDatasource: HolderDashboardQRCardDatasourceProtocol
	private let blockedEventsDatasource: HolderDashboardRemovedEventsDatasourceProtocol
	private let mismatchedIdentityDatasource: HolderDashboardRemovedEventsDatasourceProtocol
	
	// Observation tokens:
	private var remoteConfigUpdateObserverToken: Observatory.ObserverToken?
	private var clockDeviationObserverToken: Observatory.ObserverToken?
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
		qrcardDatasource: HolderDashboardQRCardDatasourceProtocol,
		blockedEventsDatasource: HolderDashboardRemovedEventsDatasourceProtocol,
		mismatchedIdentityDatasource: HolderDashboardRemovedEventsDatasourceProtocol,
		strippenRefresher: DashboardStrippenRefreshing,
		configurationNotificationManager: ConfigurationNotificationManagerProtocol,
		vaccinationAssessmentNotificationManager: VaccinationAssessmentNotificationManagerProtocol,
		versionSupplier: AppVersionSupplierProtocol?
	) {
		self.coordinator = coordinator
		self.qrcardDatasource = qrcardDatasource
		self.blockedEventsDatasource = blockedEventsDatasource
		self.mismatchedIdentityDatasource = mismatchedIdentityDatasource
		self.strippenRefresher = strippenRefresher
		self.configurationNotificationManager = configurationNotificationManager
		self.vaccinationAssessmentNotificationManager = vaccinationAssessmentNotificationManager
		self.versionSupplier = versionSupplier

		self.state = State(
			qrCards: [],
			expiredGreenCards: [],
			blockedEventItems: [],
			mismatchedIdentityItems: [],
			isRefreshingStrippen: false,
			deviceHasClockDeviation: Current.clockDeviationManager.hasSignificantDeviation ?? false,
			shouldShowConfigurationIsAlmostOutOfDateBanner: configurationNotificationManager.shouldShowAlmostOutOfDateBanner,
			shouldShowCompleteYourVaccinationAssessmentBanner: vaccinationAssessmentNotificationManager.hasVaccinationAssessmentEventButNoOrigin(now: Current.now())
		)

		setupQRCardDatasource()
		setupBlockedEventsDatasource()
		setupFuzzyMatchingRemovedEventsDatasource()
		setupStrippenRefresher()
		setupNotificationListeners()
		setupRecommendedVersion()
		setupObservers()
		recalculateDisclosureBannerState()

		didUpdateState(fromOldState: nil)
	}
	
	private func setupObservers() {
	
		// Observers
		clockDeviationObserverToken = Current.clockDeviationManager.observatory.append { [weak self] hasClockDeviation in
			self?.state.deviceHasClockDeviation = hasClockDeviation
			self?.qrcardDatasource.reload() // this could cause some QR code states to change, so reload.
		}
		
		// If the config ever changes, reload dependencies:
		remoteConfigUpdateObserverToken = Current.remoteConfigManager.observatoryForUpdates.append { [weak self] _, _, _, hash in
			self?.strippenRefresher.load()
			self?.setupRecommendedVersion() // Config changed, check recommended version.
			self?.state.lastKnownConfigHash = hash
		}
		
		configurationAlmostOutOfDateObserverToken = configurationNotificationManager.almostOutOfDateObservatory.append { [weak self] configIsAlmostOutOfDate in
			guard let self else { return }
			self.state.shouldShowConfigurationIsAlmostOutOfDateBanner = configIsAlmostOutOfDate
		}
	}

	deinit {
		notificationCenter.removeObserver(self)
		clockDeviationObserverToken.map(Current.clockDeviationManager.observatory.remove)
		remoteConfigUpdateObserverToken.map(Current.remoteConfigManager.observatoryForUpdates.remove)
	}

	// MARK: - Setup

	private func setupQRCardDatasource() {
		qrcardDatasource.didUpdate = { [weak self] (qrCardDataItems: [QRCard], expiredGreenCards: [ExpiredQR]) in
			guard let self else { return }
			
			DispatchQueue.main.async {
				var state = self.state
				state.qrCards = qrCardDataItems
				state.expiredGreenCards += expiredGreenCards
				state.shouldShowCompleteYourVaccinationAssessmentBanner = self.vaccinationAssessmentNotificationManager.hasVaccinationAssessmentEventButNoOrigin(now: Current.now())
				self.state = state
			}
		}
	}

	private func setupBlockedEventsDatasource() {

		blockedEventsDatasource.didUpdate = { [weak self] blockedEventItems in
			guard let self else { return }

			DispatchQueue.main.async {
				if blockedEventItems.isNotEmpty && !Current.userSettings.hasShownBlockedEventsAlert {
					self.displayBlockedEventsAlert(blockedEventItems: blockedEventItems)
				}

				self.state.blockedEventItems = blockedEventItems
			}
		}
	}
	
	private func setupFuzzyMatchingRemovedEventsDatasource() {

		mismatchedIdentityDatasource.didUpdate = { [weak self] items in
			guard let self else { return }

			DispatchQueue.main.async {
				self.state.mismatchedIdentityItems = items
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

	// MARK: - View Lifecycle callbacks:

	func viewWillAppear() {
		qrcardDatasource.reload()
	}

	// MARK: - Receive Updates

	/// Don't call directly, apart from within `init` and from within `var state: State { didSet { ... } }`
	fileprivate func didUpdateState(fromOldState oldState: State?) {
		guard state != oldState // save recomputation effort if `==`
		else { return }
		
		internationalCards.value = HolderDashboardViewModel.assembleInternationalCards(
			forValidityRegion: .europeanUnion,
			state: state,
			actionHandler: self,
			now: Current.now()
		)

		shouldShowAddCertificateFooter.value = state.shouldShowAddCertificateFooter
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
			qrcardDatasource.reload()
		}

		// Handle combination of Loading State + Expiry State + Error presentation:
		switch (refresherState.loadingState, refresherState.greencardsCredentialExpiryState, refresherState.userHasPreviouslyDismissedALoadingError) {
			case (_, .noActionNeeded, _):
				logDebug("StrippenRefresh: No action needed.")

			// 🔌 NO INTERNET: Refresher has no internet and wants to know what to do next

			case (.noInternet, .expired, false):
				logDebug("StrippenRefresh: Need refreshing now, but no internet. Presenting alert.")
				currentlyPresentedAlert.value = AlertContent.strippenExpiredWithNoInternet(strippenRefresher: strippenRefresher)

			case (.noInternet, .expired, true):
				logDebug("StrippenRefresh: Need refreshing now, but no internet. Showing in UI.")
				state.errorForQRCardsMissingCredentials = .noInternet

			case (.noInternet, .expiring, true):
				// Do nothing
				logDebug("StrippenRefresh: Need refreshing soon, but no internet. Do nothing.")

			case (.noInternet, .expiring(let expiryDate), false):
				logDebug("StrippenRefresh: Need refreshing soon, but no internet. Presenting alert.")
				currentlyPresentedAlert.value = AlertContent.strippenExpiringWithNoInternet(expiryDate: expiryDate, strippenRefresher: strippenRefresher, now: Current.now())

			// ❤️‍🩹 NETWORK ERRORS: Refresher has entered a failed state (i.e. Server Error)

			case let(.failed(error), .expired, _):
				logDebug("StrippenRefresh: Need refreshing now, but server error. Showing in UI.")
				checkForMismatchedIdentityError(error: error)

				state.errorForQRCardsMissingCredentials = refresherState.errorOccurenceCount > 1
					? .otherFailureSubsequentOccurence
					: .otherFailureFirstOccurence

			case let (.failed(error), .expiring, _):
				// In this case we just swallow the server errors.
				// We do handle "no internet" though - see above.
				logDebug("StrippenRefresh: Swallowing server error because can refresh later.")
				checkForMismatchedIdentityError(error: error)

			case (.serverResponseHasNoChanges, _, _):
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
	
	fileprivate func checkForMismatchedIdentityError(error: DashboardStrippenRefresher.Error) {
	
		// Check if we ran into a mismatched Identity error
		if case let DashboardStrippenRefresher.Error.greencardLoaderError(error: GreenCardLoader.Error.credentials(.error(_, response, _))) = error {
			if let matchingBlobIds = response?.context?.matchingBlobIds,
			   response?.code == GreenCardResponseError.mismatchedIdentity {
				coordinator?.handleMismatchedIdentityError(matchingBlobIds: matchingBlobIds)
			}
		}
	}
	
	fileprivate func setupRecommendedVersion() {
		
		let recommendedVersion = Current.remoteConfigManager.storedConfiguration.recommendedVersion?.fullVersionString() ?? "1.0.0"
		let currentVersion = versionSupplier?.getCurrentVersion().fullVersionString() ?? "1.0.0"
		self.state.shouldShowRecommendedUpdateBanner = recommendedVersion.compare(currentVersion, options: .numeric) == .orderedDescending
	}
	
	fileprivate func recalculateDisclosureBannerState() {
		
		state.shouldShow0GDisclosurePolicyBecameActiveBanner = !Current.userSettings.hasDismissedZeroGPolicy
	}
	
	// MARK: - NSNotification
	
	fileprivate func setupNotificationListeners() {

		notificationCenter.addObserver(self, selector: #selector(receiveDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
	}

	@objc func receiveDidBecomeActiveNotification() {
		qrcardDatasource.reload()
	}

	// MARK: - Present alerts

	private func displayBlockedEventsAlert(blockedEventItems: [RemovedEventItem]) {
		
		currentlyPresentedAlert.value = AlertContent(
			title: L.holder_invaliddetailsremoved_alert_title(),
			subTitle: L.holder_invaliddetailsremoved_alert_body(),
			okAction: AlertContent.Action(
				title: L.holder_invaliddetailsremoved_alert_button_moreinfo(),
				action: { [weak self] _ in
					self?.didTapBlockedEventsDeletedMoreInfo(blockedEventItems: blockedEventItems)
				}
			),
			cancelAction: AlertContent.Action(
				title: L.holder_invaliddetailsremoved_alert_button_close(),
				action: nil
			),
			alertWasPresentedCallback: {
				Current.userSettings.hasShownBlockedEventsAlert = true
			}
		)
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
	
	private static func assembleInternationalCards(
		forValidityRegion validityRegion: QRCodeValidityRegion,
		state: HolderDashboardViewModel.State,
		actionHandler: HolderDashboardCardUserActionHandling,
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
		cards += VCCard.makeBlockedEventsCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeMismatchedIdentityEventsCard(state: state, actionHandler: actionHandler)
		cards += VCCard.makeExpiredQRCard(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeDisclosurePolicyInformation0GBanner(validityRegion: validityRegion, state: state, actionHandler: actionHandler)
		cards += VCCard.makeEmptyStatePlaceholderImageCard(validityRegion: validityRegion, state: state)
		cards += VCCard.makeQRCards(
			validityRegion: validityRegion,
			state: state,
			actionHandler: actionHandler
		)
		cards += VCCard.makeAddCertificateCard(state: state, actionHandler: actionHandler)
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
	
	func didTapBlockedEventsDeletedMoreInfo(blockedEventItems: [RemovedEventItem]) {
		coordinator?.userWishesMoreInfoAboutBlockedEventsBeingDeleted(blockedEventItems: blockedEventItems)
	}
	
	func didTapBlockedEventsDeletedDismiss(blockedEventItems: [RemovedEventItem]) {
		Current.walletManager.removeExistingBlockedEvents()
		Current.userSettings.hasShownBlockedEventsAlert = false
	}
	
	func didTapMismatchedIdentityEventsDeletedMoreInfo(items: [RemovedEventItem]) {
		coordinator?.userWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted(items: items)
	}
	
	func didTapMismatchedIdentityEventsDeletedDismiss(items: [RemovedEventItem] ) {
		Current.walletManager.removeExistingMismatchedIdentityEvents()
		Current.secureUserSettings.selectedIdentity = nil
	}
	
	func didTapDeviceHasClockDeviationMoreInfo() {
		coordinator?.userWishesMoreInfoAboutClockDeviation()
	}
	
	func didTapShowQR(greenCardObjectIDs: [NSManagedObjectID]) {
		coordinator?.userWishesToViewQRs(greenCardObjectIDs: greenCardObjectIDs)
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
	
	func didTapDisclosurePolicyInformation0GBannerMoreInformation() {
		
		guard let url = URL(string: L.holder_dashboard_noDomesticCertificatesBanner_url()) else { return }
		openUrl(url)
	}
	
	func didTapDisclosurePolicyInformation0GBannerClose() {

		Current.userSettings.hasDismissedZeroGPolicy = true
		recalculateDisclosureBannerState()
	}
}
