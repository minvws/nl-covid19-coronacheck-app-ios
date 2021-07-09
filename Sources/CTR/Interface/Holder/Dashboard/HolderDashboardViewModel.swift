/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable file_length

import UIKit
import CoreData

class HolderDashboardViewModel: Logging {

	// MARK: - Public properties

	/// The logging category
	var loggingCategory: String = "HolderDashboardViewModel"

	/// The title of the scene
	@Bindable private(set) var title: String = L.holderDashboardTitle()

	@Bindable private(set) var cards = [HolderDashboardViewController.Card]()
	
	@Bindable private(set) var primaryButtonTitle = L.holderMenuProof()
	
	@Bindable private(set) var hasAddCertificateMode: Bool = false
	
	@Bindable private(set) var regionMode: (buttonTitle: String, currentLocationTitle: String)? = (buttonTitle: L.holderDashboardChangeregionButtonEu(),
																								  currentLocationTitle: L.holderDashboardChangeregionTitleNl())

	// MARK: - Private types

	/// Wrapper around some state variables
	/// that allows us to use a `didSet{}` to
	/// get a callback if any of them are mutated.
	fileprivate struct State {
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
			
			hasAddCertificateMode = state.myQRCards.isEmpty
			
			// If there are any cards to show, show the region picker:
			if !state.myQRCards.isEmpty {
				switch state.qrCodeValidityRegion {
					case .domestic:
						regionMode = (buttonTitle: L.holderDashboardChangeregionButtonEu(), currentLocationTitle: L.holderDashboardChangeregionTitleNl())
					case .europeanUnion:
						regionMode = (buttonTitle: L.holderDashboardChangeregionButtonNl(), currentLocationTitle: L.holderDashboardChangeregionTitleEu())
				}
			} else {
				regionMode = nil
			}
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
	///   - dataStoreManager: the data store manager
	init(
		coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol),
		cryptoManager: CryptoManaging,
		proofManager: ProofManaging,
		configuration: ConfigurationGeneralProtocol,
		dataStoreManager: DataStoreManaging
	) {

		self.coordinator = coordinator
		self.cryptoManager = cryptoManager
		self.proofManager = proofManager
		self.configuration = configuration
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
		coordinator?.userWishesToCreateAQR()
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

		if !state.myQRCards.isEmpty {
			cards += [.headerMessage(
						message: {
							return state.qrCodeValidityRegion == .domestic
								? L.holderDashboardIntroDomestic()
								: L.holderDashboardIntroInternational()
						}())
			]
		}

		cards += state.expiredGreenCards.compactMap { expiredQR -> HolderDashboardViewController.Card? in
			guard expiredQR.region == state.qrCodeValidityRegion else { return nil }

			let message = String.holderDashboardQRExpired(
				localizedRegion: expiredQR.region.localizedAdjective,
				localizedOriginType: expiredQR.type.localizedProof
			)

			return .expiredQR(message: message, didTapClose: {
				didTapCloseExpiredQR(expiredQR)
			})
		}

		if state.myQRCards.isEmpty {
			cards += [
				.emptyState(
					title: L.holderDashboardEmptyTitle(),
					message: L.holderDashboardEmptyMessage()
				)
			]
		}

		// for each origin which is in the other region but not in this one, add a new MessageCard to explain.
		// e.g. "Je vaccinatie is niet geldig in Europa. Je hebt alleen een Nederlandse QR-code."
		cards += localizedOriginsValidOnlyInOtherRegionsMessages(state: state)
			.sorted(by: { $0.originType.customSortIndex < $1.originType.customSortIndex })
			.map { originType, message in
				return .originNotValidInThisRegion(message: message) {
					coordinatorDelegate.userWishesMoreInfoAboutUnavailableQR(
						originType: originType,
						currentRegion: state.qrCodeValidityRegion,
						availableRegion: state.qrCodeValidityRegion.opposite)
				}
			}

		cards += state.myQRCards

			// Map a `MyQRCard` to a `VC.Card`:
			.flatMap { (qrcardDataItem: HolderDashboardViewModel.MyQRCard) -> [HolderDashboardViewController.Card] in

				switch (state.qrCodeValidityRegion, qrcardDataItem) {
					case (.domestic, .netherlands(let greenCardObjectID, let origins, let evaluateEnabledState)):
						let rows = origins.map { origin in
							HolderDashboardViewController.Card.QRCardRow(
								typeText: origin.type.localizedProof.capitalizingFirstLetter(),
								validityTextEvaluator: { now in
									qrcardDataItem.localizedDateExplanation(forOrigin: origin, forNow: now)
								}
							)
						}

						return [HolderDashboardViewController.Card.domesticQR(
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

								return (L.holderDashboardQrExpiryDatePrefixExpiresIn() + " " + relativeDateString).trimmingCharacters(in: .whitespacesAndNewlines)
							}
						)]

					case (.europeanUnion, .europeanUnion(let greenCardObjectID, let origins, let evaluateEnabledState)):
						let rows = origins.map { origin in
							HolderDashboardViewController.Card.QRCardRow(
								typeText: origin.type.localizedEvent.capitalizingFirstLetter(),
								validityTextEvaluator: { now in
									qrcardDataItem.localizedDateExplanation(forOrigin: origin, forNow: now)
								}
							)
						}

						return [HolderDashboardViewController.Card.europeanUnionQR(
							rows: rows,
							didTapViewQR: { coordinatorDelegate.userWishesToViewQR(greenCardObjectID: greenCardObjectID) },
							buttonEnabledEvaluator: evaluateEnabledState,
							expiryCountdownEvaluator: nil
						)]

					default: return []
				}
			}

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

