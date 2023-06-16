/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */
// swiftlint:disable file_length

import UIKit
import CoreData
import Reachability
import Shared
import ReusableViews
import Transport
import OpenIDConnect
import Persistence
import Models
import Managers
import Resources

protocol HolderCoordinatorDelegate: AnyObject {
	
	/// Navigate to the start of the holder flow
	func navigateBackToStart()
	
	func handleMismatchedIdentityError(matchingBlobIds: [[String]])
	
	func openUrl(_ url: URL)
	
	func presentError(content: Content, backAction: (() -> Void)?)
	
	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool)
	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String)
	
	func userWishesMoreInfoAboutBlockedEventsBeingDeleted(blockedEventItems: [RemovedEventItem])
	func userWishesMoreInfoAboutClockDeviation()
	func userWishesMoreInfoAboutExpiredQR(type: OriginType)
	func userWishesMoreInfoAboutHiddenQR()
	func userWishesMoreInfoAboutGettingTested()
	func userWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted(items: [RemovedEventItem])
	func userWishesMoreInfoAboutNoTestToken()
	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String)
	func userWishesToAddPaperProof()
	func userWishesToChooseTestLocation()
	func userWishesToCreateANegativeTestQR()
	func userWishesToCreateANegativeTestQRFromGGD()
	func userWishesToCreateAQR()
	func userWishesToCreateARecoveryQR()
	func userWishesToCreateAVaccinationQR()
	func userWishesToExportPDF()
	func userWishesToLaunchThirdPartyTicketApp()
	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode)
	func userWishesToMigrate()
	func userWishesToOpenTheMenu()
	func userWishesToRestart()
	func userWishesToSeeAboutThisApp()
	func userWishesToSeeEventDetails(_ title: String, details: [EventDetails])
	func userWishesToSeeHelpAndInfoMenu()
	func userWishesToSeeHelpdesk()
	func userWishesToSeeStoredEvents()
	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID])
}

class HolderCoordinator: SharedCoordinator {
	
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()
	
	///	A (whitelisted) third-party can open the app & - if they provide a return URL, we will
	///	display a "return to Ticket App" button on the ShowQR screen
	/// Docs: https://shrtm.nu/oc45
	var thirdpartyTicketApp: (name: String, returnURL: URL)?
	
	/// If set, this should be handled at the first opportunity:
	var unhandledUniversalLink: UniversalLink?
	
	// MARK: - Setup
	
	override init(navigationController: UINavigationController, window: UIWindow) {
		super.init(navigationController: navigationController, window: window)
		setupNotificationListeners()
	}
	
	// MARK: - Teardown
	
	private func removeChildCoordinator() {
		
		guard let coordinator = childCoordinators.last else { return }
		removeChildCoordinator(coordinator)
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Starting Coordinator
	
	// Designated starter method
	override func start() {

		performAppLaunchCleanup()
		
		if LaunchArgumentsHandler.shouldSkipOnboarding() {
			navigateToDashboard(replacingWindowRootViewController: true)
			return
		}
				
		handleOnboarding(
			onboardingFactory: onboardingFactory,
			newFeaturesFactory: HolderNewFeaturesFactory(featureFlagManager: Current.featureFlagManager)
		) {
			
			if let unhandledUniversalLink {
				
				// Attempt to consume the universal link again:
				self.unhandledUniversalLink = nil // prevent potential infinite loops
				navigateToDashboard(replacingWindowRootViewController: true) {
					self.consume(universalLink: unhandledUniversalLink)
				}
				
			} else {
				
				// Start with the holder app
				navigateToDashboard(replacingWindowRootViewController: true) { }
			}
		}
	}
	
	private func startEventFlowForVaccination() {
		
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithVaccination()
		
	}
	
	private func startEventFlowForRecovery() {
		
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithRecovery()
		
	}
	
	private func startEventFlowForNegativeTest() {
		
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithNegativeTest()
		
	}
	
	func handleMismatchedIdentityError(matchingBlobIds: [[String]]) {
		
		let fmCoordinator = FuzzyMatchingCoordinator(
			navigationController: navigationController,
			matchingBlobIds: matchingBlobIds,
			onboardingFactory: FuzzyMatchingOnboardingFactory(),
			delegate: self
		)
		startChildCoordinator(fmCoordinator)
	}
	
	// MARK: - Setup Listeners
	
	private func setupNotificationListeners() {
		
		// Prevent the thirdparty ticket feature persisting forever, let's clear it when the user minimises the app
		NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.thirdpartyTicketApp = nil
		}
	}
	
