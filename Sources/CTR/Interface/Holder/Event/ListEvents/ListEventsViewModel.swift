/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ListEventsViewModel: Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var walletManager: WalletManaging
	var remoteConfigManager: RemoteConfigManaging
	private let greenCardLoader: GreenCardLoading
	let cryptoManager: CryptoManaging?
	private let couplingManager: CouplingManaging
	let mappingManager: MappingManaging
	private let identityChecker: IdentityCheckerProtocol

	var eventMode: EventMode

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	lazy var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()
	
	lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "d MMMM yyyy"
		return dateFormatter
	}()
	lazy var printTestDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EE d MMMM HH:mm"
		return dateFormatter
	}()
	lazy var printTestLongDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()
	lazy var printMonthFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: ListEventsViewController.State

	@Bindable internal var alert: AlertContent?

	@Bindable internal var shouldPrimaryButtonBeEnabled: Bool = true

	@Bindable private(set) var hideForCapture: Bool = false

	private let screenCaptureDetector = ScreenCaptureDetector()

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode,
		remoteEvents: [RemoteEvent],
		greenCardLoader: GreenCardLoading = Services.greenCardLoader,
		walletManager: WalletManaging = Services.walletManager,
		remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager,
		cryptoManager: CryptoManaging = Services.cryptoManager,
		couplingManager: CouplingManaging = Services.couplingManager,
		identityChecker: IdentityCheckerProtocol = IdentityChecker(),
		mappingManager: MappingManaging = Services.mappingManager,
		eventsMightBeMissing: Bool = false
	) {

		self.coordinator = coordinator
		self.eventMode = eventMode
		self.walletManager = walletManager
		self.remoteConfigManager = remoteConfigManager
		self.greenCardLoader = greenCardLoader
		self.cryptoManager = cryptoManager
		self.couplingManager = couplingManager
		self.identityChecker = identityChecker
		self.mappingManager = mappingManager

		viewState = .loading(
			content: Content(
				title: {
					switch eventMode {
						case .recovery:
							return L.holderRecoveryListTitle()
						case .paperflow:
							return L.holderDccListTitle()
						case .test:
							return L.holderTestresultsResultsTitle()
						case .vaccination:
							return L.holderVaccinationListTitle()
					}
				}(),
				subTitle: nil,
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: nil,
				secondaryAction: nil
			)
		)

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}

		if eventsMightBeMissing {
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
				self?.displaySomeResultsMightBeMissing()
			}
		}

		viewState = getViewState(from: remoteEvents)
	}

	func backButtonTapped() {

		switch viewState {
			case .loading, .listEvents:
				warnBeforeGoBack()
			case .feedback:
				goBack()
		}
	}

	func warnBeforeGoBack() {

		alert = AlertContent(
			title: L.holderVaccinationAlertTitle(),
			subTitle: {
				switch eventMode {
					case .recovery:
						return L.holderRecoveryAlertMessage()
					case .paperflow:
						return L.holderDccAlertMessage()
					case .test:
						return L.holderTestAlertMessage()
					case .vaccination:
						return L.holderVaccinationAlertMessage()

				}
			}(),
			cancelAction: nil,
			cancelTitle: L.holderVaccinationAlertCancel(),
			okAction: { [weak self] _ in
				self?.goBack()
			},
			okTitle: L.holderVaccinationAlertOk()
		)
	}

	func goBack() {

		coordinator?.listEventsScreenDidFinish(.back(eventMode: eventMode))
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}

	// MARK: Sign the events

	internal func userWantsToMakeQR(remoteEvents: [RemoteEvent], completion: @escaping (Bool) -> Void) {

		if identityChecker.compare(eventGroups: walletManager.listEventGroups(), with: remoteEvents) {
			storeAndSign(remoteEvents: remoteEvents, replaceExistingEventGroups: false, completion: completion)
		} else {
			showIdentityMismatch {
				// Replace the stored eventgroups
				self.storeAndSign(remoteEvents: remoteEvents, replaceExistingEventGroups: true, completion: completion)
			}
		}
	}

	private func storeAndSign(remoteEvents: [RemoteEvent], replaceExistingEventGroups: Bool, completion: @escaping (Bool) -> Void) {

		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		var eventModeForStorage = eventMode

		if let dccEvent = remoteEvents.first?.wrapper.events?.first?.dccEvent,
			let cryptoManager = cryptoManager,
			let dccEventType = dccEvent.getEventType(cryptoManager: cryptoManager) {
			eventModeForStorage = dccEventType
			logVerbose("Setting eventModeForStorage to \(eventModeForStorage.rawValue)")
		}

		storeEvent(
			remoteEvents: remoteEvents,
			eventModeForStorage: eventModeForStorage,
			replaceExistingEventGroups: replaceExistingEventGroups) { saved in

			guard saved else {
				self.progressIndicationCounter.decrement()
				self.shouldPrimaryButtonBeEnabled = true
				self.handleClientSideError(clientCode: .storingEvents, for: .storingEvents, with: remoteEvents)
				return
			}

			self.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: { [weak self] remoteResponse in
				// Check if we have any origin for the event mode
				// == 0 -> No greenCards from the signer (name mismatch, expired, etc)
				// > 0 -> Success

				let domesticOrigins: Int = remoteResponse.domesticGreenCard?.origins
					.filter { $0.type == eventModeForStorage.rawValue }
					.count ?? 0
				let internationalOrigins: Int = remoteResponse.euGreenCards?
					.flatMap { $0.origins }
					.filter { $0.type == eventModeForStorage.rawValue }
					.count ?? 0

				self?.logVerbose("We got \(domesticOrigins) domestic Origins of type \(eventModeForStorage.rawValue)")
				self?.logVerbose("We got \(internationalOrigins) international Origins of type \(eventModeForStorage.rawValue)")
				return internationalOrigins + domesticOrigins > 0

			}, completion: { result in
				self.progressIndicationCounter.decrement()

				switch result {
					case .success:
						self.coordinator?.listEventsScreenDidFinish(
							.continue(
								value: nil,
								eventMode: self.eventMode
							)
						)

					case .failure(GreenCardLoader.Error.didNotEvaluate):
						self.viewState = self.cannotCreateEventsState()
						self.shouldPrimaryButtonBeEnabled = true

					case .failure(GreenCardLoader.Error.noEvents):
						self.shouldPrimaryButtonBeEnabled = true
						completion(false)

					case .failure(GreenCardLoader.Error.failedToParsePrepareIssue):
						self.handleClientSideError(clientCode: .failedToParsePrepareIssue, for: .nonce, with: remoteEvents)

					case .failure(GreenCardLoader.Error.preparingIssue(let serverError)):
						self.handleServerError(serverError, for: .nonce, with: remoteEvents)

					case .failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage):
						self.handleClientSideError(clientCode: .failedToGenerateCommitmentMessage, for: .nonce, with: remoteEvents)

					case .failure(GreenCardLoader.Error.credentials(let serverError)):
						self.handleServerError(serverError, for: .signer, with: remoteEvents)

					case .failure(GreenCardLoader.Error.failedToSaveGreenCards):
						self.handleClientSideError(clientCode: .failedToSaveGreenCards, for: .storingCredentials, with: remoteEvents)

					case .failure(let error):
						self.logError("storeAndSign - unhandled: \(error)")
						self.handleClientSideError(clientCode: .unhandled, for: .signer, with: remoteEvents)
				}
			})
		}
	}

	func handleClientSideError(clientCode: ErrorCode.ClientCode, for step: ErrorCode.Step, with remoteEvents: [RemoteEvent]) {

		let errorCode = ErrorCode(
			flow: determineErrorCodeFlow(remoteEvents: remoteEvents),
			step: step,
			provider: determineErrorCodeProvider(remoteEvents: remoteEvents),
			errorCode: clientCode.value
		)
		logDebug("errorCode: \(errorCode)")
		viewState = displayClientErrorCode(errorCode)
		shouldPrimaryButtonBeEnabled = true
	}

	func handleServerError(_ serverError: ServerError, for step: ErrorCode.Step, with remoteEvents: [RemoteEvent]) {

		if case let ServerError.error(statusCode, serverResponse, error) = serverError {
			self.logDebug("handleServerError \(serverError)")

			switch error {
				case .serverBusy:
					showServerTooBusyError()
					shouldPrimaryButtonBeEnabled = true
					
				case .serverUnreachable:
					showServerUnreachable(remoteEvents: remoteEvents)
					shouldPrimaryButtonBeEnabled = true

				case .noInternetConnection:
					showNoInternet(remoteEvents: remoteEvents)
					shouldPrimaryButtonBeEnabled = true

				case .responseCached, .redirection, .resourceNotFound, .serverError:
					// 304, 3xx, 4xx, 5xx
					let errorCode = ErrorCode(
						flow: determineErrorCodeFlow(remoteEvents: remoteEvents),
						step: step,
						provider: determineErrorCodeProvider(remoteEvents: remoteEvents),
						errorCode: "\(statusCode ?? 000)",
						detailedCode: serverResponse?.code
					)
					logDebug("errorCode: \(errorCode)")
					viewState = displayServerErrorCode(errorCode)
					shouldPrimaryButtonBeEnabled = true

				case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize:
					// Client side
					let errorCode = ErrorCode(
						flow: determineErrorCodeFlow(remoteEvents: remoteEvents),
						step: step,
						provider: determineErrorCodeProvider(remoteEvents: remoteEvents),
						errorCode: error.getClientErrorCode() ?? "000",
						detailedCode: serverResponse?.code
					)
					logDebug("errorCode: \(errorCode)")
					viewState = displayClientErrorCode(errorCode)
					shouldPrimaryButtonBeEnabled = true
			}
		}

	}

	// MARK: Store events

	private func storeEvent(
		remoteEvents: [RemoteEvent],
		eventModeForStorage: EventMode,
		replaceExistingEventGroups: Bool,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		if replaceExistingEventGroups {
			walletManager.removeExistingEventGroups()
		}

		for response in remoteEvents where response.wrapper.status == .complete {

			var data: Data?

			if let signedResponse = response.signedResponse,
			   let jsonData = try? JSONEncoder().encode(signedResponse) {
				data = jsonData
			} else if let dccEvent = response.wrapper.events?.first?.dccEvent,
					  let jsonData = try? JSONEncoder().encode(dccEvent) {
				data = jsonData
			}

			// Remove any existing events for the provider
			walletManager.removeExistingEventGroups(
				type: eventModeForStorage,
				providerIdentifier: response.wrapper.providerIdentifier
			)

			// Store the new events
			if let maxIssuedAt = response.wrapper.getMaxIssuedAt(),
			   let jsonData = data {
				success = success && walletManager.storeEventGroup(
					eventModeForStorage,
					providerIdentifier: response.wrapper.providerIdentifier,
					jsonData: jsonData,
					issuedAt: maxIssuedAt
				)
				if !success {
					break
				}
			} else {
				logWarning("Could not store event group")
			}
		}
		onCompletion(success)
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let failedToParsePrepareIssue = ErrorCode.ClientCode(value: "053")
	static let failedToGenerateCommitmentMessage = ErrorCode.ClientCode(value: "054")
	static let failedToSaveGreenCards = ErrorCode.ClientCode(value: "055")
	static let storingEvents = ErrorCode.ClientCode(value: "056")
	static let unhandled = ErrorCode.ClientCode(value: "999")
}
