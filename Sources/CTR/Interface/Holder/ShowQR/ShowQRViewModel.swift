/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

protocol ShowQRDatasourceProtocol {

	var items: [ShowQRItem] { get }

	init(greenCards: [GreenCard])

	func getGreenCardForIndex(_ index: Int) -> GreenCard?

	func shouldGreenCardBeHidden(_ greenCard: GreenCard) -> Bool
}

class ShowQRDatasource: ShowQRDatasourceProtocol, Logging {

	weak var cryptoManager: CryptoManaging? = Services.cryptoManager

	static let days: TimeInterval = 2

	private(set) var items = [ShowQRItem]()

	private var cardsWithSortedOrigins = [(greenCard: GreenCard, origins: [Origin])]()

	private var highestFullyVaccinatedGreenCard: (greenCard: GreenCard, doseNumber: Int, totalDose: Int)?

	required init(greenCards: [GreenCard]) {

		self.cardsWithSortedOrigins = greenCards
			.compactMap { greenCard in
				// map on greenCard, sorted origins.
				greenCard.castOrigins().map { (greenCard: greenCard, origins: $0.sorted { lhsOrigin, rhsOrigin in
					// Sort the origins ascending
					lhsOrigin.eventDate ?? .distantFuture < rhsOrigin.eventDate ?? .distantFuture
				}) }
			}
			.sorted { lhs, rhs in
				// Sort the greenCards ascending (on the first origin)
				if let lhsEventDate = lhs.origins.first?.eventDate, let rhsEventDate = rhs.origins.first?.eventDate {
					return lhsEventDate < rhsEventDate
				}
				return false
			}
		self.items = cardsWithSortedOrigins
			.map { ShowQRItem(greenCard: $0.greenCard) }

		self.highestFullyVaccinatedGreenCard = findHighestFullyVaccinatedGreenCard()
	}

	func getGreenCardForIndex(_ index: Int) -> GreenCard? {

		guard index < items.count else {
			return nil
		}

		return items[index].greenCard
	}

	private func findHighestFullyVaccinatedGreenCard() -> (greenCard: GreenCard, doseNumber: Int, totalDose: Int)? {

		let vaccinationGreenCardsWithAttributes: [(greenCard: GreenCard, attributes: EuCredentialAttributes)] = cardsWithSortedOrigins
		// only international
			.filter { $0.greenCard.type == GreenCardType.eu.rawValue }
		// only with attributes
			.compactMap { cardsWithSortedOrigin in
				if let credential = cardsWithSortedOrigin.greenCard.getActiveCredential(),
				   let data = credential.data,
				   let euCredentialAttributes = self.cryptoManager?.readEuCredentials(data) {

					return (cardsWithSortedOrigin.greenCard, attributes: euCredentialAttributes)
				}
				return nil
			}
		// only with vaccinations
			.filter { $0.attributes.digitalCovidCertificate.vaccinations?.first != nil }

		// Map with dosage and date information
		let greencardsWithDateAndDosage: [(greenCard: GreenCard, date: Date, doseNumber: Int, totalDose: Int)] = vaccinationGreenCardsWithAttributes
			.compactMap {
				if let euVaccination = $0.attributes.digitalCovidCertificate.vaccinations?.first,
				   let eventDate = Formatter.getDateFrom(dateString8601: euVaccination.dateOfVaccination),
				   let doseNumber = euVaccination.doseNumber,
				   let totalDose = euVaccination.totalDose {

					return ($0.greenCard, date: eventDate, doseNumber: doseNumber, totalDose: totalDose)
				}
				return nil
			}

		// Get the ones that are fully vaccinated
		let fullyVaccinated = greencardsWithDateAndDosage.filter { $0.doseNumber == $0.totalDose }.sorted { lhs, rhs in lhs.totalDose > rhs.totalDose }

		let oldEnough = fullyVaccinated.filter {
			return $0.date < Date().addingTimeInterval(ShowQRDatasource.days * 24 * 60 * 60 * -1)
		}

		if let topDog = oldEnough.first {
			logDebug("topDog: \(topDog.date) \(topDog.doseNumber) \(topDog.totalDose)")
			return (topDog.greenCard, topDog.doseNumber, topDog.totalDose)
		}
		return nil
	}

