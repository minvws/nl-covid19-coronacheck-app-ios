/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CoreData

/// Currently used for the NL/EU toggle on the dashboard
/// but could be expanded elsewhere
enum QRCodeValidityRegion: String, Codable {
	case domestic
	case europeanUnion

	var localized: String {
		switch self {
			case .domestic: return .netherlands
			case .europeanUnion: return .europeanUnion
		}
	}
}

enum QRCodeOriginType: String, Codable {
	case negativeTest
	case vaccination
	case recovery

	var localized: String {
		switch self {
			case .recovery: return .qrTypeRecovery
			case .vaccination: return .qrTypeVaccination
			case .negativeTest: return .qrTypeNegativeTest
		}
	}
}

class HolderDashboardViewModel: Logging {

	// MARK: - Public properties

	/// The logging category
	var loggingCategory: String = "HolderDashboardViewModel"

	/// The title of the scene
	@Bindable private(set) var title: String = .holderDashboardTitle

	@Bindable private(set) var cards = [HolderDashboardViewController.Card]()

	// MARK: - Private types

	/// Wrapper around some state variables
	/// that allows us to use a `didSet{}` to
	/// get a callback if any of them are mutated.
	private struct State {
		var myQRCards: [MyQRCard]
		var expiredGreenCards: [ExpiredQR]
		var showCreateCard: Bool
		var qrCodeValidityRegion: QRCodeValidityRegion
	}

	// MARK: - Private properties

	/// Coordination Delegate
	private weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

	/// The crypto manager
	private weak var cryptoManager: CryptoManaging?

	/// The proof manager
	private weak var proofManager: ProofManaging?

	/// The configuration
	private var configuration: ConfigurationGeneralProtocol

	/// The proof validator
	private var proofValidator: ProofValidatorProtocol

	/// the notification center
	private var notificationCenter: NotificationCenterProtocol = NotificationCenter.default

	@UserDefaults(key: "dashboardRegionToggleValue", defaultValue: QRCodeValidityRegion.domestic)
	private var dashboardRegionToggleValue: QRCodeValidityRegion { // swiftlint:disable:this let_var_whitespace
		didSet {
			state.qrCodeValidityRegion = dashboardRegionToggleValue
		}
	}

	private var state: State {
		didSet {
			guard let coordinator = coordinator else { return }

			self.cards = HolderDashboardViewModel.assembleCards(
				state: state,
				didTapCloseExpiredQR: { expiredQR in
					self.state.expiredGreenCards.removeAll(where: { $0.id == expiredQR.id })
				},
				coordinatorDelegate: coordinator
			)
		}
	}

	private let datasource: Datasource

	// MARK: -

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
		maxValidity: Int,
		dataStoreManager: DataStoreManaging
	) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.configuration = configuration
		self.proofValidator = ProofValidator(maxValidity: maxValidity)
		self.datasource = Datasource(dataStoreManager: dataStoreManager)

		self.state = State(
			myQRCards: [],
			expiredGreenCards: [],
			showCreateCard: true,
			qrCodeValidityRegion: .domestic
		)

		self.datasource.didUpdate = { [weak self] (qrCardDataItems: [MyQRCard], expiredGreenCards: [ExpiredQR]) in
			DispatchQueue.main.async {
				self?.state.myQRCards = qrCardDataItems
				self?.state.expiredGreenCards += expiredGreenCards
			}
		}

		// Update State from UserDefaults:
		self.state.qrCodeValidityRegion = dashboardRegionToggleValue

		self.setupNotificationListeners()

