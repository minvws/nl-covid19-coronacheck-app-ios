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
import Transport
import OpenIDConnect

protocol HolderCoordinatorDelegate: AnyObject {
	
	/// Navigate to the start of the holder flow
	func navigateBackToStart()
	
	func openUrl(_ url: URL, inApp: Bool)
	
	func presentError(content: Content, backAction: (() -> Void)?)
	
	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool)
	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String)
	
	func userWishesMoreInfoAboutBlockedEventsBeingDeleted(blockedEventItems: [RemovedEventItem])
	func userWishesMoreInfoAboutClockDeviation()
	func userWishesMoreInfoAboutCompletingVaccinationAssessment()
	func userWishesMoreInfoAboutExpiredDomesticVaccination()
	func userWishesMoreInfoAboutExpiredQR()
	func userWishesMoreInfoAboutHiddenQR()
	func userWishesMoreInfoAboutGettingTested()
	func userWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted(items: [RemovedEventItem])
	func userWishesMoreInfoAboutNoTestToken()
	func userWishesMoreInfoAboutNoVisitorPassToken()
	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String)
	func userWishesMoreInfoAboutUnavailableQR(originType: OriginType, currentRegion: QRCodeValidityRegion)
	func userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL()
	func userWishesToChooseTestLocation()
	func userWishesToCreateANegativeTestQR()
	func userWishesToCreateANegativeTestQRFromGGD()
	func userWishesToCreateAQR()
	func userWishesToCreateARecoveryQR()
	func userWishesToCreateAVaccinationQR()
	func userWishesToCreateAVisitorPass()
	func userWishesToLaunchThirdPartyTicketApp()
	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode)
	func userWishesToOpenTheMenu()
	func userWishesToSeeEventDetails(_ title: String, details: [EventDetails])
	func userWishesToStartFuzzyMatchingFlow(matchingBlobIds: [[String]])
	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?)
}

class HolderCoordinator: SharedCoordinator {
	
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()
	
	///	A (whitelisted) third-party can open the app & - if they provide a return URL, we will
	///	display a "return to Ticket App" button on the ShowQR screen
	/// Docs: https://shrtm.nu/oc45
	var thirdpartyTicketApp: (name: String, returnURL: URL)?
	
	/// If set, this should be handled at the first opportunity:
	var unhandledUniversalLink: UniversalLink?
	
