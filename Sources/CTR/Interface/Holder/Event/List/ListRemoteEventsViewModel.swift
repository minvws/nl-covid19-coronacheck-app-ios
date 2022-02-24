/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import Foundation

class ListRemoteEventsViewModel: Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private let walletManager: WalletManaging = Current.walletManager
	let remoteConfigManager: RemoteConfigManaging = Current.remoteConfigManager
	private let greenCardLoader: GreenCardLoading
	let cryptoManager: CryptoManaging? = Current.cryptoManager
	let mappingManager: MappingManaging = Current.mappingManager
	private let identityChecker: IdentityCheckerProtocol

	var eventMode: EventMode
	var originalEventMode: EventMode?

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: ListRemoteEventsViewController.State

	@Bindable internal var alert: AlertContent?

	@Bindable internal var shouldPrimaryButtonBeEnabled: Bool = true

	@Bindable private(set) var hideForCapture: Bool = false

	private let screenCaptureDetector = ScreenCaptureDetector()

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	private let hasExistingDomesticVaccination: Bool

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode,
		originalMode: EventMode? = nil,
		remoteEvents: [RemoteEvent],
		identityChecker: IdentityCheckerProtocol = IdentityChecker(),
		eventsMightBeMissing: Bool = false,
		greenCardLoader: GreenCardLoading
	) {

		self.coordinator = coordinator
		self.greenCardLoader = greenCardLoader
		self.eventMode = eventMode
		self.identityChecker = identityChecker
		self.originalEventMode = originalMode
		
		viewState = .loading(content: Content(title: eventMode.title))
		hasExistingDomesticVaccination = walletManager.hasDomesticGreenCard(originType: OriginType.vaccination.rawValue)

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
			subTitle: eventMode.alertBody,
			cancelAction: { [weak self] _ in
				self?.goBack()
			},
			cancelTitle: L.holderVaccinationAlertStop(),
			cancelActionIsDestructive: true,
			okAction: nil,
			okTitle: L.holderVaccinationAlertContinue(),
			okActionIsPreferred: true
 		)
	}

	func goBack() {
		
		if let originalEventMode = originalEventMode {
			coordinator?.listEventsScreenDidFinish(.back(eventMode: originalEventMode))
		} else {
			coordinator?.listEventsScreenDidFinish(.back(eventMode: eventMode))
		}
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

		// Expanded Event Mode resolves a paper flow to vaccination / recovery / test.
		let expandedEventMode = expandEventMode(remoteEvents: remoteEvents)
		
		storeEvent(
			remoteEvents: remoteEvents,
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
				
				guard expandedEventMode == .vaccination else {
					// Origin check before storage only for vaccination
					return true
				}

				let domesticOrigins: Int = remoteResponse.getDomesticOrigins(ofType: expandedEventMode.rawValue).count
				let internationalOrigins: Int = remoteResponse.getInternationalOrigins(ofType: expandedEventMode.rawValue).count

				self?.logVerbose("We got \(domesticOrigins) domestic Origins of type \(expandedEventMode.rawValue)")
				self?.logVerbose("We got \(internationalOrigins) international Origins of type \(expandedEventMode.rawValue)")
				return internationalOrigins + domesticOrigins > 0

			}, completion: { result in
				self.progressIndicationCounter.decrement()
				self.handleGreenCardResult(
					result,
					expandedEventMode: expandedEventMode,
					remoteEvents: remoteEvents,
					completion: completion
				)
			})
		}
	}

	private func expandEventMode(remoteEvents: [RemoteEvent]) -> EventMode {

		if let dccEvent = remoteEvents.first?.wrapper.events?.first?.dccEvent,
		   let credentialData = dccEvent.credential.data(using: .utf8),
		   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData),
		   let dccEventType = euCredentialAttributes.eventMode {
			logVerbose("Setting expandedEventMode to \(dccEventType.rawValue)")
			return dccEventType
		}
		return eventMode
	}

	private func getStorageMode(remoteEvent: RemoteEvent) -> EventMode? {
		
		var storageEventMode: EventMode?
		if remoteEvent.wrapper.result != nil {
			// V2
			storageEventMode = .test
		} else if let storageMode = remoteEvent.wrapper.events?.first?.storageMode {
			// V3
			storageEventMode = storageMode
			if storageEventMode == .paperflow {
				// PaperFlow
				if let dccEvent = remoteEvent.wrapper.events?.first?.dccEvent,
				   let credentialData = dccEvent.credential.data(using: .utf8),
				   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData),
				   let dccEventType = euCredentialAttributes.eventMode {
					storageEventMode = dccEventType
				}
			}
		}
		logDebug("Setting storageEventMode to \(String(describing: storageEventMode))")
		return storageEventMode
	}

	private func handleGreenCardResult(
		_ result: Result<RemoteGreenCards.Response, Error>,
		expandedEventMode: EventMode,
		remoteEvents: [RemoteEvent],
		completion: @escaping (Bool) -> Void) {

		switch result {
			case let .success(greencardResponse):
				self.handleSuccess(greencardResponse, expandedEventMode: expandedEventMode, with: remoteEvents)

			case .failure(GreenCardLoader.Error.didNotEvaluate):
				self.viewState = self.originMismatchState(flow: determineErrorCodeFlow(remoteEvents: remoteEvents))
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
	}

	private func handleSuccess(_ greencardResponse: RemoteGreenCards.Response, expandedEventMode: EventMode, with remoteEvents: [RemoteEvent]) {
		
		guard eventMode != .paperflow else {
			// 2701: No special end states for the paperflow
			Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
			completeFlow()
			return
		}

		switch expandedEventMode {
			case .paperflow:
				completeFlow()
			case .test:
				handleSuccessForNegativeTest(greencardResponse, with: remoteEvents)
			case .positiveTest:
				handleSuccessForCombinedVaccinationAndPositiveTest(greencardResponse)
			case .recovery:
				handleSuccessForRecovery(greencardResponse, with: remoteEvents)
			case .vaccination:
				handleSuccessForVaccination(greencardResponse)
			case .vaccinationassessment:
				handleSuccessForVaccinationAssessment(greencardResponse)
		}
	}

	private func completeFlow() {

		self.coordinator?.listEventsScreenDidFinish(.continue(eventMode: self.eventMode))
	}
	
	private func handleSuccessForNegativeTest(_ greencardResponse: RemoteGreenCards.Response, with remoteEvents: [RemoteEvent]) {

		inspectGreencardResponseForNegativeTestAndVaccinationAssessment(
			greencardResponse,
			onBothNegativeTestAndVaccinactionAssessmentOrigins: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				self.completeFlow()
			},
			onNegativeTestOriginOnly: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				// if we entered a negative test in the vaccination assessment flow
				// AND we do not have a vaccination assessment origin
				// -> Remind the user to add his/her vaccination assessment
				if self.originalEventMode == .vaccinationassessment {
					self.shouldPrimaryButtonBeEnabled = true
					self.viewState = self.negativeTestInVaccinationAssessmentFlow()
				} else {
					self.completeFlow()
				}
			},
			onVaccinactionAssessmentOriginOnly: {
				self.shouldPrimaryButtonBeEnabled = true
				self.viewState = self.originMismatchState(flow: self.determineErrorCodeFlow(remoteEvents: remoteEvents))
			},
			onNoOrigins: {
				self.shouldPrimaryButtonBeEnabled = true
				self.viewState = self.originMismatchState(flow: self.determineErrorCodeFlow(remoteEvents: remoteEvents))
			}
		)
	}

	private func handleSuccessForVaccination(_ greencardResponse: RemoteGreenCards.Response) {

		Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
		if !greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccination.rawValue) &&
			greencardResponse.hasInternationalOrigins(ofType: OriginType.vaccination.rawValue) {
			shouldPrimaryButtonBeEnabled = true
			viewState = internationalQROnly()
		} else {
			completeFlow()
		}
	}

	private func handleSuccessForCombinedVaccinationAndPositiveTest(_ greencardResponse: RemoteGreenCards.Response) {

		shouldPrimaryButtonBeEnabled = true

		inspectGreencardResponseForPositiveTestAndRecovery(
			greencardResponse,
			onBothVaccinationAndRecoveryOrigins: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				
				let hasDomesticVaccinationOrigins = greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccination.rawValue)
				if hasDomesticVaccinationOrigins {
					self.viewState = self.positiveTestFlowRecoveryAndVaccinationCreated()
				} else {
					self.viewState = self.positiveTestFlowRecoveryAndInternationalVaccinationCreated()
				}
			},
			onVaccinationOriginOnly: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				
				let hasDomesticVaccinationOrigins = greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccination.rawValue)
				if hasDomesticVaccinationOrigins {
					self.completeFlow()
				} else {
					self.viewState = self.positiveTestFlowRecoveryAndInternationalVaccinationCreated()
				}
			},
			onRecoveryOriginOnly: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				self.viewState = self.positiveTestFlowRecoveryOnlyCreated()
			},
			onNoOrigins: {
				self.viewState = self.originMismatchState(flow: .positiveTest)
			}
		)
	}

	private func handleSuccessForRecovery(_ greencardResponse: RemoteGreenCards.Response, with remoteEvents: [RemoteEvent]) {

		shouldPrimaryButtonBeEnabled = true
		inspectGreencardResponseForPositiveTestAndRecovery(
			greencardResponse,
			onBothVaccinationAndRecoveryOrigins: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				if self.hasExistingDomesticVaccination {
					self.completeFlow()
				} else {
					self.viewState = self.recoveryFlowRecoveryAndVaccinationCreated()
				}
			},
			onVaccinationOriginOnly: {
				if self.hasExistingDomesticVaccination {
					self.viewState = self.originMismatchState(flow: .recovery)
				} else {
					Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
					self.viewState = self.recoveryFlowVaccinationOnly()
				}
			},
			onRecoveryOriginOnly: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				self.completeFlow()
			},
			onNoOrigins: {
				let recoveryExpirationDays = TimeInterval( self.remoteConfigManager.storedConfiguration.recoveryExpirationDays ?? 180)
				if let positiveTestEvent = remoteEvents.first?.wrapper.events?.first, positiveTestEvent.hasPositiveTest,
				   let date = positiveTestEvent.positiveTest?.getDate(with: ListRemoteEventsViewModel.iso8601DateFormatter),
				   date.addingTimeInterval(recoveryExpirationDays) < Current.now() {
					self.viewState = self.recoveryFlowPositiveTestTooOld()
				} else {
					self.viewState = self.originMismatchState(flow: .recovery)
				}
			}
		)

		// While the recovery is expired, it is still in Core Data
		// Let's remove it, to avoid any banner issues on the dashboard (Je bewijs is verlopen)
		_ = walletManager.removeExpiredGreenCards()
	}

	private func handleSuccessForVaccinationAssessment(_ greencardResponse: RemoteGreenCards.Response) {
		
		inspectGreencardResponseForNegativeTestAndVaccinationAssessment(
			greencardResponse,
			onBothNegativeTestAndVaccinactionAssessmentOrigins: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				self.completeFlow()
			},
			onNegativeTestOriginOnly: {
				self.shouldPrimaryButtonBeEnabled = true
				self.viewState = self.originMismatchState(flow: .visitorPass)
			},
			onVaccinactionAssessmentOriginOnly: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				self.completeFlow()
			},
			onNoOrigins: {
				if Current.walletManager.listEventGroups().filter({ $0.type == OriginType.test.rawValue }).isEmpty {
					// No negative test event send
					Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
					self.completeFlow()
				} else {
					// Negative test event send, no origin returned
					self.shouldPrimaryButtonBeEnabled = true
					self.viewState = self.originMismatchState(flow: .visitorPass)
				}
			}
		)
	}
	
	private func inspectGreencardResponseForPositiveTestAndRecovery(
		_ greencardResponse: RemoteGreenCards.Response,
		onBothVaccinationAndRecoveryOrigins: (() -> Void)?,
		onVaccinationOriginOnly: (() -> Void)?,
		onRecoveryOriginOnly: (() -> Void)?,
		onNoOrigins: (() -> Void)?) {

		let hasDomesticVaccinationOrigins = greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccination.rawValue)
		let hasInternationalVaccinationOrigins = greencardResponse.hasInternationalOrigins(ofType: OriginType.vaccination.rawValue)
		let hasVaccinationOrigins = hasDomesticVaccinationOrigins || hasInternationalVaccinationOrigins
		let domesticRecoveryOrigins = greencardResponse.getDomesticOrigins(ofType: OriginType.recovery.rawValue)
		var hasValidDomesticRecoveryOrigin = false
		for origin in domesticRecoveryOrigins where origin.expirationTime > Date() {
			hasValidDomesticRecoveryOrigin = true
		}

		switch (hasVaccinationOrigins, hasValidDomesticRecoveryOrigin ) {

			case (true, true): onBothVaccinationAndRecoveryOrigins?()
			case (true, false): onVaccinationOriginOnly?()
			case (false, true): onRecoveryOriginOnly?()
			case (false, false): onNoOrigins?()
		}
	}
	
	private func inspectGreencardResponseForNegativeTestAndVaccinationAssessment(
		_ greencardResponse: RemoteGreenCards.Response,
		onBothNegativeTestAndVaccinactionAssessmentOrigins: (() -> Void)?,
		onNegativeTestOriginOnly: (() -> Void)?,
		onVaccinactionAssessmentOriginOnly: (() -> Void)?,
		onNoOrigins: (() -> Void)?) {
			
		let hasDomesticVaccinationAssessmentOrigins = greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccinationassessment.rawValue)
		let hasDomesticNegativeTestOrigins = greencardResponse.hasDomesticOrigins(ofType: OriginType.test.rawValue)
		let hasInternationalNegativeTestOrigins = greencardResponse.hasInternationalOrigins(ofType: OriginType.test.rawValue)
		let hasNegativeTestOrigins = hasDomesticNegativeTestOrigins || hasInternationalNegativeTestOrigins
		
		switch (hasDomesticVaccinationAssessmentOrigins, hasNegativeTestOrigins ) {
				
			case (true, true): onBothNegativeTestAndVaccinactionAssessmentOrigins?()
			case (true, false): onVaccinactionAssessmentOriginOnly?()
			case (false, true): onNegativeTestOriginOnly?()
			case (false, false): onNoOrigins?()
		}
	}

	private func handleClientSideError(clientCode: ErrorCode.ClientCode, for step: ErrorCode.Step, with remoteEvents: [RemoteEvent]) {

		let errorCode = ErrorCode(
			flow: determineErrorCodeFlow(remoteEvents: remoteEvents),
			step: step,
			provider: determineErrorCodeProvider(remoteEvents: remoteEvents),
			errorCode: clientCode.value
		)
		logDebug("errorCode: \(errorCode)")
		displayClientErrorCode(errorCode)
		shouldPrimaryButtonBeEnabled = true
	}

	private func handleServerError(_ serverError: ServerError, for step: ErrorCode.Step, with remoteEvents: [RemoteEvent]) {

		if case let ServerError.error(statusCode, serverResponse, error) = serverError {
			self.logDebug("handleServerError \(serverError)")

			switch error {
				case .serverBusy:
					showServerTooBusyError(errorCode: ErrorCode(flow: determineErrorCodeFlow(remoteEvents: remoteEvents), step: step, errorCode: "429"))
					shouldPrimaryButtonBeEnabled = true
					
				case .serverUnreachableTimedOut, .serverUnreachableInvalidHost, .serverUnreachableConnectionLost:
					showServerUnreachable(ErrorCode(flow: determineErrorCodeFlow(remoteEvents: remoteEvents), step: step, clientCode: error.getClientErrorCode() ?? .unhandled))
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
					displayServerErrorCode(errorCode)
					shouldPrimaryButtonBeEnabled = true

				case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize, .authenticationCancelled:
					// Client side
					let errorCode = ErrorCode(
						flow: determineErrorCodeFlow(remoteEvents: remoteEvents),
						step: step,
						provider: determineErrorCodeProvider(remoteEvents: remoteEvents),
						clientCode: error.getClientErrorCode() ?? .unhandled,
						detailedCode: serverResponse?.code
					)
					logDebug("errorCode: \(errorCode)")
					displayClientErrorCode(errorCode)
					shouldPrimaryButtonBeEnabled = true
			}
		}
	}

	// MARK: Store events

	private func storeEvent(
		remoteEvents: [RemoteEvent],
		replaceExistingEventGroups: Bool,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		if replaceExistingEventGroups {
			// Replace when there is a identity mismatch
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
			guard let storageMode = getStorageMode(remoteEvent: response) else {
				return
			}

			// Remove any existing events for the provider
			// 2463: Allow multiple vaccinations for paperflow. 
			if eventMode != .paperflow || storageMode != .vaccination {
				walletManager.removeExistingEventGroups(
					type: storageMode,
					providerIdentifier: response.wrapper.providerIdentifier
				)
			} else {
				logDebug("Skipping remove existing eventgroup for \(eventMode) [\(storageMode)]")
			}

			// Store the new event group
			if let maxIssuedAt = getMaxIssuedAt(wrapper: response.wrapper),
			   let jsonData = data {
				success = success && walletManager.storeEventGroup(
					storageMode,
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

	private func getMaxIssuedAt(wrapper: EventFlow.EventResultWrapper) -> Date? {

		// 2.0
		if let result = wrapper.result,
		   let sampleDate = Formatter.getDateFrom(dateString8601: result.sampleDate) {
			return sampleDate
		}

		// 3.0
		let maxIssuedAt: Date? = wrapper.events?
			.compactMap {
				if $0.hasVaccination {
					return $0.vaccination?.dateString
				} else if $0.hasVaccinationAssessment {
					return $0.vaccinationAssessment?.dateTimeString
				} else if $0.hasNegativeTest {
					return $0.negativeTest?.sampleDateString
				} else if $0.hasRecovery {
					return $0.recovery?.sampleDate
				} else if $0.hasPaperCertificate {
					if let credentialData = $0.dccEvent?.credential.data(using: .utf8) {
						return cryptoManager?.readEuCredentials(credentialData)?.maxIssuedAt
					}
					return nil
				}
				return $0.positiveTest?.sampleDateString
			}
			.compactMap(Formatter.getDateFrom)
			.reduce(nil) { (latestDateFound: Date?, nextDate: Date) -> Date? in

				switch latestDateFound {
					case let latestDateFound? where nextDate > latestDateFound:
						return nextDate
					case .none:
						return nextDate
					default:
						return latestDateFound
				}
			}
		return maxIssuedAt
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {

	static let failedToParsePrepareIssue = ErrorCode.ClientCode(value: "053")
	static let failedToGenerateCommitmentMessage = ErrorCode.ClientCode(value: "054")
	static let failedToSaveGreenCards = ErrorCode.ClientCode(value: "055")
	static let storingEvents = ErrorCode.ClientCode(value: "056")
	static let originMismatch = ErrorCode.ClientCode(value: "058")
	static let unhandled = ErrorCode.ClientCode(value: "999")
}