//		#if DEBUG
//		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//			injectSampleData(dataStoreManager: dataStoreManager)
//			self.datasource.reload()
//		}
//		#endif
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	func viewWillAppear() {
		datasource.reload()
	}

	// MARK: Capture User input:

	@objc func addProofTapped() {
		coordinator?.navigateToAboutMakingAQR()
	}

	func openUrl(_ url: URL) {
		coordinator?.openUrl(url, inApp: true)
	}

	func didTapChangeRegion() {
		coordinator?.userWishesToChangeRegion(currentRegion: state.qrCodeValidityRegion) { [weak self] newRegion in
			self?.dashboardRegionToggleValue = newRegion
		}
	}

	// MARK: - Static Methods

	private static func assembleCards(
		state: HolderDashboardViewModel.State,
		didTapCloseExpiredQR: @escaping (ExpiredQR) -> Void,
		coordinatorDelegate: (HolderCoordinatorDelegate)) -> [HolderDashboardViewController.Card] {
		var cards = [HolderDashboardViewController.Card]()

		cards += [.headerMessage(message: .holderDashboardIntro)]

		cards += state.expiredGreenCards.compactMap { expiredQR -> HolderDashboardViewController.Card? in
			guard expiredQR.region == state.qrCodeValidityRegion else { return nil }

			let message = String.holderDashboardQRExpired(
				localizedRegion: expiredQR.region.localized,
				localizedOriginType: expiredQR.type.localized
			)

			return .expiredQR(message: message, didTapClose: {
				didTapCloseExpiredQR(expiredQR)
			})
		}

		if state.myQRCards.isEmpty {
			cards += [
				.makeQR(
					title: .holderDashboardCreateTitle,
					message: .holderDashboardCreateMessage,
					actionTitle: .holderDashboardCreateAction,
					didTapMakeQR: { [weak coordinatorDelegate] in
						coordinatorDelegate?.navigateToAboutMakingAQR()
					}
				)
			]
		}

		cards += state.myQRCards

			// Map a `MyQRCard` to a `VC.Card`:
			.compactMap { (qrcardDataItem: HolderDashboardViewModel.MyQRCard) -> HolderDashboardViewController.Card? in
				switch (state.qrCodeValidityRegion, qrcardDataItem) {

					case (.domestic, .netherlands(let greenCardObjectID, let origins, let evaluateEnabledState)):
						let rows = origins.map { origin in
							HolderDashboardViewController.Card.QRCardRow(
								typeText: origin.type.localized,
								validityTextEvaluator: { now in
									qrcardDataItem.localizedDateExplanation(forOrigin: origin, forNow: now)
								}
							)
						}

						return HolderDashboardViewController.Card.domesticQR(
							rows: rows,
							didTapViewQR: { coordinatorDelegate.userWishesToViewQR(greenCardObjectID: greenCardObjectID) },
							buttonEnabledEvaluator: evaluateEnabledState,
							expiryCountdownEvaluator: { now in
								let mostDistantFutureExpiryDate = origins.reduce(Date()) { result, nextOrigin in
									nextOrigin.expirationTime > result ? nextOrigin.expirationTime : result
								}

								// if all origins will be expired in next six hours:
								let sixHours: TimeInterval = 6 * 60 * 60
								guard mostDistantFutureExpiryDate > Date() && mostDistantFutureExpiryDate < Date(timeIntervalSinceNow: sixHours)
								else { return nil }

								// e.g. "5 uur 59 min"
								guard let relativeDateString = HolderDashboardViewModel.hmsRelativeFormatter.string(from: Date(), to: mostDistantFutureExpiryDate)
								else { return nil }

								return String.qrExpiryDatePrefixExpiresIn + relativeDateString
							}
						)

					case (.europeanUnion, .europeanUnion(let greenCardObjectID, let origins, let evaluateEnabledState)):
						let rows = origins.map { origin in
							HolderDashboardViewController.Card.QRCardRow(
								typeText: origin.type.localized,
								validityTextEvaluator: { now in
									qrcardDataItem.localizedDateExplanation(forOrigin: origin, forNow: now)
								}
							)
						}

						return HolderDashboardViewController.Card.europeanUnionQR(
							rows: rows,
							didTapViewQR: { coordinatorDelegate.userWishesToViewQR(greenCardObjectID: greenCardObjectID) },
							buttonEnabledEvaluator: evaluateEnabledState,
							expiryCountdownEvaluator: nil
						)

					default: return nil
				}
			}

		cards += [
			.changeRegion(
				buttonTitle: .changeRegionButton,
				currentLocationTitle: {
					switch state.qrCodeValidityRegion {
						case .domestic:
							return .changeRegionTitleNL
						case .europeanUnion:
							return .changeRegionTitleEU
					}
				}()
			)
		]

		return cards
	}
}

// MARK: - NSNotification

extension HolderDashboardViewModel {

	fileprivate func setupNotificationListeners() {

		NotificationCenter.default.addObserver(
			self,
			selector: #selector(receiveDidBecomeActiveNotification),
			name: UIApplication.didBecomeActiveNotification,
			object: nil
		)
	}

	@objc func receiveDidBecomeActiveNotification() {
		datasource.reload()
	}
}

// MARK: - MyQRCard

extension HolderDashboardViewModel {

	/// Represents a Greencard in the UI,
	/// Contains an array of `MyQRCard.Origin`.

