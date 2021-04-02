/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// The different kind of cards
enum CardIdentifier {

	/// Make an appointment to get tested
	case appointment

	/// Create a QR code
	case create

	/// The QR code card
	case qrcode
}

/// The card information
struct CardInfo {

	/// The identifier of the card
	let identifier: CardIdentifier

	/// The title of the card
	let title: String

	/// The message of the card
	let message: String

	/// The title on the action button of the card
	let actionTitle: String

	/// The optional background image
	let image: UIImage?

	/// The background color
	let backgroundColor: UIColor?
}

/// The card information for QR
struct QRCardInfo {

	/// The identifier of the card
	let identifier: CardIdentifier

	/// The title of the card
	let title: String

	/// The message of the card
	let message: String

	/// The identiry of the holder
	let holder: String

	/// The title on the action button of the card
	let actionTitle: String

	/// The optional background image
	let image: UIImage?

	/// the valid until date
	let validUntil: String

	/// the valid until date pronounced
	let validUntilAccessibility: String
}

class HolderDashboardViewModel: PreventableScreenCapture, Logging {

	/// The logging category
	var loggingCategory: String = "HolderDashboardViewModel"

	/// Coordination Delegate
	weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

	/// The crypto manager
	weak var cryptoManager: CryptoManaging?

	/// The proof manager
	weak var proofManager: ProofManaging?

	/// The configuration
	var configuration: ConfigurationGeneralProtocol

	/// The proof validator
	var proofValidator: ProofValidatorProtocol

	/// The banner manager
	var bannerManager: BannerManaging = BannerManager.shared

	/// the notification center
	var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	/// The previous brightness
	var previousBrightness: CGFloat?

	/// A timer to keep refreshing the QR
	var validityTimer: Timer?

	/// The title of the scene
	@Bindable private(set) var title: String

	/// The introduction message of the scene
	@Bindable private(set) var message: String

	/// The message on the expired card
	@Bindable private(set) var expiredTitle: String?

	/// Show an expired QR Message
	@Bindable private(set) var showExpiredQR: Bool

	/// The appointment Card information
	@Bindable private(set) var appointmentCard: CardInfo

	/// The create QR Card information
	@Bindable private(set) var createCard: CardInfo

