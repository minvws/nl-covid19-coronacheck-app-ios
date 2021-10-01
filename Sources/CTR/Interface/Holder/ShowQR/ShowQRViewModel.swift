/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

class ShowQRViewModel: Logging {

	private var greenCards = [GreenCard]()

	weak private var coordinator: HolderCoordinatorDelegate?

	@Bindable private(set) var title: String?

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
		self.greenCards = greenCards

		self.items = greenCards.map { return ShowQRItem(greenCard: $0) }

//		if greenCard.type == GreenCardType.domestic.rawValue {
//			title = L.holderShowqrDomesticTitle()
//			qrAccessibility = L.holderShowqrDomesticQrTitle()
//			infoButtonAccessibility = L.holderShowqrDomesticAboutTitle()
//			showInternationalAnimation = false
			thirdPartyTicketAppButtonTitle = thirdPartyTicketAppName.map { L.holderDashboardQrBackToThirdPartyApp($0) }
//		} else if greenCard.type == GreenCardType.eu.rawValue {
			title = L.holderShowqrEuTitle()
			infoButtonAccessibility = L.holderShowqrEuAboutTitle()
			showInternationalAnimation = true
//		}
	}

	func didTapThirdPartyAppButton() {
		coordinator?.userWishesToLaunchThirdPartyTicketApp()
	}

	func showMoreInformation() {
		logDebug("Todo")
	}

