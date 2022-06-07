/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
// swiftlint:disable type_body_length

import Foundation

class ListRemoteEventsViewModel {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private let walletManager: WalletManaging = Current.walletManager
	let remoteConfigManager: RemoteConfigManaging = Current.remoteConfigManager
	private let greenCardLoader: GreenCardLoading
	let cryptoManager: CryptoManaging? = Current.cryptoManager
	let mappingManager: MappingManaging = Current.mappingManager

	var eventMode: EventMode
	var originalEventMode: EventMode?
	var remoteEvents: [RemoteEvent]

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

	private let hasExistingDomesticVaccination: Bool

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode,
		originalMode: EventMode? = nil,
		remoteEvents: [RemoteEvent],
		eventsMightBeMissing: Bool = false,
		greenCardLoader: GreenCardLoading
	) {

		self.coordinator = coordinator
		self.greenCardLoader = greenCardLoader
		self.eventMode = eventMode
		self.originalEventMode = originalMode
		self.remoteEvents = remoteEvents
		
		viewState = .loading(content: Content(title: Strings.title(forEventMode: eventMode)))
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
			okAction: AlertContent.Action(
				title: L.holderVaccinationAlertContinue(),
				isPreferred: true
			),
			cancelAction: AlertContent.Action(
				title: L.holderVaccinationAlertStop(),
				action: { [weak self] _ in
					self?.goBack()
				},
				isDestructive: true
			)
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

	internal func userWantsToMakeQR() {

		if Current.identityChecker.compare(eventGroups: walletManager.listEventGroups(), with: remoteEvents) {
			storeAndSign(replaceExistingEventGroups: false)
		} else {
			showIdentityMismatch {
				// Replace the stored eventgroups
				self.storeAndSign(replaceExistingEventGroups: true)
			}
		}
	}

	private func storeAndSign(replaceExistingEventGroups: Bool) {

		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		// Expanded Event Mode resolves a paper flow to vaccination / recovery / test.
		let expandedEventMode = expandEventMode()
		
		storeEvent(
			replaceExistingEventGroups: replaceExistingEventGroups) { saved in

			guard saved else {
				self.progressIndicationCounter.decrement()
				self.shouldPrimaryButtonBeEnabled = true
				self.handleStorageError()
				return
			}

			self.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: { [weak self] remoteResponse in
				
				return self?.areTheOriginsAsExpected(
					remoteResponse: remoteResponse,
					expandedEventMode: expandedEventMode) ?? true
				
			}, completion: { result in
				self.progressIndicationCounter.decrement()
				self.handleGreenCardResult(
					result
				)
			})
		}
	}
	
	/// The response evaluator
	/// - Parameters:
	///   - remoteResponse: the response from the signer
	///   - expandedEventMode: the event mode
	/// - Returns: True if we received the expected origins for the event mode.
	/// If we do not get the expected origins, we show the mismatch state (error 058)
	private func areTheOriginsAsExpected(remoteResponse: RemoteGreenCards.Response, expandedEventMode: EventMode ) -> Bool {
		// Check if we have any origin for the event mode
		// == 0 -> No greenCards from the signer (name mismatch, expired, etc)
		// > 0 -> Success
		
		guard eventMode != .paperflow else {
			return true
		}
		
		switch expandedEventMode {
			case .paperflow:
				// No special states for the paper flow
				return true
			case .vaccinationAndPositiveTest:
				return areThereOrigins(remoteResponse: remoteResponse, forEventMode: .vaccination, now: Current.now()) ||
				areThereOrigins(remoteResponse: remoteResponse, forEventMode: .recovery, now: Current.now())
			case .recovery:
				if let recoveryExpirationDays = self.remoteConfigManager.storedConfiguration.recoveryExpirationDays,
				   let event = remoteEvents.first?.wrapper.events?.first, event.hasPositiveTest,
				   let sampleDateString = event.positiveTest?.sampleDateString,
				   let date = Formatter.getDateFrom(dateString8601: sampleDateString),
				   date.addingTimeInterval(TimeInterval(recoveryExpirationDays * 24 * 60 * 60)) < Current.now() {
					// End State 7
					return true
				}
				return areThereOrigins(remoteResponse: remoteResponse, forEventMode: expandedEventMode, now: Current.now())
			case .test, .vaccination:
				return areThereOrigins(remoteResponse: remoteResponse, forEventMode: expandedEventMode, now: Current.now())
			case .vaccinationassessment:
				// no origins to check.
				return true
		}
	}
	
	private func areThereOrigins(remoteResponse: RemoteGreenCards.Response, forEventMode: EventMode, now: Date) -> Bool {
		
		func validate(origins: [RemoteGreenCards.Origin]) -> Bool {
			origins.contains(where: { $0.expirationTime > now })
		}
		
		if Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() {
			return validate(origins: remoteResponse.getInternationalOrigins(ofType: forEventMode.rawValue))
		} else {
			return validate(origins: remoteResponse.getOrigins(ofType: forEventMode.rawValue))
		}
	}
	
	private func expandEventMode() -> EventMode {

		if let dccEvent = remoteEvents.first?.wrapper.events?.first?.dccEvent,
		   let credentialData = dccEvent.credential.data(using: .utf8),
		   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData),
		   let dccEventType = euCredentialAttributes.eventMode {
			Current.logHandler.logVerbose("Setting expandedEventMode to \(dccEventType.rawValue)")
			return dccEventType
		}
		return eventMode
	}

	private func getStorageMode(remoteEvent: RemoteEvent) -> EventMode? {
		
		var storageEventMode: EventMode?
		if let storageMode = remoteEvent.wrapper.events?.first?.storageMode {
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
			if eventMode == .recovery {
				// When in recovery flow, save as recovery to distinct from positive tests.
				storageEventMode = .recovery
			}
		}
		Current.logHandler.logVerbose("Setting storageEventMode to \(String(describing: storageEventMode))")
		return storageEventMode
	}

	private func handleGreenCardResult(_ result: Result<RemoteGreenCards.Response, Error>) {
		
		switch result {
			case let .success(response):
				handleSuccess(response, expandedEventMode: expandEventMode())
				
			case let .failure(greenCardError):
				let parser = GreenCardResponseErrorParser(flow: determineErrorCodeFlow())
				switch parser.parse(greenCardError) {
					case .noInternet:
						showNoInternet()
						shouldPrimaryButtonBeEnabled = true
						
					case .didNotEvaluate:
						// End state 3
						viewState = originMismatchState(flow: determineErrorCodeFlow())
						shouldPrimaryButtonBeEnabled = true
						
					case .noSignedEvents:
						
						showEventError()
						shouldPrimaryButtonBeEnabled = true
						
					case let .customError(title: title, message: message):
						displayError(title: title, message: message)
				}
		}
	}

	// MARK: - Success Handling
	
	private func handleSuccess(_ greencardResponse: RemoteGreenCards.Response, expandedEventMode: EventMode) {

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
				handleSuccessForNegativeTest(greencardResponse)
			case .vaccinationAndPositiveTest:
				handleSuccessForCombinedVaccinationAndPositiveTest(greencardResponse)
			case .recovery:
				handleSuccessForRecovery(greencardResponse)
			case .vaccination:
				handleSuccessForVaccination(greencardResponse)
			case .vaccinationassessment:
				handleSuccessForVaccinationAssessment(greencardResponse)
		}
	}

	private func completeFlow() {

		self.coordinator?.listEventsScreenDidFinish(.continue(eventMode: self.eventMode))
	}
	
	// MARK: - Negative Test Flow
	
	private func handleSuccessForNegativeTest(_ greencardResponse: RemoteGreenCards.Response) {

		inspectGreencardResponseForNegativeTestAndVaccinationAssessment(
			greencardResponse,
			onBothNegativeTestAndVaccinactionAssessmentOrigins: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				self.completeFlow()
			},
			onNegativeTestOriginOnly: {
				self.negativeTestFlowNegativeTestOriginOnly()
			},
			onVaccinactionAssessmentOriginOnly: {
				self.shouldPrimaryButtonBeEnabled = true
				self.viewState = self.originMismatchState(flow: self.determineErrorCodeFlow())
			},
			onNoOrigins: {
				// Handled by response evaluator
			}
		)
	}
	
	private func negativeTestFlowNegativeTestOriginOnly() {
		
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
	}
	
	// MARK: - Vaccination Flow

	private func handleSuccessForVaccination(_ greencardResponse: RemoteGreenCards.Response) {

		Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
		if !greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccination.rawValue) &&
			greencardResponse.hasInternationalOrigins(ofType: OriginType.vaccination.rawValue) {
			shouldPrimaryButtonBeEnabled = true

			guard !Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() else {
				// In 0G, this is expected behaviour. Go to dashboard
				self.completeFlow()
				return
			}

			// End state 2
			viewState = internationalQROnly()
		} else {
			completeFlow()
		}
	}
	
	// MARK: - Vaccination and Positive Test (combined) Flow

	private func handleSuccessForCombinedVaccinationAndPositiveTest(_ greencardResponse: RemoteGreenCards.Response) {

		shouldPrimaryButtonBeEnabled = true

		inspectGreencardResponseForPositiveTestAndRecovery(
			greencardResponse,
			onBothVaccinationAndRecoveryOrigins: {
				self.combinedFlowBothVaccinationAndRecoveryOrigins(greencardResponse)
			},
			onVaccinationOriginOnly: {
				self.combinedFlowVaccinationOriginOnly(greencardResponse)
			},
			onRecoveryOriginOnly: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				// End state 10
				self.viewState = self.positiveTestFlowRecoveryOnlyCreated()
			},
			onNoOrigins: {
				// End State 3 / 11
				// Handled by response evaluator
			}
		)
	}
	
	private func combinedFlowBothVaccinationAndRecoveryOrigins(_ greencardResponse: RemoteGreenCards.Response) {
		
		Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()

		guard !Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() else {

			let hasInternationalRecovery = greencardResponse.hasInternationalOrigins(ofType: OriginType.recovery.rawValue)
			let hasInternationalVaccination = greencardResponse.hasInternationalOrigins(ofType: OriginType.vaccination.rawValue)

			switch (hasInternationalRecovery, hasInternationalVaccination) {
				case (true, true):
					self.viewState = self.positiveTestFlowRecoveryAndVaccinationCreated()
				case (true, false):
					self.viewState = self.positiveTestFlowRecoveryOnlyCreated()
				case (false, true):
					self.completeFlow()
				case (false, false):
					self.viewState = self.originMismatchState(flow: .vaccinationAndPositiveTest)
			}
			return
		}
		let hasDomesticVaccinationOrigins = greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccination.rawValue)
		if hasDomesticVaccinationOrigins {
			// End state 6 / 7
			self.viewState = self.positiveTestFlowRecoveryAndVaccinationCreated()
		} else {
			// End state 8
			self.viewState = self.positiveTestFlowRecoveryAndInternationalVaccinationCreated()
		}
	}
	
	private func combinedFlowVaccinationOriginOnly(_ greencardResponse: RemoteGreenCards.Response) {
	
		Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()

		guard !Current.featureFlagManager.areZeroDisclosurePoliciesEnabled() else {
			// In 0G, this is expected behaviour. Go to dashboard
			self.completeFlow()
			return
		}

		let hasDomesticVaccinationOrigins = greencardResponse.hasDomesticOrigins(ofType: OriginType.vaccination.rawValue)
		if hasDomesticVaccinationOrigins {
			self.completeFlow()
		} else {
			let hasPositiveTestRemoteEvent = self.remoteEvents.contains { wrapper, _ in wrapper.events?.first?.hasPositiveTest ?? false }
			if hasPositiveTestRemoteEvent {
				// End state 9
				self.viewState = self.positiveTestFlowInternationalVaccinationCreated()
			} else {
				// End state 2
				self.viewState = self.internationalQROnly()
			}
		}
	}
	
	// MARK: - Recovery Flow
	
	private func handleSuccessForRecovery(_ greencardResponse: RemoteGreenCards.Response) {

		shouldPrimaryButtonBeEnabled = true
		inspectGreencardResponseForPositiveTestAndRecovery(
			greencardResponse,
			onBothVaccinationAndRecoveryOrigins: {
				self.recoveryFlowBothVaccinationAndRecoveryOrigins(greencardResponse)
			},
			onVaccinationOriginOnly: {
				self.recoveryFlowVaccinationOnlyOrigins()
			},
			onRecoveryOriginOnly: {
				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				self.completeFlow()
			},
			onNoOrigins: {
				self.recoveryFlowNoOrigins(greencardResponse)
			}
		)

		// While the recovery is expired, it is still in Core Data
		// Let's remove it, to avoid any banner issues on the dashboard (Je bewijs is verlopen)
		_ = walletManager.removeExpiredGreenCards(forDate: Current.now())
	}

	private func recoveryFlowBothVaccinationAndRecoveryOrigins(_ greencardResponse: RemoteGreenCards.Response) {
		
		Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()

		let firstRecoveryOrigin = greencardResponse.getOrigins(ofType: OriginType.recovery.rawValue)
			.sorted { $0.eventTime < $1.eventTime }
			.first
		let firstVaccinationOrigin = greencardResponse.getOrigins(ofType: OriginType.vaccination.rawValue)
			.sorted { $0.eventTime < $1.eventTime }
			.first

		guard let firstRecoveryOrigin = firstRecoveryOrigin, let firstVaccinationOrigin = firstVaccinationOrigin else {
			// Should not happen, part of the if let flow.
			Current.logHandler.logWarning("handleSuccessForRecovery - onBothVaccinationAndRecoveryOrigins, some origins are missing")
			self.completeFlow()
			return
		}
		if firstRecoveryOrigin.eventTime < firstVaccinationOrigin.eventTime {
			// End State 5
			self.viewState = self.recoveryFlowRecoveryAndVaccinationCreated()
		} else {
			// End State 4
			self.completeFlow()
		}
	}
	
	private func recoveryFlowVaccinationOnlyOrigins() {
		
		if self.hasExistingDomesticVaccination {
			// End State 7
			self.viewState = self.recoveryFlowPositiveTestTooOld()
		} else {
			// End State 6
			Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
			self.viewState = self.recoveryFlowVaccinationOnly()
		}
	}
	
	private func recoveryFlowNoOrigins(_ greencardResponse: RemoteGreenCards.Response) {
		
		if let recoveryExpirationDays = self.remoteConfigManager.storedConfiguration.recoveryExpirationDays,
		   let event = self.remoteEvents.first?.wrapper.events?.first, event.hasPositiveTest,
		   let sampleDateString = event.positiveTest?.sampleDateString,
		   let date = Formatter.getDateFrom(dateString8601: sampleDateString),
		   date.addingTimeInterval(TimeInterval(recoveryExpirationDays * 24 * 60 * 60)) < Current.now() {
			// End State 7
			self.viewState = self.recoveryFlowPositiveTestTooOld()
		} else {
			// End State 3
			// Handled by response evaluator
		}
	}
	
	// MARK: - Vaccination Assessment Flow
	
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
				self.vaccinationAssessmentFlowNoOrigins()
			}
		)
	}
	
	private func vaccinationAssessmentFlowNoOrigins() {
		
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
	
	// MARK: - Response evaluator helpers

	private func inspectGreencardResponseForPositiveTestAndRecovery(
		_ greencardResponse: RemoteGreenCards.Response,
		onBothVaccinationAndRecoveryOrigins: (() -> Void)?,
		onVaccinationOriginOnly: (() -> Void)?,
		onRecoveryOriginOnly: (() -> Void)?,
		onNoOrigins: (() -> Void)?) {

		let hasVaccinationOrigins = areThereOrigins(remoteResponse: greencardResponse, forEventMode: .vaccination, now: Current.now())
		let hasRecoveryOrigins = areThereOrigins(remoteResponse: greencardResponse, forEventMode: .recovery, now: Current.now())

		switch (hasVaccinationOrigins, hasRecoveryOrigins ) {

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

	// MARK: - Store events

	private func storeEvent(
		replaceExistingEventGroups: Bool,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		if replaceExistingEventGroups {
			// Replace when there is a identity mismatch
			walletManager.removeExistingEventGroups()
		}

		let storableEvents = remoteEvents.filter { (wrapper: EventFlow.EventResultWrapper, signedResponse: SignedResponse?) in
			// We can not store empty remoteEvents without an v2 result or a v3 event.
			// ZZZ sometimes returns an empty array of events in the combined flow.
			(wrapper.events ?? []).isNotEmpty
		}

		for response in storableEvents where response.wrapper.status == .complete {

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
				Current.logHandler.logDebug("Skipping remove existing eventgroup for \(eventMode) [\(storageMode)]")
			}

			// Store the new event group
			if let jsonData = data {
				success = success && walletManager.storeEventGroup(
					storageMode,
					providerIdentifier: response.wrapper.providerIdentifier,
					jsonData: jsonData,
					expiryDate: nil
				)
				if !success {
					break
				}
			} else {
				Current.logHandler.logWarning("Could not store event group")
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
	static let originMismatch = ErrorCode.ClientCode(value: "058")
	static let unhandled = ErrorCode.ClientCode(value: "999")
}
