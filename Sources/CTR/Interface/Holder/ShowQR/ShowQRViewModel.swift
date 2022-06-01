/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

class ShowQRViewModel {

	// MARK: - Private types
	final private class ScreenBrightnessManager {
		
		private let initialBrightness: CGFloat
		private var latestAnimation: UUID?
		private let notificationCenter: NotificationCenterProtocol
		
		init(initialBrightness: CGFloat = UIScreen.main.brightness, notificationCenter: NotificationCenterProtocol) {
			self.initialBrightness = initialBrightness
			self.notificationCenter = notificationCenter
			
			notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
				self?.animateToFullBrightness()
			}
			notificationCenter.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { [weak self] _ in
				guard let self = self else { return }
				
				// Immediately back to initial brightness as we left the app:
				UIScreen.main.brightness = self.initialBrightness
			}
		}
		
		func animateToFullBrightness() {

			let brightnessStep: CGFloat = 0.03
			var iterationsPermitted = 1 / brightnessStep // a basic guard against fighting with another (unknown, external) brightness loop to change brightness (preventing infinite loop)
			let animationID = UUID()
			latestAnimation = animationID // if we're no longer the latest animation, abort the loop.
			Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
				guard iterationsPermitted > 0,
					self.latestAnimation == animationID,
					UIScreen.main.brightness < 1
				else { timer.invalidate(); return }
				
				iterationsPermitted -= 1
				UIScreen.main.brightness += brightnessStep
			}
		}
		
		func animateToInitialBrightness() {
			guard (0...1).contains(initialBrightness) else {
				UIScreen.main.brightness = 1
				return
			}
			
			let brightnessStep: CGFloat = 0.03
			var iterationsPermitted = 1 / brightnessStep // a basic guard against fighting with another (unknown, external) brightness loop to change brightness (preventing infinite loop)
			let animationID = UUID()
			latestAnimation = animationID // if we're no longer the latest animation, abort the loop.
			Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
				guard iterationsPermitted > 0,
					self.latestAnimation == animationID,
					self.initialBrightness < UIScreen.main.brightness,
					UIScreen.main.brightness > brightnessStep
				else { timer.invalidate(); return }
				
				iterationsPermitted -= 1
				UIScreen.main.brightness -= brightnessStep
			}
		}
	}

	// MARK: - private variables

	weak private var coordinator: HolderCoordinatorDelegate?

	weak private var cryptoManager: CryptoManaging? = Current.cryptoManager
	weak private var remoteConfigManager: RemoteConfigManaging? = Current.remoteConfigManager
	private var mappingManager: MappingManaging? = Current.mappingManager
	private let notificationCenter: NotificationCenterProtocol
	private let screenBrightnessManager: ScreenBrightnessManager
	private let disclosurePolicy: DisclosurePolicy?

	private var dataSource: ShowQRDatasourceProtocol

	private var currentPage: Int {
		didSet {
			Current.logHandler.logVerbose("current page set to \(currentPage)")
			displayQRInformation()
		}
	}

	// MARK: - Bindable

	@Bindable private(set) var title: String?
	
	@Bindable private(set) var dosage: String?

	@Bindable private(set) var relevancyInformation: String?

	@Bindable private(set) var infoButtonAccessibility: String?

	@Bindable private(set) var showInternationalAnimation: Bool = false

	@Bindable private(set) var thirdPartyTicketAppButtonTitle: String?

	@Bindable private(set) var items = [ShowQRItem]()

	@Bindable private(set) var startingPage: Int
	
	@Bindable private(set) var pageButtonAccessibility: (previous: String, next: String)?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(
		coordinator: HolderCoordinatorDelegate,
		greenCards: [GreenCard],
		disclosurePolicy: DisclosurePolicy?,
		thirdPartyTicketAppName: String?,
		notificationCenter: NotificationCenterProtocol = NotificationCenter.default
	) {

		self.coordinator = coordinator
		self.screenBrightnessManager = ScreenBrightnessManager(notificationCenter: notificationCenter)
		self.dataSource = ShowQRDatasource(greenCards: greenCards, disclosurePolicy: disclosurePolicy)
		self.notificationCenter = notificationCenter
		self.items = dataSource.items
		let mostRelevantPage = dataSource.getIndexForMostRelevantGreenCard()
		self.startingPage = mostRelevantPage
		self.currentPage = mostRelevantPage
		self.disclosurePolicy = disclosurePolicy

		displayQRInformation()
		setupContent(greenCards: greenCards, thirdPartyTicketAppName: thirdPartyTicketAppName)
		setupListeners()
	}

	deinit {
		notificationCenter.removeObserver(self)
	}

	private func setupContent(greenCards: [GreenCard], thirdPartyTicketAppName: String?) {

		if let greenCard = greenCards.first {
			if greenCard.getType() == GreenCardType.domestic {
				title = L.holderShowqrDomesticTitle()
				infoButtonAccessibility = L.holder_showqr_domestic_accessibility_button_details()
				showInternationalAnimation = false
				thirdPartyTicketAppButtonTitle = thirdPartyTicketAppName.map { L.holderDashboardQrBackToThirdPartyApp($0) }
			} else if greenCard.getType() == GreenCardType.eu {
				title = L.holderShowqrEuTitle()
				infoButtonAccessibility = L.holder_showqr_international_accessibility_button_details()
				showInternationalAnimation = true
			}
		}
		
		pageButtonAccessibility = (L.holderShowqrPreviousbutton(), L.holderShowqrNextbutton())
	}

	private func setupListeners() {

		// When the app is backgrounded, the holdercoordinator clears the reference to the third-party ticket app
		// so we should hide that from the UI on this screen too.
		notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.thirdPartyTicketAppButtonTitle = nil
		}
	}

	func viewWillAppear() {
		screenBrightnessManager.animateToFullBrightness()
	}
	
	func viewWillDisappear() {
		screenBrightnessManager.animateToInitialBrightness()
	}
	
	func userDidChangeCurrentPage(toPageIndex pageIndex: Int) {
		currentPage = pageIndex
	}

	func didTapThirdPartyAppButton() {

		coordinator?.userWishesToLaunchThirdPartyTicketApp()
	}

	func showMoreInformation() {
		
		guard let greenCard = dataSource.getGreenCardForIndex(currentPage) else {
			return
		}
		
		if greenCard.getType() == GreenCardType.domestic {
			guard let credentialData = greenCard.getActiveDomesticCredential()?.data else { return }
			
			showDomesticDetails(credentialData)
		} else if greenCard.getType() == GreenCardType.eu {
			guard let credentialData = greenCard.getLatestInternationalCredential()?.data else { return }
			
			if let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData) {
				showInternationalDetails(euCredentialAttributes)
			}
		}
	}

	private func handleVaccinationDosageInformation(_ euVaccination: EuCredentialAttributes.Vaccination) {
		
		if let doseNumber = euVaccination.doseNumber,
		   let totalDose = euVaccination.totalDose {
			dosage = L.holderShowqrQrEuVaccinecertificatedoses("\(doseNumber)", "\(totalDose)")
		}
	}
	
	private func displayRelevancy(_ greenCard: GreenCard) {
		
		if dataSource.isVaccinationExpired(greenCard) {
			relevancyInformation = L.holder_showQR_label_expiredVaccination()
		} else  if dataSource.isDosenumberSmallerThanTotalDose(greenCard) {
			relevancyInformation = L.holder_showQR_label_newerQRAvailable()
		} else {
			relevancyInformation = nil
		}
	}
	
	private func displayQRInformation() {
		
		guard let greenCard = dataSource.getGreenCardForIndex(currentPage),
			  greenCard.getType() == GreenCardType.eu,
			  let euCredentialAttributes = dataSource.getEuCredentialAttributes(greenCard),
			  let euVaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first else {
			return
		}
		handleVaccinationDosageInformation(euVaccination)
		displayRelevancy(greenCard)
	}

	private func showDomesticDetails(_ data: Data) {
		
		if let domesticCredentialAttributes = cryptoManager?.readDomesticCredentials(data) {
			coordinator?.presentInformationPage(
				title: L.holderShowqrDomesticAboutTitle(),
				body: getDomesticDetailsBody(domesticCredentialAttributes),
				hideBodyForScreenCapture: true,
				openURLsInApp: true
			)
		} else {
			Current.logHandler.logError("Can't read the domestic credentials")
		}
	}
	
	private func getDomesticDetailsBody(_ domesticCredentialAttributes: DomesticCredentialAttributes) -> String {
		
		let identity = domesticCredentialAttributes
			.mapIdentity(months: String.shortMonths)
			.map({ $0.isEmpty ? "_" : $0 })
			.joined(separator: " ")
		
		if disclosurePolicy == .policy1G {
			return L.holder_qr_explanation_description_domestic_1G(identity)
		}
		return L.holderShowqrDomesticAboutMessage(identity)
	}

	private func showInternationalDetails(_ euCredentialAttributes: EuCredentialAttributes) {
		
		if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
			showVaccinationDetails(euCredentialAttributes: euCredentialAttributes, vaccination: vaccination)
		} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
			showTestDetails(euCredentialAttributes: euCredentialAttributes, test: test)
		} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
			showRecoveryDetails(euCredentialAttributes: euCredentialAttributes, recovery: recovery)
		}
	}

	private func showVaccinationDetails(euCredentialAttributes: EuCredentialAttributes, vaccination: EuCredentialAttributes.Vaccination) {

		var title: String?
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			title = L.holderShowqrEuAboutVaccinationTitle("\(doseNumber)", "\(totalDose)")
		}
		coordinator?.presentDCCQRDetails(
			title: title ?? L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutVaccinationDescription(),
			details: VaccinationQRDetailsGenerator.getDetails(euCredentialAttributes: euCredentialAttributes, vaccination: vaccination),
			dateInformation: L.holderShowqrEuAboutVaccinationDateinformation()
		)
	}

	private func showTestDetails(euCredentialAttributes: EuCredentialAttributes, test: EuCredentialAttributes.TestEntry) {

		coordinator?.presentDCCQRDetails(
			title: L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutTestDescription(),
			details: NegativeTestQRDetailsGenerator.getDetails(euCredentialAttributes: euCredentialAttributes, test: test),
			dateInformation: L.holderShowqrEuAboutTestDateinformation()
		)
	}

	private func showRecoveryDetails(euCredentialAttributes: EuCredentialAttributes, recovery: EuCredentialAttributes.RecoveryEntry) {

		coordinator?.presentDCCQRDetails(
			title: L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutRecoveryDescription(),
			details: RecoveryQRDetailsGenerator.getDetails(euCredentialAttributes: euCredentialAttributes, recovery: recovery),
			dateInformation: L.holderShowqrEuAboutRecoveryDateinformation()
		)
	}

	func showQRItemViewController(forItem item: ShowQRItem) -> ShowQRItemViewController {

		let viewController = ShowQRItemViewController(
			viewModel: ShowQRItemViewModel(
				delegate: self,
				greenCard: item.greenCard,
				disclosurePolicy: item.policy,
				qrShouldInitiallyBeHidden: dataSource.shouldGreenCardBeHidden(item.greenCard)
			)
		)
		viewController.isAccessibilityElement = true
		return viewController
	}
}

// MARK: - ShowQRItemViewModelDelegate

extension ShowQRViewModel: ShowQRItemViewModelDelegate {

	func itemIsNotValid() {
		coordinator?.navigateBackToStart()
	}
}