	// MARK: - App Launch Cleanup
	
	func performAppLaunchCleanup() {
		
		// Remove CTB Stuff
		Current.walletManager.removeDomesticGreenCards()
		Current.walletManager.removeVaccinationAssessmentEventGroups()
		
		if !Current.featureFlagManager.isInArchiveMode() {
			
			// Remove leftovers from previous sessions
			Current.walletManager.removeDraftEventGroups()
			
			// Remove expired event groups
			Current.walletManager.expireEventGroups(forDate: Current.now())
		}
	}
	
	// MARK: - Universal Links
	
	/// Try to consume the Activity
	/// returns: bool indicating whether it was possible.
	@discardableResult
	override func consume(universalLink: UniversalLink) -> Bool {
		switch universalLink {
			case .redeemHolderToken(let requestToken):
				return consumeToken(requestToken, universalLink: universalLink)
			case .thirdPartyTicketApp(let returnURL):
				return consumeThirdPartyTicket(returnURL)
			case .tvsAuth(let returnURL):
				return consumeTvsAuthLink(returnURL)
			default:
				return false
		}
	}
	
	private func consumeToken(_ requestToken: RequestToken, universalLink: UniversalLink) -> Bool {
		
		guard Current.featureFlagManager.isAddingEventsEnabled() else { return false }
		
		// Need to handle two situations:
		// - the user is currently viewing onboarding/consent/force-information (and these should not be skipped)
		//   ⮑ in this situation, it is nice to keep hold of the UniversalLink and go straight to handling
		//      that after the user has completed these screens.
		// - the user is somewhere in the Holder app, and the nav stack can just be replaced.
		
		if onboardingManager.needsOnboarding || onboardingManager.needsConsent || newFeaturesManager.needsUpdating {
			self.unhandledUniversalLink = universalLink
		} else {
			// Do it on the next runloop, to standardise all the entry points to this function:
			DispatchQueue.main.async { [self] in
				navigateToTokenEntry(requestToken)
			}
		}
		return true
	}
	
	private func consumeThirdPartyTicket(_ returnURL: URL?) -> Bool {
		
		guard let returnURL = returnURL,
			  let matchingMetadata = remoteConfigManager.storedConfiguration.universalLinkPermittedDomains?.first(where: { permittedDomain in
				  permittedDomain.url == returnURL.host
			  })
		else {
			return true
		}
		
		thirdpartyTicketApp = (name: matchingMetadata.name, returnURL: returnURL)
		
		return true
	}
	