	// Future: it's turned out that this can be converted to a struct with a `.region` enum instead
	fileprivate enum MyQRCard {
		case europeanUnion(greenCardObjectID: NSManagedObjectID, origins: [Origin], evaluateEnabledState: (Date) -> Bool)
		case netherlands(greenCardObjectID: NSManagedObjectID, origins: [Origin], evaluateEnabledState: (Date) -> Bool)

		/// Represents an Origin
		struct Origin {
			let type: QRCodeOriginType // vaccination | negativeTest | recovery
			let eventDate: Date
			let expirationTime: Date
			let validFromDate: Date

			/// There is a particular order to sort these onscreen
			var customSortIndex: Int {
				switch type {
					case .vaccination: return 0
					case .recovery: return 1
					case .negativeTest: return 2
				}
			}

			var isCurrentlyValid: Bool {
				return isValid(duringDate: Date())
			}

			func isValid(duringDate date: Date) -> Bool {
				date.isWithinTimeWindow(from: validFromDate, to: expirationTime)
			}
		}

		func localizedDateExplanation(forOrigin origin: Origin, forNow now: Date = Date()) -> HolderDashboardViewController.ValidityText {
			
			if origin.expirationTime < now { // expired
				return .init(text: "", kind: .past)
			} else if origin.validFromDate > now, case .netherlands = self { // not valid yet

				if origin.validFromDate > (now.addingTimeInterval(60 * 60 * 24)) { // > 1 day until valid
					let dateString = HolderDashboardViewModel.daysRelativeFormatter.string(from: Date(), to: origin.validFromDate) ?? "-"
					let prefix = localizedDateExplanationPrefix(forOrigin: origin)
					return .init(text: prefix + dateString, kind: .future)
				} else {
					let dateString = HolderDashboardViewModel.hmsRelativeFormatter.string(from: Date(), to: origin.validFromDate) ?? "-"
					let prefix = localizedDateExplanationPrefix(forOrigin: origin)
					return .init(text: prefix + dateString, kind: .future)
				}

			} else {
				switch self {
					// Netherlands uses expireTime
					case .netherlands:
						let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.expirationTime)
						let prefix = localizedDateExplanationPrefix(forOrigin: origin)
						return .init(text: prefix + dateString, kind: .current)

					// EU cards use Valid From (eventTime) because we don't know the expiry date
					case .europeanUnion:
						let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.validFromDate)
						let prefix = localizedDateExplanationPrefix(forOrigin: origin)
						return .init(text: prefix + dateString, kind: .current)
				}
			}
		}

		// MARK: - private

		/// Each origin has its own prefix
		private func localizedDateExplanationPrefix(forOrigin origin: Origin) -> String {

			switch self {
				case .netherlands:
					if origin.isCurrentlyValid {
						return .qrExpiryDatePrefixValidUpToAndIncluding
					} else {
						return .qrValidityDatePrefixAutomaticallyBecomesValidOn
					}

				case .europeanUnion:
					if origin.isCurrentlyValid {
						if origin.type == .recovery {
							return .qrValidityDatePrefixValidFrom
						} else {
							return ""
						}
					} else {
						return .qrValidityDatePrefixValidFrom
					}
			}
		}

		/// Each origin has a different date/time format
		/// (Region + Origin) -> DateFormatter
		private func localizedDateExplanationDateFormatter(forOrigin origin: Origin) -> DateFormatter {
			switch (self, origin.type) {
				case (.netherlands, .negativeTest):
					return HolderDashboardViewModel.dateWithDayAndTimeFormatter

				case (.netherlands, _):
					return HolderDashboardViewModel.dateWithoutTimeFormatter

				case (.europeanUnion, .vaccination):
					return HolderDashboardViewModel.dateWithoutTimeFormatter

				case (.europeanUnion, .recovery):
					return HolderDashboardViewModel.dayAndMonthFormatter

				case (.europeanUnion, .negativeTest):
					return HolderDashboardViewModel.dateWithDayAndTimeFormatter
			}
		}

		/// If at least one origin('s date range) is valid:
		var isCurrentlyValid: Bool {
			origins.contains(where: { $0.isCurrentlyValid })
		}

		/// Without distinguishing NL/EU, just give me the origins:
		var origins: [Origin] {
			switch self {
				case .europeanUnion(_, let origins, _), .netherlands(_, let origins, _):
					return origins
			}
		}

		var effectiveExpiratedAt: Date {
			return origins.compactMap { $0.expirationTime }.sorted().last ?? .distantPast
		}
	}

	struct ExpiredQR {
		let id = UUID().uuidString
		let region: QRCodeValidityRegion
		let type: QRCodeOriginType
	}
}

