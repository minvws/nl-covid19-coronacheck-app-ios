//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Reachability

class DashboardStrippenRefresher: Logging {

	enum Error: Swift.Error, LocalizedError, Equatable {
		case unknownErrorA
		case logicalErrorA
		case greencardLoaderError(error: GreenCardLoader.Error)

		var errorDescription: String? {
			switch self {
				case .greencardLoaderError(let error):
					return error.localizedDescription
				case .logicalErrorA:
					return "Logical error A"
				case .unknownErrorA:
					return "Unknown error A"
			}
		}
	}

	struct State: Equatable {

		// MARK: - Types
		enum LoadingState: Equatable {
			case idle
			case loading(silently: Bool)
			case failed(error: DashboardStrippenRefresher.Error)
			case noInternet // waitingForInternet?
			case completed // nothing more to do.

			var isLoading: Bool {
				switch self {
					case .loading: return true
					default: return false
				}
			}
		}

		enum GreencardsCredentialExpiryState: Equatable {
			case noActionNeeded
			case expired
			case expiring(deadline: Date)
		}

		// MARK: - Vars
		private(set) var loadingState: LoadingState = .idle
		var greencardsCredentialExpiryState: GreencardsCredentialExpiryState

		// purpose: until a user dismisses the error, it should be presented via an alert.
		// thereafter, it should be displayed non-modally in the UI instead.
		var userHasPreviouslyDismissedALoadingError: Bool = false
		var hasLoadingEverFailed: Bool = false // for whatever reason (server or connection)
		var serverErrorOccurenceCount = 0

		// Whether the refresher is (non-silently) loading.
		// (if you want to check for silent loading, check the state directly).
		var isNonsilentlyLoading: Bool {
			loadingState == .loading(silently: false)
		}

		// MARK: - Methods
		mutating func beginLoading() {
			self.loadingState = .loading(silently: !hasLoadingEverFailed && greencardsCredentialExpiryState != .expired)
		}

		mutating func endLoading() {
			self.loadingState = .idle
		}

		// Apply an error state to the current loading state:
		mutating func endLoadingWithError(error: Swift.Error) {
			var state = self
			state.hasLoadingEverFailed = true

			switch error {
				// FUTURE: noInternetConnection etc should be removed from GreenCardLoader and just use NetworkError instead.
				case GreenCardLoader.Error.noInternetConnection, GreenCardLoader.Error.requestTimedOut: // Future: handle timeout separately.
					state.loadingState = .noInternet
				case let error as GreenCardLoader.Error:
					state.serverErrorOccurenceCount += 1
					state.loadingState = .failed(error: .greencardLoaderError(error: error))
				case let error as DashboardStrippenRefresher.Error:
					state.loadingState = .failed(error: error)
				default:
					state.loadingState = .failed(error: .unknownErrorA)
			}
			self = state
		}
	}

	private(set) var state: State {
		didSet {
			if state != oldValue {
				DispatchQueue.main.async {
					self.didUpdate?(oldValue, self.state)
				}
			}
		}
	}
	var didUpdate: ((State?, State) -> Void)? {
		didSet {
			DispatchQueue.main.async {
				// Immediately provide the current value:
				self.didUpdate?(nil, self.state)
			}
		}
	}

	private let walletManager: WalletManaging
	private let greencardLoader: GreenCardLoading
	private let reachability: Reachability?

	private let minimumThresholdOfValidCredentialsTriggeringRefresh: Int // (values <= this number trigger refresh.)

	init(minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: Int, walletManager: WalletManaging, greencardLoader: GreenCardLoading) {
		self.minimumThresholdOfValidCredentialsTriggeringRefresh = minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh
		self.walletManager = walletManager
		self.greencardLoader = greencardLoader

		let expiryState = DashboardStrippenRefresher.calculateGreenCardsCredentialExpiryState(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh,
			walletManager: walletManager
		)

		state = State(greencardsCredentialExpiryState: expiryState)

		// Start updates for network access availablity:
		self.reachability = try? Reachability()
		reachability?.whenReachable = { [weak self] _ in
			guard let self = self,
				  self.state.loadingState == .noInternet
			else { return }

			self.load()
		}
		reachability?.whenUnreachable = { _ in }
		try? reachability?.startNotifier()
	}