	/// The create QR Card information
	@Bindable private(set) var qrCard: QRCardInfo?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - cryptoManager: the crypto manager
	///   - proofManager: the proof manager
	///   - configuration: the configuration
	///   - maxValidity: the maximum validity of a test in hours
	init(
		coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol),
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol,
		maxValidity: Int) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.configuration = configuration
		self.title = .holderDashboardTitle
		self.message = .holderDashboardIntro
		self.expiredTitle = .holderDashboardQRExpired

		// Start by showing nothing
		self.showExpiredQR = false

		self.appointmentCard = CardInfo(
			identifier: .appointment,
			title: .holderDashboardAppointmentTitle,
			message: .holderDashboardAppointmentMessage,
			actionTitle: .holderDashboardAppointmentAction,
			image: .appointmentTile,
			backgroundColor: Theme.colors.appointment
		)
		self.createCard = CardInfo(
			identifier: .create,
			title: .holderDashboardCreateTitle,
			message: .holderDashboardCreateMessage,
			actionTitle: .holderDashboardCreateAction,
			image: .createTile,
			backgroundColor: Theme.colors.create
		)

		self.proofValidator = ProofValidator(maxValidity: maxValidity)

		super.init()
		self.addObserver()
	}

	/// The user tapped on one of the cards
	/// - Parameter identifier: the identifier of the card
	func cardTapped(_ identifier: CardIdentifier) {

		switch identifier {
			case .appointment:
				coordinator?.navigateToAppointment()
			case .create:
				coordinator?.navigateToChooseProvider()
			case .qrcode:
				coordinator?.navigateToEnlargedQR()
		}
	}

	/// Check the QR Validity
	@objc func checkQRValidity() {

		guard let credential = cryptoManager?.readCredential() else {
			qrCard = nil
			validityTimer?.invalidate()
			validityTimer = nil
			setupCreateCard()
			return
		}

		if let sampleTimeStamp = TimeInterval(credential.sampleTime) {

			let holder = TestHolderIdentity(
				firstNameInitial: credential.firstNameInitial ?? "",
				lastNameInitial: credential.lastNameInitial ?? "",
				birthDay: credential.birthDay ?? "",
				birthMonth: credential.birthMonth ?? ""
			)
			switch proofValidator.validate(sampleTimeStamp) {
				case let .valid(validUntilDate):
					showExpiredQR = false
					showQRMessageIsValid(validUntilDate, holder: holder)
					startValidityTimer()

				case let .expiring(validUntilDate, timeLeft):
					showExpiredQR = false
					showQRMessageIsExpiring(validUntilDate, timeLeft: timeLeft, holder: holder)
					startValidityTimer()

				case .expired:

					// Clear the cache
					cryptoManager?.removeCredential()

					logDebug("Proof is no longer valid")
					showQRMessageIsExpired()
					validityTimer?.invalidate()
					validityTimer = nil
			}
		}
		setupCreateCard()
	}

	/// Show the QR message is valid
	/// - Parameters:
	///   - validUntil: valid until time
	///   - holder: the holder identity
	func showQRMessageIsValid(
		_ validUntil: Date,
		holder: TestHolderIdentity) {

		let validUntilDateString = printDateFormatter.string(from: validUntil)
		logDebug("Proof is valid until \(validUntilDateString)")
		let validUntilString = String(format: .holderDashboardQRMessage, validUntilDateString)

		let accessibilityValidUntilDateString = accessibilityDateFormatter.string(from: validUntil)
		let acceccibilityTimeString = getAccessibilityTime(validUntil)
		let accessibiliyValidUntilString = String(format: .holderDashboardQRMessageAccessibility, accessibilityValidUntilDateString, acceccibilityTimeString)

		makeQRCard(
			validUntil: validUntilString,
			validUntilAccessibility: accessibiliyValidUntilString,
			holder: holder
		)
	}

	/// Show the QR message is valid, but expiring
	/// - Parameters:
	///   - validUntil: valid until time
	///   - timeLeft: the time left until expiring
	///   - holder: the holder identity
	func showQRMessageIsExpiring(
		_ validUntil: Date,
		timeLeft: TimeInterval,
		holder: TestHolderIdentity) {

		let validUntilDateString = printDateFormatter.string(from: validUntil)
		logDebug("Proof is valid until \(validUntilDateString), expiring in \(timeLeft)")

		let validUntilString = String(format: .holderDashboardQRExpiring, validUntilDateString, timeLeft.stringTime)

		let accessibilityValidUntilDateString = accessibilityDateFormatter.string(from: validUntil)
		let acceccibilityTimeString = getAccessibilityTime(validUntil)
		let accessibiliyValidUntilString = String(format: .holderDashboardQRExpiringAccessibility, accessibilityValidUntilDateString, acceccibilityTimeString, timeLeft.accessibilityTime)

		makeQRCard(
			validUntil: validUntilString,
			validUntilAccessibility: accessibiliyValidUntilString,
			holder: holder
		)
		
		// Cut off at the cut off time
		if timeLeft < 60 {
			validityTimer?.invalidate()
			validityTimer = Timer.scheduledTimer(
				timeInterval: timeLeft,
				target: self,
				selector: (#selector(checkQRValidity)),
				userInfo: nil,
				repeats: true
			)
		}
	}

	/// Make the QR Card
	/// - Parameters:
	///   - validUntil: the valid until time string
	///   - validUntilAccessibility: the valid until time string for pronouncation
	///   - holder: the holder identity
	func makeQRCard(
		validUntil: String,
		validUntilAccessibility: String,
		holder: TestHolderIdentity) {

		let identity = holder
			.mapIdentity(months: String.shortMonths)
			.map({ $0.isEmpty ? "_" : $0 })
			.joined(separator: " ")

		qrCard = QRCardInfo(
			identifier: .qrcode,
			title: .holderDashboardQRTitle,
			message: .holderDashboardQRSubTitle,
			holder: identity,
			actionTitle: .holderDashboardQRAction,
			image: .myQR,
			validUntil: validUntil,
			validUntilAccessibility: validUntilAccessibility
		)
	}

	/// Show the QR Message is expired
	func showQRMessageIsExpired() {

		qrCard = nil
		showExpiredQR = true
	}

	/// Start the validity timer, check every 10 seconds.
	func startValidityTimer() {

		guard validityTimer == nil else {
			return
		}

		validityTimer = Timer.scheduledTimer(
			timeInterval: TimeInterval(60),
			target: self,
			selector: (#selector(checkQRValidity)),
			userInfo: nil,
			repeats: true
		)
	}

	/// User wants to close the expired QR
	func closeExpiredRQ() {

		showExpiredQR = false
		checkQRValidity()
	}

	/// Formatter to print
	private lazy var printDateFormatter: DateFormatter = {
		
		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "CET")
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "EEEE '<br>' d MMMM HH:mm"
		return dateFormatter
	}()

	/// Formatter for accessibility
	private lazy var accessibilityDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(abbreviation: "CET")
		dateFormatter.locale = Locale(identifier: "nl_NL")
		dateFormatter.dateFormat = "EEEE d MMMM"
		return dateFormatter
	}()

	/// Get the accessibility time label
	/// - Parameter date: the date to use
	/// - Returns: The time of the message as a string
	func getAccessibilityTime(_ date: Date) -> String {

		let components = Calendar.current.dateComponents([.hour, .minute], from: date)
		return DateComponentsFormatter.localizedString(from: components, unitsStyle: .spellOut) ?? ""
	}

	@objc func showBanner() {

		bannerManager.showBanner(
			title: .holderBannerNewQRTitle,
			message: .holderBannerNewQRMessage,
//			link: .holderBannerNewQRMessageLink,
			icon: UIImage.alert,
			callback: { [weak self] in

				if let url = self?.configuration.getHolderFAQURL() {
					self?.coordinator?.openUrl(url, inApp: true)
				}
			}
		)
	}

	func setupCreateCard() {

		self.createCard = CardInfo(
			identifier: .create,
			title: qrCard == nil ? .holderDashboardCreateTitle : .holderDashboardChangeTitle,
			message: .holderDashboardCreateMessage,
			actionTitle: qrCard == nil ? .holderDashboardCreateAction : .holderDashboardChangeAction,
			image: .createTile,
			backgroundColor: Theme.colors.create
		)
	}
}

