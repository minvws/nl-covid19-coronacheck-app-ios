/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import CoreData
import Reachability

protocol HolderCoordinatorDelegate: AnyObject {
	
	// MARK: Navigation
	
	/// Navigate to the start fo the holder flow
	func navigateBackToStart()
	
	/// Show an information page
	/// - Parameters:
	///   - title: the title of the page
	///   - body: the body of the page
	///   - hideBodyForScreenCapture: hide sensitive data for screen capture
	func presentInformationPage(title: String, body: String, hideBodyForScreenCapture: Bool, openURLsInApp: Bool)
	
	func presentDCCQRDetails(title: String, description: String, details: [DCCQRDetails], dateInformation: String)
	
	func userWishesToOpenTheMenu()
	
	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode)
	
	func userWishesToCreateAQR()
	
	func userWishesToCreateANegativeTestQR()
	
	func userWishesToCreateAVisitorPass()
	
	func userWishesToChooseTestLocation()
	
	func userHasNotBeenTested()
	
	func userWishesToCreateANegativeTestQRFromGGD()
	
	func userWishesToCreateAVaccinationQR()
	
	func userWishesToCreateARecoveryQR()
	
	func userWishesToFetchPositiveTests()
	
	func userDidScanRequestToken(requestToken: RequestToken)
	
	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion)
	
	func userWishesMoreInfoAboutClockDeviation()
	
	func userWishesMoreInfoAboutCompletingVaccinationAssessment()
	
	func userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL()
	
	func userWishesMoreInfoAboutTestOnlyValidFor3G()
	
	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String)
	
	func userWishesMoreInfoAboutIncompleteDutchVaccination()
	
	func userWishesMoreInfoAboutExpiredDomesticVaccination()
	
	func openUrl(_ url: URL, inApp: Bool)
	
	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID])
	
	func userWishesToLaunchThirdPartyTicketApp()
	
	func displayError(content: Content, backAction: @escaping () -> Void)
	
	func userWishesMoreInfoAboutNoTestToken()
	
	func userWishesMoreInfoAboutNoVisitorPassToken()
}

// swiftlint:enable class_delegate_protocol

class HolderCoordinator: SharedCoordinator {
	
	var onboardingFactory: OnboardingFactoryProtocol = HolderOnboardingFactory()
	
	///	A (whitelisted) third-party can open the app & - if they provide a return URL, we will
	///	display a "return to Ticket App" button on the ShowQR screen
	/// Docs: https://shrtm.nu/oc45
	private var thirdpartyTicketApp: (name: String, returnURL: URL)?
	
	/// If set, this should be handled at the first opportunity:
	private var unhandledUniversalLink: UniversalLink?
	
	// MARK: - Setup
	
	override init(navigationController: UINavigationController, window: UIWindow) {
		super.init(navigationController: navigationController, window: window)
		setupNotificationListeners()
	}
	
	// Designated starter method
	override func start() {
		
		handleOnboarding(
			onboardingFactory: onboardingFactory,
			forcedInformationFactory: HolderForcedInformationFactory()
		) {
			
			if let unhandledUniversalLink = unhandledUniversalLink {
				
				// Attempt to consume the universal link again:
				self.unhandledUniversalLink = nil // prevent potential infinite loops
				navigateToHolderStart {
					self.consume(universalLink: unhandledUniversalLink)
				}
				
			} else {
				
				// Start with the holder app
				navigateToHolderStart()
			}
		}
	}
	
	// MARK: - Teardown
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
	
	// MARK: - Listeners
	