// MARK: - DataSource

extension HolderDashboardViewModel {

	fileprivate class Datasource {

		var didUpdate: (([HolderDashboardViewModel.MyQRCard], [QRCodeOriginType]) -> Void)? {
			didSet {
				reload()
			}
		}

		private let dataStoreManager: DataStoreManaging
		private var reloadTimer: Timer?

		init(dataStoreManager: DataStoreManaging) {
			self.dataStoreManager = dataStoreManager
			self.reload()
		}

		// Calls fetch, then updates subscribers.

		func reload() {
			guard let didUpdate = didUpdate else { return }

			reloadTimer?.invalidate()
			reloadTimer = nil

			let expiredGreenCards: [ExpiredQR] = Services.walletManager.removeExpiredGreenCards().compactMap { (greencardType: String, originType: String) -> ExpiredQR? in
				guard let region = QRCodeValidityRegion(rawValue: greencardType) else { return nil }
				guard let originType = QRCodeOriginType(rawValue: originType) else { return nil }
				return ExpiredQR(region: region, type: originType)
			}
			let cards: [HolderDashboardViewModel.MyQRCard] = fetch()

			didUpdate(cards, expiredGreenCards)

			// Schedule a Timer to reload the next time an origin will expire:
			let nextFetchInterval: TimeInterval = cards
				.flatMap { $0.origins }
				.reduce(Date.distantFuture) { (result: Date, origin: HolderDashboardViewModel.MyQRCard.Origin) -> Date in
					origin.expirationTime < result ? origin.expirationTime : result
				}.timeIntervalSinceNow

			guard nextFetchInterval > 0 else { return }

			reloadTimer = Timer.scheduledTimer(withTimeInterval: nextFetchInterval, repeats: false, block: { [weak self] _ in
				self?.reload()
			})
		}

		/// Fetch the Greencards+Origins from Database
		/// and convert to UI-appropriate model types.
		private func fetch() -> [HolderDashboardViewModel.MyQRCard] {
			let walletManager = Services.walletManager
			let greencards = walletManager.listGreenCards()

			let items = greencards
				.compactMap { (greencard: GreenCard) -> (GreenCard, [Origin])? in
					// Get all origins
					guard let untypedOrigins = greencard.origins else { return nil }
					let origins = untypedOrigins.compactMap({ $0 as? Origin })
					return (greencard, origins)
				}
				// map DB types to local types to have more control over optionality & avoid worrying about threading
				.flatMap { (greencard: GreenCard, origins: [Origin]) -> [MyQRCard] in

					// Entries on the Card that represent an Origin.
					let originEntries = origins
						.compactMap { origin -> MyQRCard.Origin? in
							guard let typeRawValue = origin.type,
								  let type = QRCodeOriginType(rawValue: typeRawValue),
								  let eventDate = origin.eventDate,
								  let expirationTime = origin.expirationTime,
								  let validFromDate = origin.validFromDate
							else { return nil }

							return MyQRCard.Origin(
								type: type,
								eventDate: eventDate,
								expirationTime: expirationTime,
								validFromDate: validFromDate
							)
						}
						.filter {
							// Pro-actively remove invalid Origins here, in case the database is laggy:
							// Future: this could be moved to the DB layer like how greencard.getActiveCredentials does it.
							Date() < $0.expirationTime
						}
						.sorted { $0.customSortIndex < $1.customSortIndex }

					func evaluateButtonEnabledState(date: Date) -> Bool {
						let activeCredential: Credential? = greencard.getActiveCredential(forDate: date)
						return !(activeCredential == nil || originEntries.isEmpty)
					}

					switch greencard.getType() {
						case .domestic:
							return [MyQRCard.netherlands(
								greenCardObjectID: greencard.objectID,
								origins: originEntries,
								evaluateEnabledState: evaluateButtonEnabledState
							)]
						case .eu:
							// The EU cards should only have one entry per card, so let's divide them up:
							return originEntries.map {originEntry in
								MyQRCard.europeanUnion(
									greenCardObjectID: greencard.objectID,
									origins: [originEntry],
									evaluateEnabledState: evaluateButtonEnabledState
								)
							}
						default:
							return []
					}
				}
				.filter {
					// When a GreenCard has no more origins with a
					// current/future validity, hide the Card
					!$0.origins.isEmpty
				}
				.sorted { qrCardA, qrCardB in
					qrCardA.effectiveExpiratedAt > qrCardB.effectiveExpiratedAt
				}

			return items
		}
	}
}

