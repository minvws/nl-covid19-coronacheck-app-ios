/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

class ShowQRViewModel: Logging {

	// MARK: - private variables

	weak private var coordinator: HolderCoordinatorDelegate?

	weak private var cryptoManager: CryptoManaging? = Services.cryptoManager
	weak private var remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager
	private var mappingManager: MappingManaging? = Services.mappingManager
	private let notificationCenter: NotificationCenterProtocol

	private var previousBrightness: CGFloat?

	private var dataSource: ShowQRDatasourceProtocol

	private var currentPage: Int {
		didSet {
			logVerbose("current page set to \(currentPage)")
			handleVaccinationDosageInformation()
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
		thirdPartyTicketAppName: String?,
		notificationCenter: NotificationCenterProtocol = NotificationCenter.default
	) {

		self.coordinator = coordinator
		self.dataSource = ShowQRDatasource(
			greenCards: greenCards,
			internationalQRRelevancyDays: TimeInterval(remoteConfigManager?.storedConfiguration.internationalQRRelevancyDays ?? 28)
		)
		self.notificationCenter = notificationCenter
		self.items = dataSource.items
		let mostRelevantPage = dataSource.getIndexForMostRelevantGreenCard()
		self.startingPage = mostRelevantPage
		self.currentPage = mostRelevantPage

		handleVaccinationDosageInformation()
		setupContent(greenCards: greenCards, thirdPartyTicketAppName: thirdPartyTicketAppName)
		setupListeners()
	}

	deinit {
		notificationCenter.removeObserver(self)
	}

	private func setupContent(greenCards: [GreenCard], thirdPartyTicketAppName: String?) {

		if let greenCard = greenCards.first {
			if greenCard.type == GreenCardType.domestic.rawValue {
				title = L.holderShowqrDomesticTitle()
				infoButtonAccessibility = L.holderShowqrDomesticAboutTitle()
				showInternationalAnimation = false
				thirdPartyTicketAppButtonTitle = thirdPartyTicketAppName.map { L.holderDashboardQrBackToThirdPartyApp($0) }
			} else if greenCard.type == GreenCardType.eu.rawValue {
				title = L.holderShowqrEuTitle()
				infoButtonAccessibility = L.holderShowqrEuAboutTitle()
				showInternationalAnimation = true
			}
		}
		
		pageButtonAccessibility = (L.holderShowqrPreviousbutton(), L.holderShowqrNextbutton())
	}

	private func setupListeners() {

		notificationCenter.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
			self?.setBrightness()
		}

		// When the app is backgrounded, the holdercoordinator clears the reference to the third-party ticket app
		// so we should hide that from the UI on this screen too.
		notificationCenter.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { [weak self] _ in
			self?.thirdPartyTicketAppButtonTitle = nil
		}
	}

	/// Adjust the brightness
	/// - Parameter reset: True if we reset to previous value
	func setBrightness(reset: Bool = false) {

		let currentBrightness = UIScreen.main.brightness
		if currentBrightness < 1 {
			previousBrightness = currentBrightness
		}

		UIScreen.main.brightness = reset ? previousBrightness ?? 1 : 1
	}

	func userDidChangeCurrentPage(toPageIndex pageIndex: Int) {
		currentPage = pageIndex
	}

	func didTapThirdPartyAppButton() {

		coordinator?.userWishesToLaunchThirdPartyTicketApp()
	}

	func showMoreInformation() {

		guard let greenCard = dataSource.getGreenCardForIndex(currentPage),
			  let credential = greenCard.getActiveCredential(),
			  let data = credential.data else {
				return
		}

		if greenCard.type == GreenCardType.domestic.rawValue {
			showDomesticDetails(data)
		} else if greenCard.type == GreenCardType.eu.rawValue {
			showInternationalDetails(data)
		}
	}

	func handleVaccinationDosageInformation() {

		guard let greenCard = dataSource.getGreenCardForIndex(currentPage),
			  let credential = greenCard.getActiveCredential(),
			  let data = credential.data else {
			return
		}

		if greenCard.type == GreenCardType.eu.rawValue {
			if let euCredentialAttributes = self.cryptoManager?.readEuCredentials(data),
			   let euVaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first,
			   let doseNumber = euVaccination.doseNumber,
			   let totalDose = euVaccination.totalDose {
				dosage = L.holderShowqrQrEuVaccinecertificatedoses("\(doseNumber)", "\(totalDose)")
				if euVaccination.isOverVaccinated {
					relevancyInformation = L.holderShowqrOvervaccinated()
				} else if dataSource.shouldGreenCardBeHidden(greenCard) {
					relevancyInformation = L.holderShowqrNotneeded()
				} else {
					relevancyInformation = nil
				}
			}
		}
	}

	private func showDomesticDetails(_ data: Data) {
		
		if let domesticCredentialAttributes = cryptoManager?.readDomesticCredentials(data) {
			let identity = domesticCredentialAttributes
				.mapIdentity(months: String.shortMonths)
				.map({ $0.isEmpty ? "_" : $0 })
				.joined(separator: " ")
			
			let body: String = Services.featureFlagManager.isVerificationPolicyEnabled() ? L.qr_explanation_description_domestic_2G(identity) : L.holderShowqrDomesticAboutMessage(identity)
			
			coordinator?.presentInformationPage(
				title: L.holderShowqrDomesticAboutTitle(),
				body: body,
				hideBodyForScreenCapture: true,
				openURLsInApp: true
			)
		}
	}

	private func showInternationalDetails(_ data: Data) {

		if let euCredentialAttributes = cryptoManager?.readEuCredentials(data) {
			if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
				showVaccinationDetails(euCredentialAttributes: euCredentialAttributes, vaccination: vaccination)
			} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
				showTestDetails(euCredentialAttributes: euCredentialAttributes, test: test)
			} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
				showRecoveryDetails(euCredentialAttributes: euCredentialAttributes, recovery: recovery)
			}
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

private extension EuCredentialAttributes.Vaccination {

	var isOverVaccinated: Bool {
		guard let doseNumber = doseNumber, let totalDose = totalDose else {
			return false
		}
		return doseNumber > totalDose
	}
}