//	func showMoreInformation() {
//
//		guard let credential = greenCard.getActiveCredential(), let data = credential.data else { return }
//
//		if greenCard.type == GreenCardType.domestic.rawValue {
//			if let domesticCredentialAttributes = cryptoManager?.readDomesticCredentials(data) {
//				let identity = domesticCredentialAttributes
//					.mapIdentity(months: String.shortMonths)
//					.map({ $0.isEmpty ? "_" : $0 })
//					.joined(separator: " ")
//
//				coordinator?.presentInformationPage(
//					title: L.holderShowqrDomesticAboutTitle(),
//					body: L.holderShowqrDomesticAboutMessage(identity),
//					hideBodyForScreenCapture: true,
//					openURLsInApp: true
//				)
//			}
//		} else if greenCard.type == GreenCardType.eu.rawValue {
//			if let euCredentialAttributes = cryptoManager?.readEuCredentials(data) {
//
//				logVerbose("euCredentialAttributes: \(euCredentialAttributes)")
//
//				if let vaccination = euCredentialAttributes.digitalCovidCertificate.vaccinations?.first {
//					showVaccinationDetails(euCredentialAttributes: euCredentialAttributes, vaccination: vaccination)
//				} else if let test = euCredentialAttributes.digitalCovidCertificate.tests?.first {
//					showTestDetails(euCredentialAttributes: euCredentialAttributes, test: test)
//				} else if let recovery = euCredentialAttributes.digitalCovidCertificate.recoveries?.first {
//					showRecoveryDetails(euCredentialAttributes: euCredentialAttributes, recovery: recovery)
//				}
//			}
//		}
//	}
//
//	private func showVaccinationDetails(euCredentialAttributes: EuCredentialAttributes, vaccination: EuCredentialAttributes.Vaccination) {
//
//		var dosage: String?
//		if let doseNumber = vaccination.doseNumber, let totalDose = vaccination.totalDose, doseNumber > 0, totalDose > 0 {
//			dosage = "\(doseNumber) / \(totalDose)"
//		}
//
//		let vaccineType = remoteConfigManager?.getConfiguration().getTypeMapping(
//			vaccination.vaccineOrProphylaxis) ?? vaccination.vaccineOrProphylaxis
//		let vaccineBrand = remoteConfigManager?.getConfiguration().getBrandMapping(
//			vaccination.medicalProduct) ?? vaccination.medicalProduct
//		let vaccineManufacturer = remoteConfigManager?.getConfiguration().getVaccinationManufacturerMapping(
//			vaccination.marketingAuthorizationHolder) ?? vaccination.marketingAuthorizationHolder
//
//		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
//		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)
//
//		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
//			.map(printDateFormatter.string) ?? vaccination.dateOfVaccination
//
//		let issuer = getDisplayIssuer(vaccination.issuer)
//		let country = getDisplayCountry(vaccination.country)
//
//		let details: [DCCQRDetails] = [
//			DCCQRDetails(field: DCCQRDetailsVaccination.name, value: name),
//			DCCQRDetails(field: DCCQRDetailsVaccination.dateOfBirth, value: formattedBirthDate),
//			DCCQRDetails(field: DCCQRDetailsVaccination.pathogen, value: L.holderShowqrEuAboutVaccinationPathogenvalue()),
//			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineBrand, value: vaccineBrand),
//			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineType, value: vaccineType),
//			DCCQRDetails(field: DCCQRDetailsVaccination.vaccineManufacturer, value: vaccineManufacturer),
//			DCCQRDetails(field: DCCQRDetailsVaccination.dosage, value: dosage),
//			DCCQRDetails(field: DCCQRDetailsVaccination.date, value: formattedVaccinationDate),
//			DCCQRDetails(field: DCCQRDetailsVaccination.country, value: country),
//			DCCQRDetails(field: DCCQRDetailsVaccination.issuer, value: issuer),
//			DCCQRDetails(field: DCCQRDetailsVaccination.uniqueIdentifer, value: vaccination.certificateIdentifier)
//		]
//
//		coordinator?.presentDCCQRDetails(
//			title: L.holderShowqrEuAboutTitle(),
//			description: L.holderShowqrEuAboutVaccinationDescription(),
//			details: details,
//			dateInformation: L.holderShowqrEuAboutVaccinationDateinformation()
//		)
//	}
//
//	private func showTestDetails(euCredentialAttributes: EuCredentialAttributes, test: EuCredentialAttributes.TestEntry) {
//
//		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
//		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)
//
//		let formattedTestDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
//			.map(printDateTimeFormatter.string) ?? test.sampleDate
//
//		let testType = remoteConfigManager?.getConfiguration().getTestTypeMapping(
//			test.typeOfTest) ?? test.typeOfTest
//
//		let manufacturer = remoteConfigManager?.getConfiguration().getTestManufacturerMapping(
//			test.marketingAuthorizationHolder) ?? (test.marketingAuthorizationHolder ?? "")
//
//		var testResult = test.testResult
//		if test.testResult == "260415000" {
//			testResult = L.holderShowqrEuAboutTestNegative()
//		}
//		if test.testResult == "260373001" {
//			testResult = L.holderShowqrEuAboutTestPostive()
//		}
//
//		let issuer = getDisplayIssuer(test.issuer)
//		let country = getDisplayCountry(test.country)
//		let facility = getDisplayFacility(test.testCenter)
//
//		let details: [DCCQRDetails] = [
//			DCCQRDetails(field: DCCQRDetailsTest.name, value: name),
//			DCCQRDetails(field: DCCQRDetailsTest.dateOfBirth, value: formattedBirthDate),
//			DCCQRDetails(field: DCCQRDetailsTest.pathogen, value: L.holderShowqrEuAboutTestPathogenvalue()),
//			DCCQRDetails(field: DCCQRDetailsTest.testType, value: testType),
//			DCCQRDetails(field: DCCQRDetailsTest.testName, value: test.name),
//			DCCQRDetails(field: DCCQRDetailsTest.date, value: formattedTestDate),
//			DCCQRDetails(field: DCCQRDetailsTest.result, value: testResult),
//			DCCQRDetails(field: DCCQRDetailsTest.facility, value: facility),
//			DCCQRDetails(field: DCCQRDetailsTest.manufacturer, value: manufacturer),
//			DCCQRDetails(field: DCCQRDetailsTest.country, value: country),
//			DCCQRDetails(field: DCCQRDetailsTest.issuer, value: issuer),
//			DCCQRDetails(field: DCCQRDetailsTest.uniqueIdentifer, value: test.certificateIdentifier)
//		]
//
//		coordinator?.presentDCCQRDetails(
//			title: L.holderShowqrEuAboutTitle(),
//			description: L.holderShowqrEuAboutTestDescription(),
//			details: details,
//			dateInformation: L.holderShowqrEuAboutTestDateinformation()
//		)
//	}
//
//	private func showRecoveryDetails(euCredentialAttributes: EuCredentialAttributes, recovery: EuCredentialAttributes.RecoveryEntry) {
//
//		let name = "\(euCredentialAttributes.digitalCovidCertificate.name.familyName), \(euCredentialAttributes.digitalCovidCertificate.name.givenName)"
//		let formattedBirthDate = euCredentialAttributes.dateOfBirth(printDateFormatter)
//
//		let formattedFirstPostiveDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
//			.map(printDateFormatter.string) ?? recovery.firstPositiveTestDate
//		let formattedValidFromDate: String = Formatter.getDateFrom(dateString8601: recovery.validFrom)
//			.map(printDateFormatter.string) ?? recovery.validFrom
//		let formattedValidUntilDate: String = Formatter.getDateFrom(dateString8601: recovery.expiresAt)
//			.map(printDateFormatter.string) ?? recovery.expiresAt
//
//		let country = getDisplayCountry(recovery.country)
//		let issuer = getDisplayIssuer(recovery.issuer)
//
//		let details: [DCCQRDetails] = [
//			DCCQRDetails(field: DCCQRDetailsRecovery.name, value: name),
//			DCCQRDetails(field: DCCQRDetailsRecovery.dateOfBirth, value: formattedBirthDate),
//			DCCQRDetails(field: DCCQRDetailsRecovery.pathogen, value: L.holderShowqrEuAboutRecoveryPathogenvalue()),
//			DCCQRDetails(field: DCCQRDetailsRecovery.date, value: formattedFirstPostiveDate),
//			DCCQRDetails(field: DCCQRDetailsRecovery.country, value: country),
//			DCCQRDetails(field: DCCQRDetailsRecovery.issuer, value: issuer),
//			DCCQRDetails(field: DCCQRDetailsRecovery.validFrom, value: formattedValidFromDate),
//			DCCQRDetails(field: DCCQRDetailsRecovery.validUntil, value: formattedValidUntilDate),
//			DCCQRDetails(field: DCCQRDetailsRecovery.uniqueIdentifer, value: recovery.certificateIdentifier)
//		]
//
//		coordinator?.presentDCCQRDetails(
//			title: L.holderShowqrEuAboutTitle(),
//			description: L.holderShowqrEuAboutRecoveryDescription(),
//			details: details,
//			dateInformation: L.holderShowqrEuAboutRecoveryDateinformation()
//		)
//	}

	func showQRItemViewController(forItem item: ShowQRItem) -> ShowQRItemViewController {

		let viewController = ShowQRItemViewController(
			viewModel: ShowQRItemViewModel(
				coordinator: coordinator!,
				greenCard: item.greenCard
			)
		)
		viewController.isAccessibilityElement = true
		return viewController
	}