// MARK: - qrCreated

extension HolderDashboardViewModel {

	/// Add an observer for the qrCreated
	func addObserver() {

		notificationCenter.addObserver(
			self,
			selector: #selector(showBanner),
			name: .qrCreated,
			object: nil
		)
	}
}

extension TimeInterval {

	private var minutes: Int {

		return (Int(self) / 60 ) % 60
	}

	private var hours: Int {

		return Int(self) / 3600
	}

	var stringTime: String {

		if hours != 0 {
			return "\(hours) \(String.hour) \(minutes) \(String.minute)"
		} else if minutes != 0 {
			return "\(minutes) \(String.minute)"
		} else {
			return  "1 \(String.minute)"
		}
	}

	var accessibilityTime: String {

		if hours != 0 {
			if minutes > 1 {
				return "\(hours) \(String.hour) \(minutes) \(String.longMinutes)"
			} else if minutes == 0 {
				return "\(hours) \(String.hour)"
			} else {
				return "\(hours) \(String.hour) \(minutes) \(String.longMinute)"
			}
		} else if minutes != 0 {
			if minutes > 1 {
				return "\(minutes) \(String.longMinutes)"
			} else {
				return "\(minutes) \(String.longMinute)"
			}
		} else {
			return  "1 \(String.longMinute)"
		}
	}
}