	func shouldGreenCardBeHidden(_ greenCard: GreenCard) -> Bool {

		guard self.items.count > 1 else {
			return false
		}

		guard greenCard.type == GreenCardType.eu.rawValue,
			let highestFullyVaccinatedGreenCard = highestFullyVaccinatedGreenCard,
			let credential = greenCard.getActiveCredential(),
			let data = credential.data,
			let euCredentialAttributes = self.cryptoManager?.readEuCredentials(data),
			let euVaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first,
			let doseNumber = euVaccination.doseNumber,
			let totalDose = euVaccination.totalDose else {
			return false
		}

		logDebug("We are \(doseNumber) / \(totalDose) : \(highestFullyVaccinatedGreenCard.totalDose)")
		return doseNumber < highestFullyVaccinatedGreenCard.totalDose
	}
}

class ShowQRViewModel: Logging {

	// MARK: - private variables

	weak private var coordinator: HolderCoordinatorDelegate?

	weak private var cryptoManager: CryptoManaging? = Services.cryptoManager
	weak private var remoteConfigManager: RemoteConfigManaging? = Services.remoteConfigManager
	private var mappingManager: MappingManaging? = Services.mappingManager

	var dataSource: ShowQRDatasourceProtocol

	private var currentPage: Int {
		didSet {
			logInfo("current page set to \(currentPage)")
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

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(
		coordinator: HolderCoordinatorDelegate,
		greenCards: [GreenCard],
		thirdPartyTicketAppName: String?
	) {

		self.coordinator = coordinator
		self.dataSource = ShowQRDatasource(greenCards: greenCards)
		self.items = dataSource.items
		self.currentPage = 0
		handleVaccinationDosageInformation()

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
					relevancyInformation = L.holderShowqrOvervaccinated("\(totalDose)", "\(totalDose)")
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

			coordinator?.presentInformationPage(
				title: L.holderShowqrDomesticAboutTitle(),
				body: L.holderShowqrDomesticAboutMessage(identity),
				hideBodyForScreenCapture: true,
				openURLsInApp: true
			)
		}
	}

	private func showInternationalDetails(_ data: Data) {

		if let euCredentialAttributes = cryptoManager?.readEuCredentials(data) {

			logVerbose("euCredentialAttributes: \(euCredentialAttributes)")

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

		var dosage: String?
		var title: String?
		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
			dosage = "\(doseNumber) / \(totalDose)"
			title = L.holderShowqrEuAboutVaccinationTitle("\(doseNumber)", "\(totalDose)")
		}

		let vaccineType = remoteConfigManager?.getConfiguration().getTypeMapping(
			vaccination.vaccineOrProphylaxis) ?? vaccination.vaccineOrProphylaxis
		let vaccineBrand = remoteConfigManager?.getConfiguration().getBrandMapping(
			vaccination.medicalProduct) ?? vaccination.medicalProduct
		let vaccineManufacturer = remoteConfigManager?.getConfiguration().getVaccinationManufacturerMapping(
			vaccination.marketingAuthorizationHolder) ?? vaccination.marketingAuthorizationHolder

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)

		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(printDateFormatter.string) ?? vaccination.dateOfVaccination

		let details: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsVaccination.name, value: name),
			DCCQRDetails(field: DCCQRDetailsVaccination.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsVaccination.pathogen, value: L.holderShowqrEuAboutVaccinationPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineBrand, value: vaccineBrand),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineType, value: vaccineType),
			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineManufacturer, value: vaccineManufacturer),
			DCCQRDetails(field: DCCQRDetailsVaccination.dosage, value: dosage),
			DCCQRDetails(field: DCCQRDetailsVaccination.date, value: formattedVaccinationDate),
			DCCQRDetails(field: DCCQRDetailsVaccination.country, value: mappingManager?.getDisplayCountry(vaccination.country)),
			DCCQRDetails(field: DCCQRDetailsVaccination.issuer, value: mappingManager?.getDisplayIssuer(vaccination.issuer)),
			DCCQRDetails(field: DCCQRDetailsVaccination.uniqueIdentifer, value: vaccination.certificateIdentifier)
		]

		coordinator?.presentDCCQRDetails(
			title: title ?? L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutVaccinationDescription(),
			details: details,
			dateInformation: L.holderShowqrEuAboutVaccinationDateinformation()
		)
	}

	private func showTestDetails(euCredentialAttributes: EuCredentialAttributes, test: EuCredentialAttributes.TestEntry) {

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)

		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(printDateTimeFormatter.string) ?? test.sampleDate

		let testType = remoteConfigManager?.getConfiguration().getTestTypeMapping(
			test.typeOfTest) ?? test.typeOfTest

		let manufacturer = remoteConfigManager?.getConfiguration().getTestManufacturerMapping(
			test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")

		var testResult = test.testResult
		if test.testResult == "260415000" {
			testResult = L.holderShowqrEuAboutTestNegative()
		}
		if test.testResult == "260373001" {
			testResult = L.holderShowqrEuAboutTestPostive()
		}

		let details: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsTest.name, value: name),
			DCCQRDetails(field: DCCQRDetailsTest.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsTest.pathogen, value: L.holderShowqrEuAboutTestPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsTest.testType, value: testType),
			DCCQRDetails(field: DCCQRDetailsTest.testName, value: test.name),
			DCCQRDetails(field: DCCQRDetailsTest.date, value: formattedTestDate),
			DCCQRDetails(field: DCCQRDetailsTest.result, value: testResult),
			DCCQRDetails(field: DCCQRDetailsTest.facility, value: mappingManager?.getDisplayFacility(test.testCenter)),
			DCCQRDetails(field: DCCQRDetailsTest.manufacturer, value: manufacturer),
			DCCQRDetails(field: DCCQRDetailsTest.country, value: mappingManager?.getDisplayCountry(test.country)),
			DCCQRDetails(field: DCCQRDetailsTest.issuer, value: mappingManager?.getDisplayIssuer(test.issuer)),
			DCCQRDetails(field: DCCQRDetailsTest.uniqueIdentifer, value: test.certificateIdentifier)
		]

		coordinator?.presentDCCQRDetails(
			title: L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutTestDescription(),
			details: details,
			dateInformation: L.holderShowqrEuAboutTestDateinformation()
		)
	}

	private func showRecoveryDetails(euCredentialAttributes: EuCredentialAttributes, recovery: EuCredentialAttributes.RecoveryEntry) {

		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)

		let formattedFirstPostiveDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(printDateFormatter.string) ?? recovery.firstPositiveTestDate
		let formattedValidFromDate: String = Formatter.getDateFrom(dateString8601: recovery.validFrom)
			.map(printDateFormatter.string) ?? recovery.validFrom
		let formattedValidUntilDate: String = Formatter.getDateFrom(dateString8601: recovery.expiresAt)
			.map(printDateFormatter.string) ?? recovery.expiresAt

		let details: [DCCQRDetails] = [
			DCCQRDetails(field: DCCQRDetailsRecovery.name, value: name),
			DCCQRDetails(field: DCCQRDetailsRecovery.dateOfBirth, value: formattedBirthDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.pathogen, value: L.holderShowqrEuAboutRecoveryPathogenvalue()),
			DCCQRDetails(field: DCCQRDetailsRecovery.date, value: formattedFirstPostiveDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.country, value: mappingManager?.getDisplayCountry(recovery.country)),
			DCCQRDetails(field: DCCQRDetailsRecovery.issuer, value: mappingManager?.getDisplayIssuer(recovery.issuer)),
			DCCQRDetails(field: DCCQRDetailsRecovery.validFrom, value: formattedValidFromDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.validUntil, value: formattedValidUntilDate),
			DCCQRDetails(field: DCCQRDetailsRecovery.uniqueIdentifer, value: recovery.certificateIdentifier)
		]

		coordinator?.presentDCCQRDetails(
			title: L.holderShowqrEuAboutTitle(),
			description: L.holderShowqrEuAboutRecoveryDescription(),
			details: details,
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

	private lazy var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd-MM-yyyy"
		return dateFormatter
	}()

	private lazy var printDateTimeFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()
}

// MARK: - ShowQRItemViewModelDelegate

extension ShowQRViewModel: ShowQRItemViewModelDelegate {

	func itemIsNotValid() {
		coordinator?.navigateBackToStart()
	}
}

private extension EuCredentialAttributes {

	func dateOfBirth(_ dateFormatter: DateFormatter) -> String {
		return Formatter
			.getDateFrom(dateString8601: digitalCovidCertificate.dateOfBirth)
			.map(dateFormatter.string)
		?? digitalCovidCertificate.dateOfBirth
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
