/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class FetchEventsViewModel: Logging {

	weak var coordinator: VaccinationCoordinatorDelegate?

	// Resulting token from DigiD VWS
	private var tvsToken: String

	// List of tokens for the vaccination event providers
	private var accessTokens = [Vaccination.AccessToken]()

	/// List of event providers
	private var eventProviders = [Vaccination.EventProvider]()

	private var eventInformationAvailableResults = [Vaccination.EventInformationAvailable]()

	private var eventResponses = [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)]()

	private var networkManager: NetworkManaging
	private var walletManager: WalletManaging

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: VaccinationCoordinatorDelegate,
		tvsToken: String,
		networkManager: NetworkManaging = Services.networkManager,
		walletManager: WalletManaging = WalletManager()) {
		self.coordinator = coordinator
		self.tvsToken = tvsToken
		self.networkManager = networkManager
		self.walletManager = walletManager

		startFetching()
	}

	func backButtonTapped() {

		coordinator?.fetchEventsScreenDidFinish(.stop)
	}

	// MARK: Fetch access tokens and event providers

	private func fetchVaccinationAccessTokens() {

		prefetchingGroup.enter()
		progressIndicationCounter.increment()
		networkManager.fetchVaccinationAccessTokens(tvsToken: tvsToken) { [weak self] result in
			switch result {
				case let .failure(error):
					self?.logError("Error getting access tokens: \(error)")
				case let .success(tokens):
					self?.accessTokens = tokens
			}
			self?.progressIndicationCounter.decrement()
			self?.prefetchingGroup.leave()
		}
	}

	private func fetchVaccinationEventProviders() {

		prefetchingGroup.enter()
		progressIndicationCounter.increment()
		networkManager.fetchVaccinationEventProviders { [weak self] result in
			switch result {
				case let .failure(error):
					self?.logError("Error getting event providers: \(error)")
				case let .success(providers):
					self?.eventProviders = providers
			}
			self?.progressIndicationCounter.decrement()
			self?.prefetchingGroup.leave()
		}
	}

	private func startFetching() {

		fetchVaccinationAccessTokens()
		fetchVaccinationEventProviders()

		prefetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedFetching()
		}
	}

	private func finishedFetching() {

		updateEventProvidersWithAccessTokens()
		fetchHasEventInformationResponses()
	}

	private func updateEventProvidersWithAccessTokens() {

		for index in 0 ..< eventProviders.count {
			for accessToken in accessTokens where eventProviders[index].identifier == accessToken.providerIdentifier {
				eventProviders[index].accessToken = accessToken
			}
		}
	}

	// MARK: Fetch event information

	private func fetchHasEventInformationResponses() {

		for provider in eventProviders {
			fetchHasEventInformationResponse(from: provider)
		}
		hasEventInformationFetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedHasEventInformationFetching()
		}
	}

	private func fetchHasEventInformationResponse(from provider: Vaccination.EventProvider) {

		if let url = provider.unomiURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https") {

			self.logInfo("evenprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

			progressIndicationCounter.increment()
			hasEventInformationFetchingGroup.enter()
			networkManager.fetchVaccinationEventInformation(provider: provider) { [weak self] result in
				// Result<Vaccination.EventInformationAvailable, NetworkError>
				switch result {
					case let .failure(error):
						self?.logError("Error getting unomi: \(error)")
					case let .success(response):
						self?.eventInformationAvailableResults.append(response)
				}
				self?.progressIndicationCounter.decrement()
				self?.hasEventInformationFetchingGroup.leave()
			}
		}
	}

	private func finishedHasEventInformationFetching() {

		updateEventProvidersWithHasEventInformationResponse()
		fetchVaccinationEvents()
	}

	private func updateEventProvidersWithHasEventInformationResponse() {

		for index in 0 ..< eventProviders.count {
			for response in eventInformationAvailableResults where eventProviders[index].identifier == response.providerIdentifier {
				eventProviders[index].eventInformationAvailable = response
			}
		}
	}

	// MARK: Fetch vaccination events

	private func fetchVaccinationEvents() {

		for provider in eventProviders {
			fetchVaccinationEvent(from: provider)
		}
		eventFetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedEventFetching()
		}
	}

	private func fetchVaccinationEvent(from provider: Vaccination.EventProvider) {

		if let url = provider.eventURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
		   let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable {

			progressIndicationCounter.increment()
			eventFetchingGroup.enter()
			networkManager.fetchVaccinationEvents(provider: provider) { [weak self] result in
				// (Result<(TestResultWrapper, SignedResponse), NetworkError>

				switch result {
					case let .failure(error):
						self?.logError("Error getting event: \(error)")
					case let .success(response):
						self?.eventResponses.append(response)
				}
				self?.progressIndicationCounter.decrement()
				self?.eventFetchingGroup.leave()
			}
		}
	}

	private func finishedEventFetching() {

		logInfo("finishedEventFetching")

		var eventGroups = [EventGroup]()
		for response in eventResponses where response.wrapper.status == .complete {

			// Remove any existing vaccination events for the provider
			walletManager.removeExistingEventGroups(type: .vaccination, providerIdentifier: response.wrapper.providerIdentifier)

			// Store the new vaccination events

			if let maxIssuedAt = response.wrapper.getMaxIssuedAt(dateFormatter),
			   let eventGroup = walletManager.storeEventGroup(
				.vaccination,
				providerIdentifier: response.wrapper.providerIdentifier,
				signedResponse: response.signedResponse,
				issuedAt: maxIssuedAt
			   ) {
				eventGroups.append(eventGroup)
			}

			// Notify
			logInfo("Stored information \(eventGroups)")
		}
	}

	lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd"

		return dateFormatter
	}()
}