// MARK: - Date Formatters

extension HolderDashboardViewModel {

	fileprivate static let dateWithoutTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMM yyyy"
		return formatter
	}()

	fileprivate static let dateWithDayAndTimeFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEEE d MMM HH:mm"
		return formatter
	}()

	fileprivate static let dayAndMonthFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "d MMM"
		return formatter
	}()

	// e.g. "4 hours, 55 minutes"
	// 		"59 minutes"
	// 		"20 seconds"
	fileprivate static let hmsRelativeFormatter: DateComponentsFormatter = {
		let hoursFormatter = DateComponentsFormatter()
		hoursFormatter.unitsStyle = .full
		hoursFormatter.maximumUnitCount = 2
		hoursFormatter.allowedUnits = [.hour, .minute, .second]
		return hoursFormatter
	}()

	fileprivate static let daysRelativeFormatter: DateComponentsFormatter = {
		let hoursFormatter = DateComponentsFormatter()
		hoursFormatter.unitsStyle = .full
		hoursFormatter.allowedUnits = [.day]
		return hoursFormatter
	}()
}

private extension Date {

	/// to be used like `now.isWithinTimeWindow(.originValidFrom, origin.expireTime)`
	func isWithinTimeWindow(from: Date, to: Date) -> Bool {
		(from...to).contains(self)
	}
}

#if DEBUG
// MARK: - Free Functions

private func injectSampleData(dataStoreManager: DataStoreManaging) {

	let context = dataStoreManager.backgroundContext()

	context.performAndWait {
		_ = Services.walletManager // ensure single entity Wallet is created.
		guard let wallet = WalletModel.findBy(label: WalletManager.walletName, managedContext: context)
		else { fatalError("expecting wallet to have been created") }

		guard (wallet.greenCards ?? [])?.count == 0 else { return } // swiftlint:disable:this empty_count

		guard let domesticGreenCard = GreenCardModel.create(type: .domestic, wallet: wallet, managedContext: context)
		else { fatalError("Could not creat a green card") }

//		guard let euVaccinationGreenCard = GreenCardModel.create(type: .eu, wallet: wallet, managedContext: context)
//		else { fatalError("Could not create a green card") }

		/// Event Date: the date of the event that took place e.g. your vaccination.
		/// Expiration Date: the date it expires
		/// ValidFrom Date: the date that the QR becomes valid.

		let ago: TimeInterval = -1
		let fromNow: TimeInterval = 1
		let seconds: TimeInterval = 1
		let minutes: TimeInterval = 60
		let hours: TimeInterval = 60 * minutes
		let days: TimeInterval = hours * 24

		create( type: .recovery,
				eventDate: Date().addingTimeInterval(14 * days * ago),
				expirationTime: Date().addingTimeInterval((10 * seconds * fromNow)),
				validFromDate: Date().addingTimeInterval(fromNow),
				greenCard: domesticGreenCard,
				managedContext: context)

		create( type: .vaccination,
				eventDate: Date().addingTimeInterval(14 * days * ago),
				expirationTime: Date().addingTimeInterval((15 * seconds * fromNow)),
				validFromDate: Date().addingTimeInterval(fromNow),
				greenCard: domesticGreenCard,
				managedContext: context)

		create( type: .negativeTest,
				eventDate: Date().addingTimeInterval(14 * days * ago),
				expirationTime: Date().addingTimeInterval((20 * seconds * fromNow)),
				validFromDate: Date().addingTimeInterval(fromNow),
				greenCard: domesticGreenCard,
				managedContext: context)

		dataStoreManager.save(context)
		print("did insert!")
	}
}

private func create(
	type: OriginType,
	eventDate: Date,
	expirationTime: Date,
	validFromDate: Date,
	greenCard: GreenCard,
	managedContext: NSManagedObjectContext) {

	OriginModel.create(
		type: type,
		eventDate: eventDate,
		expirationTime: expirationTime,
		validFromDate: validFromDate,
		greenCard: greenCard,
		managedContext: managedContext)

	CredentialModel.create(
		data: "".data(using: .utf8)!,
		validFrom: validFromDate,
		expirationTime: expirationTime,
		greenCard: greenCard,
		managedContext: managedContext)
}
#endif