//	private lazy var dateFormatter: ISO8601DateFormatter = {
//		let dateFormatter = ISO8601DateFormatter()
//		dateFormatter.formatOptions = [.withFullDate]
//		return dateFormatter
//	}()
//
//	/// Formatter to print
//	private lazy var printDateFormatter: DateFormatter = {
//
//		let dateFormatter = DateFormatter()
//		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
//		dateFormatter.dateFormat = "dd-MM-yyyy"
//		return dateFormatter
//	}()
//
//	private lazy var printDateTimeFormatter: DateFormatter = {
//
//		let dateFormatter = DateFormatter()
//		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
//		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
//		return dateFormatter
//	}()

//	private func getDisplayIssuer(_ issuer: String) -> String {
//		guard issuer == "Ministry of Health Welfare and Sport" else {
//			return issuer
//		}
//		return L.holderVaccinationAboutIssuer()
//	}
//
//	private func getDisplayCountry(_ country: String) -> String {
//		guard ["NL", "NLD"].contains(country) else {
//			return country
//		}
//		return L.holderVaccinationAboutCountry()
//	}
//
//	private func getDisplayFacility(_ facility: String) -> String {
//		guard facility == "Facility approved by the State of The Netherlands" else {
//			return facility
//		}
//		return L.holderDccListFacility()
//	}
}