	private var disclosurePolicyUpdateObserverToken: Observatory.ObserverToken? {
		willSet {
			// Remove any existing observation:
			disclosurePolicyUpdateObserverToken.map(Current.disclosurePolicyManager.observatory.remove)
		}
	}
	
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
		disclosurePolicyUpdateObserverToken.map(Current.disclosurePolicyManager.observatory.remove)
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
			newFeaturesFactory: HolderNewFeaturesFactory()
		) {
			
			if let unhandledUniversalLink {
				
				// Attempt to consume the universal link again:
				self.unhandledUniversalLink = nil // prevent potential infinite loops
				navigateToDashboard(replacingWindowRootViewController: true) {
					self.consume(universalLink: unhandledUniversalLink)
				}
				
			} else {
				
				// Start with the holder app
				navigateToDashboard(replacingWindowRootViewController: true) {
					self.handleDisclosurePolicyUpdates()
					self.disclosurePolicyUpdateObserverToken = Current.disclosurePolicyManager.observatory.append { [weak self] in
						self?.handleDisclosurePolicyUpdates()
					}
				}
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
	
	func userWishesToStartFuzzyMatchingFlow(matchingBlobIds: [[String]]) {
		
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
		
		Current.walletManager.removeDraftEventGroups()
		Current.walletManager.expireEventGroups(forDate: Current.now()) // Vaccineassessment expiration can leave some events lingering - when reloading, make sure they are cleaned up also.
	}
	
	// MARK: - Universal Links
	
	/// Try to consume the Activity
	/// returns: bool indicating whether it was possible.
	@discardableResult
	override func consume(universalLink: UniversalLink) -> Bool {
		switch universalLink {
			case .redeemHolderToken(let requestToken):
				return consumeToken(requestToken, retrievalMode: .negativeTest, universalLink: universalLink)
			case .redeemVaccinationAssessment(let requestToken):
				return consumeToken(requestToken, retrievalMode: .visitorPass, universalLink: universalLink)
			case .thirdPartyTicketApp(let returnURL):
				return consumeThirdPartyTicket(returnURL)
			case .tvsAuth(let returnURL):
				return consumeTvsAuthLink(returnURL)
			default:
				return false
		}
	}
	
	private func consumeToken(_ requestToken: RequestToken, retrievalMode: InputRetrievalCodeMode, universalLink: UniversalLink) -> Bool {
		
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
				navigateToTokenEntry(requestToken, retrievalMode: retrievalMode)
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
		
		// Reset the dashboard back to the domestic tab:
		if let dashboardViewController = navigationController.viewControllers.last as? HolderDashboardViewController {
			dashboardViewController.viewModel.selectTab(newTab: .domestic)
		}
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
					vaccinationAssessmentNotificationManager: VaccinationAssessmentNotificationManager(),
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
	func navigateToTokenEntry(_ token: RequestToken? = nil, retrievalMode: InputRetrievalCodeMode = .negativeTest) {
		
		let destination = InputRetrievalCodeViewController(
			viewModel: InputRetrievalCodeViewModel(
				coordinator: self,
				requestToken: token,
				tokenValidator: TokenValidator(isLuhnCheckEnabled: Current.featureFlagManager.isLuhnCheckEnabled()),
				inputRetrievalCodeMode: retrievalMode
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
	
	func navigateToAddVisitorPass() {
		let viewController = VisitorPassStartViewController(viewModel: VisitorPassStartViewModel(coordinator: self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func navigateToAboutThisApp() {
		
		let viewModel = AboutThisAppViewModel(versionSupplier: versionSupplier, flavor: AppFlavor.flavor) { [weak self] outcome in
			guard let self else { return }
			switch outcome {
				case let .openURL(url, inApp):
					self.openUrl(url, inApp: inApp)
				case .coordinatorShouldRestart:
					self.restart()
				case .userWishesToSeeStoredEvents:
					self.userWishesToSeeStoredEvents()
				case .userWishesToOpenScanLog:
					break // - for VerifierCoordinator
			}
		}
		let viewController = AboutThisAppViewController(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	/// Navigate to enlarged QR
	func navigateToShowQRs(_ greenCards: [GreenCard], disclosurePolicy: DisclosurePolicy?) {
		
		let destination = ShowQRViewController(
			viewModel: ShowQRViewModel(
				coordinator: self,
				greenCards: greenCards,
				disclosurePolicy: disclosurePolicy,
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
		let message: String = L.holder_invaliddetailsremoved_moreinfo_body(bulletpoints, errorCode.description)

		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: true, openURLsInApp: false)
	}
	
	func userWishesMoreInfoAboutMismatchedIdentityEventsBeingDeleted(items: [RemovedEventItem]) {

		let bulletpoints = compactRemovedEventItems(items)
		guard bulletpoints.isNotEmpty else { return }
		guard let persistentName = Current.secureUserSettings.selectedIdentity else { return }

		let title: String = L.holder_identityRemoved_moreinfo_title()
		let message: String = L.holder_identityRemoved_moreinfo_body(persistentName, bulletpoints)

		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: true, openURLsInApp: false)
	}

	private func compactRemovedEventItems(_ items: [RemovedEventItem]) -> String {
		
		return items
			.compactMap { item -> String? in
				guard let localizedDateLabel = item.type.localizedDateLabel else { return nil }
				let dateString = DateFormatter.Format.dayMonthYear.string(from: item.eventDate)
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
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: false)
	}
	
	func userWishesMoreInfoAboutCompletingVaccinationAssessment() {
		
		presentContent(
			content: Content(
				title: L.holder_completecertificate_title(),
				body: L.holder_completecertificate_body(),
				primaryActionTitle: L.holder_completecertificate_button_fetchnegativetest(),
				primaryAction: { [weak self] in
					self?.userWishesToCreateANegativeTestQR()
				},
				secondaryActionTitle: nil,
				secondaryAction: nil
			),
			backAction: { [weak navigationController] in
				navigationController?.popViewController(animated: true, completion: {})
			},
			allowsSwipeBack: true,
			animated: true
		)
	}
	
	func userWishesMoreInfoAboutExpiredDomesticVaccination() {
		
		let viewModel = BottomSheetContentViewModel(
			content: Content(
				title: L.holder_expiredDomesticVaccinationModal_title(),
				body: L.holder_expiredDomesticVaccinationModal_body(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holder_expiredDomesticVaccinationModal_button_addBoosterVaccination(),
				secondaryAction: { [weak self] in
					guard let self else { return }
					self.navigationController.dismiss(
						animated: true,
						completion: self.userWishesToCreateAVaccinationQR
					)
				}
			),
			linkTapHander: { [weak self] url in
				self?.openUrl(url, inApp: true)
			},
			hideBodyForScreenCapture: false
		)
		
		let viewController = BottomSheetContentViewController(viewModel: viewModel)
		presentAsBottomSheet(viewController)
	}
	
	func userWishesMoreInfoAboutExpiredQR() {
	
		let viewModel = BottomSheetContentViewModel(
			content: Content(
				title: L.holder_qr_code_expired_explanation_title(),
				body: L.holder_qr_code_expired_explanation_description(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holder_qr_code_expired_explanation_action(),
				secondaryAction: { [weak self] in
					guard let self = self,
						  let url = URL(string: L.holder_qr_code_expired_explanation_url()) else { return }
					self.openUrl(url, inApp: true)
				}
			),
			linkTapHander: { [weak self] url in
				self?.openUrl(url, inApp: true)
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
					guard let self = self,
							let url = URL(string: L.holder_qr_code_hidden_explanation_url()) else { return }
					self.openUrl(url, inApp: true)
				}
			),
			linkTapHander: { [weak self] url in
				self?.openUrl(url, inApp: true)
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
			hideBodyForScreenCapture: false,
			openURLsInApp: true
		)
	}
	
	func userWishesMoreInfoAboutNoVisitorPassToken() {
		
		presentInformationPage(
			title: L.visitorpass_token_modal_notoken_title(),
			body: L.visitorpass_token_modal_notoken_details(),
			hideBodyForScreenCapture: false,
			openURLsInApp: true
		)
	}
	
	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String) {
		let title: String = L.holderDashboardConfigIsAlmostOutOfDatePageTitle()
		let message: String = L.holderDashboardConfigIsAlmostOutOfDatePageMessage(validUntil)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}
	
	func userWishesMoreInfoAboutUnavailableQR(originType: OriginType, currentRegion: QRCodeValidityRegion) {
		
		let title: String = .holderDashboardNotValidInThisRegionScreenTitle(originType: originType, currentRegion: currentRegion)
		let message: String = .holderDashboardNotValidInThisRegionScreenMessage(originType: originType, currentRegion: currentRegion)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false)
	}
	
	func userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL() {
		let title: String = L.holder_notvalidinthisregionmodal_visitorpass_international_title()
		let message: String = L.holder_notvalidinthisregionmodal_visitorpass_international_body()
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
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
	
	func userWishesToCreateAVisitorPass() {
		
		navigateToTokenEntry(retrievalMode: .visitorPass)
	}
	
	func userWishesToLaunchThirdPartyTicketApp() {
		guard let thirdpartyTicketApp = thirdpartyTicketApp else { return }
		openUrl(thirdpartyTicketApp.returnURL, inApp: false)
	}
	
	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode) {
		
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithListTestEvents([remoteEvent], originalMode: originalMode)
	}
	
	func userWishesToOpenTheMenu() {
		
		let itemAddCertificate: MenuViewModel.Item = .row(title: L.holder_menu_listItem_addVaccinationOrTest_title(), subTitle: nil, icon: I.icon_menu_add()!, action: { [weak self] in
			self?.navigateToChooseQRCodeType()
		})
		
		let itemAddPaperCertificate: MenuViewModel.Item = .row(title: L.holder_menu_paperproof_title(), subTitle: L.holder_menu_paperproof_subTitle(), icon: I.icon_menu_addpapercertificate()!, action: { [weak self] in
			self?.navigateToAddPaperProof()
		})
		
		let itemAddVisitorPass: MenuViewModel.Item = .row(title: L.holder_menu_visitorpass(), subTitle: nil, icon: I.icon_menu_addvisitorpass()!, action: { [weak self] in
			self?.navigateToAddVisitorPass()
		})
		
		let itemFAQ: MenuViewModel.Item = .row(title: L.holderMenuFaq(), subTitle: nil, icon: I.icon_menu_faq()!, action: { [weak self] in
			guard let faqUrl = URL(string: L.holderUrlFaq()) else { return }
			self?.openUrl(faqUrl, inApp: true)
		})
		
		let itemAboutThisApp: MenuViewModel.Item = .row(title: L.holderMenuAbout(), subTitle: nil, icon: I.icon_menu_aboutthisapp()!, action: { [weak self] in
			self?.navigateToAboutThisApp()
		})
		
		let items: [MenuViewModel.Item] = {
			
			if Current.featureFlagManager.isVisitorPassEnabled() {
				return [
					itemAddCertificate,
					.sectionBreak,
					itemAddPaperCertificate,
					itemAddVisitorPass,
					.sectionBreak,
					itemFAQ,
					itemAboutThisApp
				]
			} else {
				return [
					itemAddCertificate,
					itemAddPaperCertificate,
					.sectionBreak,
					itemFAQ,
					itemAboutThisApp
				]
			}
		}()
		
		let viewController = MenuViewController(viewModel: MenuViewModel(items: items))
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
	
	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID], disclosurePolicy: DisclosurePolicy?) {
		
		func presentAlertWithErrorCode(_ code: ErrorCode) {
			
			let alertController = UIAlertController(
				title: L.generalErrorTitle(),
				message: L.generalErrorTechnicalCustom("\(code)"),
				preferredStyle: .alert
			)
			
			alertController.addAction(.init(title: L.generalOk(), style: .default, handler: nil))
			navigationController.present(alertController, animated: true, completion: nil)
		}
		
		let result = GreenCardModel.fetchByIds(objectIDs: greenCardObjectIDs)
		switch result {
			case let .success(greenCards):
				if greenCards.isEmpty {
					presentAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .noGreenCardsAvailable))
				} else {
					navigateToShowQRs(greenCards, disclosurePolicy: disclosurePolicy)
				}
			case .failure:
				presentAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .coreDataFetchError))
		}
	}
}

extension HolderCoordinator: EventFlowDelegate {
	
	func eventFlowDidComplete() {
		
		/// The user completed the event flow. Go back to the dashboard.
		removeChildCoordinator()
		navigateToDashboard()
	}
	
	func eventFlowDidCompleteButVisitorPassNeedsCompletion() {
		
		/// The user completed the event flow, but needs to add a vaccination assessment test (visitor pass flow)
		removeChildCoordinator()
		navigationController.popToRootViewController(animated: false)
		userWishesToCreateAVisitorPass()
	}
	
	func eventFlowDidCancel() {
		
		/// The user cancelled the event flow.
		removeChildCoordinator()
		logInfo("HolderCoordinator: eventFlowDidCancel")
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

extension HolderCoordinator: UpdatedDisclosurePolicyDelegate {
	
	func showNewDisclosurePolicy(pagedAnnouncmentItems: [PagedAnnoucementItem]) {
		let coordinator = UpdatedDisclosurePolicyCoordinator(
			navigationController: navigationController,
			pagedAnnouncmentItems: pagedAnnouncmentItems,
			delegate: self
		)
		startChildCoordinator(coordinator)
	}
	
	func finishNewDisclosurePolicy() {
		
		if let childCoordinator = childCoordinators.first(where: { $0 is UpdatedDisclosurePolicyCoordinator }) {
			removeChildCoordinator(childCoordinator)
		}
	}
	
	func handleDisclosurePolicyUpdates() {
		
		guard !Current.onboardingManager.needsConsent, !Current.onboardingManager.needsOnboarding else {
			// No Disclosure Policy modal if we still need to finish onboarding
			return
		}
		
		guard Current.remoteConfigManager.storedConfiguration.disclosurePolicies != nil else {
			return
		}
		
		guard Current.disclosurePolicyManager.hasChanges else {
			return
		}
		
		let pagedAnnouncementItems = Current.disclosurePolicyManager.factory.create()
		guard pagedAnnouncementItems.isNotEmpty else {
			return
		}
		
		showNewDisclosurePolicy(pagedAnnouncmentItems: pagedAnnouncementItems)
	}
}

extension HolderCoordinator: FuzzyMatchingFlowDelegate {
	
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

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {
	
	static let noGreenCardsAvailable = ErrorCode.ClientCode(value: "061")
	static let coreDataFetchError = ErrorCode.ClientCode(value: "062")
}