	func load() {

		guard !state.loadingState.isLoading else {
			logDebug("@id Skipping call to `load()` as a load is already in progress.")
			return
		}

		switch state.greencardsCredentialExpiryState {
			case .noActionNeeded:
				self.logDebug("@id No greencards within threshold of needing refreshing, skipping refresh.")

			case .expired, .expiring:
				state.beginLoading()
				greencardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: nil) { [self] in
					switch $0 {
						case .success:
							self.state.endLoading()

							let newExpiryState = DashboardStrippenRefresher.calculateGreenCardsCredentialExpiryState(
								minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: minimumThresholdOfValidCredentialsTriggeringRefresh,
								walletManager: walletManager
							)

							// The state should have changed - if not, throw error to avoid infinite loop.
							guard newExpiryState != state.greencardsCredentialExpiryState else {
								self.state.endLoadingWithError(error: Error.logicalErrorA)
								return
							}

							self.state.greencardsCredentialExpiryState = newExpiryState

						case .failure(let greenCardLoaderError):
							self.state.endLoadingWithError(error: greenCardLoaderError)
					}
				}
		}
	}

	func userDismissedALoadingError() {
		state.userHasPreviouslyDismissedALoadingError = true
	}

	/// Greencards where the number of valid credentials is <= 5 and the latest credential expiration time is < than the origin expiration time
	private static func calculateGreenCardsCredentialExpiryState(minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: Int, walletManager: WalletManaging, now: Date = Date()) -> State.GreencardsCredentialExpiryState {
		let validGreenCardsForCurrentWallet = walletManager.greencardsWithUnexpiredOrigins(now: now)

		var expiredGreencards = [GreenCard]()
		var expiringGreencards = [(GreenCard, Date)]()

		validGreenCardsForCurrentWallet
			.forEach { (greencard: GreenCard) in

				guard let allCredentialsForGreencard: [Credential] = greencard.castCredentials(),
					  let allOriginsForGreencard = greencard.castOrigins()
				else { return } // unlikely logical error, greencard should have non-nil origins & credentials arrays (even if empty).

				guard let latestOriginExpiryDate = allOriginsForGreencard.latestOriginExpiryTime()
				else { return } // unlikely logical error, origins should have an expiry time, even if it's in the past.

				guard let latestCredentialExpiryDate = allCredentialsForGreencard.furthestFutureCredentialExpiryTime()
				else { return } // unlikely logical error, credentials should have an expiry time, even if it's in the past.

				// Calculate if the latest credential expiration time is < than the origin expiration time
				// (i.e. "if the Green Card has a longer validity than the latest Credential")
				let thereAreMoreCredentialsToFetch = latestCredentialExpiryDate < latestOriginExpiryDate

				guard thereAreMoreCredentialsToFetch
				else { return } // Yes we're running out of credentials, but actually the greencard itself is expiring. The user will need to add a new one.

				guard let daysUntilLastCredentialExpiry = Calendar.current.dateComponents([.day], from: now, to: latestCredentialExpiryDate).day
				else { return } // unlikely logical error, Calendar should be able to make the calculation.

				// Calculate how many valid credentials are remaining, and if that is below the threshold:
				// let remainingValidCredentialsForGreencard = allCredentialsForGreencard.filterValid()
				let greencardIsWithinThresholdForRefresh = daysUntilLastCredentialExpiry <= minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh

				guard greencardIsWithinThresholdForRefresh
				else { return } // There are still plenty of credentials remaining, no need to refresh.

				if daysUntilLastCredentialExpiry <= 0 {
					expiredGreencards += [greencard]
				} else {
					expiringGreencards += [(greencard, latestCredentialExpiryDate)]
				}
			}

		switch (expiredGreencards.count, expiringGreencards.count) {
			case (0, 0): return .noActionNeeded
			case (0, _):
				let earliestExpiryDate = expiringGreencards.map({ $1 }).reduce(.distantFuture) { result, date in
					return date < result ? date : result
				}
				return .expiring(deadline: earliestExpiryDate)
			case (_, _): return .expired
		}
	}
}