	private func setupNotificationListeners() {
		
		// Prevent the thirdparty ticket feature persisting forever, let's clear it when the user minimises the app
		NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.thirdpartyTicketApp = nil
		}
	}
	
	// MARK: - Universal Links
	
	/// Try to consume the Activity
	/// returns: bool indicating whether it was possible.
	@discardableResult
	override func consume(universalLink: UniversalLink) -> Bool {
		switch universalLink {
			case .redeemHolderToken(let requestToken):
				
				// Need to handle two situations:
				// - the user is currently viewing onboarding/consent/force-information (and these should not be skipped)
				//   ⮑ in this situation, it is nice to keep hold of the UniversalLink and go straight to handling
				//      that after the user has completed these screens.
				// - the user is somewhere in the Holder app, and the nav stack can just be replaced.
				
				if onboardingManager.needsOnboarding || onboardingManager.needsConsent || forcedInformationManager.needsUpdating {
					self.unhandledUniversalLink = universalLink
				} else {
					// Do it on the next runloop, to standardise all the entry points to this function:
					DispatchQueue.main.async { [self] in
						navigateToTokenEntry(requestToken)
					}
				}
				return true
				
			case .redeemVaccinationAssessment(let requestToken):
				
				// Need to handle two situations:
				// - the user is currently viewing onboarding/consent/force-information (and these should not be skipped)
				//   ⮑ in this situation, it is nice to keep hold of the UniversalLink and go straight to handling
				//      that after the user has completed these screens.
				// - the user is somewhere in the Holder app, and the nav stack can just be replaced.
				
				if onboardingManager.needsOnboarding || onboardingManager.needsConsent || forcedInformationManager.needsUpdating {
					self.unhandledUniversalLink = universalLink
				} else {
					// Do it on the next runloop, to standardise all the entry points to this function:
					DispatchQueue.main.async { [self] in
						navigateToTokenEntry(requestToken, retrievalMode: .visitorPass)
					}
				}
				return true
				
			case .thirdPartyTicketApp(let returnURL):
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
					dashboardViewController.viewModel.selectTab = .domestic
				}
				return true
				
			case .tvsAuth(let returnURL):
				
				if let url = returnURL,
				   let appAuthState = UIApplication.shared.delegate as? AppAuthState,
				   let authorizationFlow = appAuthState.currentAuthorizationFlow,
				   authorizationFlow.resumeExternalUserAgentFlow(with: url) {
					appAuthState.currentAuthorizationFlow = nil
				}
				return true
			default:
				return false
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
	
	private func startEventFlowForPositiveTests() {
		
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithPositiveTest()
		
	}
	
	/// Navigate to the token entry scene
	func navigateToTokenEntry(_ token: RequestToken? = nil, retrievalMode: InputRetrievalCodeMode = .negativeTest) {
		
		let destination = TokenEntryViewController(
			viewModel: TokenEntryViewModel(
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
		
		let destination = ChooseProofTypeViewController(
			viewModel: ChooseProofTypeViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func navigateToAddPaperProof() {
		let coordinator = PaperProofCoordinator(delegate: self)
		let viewController = PaperProofStartViewController(viewModel: .init(coordinator: coordinator))
		coordinator.navigationController = navigationController
		navigationController.pushViewController(viewController, animated: true)
		startChildCoordinator(coordinator)
	}
	
	func navigateToAddVisitorPass() {
		let viewController = VisitorPassStartViewController(viewModel: VisitorPassStartViewModel(coordinator: self))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func navigateToAboutThisApp() {
		let viewController = AboutThisAppViewController(
			viewModel: AboutThisAppViewModel(
				coordinator: self,
				versionSupplier: versionSupplier,
				flavor: AppFlavor.flavor
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	private func navigateToDashboard(completion: @escaping () -> Void = {}) {
		
		let dashboardViewController = HolderDashboardViewController(
			viewModel: HolderDashboardViewModel(
				coordinator: self,
				datasource: HolderDashboardQRCardDatasource(),
				strippenRefresher: DashboardStrippenRefresher(
					minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: remoteConfigManager.storedConfiguration.credentialRenewalDays ?? 5,
					reachability: try? Reachability()
				),
				configurationNotificationManager: ConfigurationNotificationManager(userSettings: Current.userSettings),
				vaccinationAssessmentNotificationManager: VaccinationAssessmentNotificationManager(),
				versionSupplier: versionSupplier
			)
		)
		
		navigationController.setViewControllers([dashboardViewController], animated: true, completion: completion)
	}
	
	private func removeChildCoordinator() {
		
		guard let coordinator = childCoordinators.last else { return }
		removeChildCoordinator(coordinator)
	}
}

// MARK: - HolderCoordinatorDelegate

extension HolderCoordinator: HolderCoordinatorDelegate {
	
	// MARK: Navigation
	
	func navigateToHolderStart(completion: @escaping () -> Void = {}) {
		
		navigateToDashboard(completion: completion)
	}
	
	/// Navigate to enlarged QR
	private func navigateToShowQRs(_ greenCards: [GreenCard]) {
		
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
	
	private func navigateToChooseTestLocation() {
		
		let destination = ChooseTestLocationViewController(
			viewModel: ChooseTestLocationViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	/// Navigate to the start fo the holder flow
	func navigateBackToStart() {
		
		//		sidePanel?.selectedViewController?.dismiss(animated: true, completion: nil)
		navigationController.popToRootViewController(animated: true)
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
	
	func userWishesToOpenTheMenu() {
		
		let itemAddCertificate: NewMenuViewModel.Item = .row(title: L.holder_menu_listItem_addVaccinationOrTest_title(), icon: I.icon_menu_add()!, action: { [weak self] in
			self?.navigateToChooseQRCodeType()
		})
		
		let itemAddPaperCertificate: NewMenuViewModel.Item = .row(title: L.holderMenuPapercertificate(), icon: I.icon_menu_addpapercertificate()!, action: { [weak self] in
			self?.navigateToAddPaperProof()
		})
		
		let itemAddVisitorPass: NewMenuViewModel.Item = .row(title: L.holder_menu_visitorpass(), icon: I.icon_menu_addvisitorpass()!, action: { [weak self] in
			self?.navigateToAddVisitorPass()
		})
		
		let itemFAQ: NewMenuViewModel.Item = .row(title: L.holderMenuFaq(), icon: I.icon_menu_faq()!, action: { [weak self] in
			guard let faqUrl = URL(string: L.holderUrlFaq()) else { return }
			self?.openUrl(faqUrl, inApp: true)
		})
		
		let itemAboutThisApp: NewMenuViewModel.Item = .row(title: L.holderMenuAbout(), icon: I.icon_menu_aboutthisapp()!, action: { [weak self] in
			self?.navigateToAboutThisApp()
		})
		
		let items: [NewMenuViewModel.Item] = {
			
			if Current.featureFlagManager.isVisitorPassEnabled() {
				return [
					itemAddCertificate,
					.breaker,
					itemAddPaperCertificate,
					itemAddVisitorPass,
					.breaker,
					itemFAQ,
					itemAboutThisApp
				]
			} else {
				return [
					itemAddCertificate,
					itemAddPaperCertificate,
					.breaker,
					itemFAQ,
					itemAboutThisApp
				]
			}
		}()
		
		let viewController = NewMenuViewController(viewModel: NewMenuViewModel(items: items))
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesToMakeQRFromRemoteEvent(_ remoteEvent: RemoteEvent, originalMode: EventMode) {
		
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		eventCoordinator.startWithListTestEvents([remoteEvent], originalMode: originalMode)
	}
	
	func userWishesToCreateANegativeTestQR() {
		navigateToTokenEntry()
	}
	
	func userWishesToCreateAVisitorPass() {
		
		navigateToTokenEntry(retrievalMode: .visitorPass)
	}
	
	func userWishesToChooseTestLocation() {
		if Current.featureFlagManager.isGGDEnabled() {
			navigateToChooseTestLocation()
		} else {
			// Fallback when GGD is not available
			navigateToTokenEntry()
		}
	}
	
	func userHasNotBeenTested() {
		
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
	
	func userWishesToCreateANegativeTestQRFromGGD() {
		startEventFlowForNegativeTest()
	}
	
	func userWishesToCreateAVaccinationQR() {
		startEventFlowForVaccination()
	}
	
	func userWishesToCreateARecoveryQR() {
		startEventFlowForRecovery()
	}
	
	func userWishesToFetchPositiveTests() {
		startEventFlowForPositiveTests()
	}
	
	func userWishesToCreateAQR() {
		navigateToChooseQRCodeType()
	}
	
	func userDidScanRequestToken(requestToken: RequestToken) {
		navigateToTokenEntry(requestToken)
	}
	
	func userWishesMoreInfoAboutUnavailableQR(originType: QRCodeOriginType, currentRegion: QRCodeValidityRegion, availableRegion: QRCodeValidityRegion) {
		
		let title: String = .holderDashboardNotValidInThisRegionScreenTitle(originType: originType, currentRegion: currentRegion, availableRegion: availableRegion)
		let message: String = .holderDashboardNotValidInThisRegionScreenMessage(originType: originType, currentRegion: currentRegion, availableRegion: availableRegion)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false)
	}
	
	func userWishesMoreInfoAboutCompletingVaccinationAssessment() {
		
		let destination = VisitorPassCompleteCertificateViewController(viewModel: VisitorPassCompleteCertificateViewModel(coordinatorDelegate: self))
		navigationController.pushViewController(destination, animated: true)
	}
	
	func userWishesMoreInfoAboutVaccinationAssessmentInvalidOutsideNL() {
		let title: String = L.holder_notvalidinthisregionmodal_visitorpass_international_title()
		let message: String = L.holder_notvalidinthisregionmodal_visitorpass_international_body()
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}
	
	func userWishesMoreInfoAboutClockDeviation() {
		let title: String = L.holderClockDeviationDetectedTitle()
		let message: String = L.holderClockDeviationDetectedMessage(UIApplication.openSettingsURLString)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}
	
	func userWishesMoreInfoAboutTestOnlyValidFor3G() {
		let title: String = L.holder_my_overview_3g_test_validity_bottom_sheet_title()
		let message: String = L.holder_my_overview_3g_test_validity_bottom_sheet_body()
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}
	
	func userWishesMoreInfoAboutOutdatedConfig(validUntil: String) {
		let title: String = L.holderDashboardConfigIsAlmostOutOfDatePageTitle()
		let message: String = L.holderDashboardConfigIsAlmostOutOfDatePageMessage(validUntil)
		presentInformationPage(title: title, body: message, hideBodyForScreenCapture: false, openURLsInApp: true)
	}
	
	func userWishesMoreInfoAboutIncompleteDutchVaccination() {
		let viewModel = IncompleteDutchVaccinationViewModel(coordinatorDelegate: self)
		let viewController = IncompleteDutchVaccinationViewController(viewModel: viewModel)
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userWishesMoreInfoAboutExpiredDomesticVaccination() {
		
		let viewModel = ContentViewModel(
			coordinator: self,
			content: Content(
				title: L.holder_expiredDomesticVaccinationModal_title(),
				body: L.holder_expiredDomesticVaccinationModal_body(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holder_expiredDomesticVaccinationModal_button_addBoosterVaccination(),
				secondaryAction: { [weak self] in
					guard let self = self else { return }
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
		
		let viewController = ContentViewController(viewModel: viewModel)
		presentAsBottomSheet(viewController)
	}
	
	func userWishesToViewQRs(greenCardObjectIDs: [NSManagedObjectID]) {
		
		let result = GreenCardModel.fetchByIds(objectIDs: greenCardObjectIDs)
		switch result {
			case let .success(greenCards):
				if greenCards.isEmpty {
					showAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .noGreenCardsAvailable))
				} else {
					navigateToShowQRs(greenCards)
				}
			case .failure:
				showAlertWithErrorCode(ErrorCode(flow: .qr, step: .showQR, clientCode: .coreDataFetchError))
		}
	}
	
	private func showAlertWithErrorCode(_ code: ErrorCode) {
		
		let alertController = UIAlertController(
			title: L.generalErrorTitle(),
			message: L.generalErrorTechnicalCustom("\(code)"),
			preferredStyle: .alert
		)
		
		alertController.addAction(.init(title: L.generalOk(), style: .default, handler: nil))
		navigationController.present(alertController, animated: true, completion: nil)
	}
	
	func userWishesToLaunchThirdPartyTicketApp() {
		guard let thirdpartyTicketApp = thirdpartyTicketApp else { return }
		openUrl(thirdpartyTicketApp.returnURL, inApp: false)
	}
	
	func displayError(content: Content, backAction: @escaping () -> Void) {
		
		let viewController = ErrorStateViewController(
			viewModel: ErrorStateViewModel(
				content: content,
				backAction: backAction
			)
		)
		navigationController.pushViewController(viewController, animated: false)
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
		
		/// The user cancelled the flow. Go back one page.
		removeChildCoordinator()
		navigationController.popViewController(animated: true)
	}
	
	func eventFlowDidCancelFromBackSwipe() {
		
		/// The user cancelled the flow from back swipe.
		removeChildCoordinator()
	}
}

extension HolderCoordinator: PaperProofFlowDelegate {
	
	func addPaperProofFlowDidFinish() {
		
		removeChildCoordinator()
		navigateToDashboard()
	}
	
	func switchToAddRegularProof() {
		
		removeChildCoordinator()
		navigateToChooseQRCodeType()
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {
	
	static let noGreenCardsAvailable = ErrorCode.ClientCode(value: "061")
	static let coreDataFetchError = ErrorCode.ClientCode(value: "062")
}
