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
	private var networkManager: NetworkManaging
	private var walletManager: WalletManaging

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		dateFormatter.dateFormat = "yyyy-MM-dd"

		return dateFormatter
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

		startFetchingEventProvidersWithAccessTokens { eventProviders in
			self.fetchHasEventInformation(eventProviders: eventProviders) { eventProvidersWithEventInformation in
				self.fetchVaccinationEvents(eventProviders: eventProvidersWithEventInformation) { eventResponses in
					self.storeVaccinationEvent(eventResponses: eventResponses) { saved in
						self.logInfo("Finished vaccination flow: \(saved)")
					}
				}
			}
		}
	}

	func backButtonTapped() {

		coordinator?.fetchEventsScreenDidFinish(.stop)
	}

	// MARK: Fetch access tokens and event providers

	private func startFetchingEventProvidersWithAccessTokens(_ onCompletion: @escaping ([Vaccination.EventProvider]) -> Void) {

		var accessTokenResult: Result<[Vaccination.AccessToken], NetworkError>?
		fetchVaccinationAccessTokens { result in
			accessTokenResult = result
		}

		var vaccinationEventProvidersResult: Result<[Vaccination.EventProvider], NetworkError>?
		fetchVaccinationEventProviders { result in
			vaccinationEventProvidersResult = result
		}

		prefetchingGroup.notify(queue: DispatchQueue.main) {

			switch (accessTokenResult, vaccinationEventProvidersResult) {
				case (.success(let accessTokens), .success(let eventProviders)):
					var eventProviders = eventProviders // mutable
					for index in 0 ..< eventProviders.count {
						for accessToken in accessTokens where eventProviders[index].identifier == accessToken.providerIdentifier {
							eventProviders[index].accessToken = accessToken
						}
					}
					onCompletion(eventProviders)

				case (.failure(let error), _):
					self.logError("Error getting access tokens: \(error)")

				case (_, .failure(let error)):
					self.logError("Error getting event providers: \(error)")

				default:
					// this should not happen due to the prefetching group
					self.logError("Unexpected: did not receive response from accessToken or eventProviders call")
			}
		}
	}

	private func fetchVaccinationAccessTokens(completion: @escaping (Result<[Vaccination.AccessToken], NetworkError>) -> Void) {

		prefetchingGroup.enter()
		progressIndicationCounter.increment()
		networkManager.fetchVaccinationAccessTokens(tvsToken: tvsToken) { [weak self] result in
			completion(result)
			self?.progressIndicationCounter.decrement()
			self?.prefetchingGroup.leave()
		}
	}

	private func fetchVaccinationEventProviders(completion: @escaping (Result<[Vaccination.EventProvider], NetworkError>) -> Void) {

		prefetchingGroup.enter()
		progressIndicationCounter.increment()
		networkManager.fetchVaccinationEventProviders { [weak self] result in
			completion(result)
			self?.progressIndicationCounter.decrement()
			self?.prefetchingGroup.leave()
		}
	}

	// MARK: Fetch event information

	private func fetchHasEventInformation(eventProviders: [Vaccination.EventProvider], onCompletion: @escaping ([Vaccination.EventProvider]) -> Void) {

		var eventInformationAvailableResults = [Vaccination.EventInformationAvailable]()

		for provider in eventProviders {
			fetchHasEventInformationResponse(from: provider) { result in
				switch result {
					case let .failure(error):
						self.logError("Error getting unomi: \(error)")
					case let .success(response):
						eventInformationAvailableResults.append(response)
				}
			}
		}

		hasEventInformationFetchingGroup.notify(queue: DispatchQueue.main) {
			var outputEventProviders = eventProviders

			for index in 0 ..< eventProviders.count {
				for response in eventInformationAvailableResults where eventProviders[index].identifier == response.providerIdentifier {
					outputEventProviders[index].eventInformationAvailable = response
				}
			}
			onCompletion(outputEventProviders)
		}
	}

	private func fetchHasEventInformationResponse(from provider: Vaccination.EventProvider, completion: @escaping (Result<Vaccination.EventInformationAvailable, NetworkError>) -> Void) {

		if let url = provider.unomiURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https") {

			self.logInfo("evenprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

			progressIndicationCounter.increment()
			hasEventInformationFetchingGroup.enter()
			networkManager.fetchVaccinationEventInformation(provider: provider) { [weak self] result in
				// Result<Vaccination.EventInformationAvailable, NetworkError>
				completion(result)
				self?.progressIndicationCounter.decrement()
				self?.hasEventInformationFetchingGroup.leave()
			}
		}
	}

	// MARK: Fetch vaccination events

	private func fetchVaccinationEvents(eventProviders: [Vaccination.EventProvider], onCompletion: @escaping ( [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)]) -> Void) {

		var eventResponses = [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)]()

		for provider in eventProviders {
			fetchVaccinationEvent(from: provider) { result in
				switch result {
					case let .failure(error):
						self.logError("Error getting event: \(error)")
					case let .success(response):
						eventResponses.append(response)
				}
			}
		}

		eventFetchingGroup.notify(queue: DispatchQueue.main) {
			onCompletion(eventResponses)
		}
	}

	private func fetchVaccinationEvent(from provider: Vaccination.EventProvider, completion: @escaping (Result<(Vaccination.EventResultWrapper, SignedResponse), NetworkError>) -> Void) {

		if let url = provider.eventURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https"),
		   let eventInformationAvailable = provider.eventInformationAvailable, eventInformationAvailable.informationAvailable {

			progressIndicationCounter.increment()
			eventFetchingGroup.enter()
			networkManager.fetchVaccinationEvents(provider: provider) { [weak self] result in
				// (Result<(TestResultWrapper, SignedResponse), NetworkError>
				completion(result)
				self?.progressIndicationCounter.decrement()
				self?.eventFetchingGroup.leave()
			}
		}
	}

	// MARK: Store vaccination events

	private func storeVaccinationEvent(eventResponses: [(wrapper: Vaccination.EventResultWrapper, signedResponse: SignedResponse)], onCompletion: @escaping (Bool) -> Void) {

		var success = true
		for response in eventResponses where response.wrapper.status == .complete {

			// Remove any existing vaccination events for the provider
			walletManager.removeExistingEventGroups(type: .vaccination, providerIdentifier: response.wrapper.providerIdentifier)

			// Store the new vaccination events

			if let maxIssuedAt = response.wrapper.getMaxIssuedAt(dateFormatter) {
				success = success && walletManager.storeEventGroup(
					.vaccination,
					providerIdentifier: response.wrapper.providerIdentifier,
					signedResponse: response.signedResponse,
					issuedAt: maxIssuedAt
				)
				if !success {
					break
				}
			}
		}
		onCompletion(success)
	}
}