	private func consumeTvsAuthLink(_ returnURL: URL?) -> Bool {
		
		var result = false
		do {
			try ObjC.catchException {
				if let url = returnURL,
				   let openIDConnectState = UIApplication.shared.delegate as? OpenIDConnectState,
				   let authorizationFlow = openIDConnectState.currentAuthorizationFlow,
				   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
					openIDConnectState.currentAuthorizationFlow = nil
				}
				result = true
			}
		} catch {
			
			result = false
		}
		return result
	}
	
	// MARK: - Navigate to..
	
	func navigateToDashboard(replacingWindowRootViewController: Bool = false, completion: @escaping () -> Void = {}) {

		if let existingDashboardVC = navigationController.viewControllers.first(where: { $0 is HolderDashboardViewController }) {
			navigationController.popToViewController(existingDashboardVC, animated: true)
		} else {
			let dashboardViewController = HolderDashboardViewController(
				viewModel: HolderDashboardViewModel(
					coordinator: self,
					qrcardDatasource: HolderDashboardQRCardDatasource(),
					blockedEventsDatasource: HolderDashboardRemovedEventsDatasource(reason: RemovalReason.blockedEvent),
					mismatchedIdentityDatasource: HolderDashboardRemovedEventsDatasource(reason: RemovalReason.mismatchedIdentity),
					strippenRefresher: DashboardStrippenRefresher(
						minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: remoteConfigManager.storedConfiguration.credentialRenewalDays ?? 5,
						reachability: try? Reachability()
					),
					configurationNotificationManager: ConfigurationNotificationManager(userSettings: Current.userSettings, remoteConfigManager: Current.remoteConfigManager, now: Current.now),
					versionSupplier: versionSupplier
				)
			)
			
			navigationController.setViewControllers([dashboardViewController], animated: !replacingWindowRootViewController, completion: completion)
			
			if replacingWindowRootViewController {
				window.replaceRootViewController(with: navigationController)
			}
		}
	}
	
	/// Navigate to the token entry scene
	func navigateToTokenEntry(_ token: RequestToken? = nil) {
		
		let destination = InputRetrievalCodeViewController(
			viewModel: InputRetrievalCodeViewModel(
				coordinator: self,
				requestToken: token,
				tokenValidator: TokenValidator(isLuhnCheckEnabled: Current.featureFlagManager.isLuhnCheckEnabled())
			)
		)
		
		navigationController.pushViewController(destination, animated: true)
	}
	
	// "Waar wil je een QR-code van maken?"
	func navigateToChooseQRCodeType() {
		
		let destination = ListOptionsViewController(
			viewModel: ChooseProofTypeViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func navigateToAddPaperProof() {
		
		let paperProofCoordinator = PaperProofCoordinator(navigationController: navigationController, delegate: self)
		startChildCoordinator(paperProofCoordinator)
	}
	
	func navigateToAboutThisApp() {
		
		let viewModel = AboutThisAppViewModel(versionSupplier: versionSupplier, flavor: AppFlavor.flavor) { [weak self] outcome in
			guard let self else { return }
			switch outcome {
				case let .openURL(url):
					self.openUrl(url)
				case .coordinatorShouldRestart:
					self.restart()
				case .userWishesToOpenScanLog:
					break // - for VerifierCoordinator
			}
		}
		let viewController = AboutThisAppViewController(viewModel: viewModel)
		
		navigationController.pushViewController(viewController, animated: true)
	}
	
	/// Navigate to enlarged QR
	func navigateToShowQRs(_ greenCards: [GreenCard]) {
		
		let destination = ShowQRViewController(
			viewModel: ShowQRViewModel(
				coordinator: self,
				greenCards: greenCards,
				thirdPartyTicketAppName: thirdpartyTicketApp?.name
			)
		)
		
		destination.modalPresentationStyle = .fullScreen
		navigationController.pushViewController(destination, animated: true)
	}
	
	func navigateToChooseTestLocation() {
		
		let destination = ListOptionsViewController(
			viewModel: ChooseTestLocationViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func showMigrationSuccessfulDialog() {
		
		let alertController = UIAlertController(
			title: L.holder_migrationFlow_deleteDetails_dialog_title(),
			message: L.holder_migrationFlow_deleteDetails_dialog_message(),
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: L.holder_migrationFlow_deleteDetails_dialog_deleteButton(),
				style: .destructive,
				handler: { [weak self] _ in
					self?.removeDataAfterMigration()
				}
			)
		)
		alertController.addAction(
			UIAlertAction(
				title: L.holder_migrationFlow_deleteDetails_dialog_retainButton(),
				style: .default,
				handler: nil
			)
		)
		navigationController.present(alertController, animated: true, completion: nil)
	}
	
	private func removeDataAfterMigration() {
		// Remove Data
		Current.walletManager.removeExistingGreenCards()
		Current.walletManager.removeExistingEventGroups()
		Current.walletManager.removeExistingBlockedEvents()
		Current.walletManager.removeExistingMismatchedIdentityEvents()
		// Trigger a reload
		NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
	}
}

// MARK: - HolderCoordinatorDelegate

extension HolderCoordinator: HolderCoordinatorDelegate {
	
	/// Navigate to the start fo the holder flow
	func navigateBackToStart() {
		
		navigationController.popToRootViewController(animated: true)
	}
	
	func presentError(content: Content, backAction: (() -> Void)?) {
		
		presentContent(content: content, backAction: backAction)
	}
	
	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String) {
		
		let viewController = DCCQRDetailsViewController(
			viewModel: DCCQRDetailsViewModel(
				coordinator: self,
				title: title,
				description: description,
				details: details,
				dateInformation: dateInformation
			)
		)
		presentAsBottomSheet(viewController)
	}
	
	// MARK: - User Wishes To ... -
	
	func userWishesToExportPDF() {
		
		let exportCoordinator = PDFExportCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		startChildCoordinator(exportCoordinator)
	}
	
	func userWishesMoreInfoAboutBlockedEventsBeingDeleted(blockedEventItems: [RemovedEventItem]) {

		let bulletpoints = compactRemovedEventItems(blockedEventItems)
		guard bulletpoints.isNotEmpty else { return }

		// I 1280 000 0514
		let errorCode = ErrorCode(
			flow: .dashboard,
			step: .signer,
			clientCode: .signerReturnedBlockedEvent
		)

		let title: String = L.holder_invaliddetailsremoved_moreinfo_title()
		let message: String = L.holder_invaliddetailsremoved_moreinfo_body(
			bulletpoints, Current.contactInformationProvider.phoneNumberLink, errorCode.description)

		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: true)
	}
	
	func userWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted(items: [RemovedEventItem]) {

		let bulletpoints = compactRemovedEventItems(items)
		guard bulletpoints.isNotEmpty else { return }
		guard let persistentName = Current.secureUserSettings.selectedIdentity else { return }

		let title: String = L.holder_identityRemoved_moreinfo_title()
		let sanitizedName = Shared.Sanitizer.sanitize(persistentName)
		let message: String = L.holder_identityRemoved_moreinfo_body(sanitizedName, bulletpoints)

		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: true)
	}

	private func compactRemovedEventItems(_ items: [RemovedEventItem]) -> String {
		
		return items
			.compactMap { item -> String? in
				guard let localizedDateLabel = item.type.localizedDateLabel else { return nil }
				let dateString = Shared.Sanitizer.sanitize(DateFormatter.Format.dayMonthYear.string(from: item.eventDate))
				return """
				<p>
					<b>\(item.type.localized.capitalizingFirstLetter())</b>
					<br />
					<b>\(localizedDateLabel.capitalizingFirstLetter()): \(dateString)</b>
				</p>
				""" }
			.joined()
		
	}
	
	func userWishesMoreInfoAboutClockDeviation() {
		let title: String = L.holderClockDeviationDetectedTitle()
		let message: String = L.holderClockDeviationDetectedMessage(UIApplication.openSettingsURLString)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false)
	}
		
	func userWishesMoreInfoAboutExpiredQR(type: OriginType) {
		
		var body: String? {
			guard Current.featureFlagManager.isInArchiveMode() else {
				return L.holder_qr_code_expired_explanation_description()
			}
			switch type {
				case .vaccination: return L.holder_qr_code_expired_explanation_description_archive_vaccination()
				case .recovery: return L.holder_qr_code_expired_explanation_description_archive_recovery()
				default: return nil
			}
		}
	
		let viewModel = BottomSheetContentViewModel(
			content: Content(
				title: L.holder_qr_code_expired_explanation_title(),
				body: body,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: Current.featureFlagManager.isInArchiveMode() ? nil : L.holder_qr_code_expired_explanation_action(),
				secondaryAction: Current.featureFlagManager.isInArchiveMode() ? nil : { [weak self] in
					guard let self,
						  let url = URL(string: L.holder_qr_code_expired_explanation_url()) else { return }
					self.openUrl(url)
				}
			),
			screenCaptureDetector: ScreenCaptureDetector(),
			linkTapHander: { [weak self] url in
				self?.openUrl(url)
			},
			hideBodyForScreenCapture: false
		)
		
		let viewController = BottomSheetContentViewController(viewModel: viewModel)
		presentAsBottomSheet(viewController)
	}
	
	func userWishesMoreInfoAboutHiddenQR() {
		
		let viewModel = BottomSheetContentViewModel(
			content: Content(
				title: L.holder_qr_code_hidden_explanation_title(),
				body: L.holder_qr_code_hidden_explanation_description(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holder_qr_code_hidden_explanation_action(),
				secondaryAction: { [weak self] in
					guard let self,
							let url = URL(string: L.holder_qr_code_hidden_explanation_url()) else { return }
					self.openUrl(url)
				}
			),
			screenCaptureDetector: ScreenCaptureDetector(),
			linkTapHander: { [weak self] url in
				self?.openUrl(url)
			},
			hideBodyForScreenCapture: false
		)
		
		let viewController = BottomSheetContentViewController(viewModel: viewModel)
		presentAsBottomSheet(viewController)
	}
	
	func userWishesMoreInfoAboutGettingTested() {
		
		let viewController = MakeTestAppointmentViewController(
			viewModel: MakeTestAppointmentViewModel(
				coordinator: self,
				title: L.holderNotestTitle(),
				message: String(format: L.holderNotestBody()),
				buttonTitle: L.holderNotestButtonTitle()
			)
		)
		presentAsBottomSheet(viewController)
	}
	
	func userWishesMoreInfoAboutNoTestToken() {
		
		presentInformationPage(
			title: L.holderTokenentryModalNotokenTitle(),
			body: L.holderTokenentryModalNotokenDetails(),
			hideBodyForScreenCapture: false
		)
	}
	
	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String) {
		let title: String = L.holderDashboardConfigIsAlmostOutOfDatePageTitle()
		let message: String = L.holderDashboardConfigIsAlmostOutOfDatePageMessage(validUntil)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false)
	}
	
	func userWishesToAddPaperProof() {
		
		navigateToAddPaperProof()
	}
	
	func userWishesToChooseTestLocation() {
		
		if Current.featureFlagManager.isGGDEnabled() {
			navigateToChooseTestLocation()
		} else {
			// Fallback when GGD is not available
			navigateToTokenEntry()
		}
	}
	
	func userWishesToCreateANegativeTestQR() {
		navigateToTokenEntry()
	}
	
	func userWishesToCreateANegativeTestQRFromGGD() {
		startEventFlowForNegativeTest()
	}
	
	func userWishesToCreateAQR() {
		
		navigateToChooseQRCodeType()
	}
	
	func userWishesToCreateARecoveryQR() {
		startEventFlowForRecovery()
	}
	
	func userWishesToCreateAVaccinationQR() {
		startEventFlowForVaccination()
	}
	
	func userWishesToLaunchThirdPartyTicketApp() {
		guard let thirdpartyTicketApp = thirdpartyTicketApp else { return }
		openUrl(thirdpartyTicketApp.returnURL)
	}
	
	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode) {
		
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithListTestEvents([remoteEvent], originalMode: originalMode)
	}
	
	func userWishesToMigrate() {
		
		let migrationCoordinator = MigrationCoordinator(navigationController: navigationController, delegate: self)
		startChildCoordinator(migrationCoordinator)
	}
	
	func userWishesToOpenTheMenu() {
		
		let viewController = MenuViewController(viewModel: HolderMainMenuViewModel(self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToRestart() {
		
		self.restart()
	}
	
	func userWishesToSeeAboutThisApp() {

		navigateToAboutThisApp()
	}
	
	func userWishesToSeeHelpAndInfoMenu() {
		
		let viewController = MenuViewController(viewModel: HolderHelpAndInfoMenuViewModel(self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToSeeEventDetails(_ title: String, details: [EventDetails]) {
		
		let viewController = StoredEventDetailsViewController(
			viewModel: RemoteEventDetailsViewModel(
				title: title,
				details: details,
				footer: nil,
				hideBodyForScreenCapture: true
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToSeeStoredEvents() {
		
		let viewController = ListStoredEventsViewController(
			viewModel: ListStoredEventsViewModel(coordinator: self)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToSeeHelpdesk() {
		
		let viewController = HelpdeskViewController(viewModel: HelpdeskViewModel(
			flavor: AppFlavor.flavor,
			versionSupplier: self.versionSupplier,
			urlHandler: { [weak self] url in
				self?.openUrl(url)
			}
		))
		
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID]) {
		
		func presentAlertWithErrorCode(_ code: ErrorCode) {
			
			let alertController = UIAlertController(
				title: L.generalErrorTitle(),
				message: L.generalErrorTechnicalCustom("\(code)"),
				preferredStyle: .alert
			)
			alertController.addAction(UIAlertAction(title: L.generalOk(), style: .default, handler: nil))
			navigationController.present(alertController, animated: true, completion: nil)
		}
		
		let result = GreenCardModel.fetchByIds(objectIDs: greenCardObjectIDs, managedObjectContext: Current.dataStoreManager.managedObjectContext())
		switch result {
			case let .success(greenCards):
				if greenCards.isEmpty {
					presentAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .noGreenCardsAvailable))
				} else {
					navigateToShowQRs(greenCards)
				}
			case .failure:
				presentAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .coreDataFetchError))
		}
	}
}

extension HolderCoordinator: EventFlowDelegate {
	
	func eventFlowDidComplete() {
		
		removeChildCoordinator()
		navigateToDashboard()
	}
	
	func eventFlowDidCancel() {
		
		removeChildCoordinator()
	}
}

extension HolderCoordinator: PaperProofFlowDelegate {
	
	func addPaperProofFlowDidCancel() {
		
		removeChildCoordinator()
	}
	
	func addPaperProofFlowDidFinish() {
		
		removeChildCoordinator()
		navigateToDashboard()
	}
	
	func switchToAddRegularProof() {
		
		removeChildCoordinator()
		navigateToChooseQRCodeType()
	}
}

extension HolderCoordinator: FuzzyMatchingFlowDelegate {
	
	func fuzzyMatchingUserBackedOutOfFlow() {
		// Isn't known to be possible, but just in case.. 
		fuzzyMatchingFlowDidStop()
	}
	
	func fuzzyMatchingFlowDidFinish() {
		if let childCoordinator = childCoordinators.first(where: { $0 is FuzzyMatchingCoordinator }) {
			removeChildCoordinator(childCoordinator)
		}
		navigateBackToStart()
	}
	
	func fuzzyMatchingFlowDidStop() {
		if let childCoordinator = childCoordinators.first(where: { $0 is FuzzyMatchingCoordinator }) {
			removeChildCoordinator(childCoordinator)
		}
		navigateBackToStart()
	}
}

extension HolderCoordinator: MigrationFlowDelegate {
	
	func dataMigrationBackAction() {
	
		removeMigrationCoordinator()
	}
	
	func dataMigrationCancelled() {
		
		navigateToDashboard()
		removeMigrationCoordinator()
	}
	
	func dataMigrationExportCompleted() {
		
		navigateToDashboard()
		removeMigrationCoordinator()
		showMigrationSuccessfulDialog()
	}
	
	func dataMigrationImportCompleted() {

		navigateToDashboard()
		removeMigrationCoordinator()
	}
	
	private func removeMigrationCoordinator() {
		
		if let childCoordinator = childCoordinators.first(where: { $0 is MigrationCoordinator }) {
			removeChildCoordinator(childCoordinator)
		}
	}
}

extension HolderCoordinator: PDFExportFlowDelegate {
	
	func exportCompleted() {
		
		removePDFExportCoordinator()
	}
	
	private func removePDFExportCoordinator() {
		
		if let childCoordinator = childCoordinators.first(where: { $0 is PDFExportCoordinator }) {
			removeChildCoordinator(childCoordinator)
		}
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {
	
	static let noGreenCardsAvailable = ErrorCode.ClientCode(value: "061")
	static let coreDataFetchError = ErrorCode.ClientCode(value: "062")
}
