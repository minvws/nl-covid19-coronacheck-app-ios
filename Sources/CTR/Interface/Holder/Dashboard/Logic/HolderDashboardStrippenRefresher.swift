/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Reachability
import UIKit

protocol DashboardStrippenRefreshing: AnyObject {
	func load()
	func userDismissedALoadingError()

	var didUpdate: ((DashboardStrippenRefresher.State?, DashboardStrippenRefresher.State) -> Void)? { get set }
}

class DashboardStrippenRefresher: DashboardStrippenRefreshing, Logging {

	enum Error: Swift.Error, LocalizedError, Equatable {
		case unknownErrorA
		case logicalErrorA
		case greencardLoaderError(error: GreenCardLoader.Error)
		case networkError(error: NetworkError, timestamp: Date)

		var errorDescription: String? {
			switch self {
				case .greencardLoaderError(let error):
					return error.errorDescription
				case .networkError(let error, _):
					return error.rawValue
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
		private(set) var now: () -> Date
		var greencardsCredentialExpiryState: GreencardsCredentialExpiryState
		// purpose: until a user dismisses the error, it should be presented via an alert.
		// thereafter, it should be displayed non-modally in the UI instead.
		var userHasPreviouslyDismissedALoadingError: Bool = false
		var hasLoadingEverFailed: Bool = false // for whatever reason (server or connection)
		var errorOccurenceCount = 0 // Excludes simple "no internet" events

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
				case NetworkError.noInternetConnection:
					state.loadingState = .noInternet

				case let error as NetworkError:
					state.errorOccurenceCount += 1
					state.loadingState = .failed(error: .networkError(error: error, timestamp: now()))

				// Catch the specific case of a wrapped NetworkError.noInternetConnection and recurse it
				case GreenCardLoader.Error.credentials(.error(_, _, let networkError)),
					 GreenCardLoader.Error.preparingIssue(.error(_, _, let networkError)):
					endLoadingWithError(error: networkError)
					return // don't update `state` on this iteration.

				case let error as GreenCardLoader.Error:
					state.errorOccurenceCount += 1
					state.loadingState = .failed(error: .greencardLoaderError(error: error))

				case let error as DashboardStrippenRefresher.Error:
					state.loadingState = .failed(error: error)

				default:
					state.loadingState = .failed(error: .unknownErrorA)
			}
			self = state
		}

		static func == (lhs: DashboardStrippenRefresher.State, rhs: DashboardStrippenRefresher.State) -> Bool {
			return lhs.loadingState == rhs.loadingState
				&& lhs.greencardsCredentialExpiryState == rhs.greencardsCredentialExpiryState
				&& lhs.userHasPreviouslyDismissedALoadingError == rhs.userHasPreviouslyDismissedALoadingError
				&& lhs.hasLoadingEverFailed == rhs.hasLoadingEverFailed
				&& lhs.errorOccurenceCount == rhs.errorOccurenceCount
				&& lhs.now() == rhs.now()
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
	private let reachability: ReachabilityProtocol?

	private let now: () -> Date
	private let minimumThresholdOfValidCredentialsTriggeringRefresh: Int // (values <= this number trigger refresh.)

	init(minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: Int, walletManager: WalletManaging, greencardLoader: GreenCardLoading, reachability: ReachabilityProtocol?, now: @escaping () -> Date) {
		self.minimumThresholdOfValidCredentialsTriggeringRefresh = minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh
		self.walletManager = walletManager
		self.greencardLoader = greencardLoader
		self.now = now

		let expiryState = DashboardStrippenRefresher.calculateGreenCardsCredentialExpiryState(
			minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh,
			walletManager: walletManager,
			now: now()
		)

		state = State(now: now, greencardsCredentialExpiryState: expiryState)

		// Start updates for network access availablity:
		self.reachability = reachability
		reachability?.whenReachable = { [weak self] _ in
			guard let self = self,
				  self.state.loadingState == .noInternet
			else { return }

			self.load()
		}
		try? reachability?.startNotifier()

		// Hotfix for 2.3.3:
		NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { [weak self] _ in
			guard let self = self else { return }

			// We've returned from the background.
			// Is the StrippenRefresher currently in a failed state due to a network error?
			// Is it also at least 10 minutes since the error occurred?
			// Then: reload the strippen refresher again.
			switch (self.state.loadingState, self.state.greencardsCredentialExpiryState) {
				case (.failed(DashboardStrippenRefresher.Error.networkError(_, timestamp: let failureDate)), .expired):
					let delay: Double = 10 * 60 // Threshold of time to wait until retrying: 10 minutes

					if self.now().timeIntervalSince(failureDate) > delay {
						self.load()
					}

				default:
					break
			}
		}
	}

	func load() {

		guard !state.loadingState.isLoading else {
			logDebug("StrippenRefresh: Skipping call to `load()` as a load is already in progress.")
			return
		}

		switch state.greencardsCredentialExpiryState {
			case .noActionNeeded:
				self.logDebug("StrippenRefresh: No greencards within threshold of needing refreshing. Skipping refresh.")

			case .expired, .expiring:
				state.beginLoading()
				greencardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: nil) { [weak self] in
					guard let self = self else { return }

					switch $0 {
						case .success:
							self.state.endLoading()

							let newExpiryState = DashboardStrippenRefresher.calculateGreenCardsCredentialExpiryState(
								minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: self.minimumThresholdOfValidCredentialsTriggeringRefresh,
								walletManager: self.walletManager,
								now: self.now()
							)

							// The state should have changed - if not, throw error to avoid infinite loop.
							guard newExpiryState != self.state.greencardsCredentialExpiryState else {
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
	private static func calculateGreenCardsCredentialExpiryState(
		minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh: Int,
		walletManager: WalletManaging,
		now: Date) -> State.GreencardsCredentialExpiryState {
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

				guard !allCredentialsForGreencard.isEmpty else {
					// It can be that a greencard is issued with zero credentials, but that it can still become valid in the future
					// (receiving credentials at some later point beyond the current signer horizon).
					if let originsValidWithinThreshold = greencard.originsActiveNowOrBeforeThresholdFromNow(
						now: now,
						thresholdDays: minimumThresholdOfValidCredentialDaysRemainingToTriggerRefresh),
					   !originsValidWithinThreshold.isEmpty {

						// Expired here is not quite accurate, because it never had a credential before.
						// But this is the correct external state for the Refresher to adopt for this greencard.
						expiredGreencards += [greencard]
					}
					return
				}

				guard let latestCredentialExpiryDate = allCredentialsForGreencard.latestCredentialExpiryTime()
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