private extension EuCredentialAttributes {

	func dateOfBirth(_ dateFormatter: DateFormatter) -> String {
		return Formatter
			.getDateFrom(dateString8601: digitalCovidCertificate.dateOfBirth)
			.map(dateFormatter.string)
		?? digitalCovidCertificate.dateOfBirth
	}
}

struct ShowQRItem {
	let greenCard: GreenCard
}

class ShowQRViewController: BaseViewController {

	let sceneView = ShowQRView()

	private let viewModel: ShowQRViewModel
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	var previousOrientation: UIInterfaceOrientation?

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ShowQRViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		sceneView.backgroundColor = .white

		setupPageController()
		setupPages()
		setupBinding()
		addBackButton()
	}

	private func setupBinding() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$infoButtonAccessibility.binding = { [weak self] in
			self?.addInfoButton(action: #selector(self?.informationButtonTapped), accessibilityLabel: $0 ?? "")
		}
		viewModel.$showInternationalAnimation.binding = { [weak self] in
			if $0 {
				self?.sceneView.setupForInternational()
			}
		}
		viewModel.$thirdPartyTicketAppButtonTitle.binding = { [weak self] in self?.sceneView.returnToThirdPartyAppButtonTitle = $0 }
		sceneView.didTapThirdPartyAppButtonCommand = { [viewModel] in viewModel.didTapThirdPartyAppButton() }
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		sceneView.play()
		previousOrientation = OrientationUtility.currentOrientation()
		OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		OrientationUtility.lockOrientation(.all, andRotateTo: previousOrientation ?? .portrait)
	}
}

// MARK: Details

extension ShowQRViewController {

	/// Add an information button to the navigation bar.
	/// - Parameters:
	///   - action: The action when the users taps the information button
	///   - accessibilityLabel: The label for Voice Over
	func addInfoButton(
		action: Selector,
		accessibilityLabel: String) {

			let config = UIBarButtonItem.Configuration(
				target: self,
				action: action,
				text: L.holderShowqrDetails(),
				tintColor: Theme.colors.iosBlue,
				accessibilityIdentifier: "InformationButton",
				accessibilityLabel: accessibilityLabel
			)
			navigationItem.rightBarButtonItem = .create(config)
		}

	@objc func informationButtonTapped() {

		viewModel.showMoreInformation()
	}
}

// MARK: PageController

extension ShowQRViewController {

	private func setupPages() {

		viewModel.$items.binding = { [weak self] in

			guard let self = self else {
				return
			}

			self.pageViewController.pages = $0.enumerated().compactMap { index, item in
				let viewController = self.viewModel.showQRItemViewController(forItem: item)
//				viewController.delegate = self
				return viewController
			}
			self.sceneView.pageControl.numberOfPages = $0.count
			self.sceneView.pageControl.currentPage = 0
		}
	}

	/// Setup the page controller
	private func setupPageController() {

		pageViewController.pageViewControllerDelegate = self
		pageViewController.view.backgroundColor = .clear

		pageViewController.view.frame = sceneView.containerView.frame
		sceneView.containerView.addSubview(pageViewController.view)
		addChild(pageViewController)
		pageViewController.didMove(toParent: self)
		sceneView.pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
	}

	/// User tapped on the page control
	@objc func pageControlValueChanged(_ pageControl: UIPageControl) {

		if pageControl.currentPage > pageViewController.currentIndex {
			pageViewController.nextPage()
		} else {
			pageViewController.previousPage()
		}
	}
}

// MARK: - PageViewControllerDelegate

extension ShowQRViewController: PageViewControllerDelegate {

	func pageViewController(_ pageViewController: PageViewController, didSwipeToPendingViewControllerAt index: Int) {
		sceneView.pageControl.currentPage = index
//		viewModel.userDidChangeCurrentPage(toPageIndex: index)
	}
}