			let type: QRCodeOriginType // vaccination | test | recovery
			let eventDate: Date
			let expirationTime: Date
			let validFromDate: Date

			/// There is a particular order to sort these onscreen
			var customSortIndex: Int {
				type.customSortIndex
			}

			var isNotYetExpired: Bool {
				expirationTime > Date()
			}

			var isCurrentlyValid: Bool {
				isValid(duringDate: Date())
			}

			func isValid(duringDate date: Date) -> Bool {
				date.isWithinTimeWindow(from: validFromDate, to: expirationTime)
			}

			var expiryIsBeyondThreeYearsFromNow: Bool {
				let threeYearsFromNow: TimeInterval = 60 * 60 * 24 * 365 * 3
				return expirationTime > Date(timeIntervalSinceNow: threeYearsFromNow)
			}
		}

		func isOfRegion(region: QRCodeValidityRegion) -> Bool {
			switch (self, region) {
				case (.europeanUnion, .europeanUnion): return true
				case (.netherlands, .domestic): return true
				default: return false
			}
		}

		func localizedDateExplanation(forOrigin origin: Origin, forNow now: Date = Date()) -> HolderDashboardViewController.ValidityText {
			
			if origin.expirationTime < now { // expired
				return .init(text: "", kind: .past)
			} else if origin.validFromDate > now {
				if origin.validFromDate > (now.addingTimeInterval(60 * 60 * 24)) { // > 1 day until valid

					// we want "full" days in future, so calculate by midnight of the validFromDate day, minus 1 second.
					// (note, when there is <1 day remaining, it switches to counting down in
					// hours/minutes using `HolderDashboardViewModel.hmsRelativeFormatter`
					// elsewhere, so this doesn't apply there anyway.
					let validFromDateEndOfDay: Date? = origin.validFromDate.oneSecondBeforeMidnight

					let dateString = validFromDateEndOfDay.flatMap {
						HolderDashboardViewModel.daysRelativeFormatter.string(from: Date(), to: $0)
					} ?? "-"

					let prefix = localizedDateExplanationPrefix(forOrigin: origin)
					return .init(
						text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
						kind: .future
					)
				} else {
					let dateString = HolderDashboardViewModel.hmsRelativeFormatter.string(from: Date(), to: origin.validFromDate) ?? "-"
					let prefix = localizedDateExplanationPrefix(forOrigin: origin)
					return .init(
						text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
						kind: .future
					)
				}
			} else {
				switch self {
					// Netherlands uses expireTime
					case .netherlands:
						if origin.expiryIsBeyondThreeYearsFromNow {
							let prefix = localizedDateExplanationPrefix(forOrigin: origin)
							return .init(text: prefix, kind: .future)
						} else {
							let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.expirationTime)
							let prefix = localizedDateExplanationPrefix(forOrigin: origin)
								return .init(
									text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
									kind: .current
								)
						}

					// EU cards use Valid From (eventTime) because we don't know the expiry date
					case .europeanUnion:
						let dateString = localizedDateExplanationDateFormatter(forOrigin: origin).string(from: origin.validFromDate)
						let prefix = localizedDateExplanationPrefix(forOrigin: origin)
						return .init(
							text: (prefix + " " + dateString).trimmingCharacters(in: .whitespacesAndNewlines),
							kind: .current
						)
				}
			}
		}

		/// There is a particular order to sort these onscreen
		var customSortIndex: Int {
			guard let firstOrigin = origins.first else { return .max }
			return firstOrigin.customSortIndex
		}

		// MARK: - private

		/// Each origin has its own prefix
		private func localizedDateExplanationPrefix(forOrigin origin: Origin) -> String {

			switch self {
				case .netherlands:
					if origin.isCurrentlyValid {
						if origin.expiryIsBeyondThreeYearsFromNow {
							return ""
						} else {
							return L.holderDashboardQrExpiryDatePrefixValidUptoAndIncluding()
						}

					} else {
						return L.holderDashboardQrValidityDatePrefixAutomaticallyBecomesValidOn()
					}

				case .europeanUnion:
					if !origin.isCurrentlyValid && origin.isNotYetExpired {
						return L.holderDashboardQrValidityDatePrefixAutomaticallyBecomesValidOn()
					} else {
						return ""
					}
			}
		}

		/// Each origin has a different date/time format
		/// (Region + Origin) -> DateFormatter
		private func localizedDateExplanationDateFormatter(forOrigin origin: Origin) -> DateFormatter {
			switch (self, origin.type) {
				case (.netherlands, .test):
					return HolderDashboardViewModel.dateWithDayAndTimeFormatter

				case (.netherlands, _):
					return HolderDashboardViewModel.dateWithoutTimeFormatter

				case (.europeanUnion, .vaccination):
					return HolderDashboardViewModel.dateWithoutTimeFormatter

				case (.europeanUnion, .recovery):
					return HolderDashboardViewModel.dayAndMonthFormatter

				case (.europeanUnion, .test):
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

// MARK: - Free Functions

private func localizedOriginsValidOnlyInOtherRegionsMessages(state: HolderDashboardViewModel.State) -> [(originType: QRCodeOriginType, message: String)] {

	// Calculate origins which exist in the other region but are not in this region:
	let originTypesForCurrentRegion = Set(state.myQRCards
		.filter { $0.isOfRegion(region: state.qrCodeValidityRegion) }
		.flatMap { $0.origins }
		.filter {
			$0.isNotYetExpired
		}
		.compactMap { $0.type }
	)

	let originTypesForOtherRegion = Set(state.myQRCards
		.filter { !$0.isOfRegion(region: state.qrCodeValidityRegion) }
		.flatMap { $0.origins }
		.filter {
			$0.isNotYetExpired
		}
		.compactMap { $0.type }
	)

	let originTypesOnlyInOtherRegion = originTypesForOtherRegion
		.subtracting(originTypesForCurrentRegion)

	// Map it to user messages:
	let userMessages = originTypesOnlyInOtherRegion.map { (originType: QRCodeOriginType) -> (originType: QRCodeOriginType, message: String) in
		switch state.qrCodeValidityRegion {
			case .domestic:
				return (originType, L.holderDashboardOriginNotValidInNetherlandsButIsInEU(originType.localizedProof))
			case .europeanUnion:
				return (originType, L.holderDashboardOriginNotValidInEUButIsInTheNetherlands(originType.localizedProof))
		}
	}

	return userMessages
}

#if DEBUG
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
//		let seconds: TimeInterval = 1
		let minutes: TimeInterval = 60
		let hours: TimeInterval = 60 * minutes
		let days: TimeInterval = hours * 24

//		create( type: .recovery,
//				eventDate: Date().addingTimeInterval(14 * days * ago),
//				expirationTime: Date().addingTimeInterval((10 * seconds * fromNow)),
//				validFromDate: Date().addingTimeInterval(fromNow),
//				greenCard: domesticGreenCard,
//				managedContext: context)

		create( type: .vaccination,
				eventDate: Date().addingTimeInterval(14 * days * ago),
				expirationTime: Date().addingTimeInterval((365 * 4 * days * fromNow)),
				validFromDate: Date().addingTimeInterval(fromNow),
				greenCard: domesticGreenCard,
				managedContext: context)

		create( type: .test,
				eventDate: Date().addingTimeInterval(20 * hours * ago),
				expirationTime: Date().addingTimeInterval((20 * hours * fromNow)),
				validFromDate: Date().addingTimeInterval(20 * hours * ago),
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
