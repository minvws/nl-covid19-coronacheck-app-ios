/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ListRemoteEventsViewModel {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private let walletManager: WalletManaging = Current.walletManager
	private let greenCardLoader: GreenCardLoading
	let cryptoManager: CryptoManaging? = Current.cryptoManager
	let mappingManager: MappingManaging = Current.mappingManager

	var eventMode: EventMode
	var originalEventMode: EventMode?
	var remoteEvents: [RemoteEvent] // these are the events we are adding in this flow.

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

		// US 4664: Prevent duplicate scanned dcc.
		guard !(eventMode == .paperflow && doRemoteEventsContainExistingPaperProofs()) else {
			self.viewState = duplicateDccState()
			return
		}
		
		shouldPrimaryButtonBeEnabled = false
		progressIndicationCounter.increment()

		var eventModeToUse: EventMode {
			if let paperFlowEmbeddedEventMode = getPaperFlowEmbeddedEventMode() {
				// Expanded Event Mode resolves a paper flow to vaccination / recovery / test.
				logVerbose("Setting eventModeToUse to \(paperFlowEmbeddedEventMode.rawValue)")
				return paperFlowEmbeddedEventMode
			} else if originalEventMode == .vaccinationassessment {
				return .vaccinationassessment
			} else {
				return eventMode
			}
		}
		
		storeEvent(
			replaceExistingEventGroups: replaceExistingEventGroups) { newlyStoredEventGroups in

			guard let newlyStoredEventGroups = newlyStoredEventGroups else {
				self.progressIndicationCounter.decrement()
				self.shouldPrimaryButtonBeEnabled = true
				self.handleStorageError()
				return
			}
			
			self.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(eventMode: eventModeToUse) { result in
				self.progressIndicationCounter.decrement()
				self.handleGreenCardResult(result, forEventMode: eventModeToUse, eventsBeingAdded: newlyStoredEventGroups)
			}
		}
	}
	
	private func doRemoteEventsContainExistingPaperProofs() -> Bool {
		
		guard let firstEvent = remoteEvents.first?.wrapper.events?.first,
			  let unique = firstEvent.unique,
			  firstEvent.hasPaperCertificate else {
			return false
		}
		
		let existingEvents = walletManager.listEventGroups()
		let uniqueIdentifier = EventFlow.paperproofIdentier + "-\(unique)"
		let filtered = existingEvents.filter { $0.providerIdentifier?.lowercased() == uniqueIdentifier.lowercased() }
		return filtered.isNotEmpty
	}
	
	private func getPaperFlowEmbeddedEventMode() -> EventMode? {

		guard let dccEvent = remoteEvents.first?.wrapper.events?.first?.dccEvent,
		   let credentialData = dccEvent.credential.data(using: .utf8),
		   let euCredentialAttributes = cryptoManager?.readEuCredentials(credentialData),
		   let dccEventType = euCredentialAttributes.eventMode
		else { return nil }
		
		return dccEventType
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
			if eventMode == .test(.commercial) {
				// Commercial mode is not handled correctly by the storagemode (undetectable)
				storageEventMode = .test(.commercial)
			}
		}
		return storageEventMode
	}

	private func handleGreenCardResult(_ result: Result<RemoteGreenCards.Response, GreenCardLoader.Error>, forEventMode eventMode: EventMode, eventsBeingAdded: [EventGroup]) {
		
		switch result {
			case let .success(response):
	
				// Events stored in the past, including whatever we're adding right now as well:
				let allEventGroups = Current.walletManager.listEventGroups()

				let eventsNotBeingAdded = allEventGroups.filter { eventGroup in
					!eventsBeingAdded.contains(where: { eventGroup.autoId != $0.autoId })
				}
			
				// The items which the backend has indicated are blocked:
				let blockItems = response.blobExpireDates?.filter { $0.reason == "event_blocked" } ?? []
				
				// If any blockItem does not match an ID of an EventGroup that was sent to backend to
				// be signed (i.e. does not match an event in `eventsBeingAdded`), then persist the blockItem:
				// Note: This is not relevant to the end state.
				blockItems.blockItems(matchingEventGroups: eventsNotBeingAdded).forEach { blockItem, eventGroup in
					BlockedEvent.createAndPersist(blockItem: blockItem, existingEventGroup: eventGroup)
				}
				
				// We may need to show an error screen here, if there's a block on any `eventsBeingAdded`:
				let shouldShowBlockingEndState = blockItems.blockItems(matchingEventGroups: eventsBeingAdded).isNotEmpty
				guard !shouldShowBlockingEndState else {
					self.shouldPrimaryButtonBeEnabled = true
					self.viewState = blockedEndState()
					return
				}

				Current.userSettings.lastSuccessfulCompletionOfAddCertificateFlowDate = Current.now()
				
				if let hints = response.hints, let nonEmptyHints = NonemptyArray(hints) {
					coordinator?.listEventsScreenDidFinish(.showHints(nonEmptyHints, eventMode: eventMode))
				} else {
					coordinator?.listEventsScreenDidFinish(.continue(eventMode: self.eventMode))
				}
				
			case let .failure(greenCardError):
				let parser = GreenCardResponseErrorParser(flow: eventMode.flow)
				switch parser.parse(greenCardError) {
					case .noInternet:
						showNoInternet()
						shouldPrimaryButtonBeEnabled = true
						
					case .noSignedEvents:
						
						showEventError()
						shouldPrimaryButtonBeEnabled = true
						
					case let .customError(title: title, message: message):
						displayError(title: title, message: message)
				}
		}
	}

	// MARK: - Store events

	private func storeEvent(
		replaceExistingEventGroups: Bool,
		onCompletion: @escaping ([EventGroup]?) -> Void) {

		if replaceExistingEventGroups {
			// Replace when there is a identity mismatch
			walletManager.removeExistingEventGroups()
		}

		// We can not store empty remoteEvents without an event. (happens with .pending)
		// ZZZ sometimes returns an empty array of events in the combined flow.
		let storableEvents = remoteEvents.filter { ($0.wrapper.events ?? []).isNotEmpty }
			
		var newlyStoredEventGroups: [EventGroup] = []
		
		for storableEvent in storableEvents where storableEvent.wrapper.status == .complete {
			
			guard let jsonData = storableEvent.getEventsAsJSON(),
				  let storageMode = getStorageMode(remoteEvent: storableEvent) else {
				
				onCompletion(nil)
				return
			}

			// We must allow multiple events, but do not want duplicates.
			// So we append the unique of the event to the provider identifier.
			// For GGD, RIVM and ZKVI events, we can not rely on the unique of the event,
			// for those we do want to overwrite the existing ones (so we do not append the unqiue)
			var uniqueIdentifier = storableEvent.wrapper.providerIdentifier
			if !(storableEvent.wrapper.isGGD || storableEvent.wrapper.isRIVM || storableEvent.wrapper.isZKVI) {
				uniqueIdentifier += "-" + storableEvent.uniqueIdentifier
			}
			
			// Remove any existing events for the uniqueIdentifier -> so we do not have duplicates
			walletManager.removeExistingEventGroups(type: storageMode, providerIdentifier: uniqueIdentifier)
			
			// Store the event group
			
			guard let eventGroup = walletManager.storeEventGroup(
				storageMode,
				providerIdentifier: uniqueIdentifier,
				jsonData: jsonData,
				expiryDate: nil
			) else {
				onCompletion(nil)
				return
			}
			
			newlyStoredEventGroups += [eventGroup]
		}
			
		onCompletion(newlyStoredEventGroups)
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

private extension Array where Element == RemoteGreenCards.BlobExpiry {
	
	/// Determine which blockItems match EventGroups which were sent to be signed:
	func blockItems(matchingEventGroups eventGroups: [EventGroup]) -> [(RemoteGreenCards.BlobExpiry, EventGroup)] {
		reduce([]) { partialResult, blockItem in
			guard let matchingEvent = eventGroups.first(where: { "\($0.autoId)" == blockItem.identifier }) else { return partialResult }
			return partialResult + [(blockItem, matchingEvent)]
		}
	}
}

private extension BlockedEvent {
	
	@discardableResult
	static func createAndPersist(blockItem: RemoteGreenCards.BlobExpiry, existingEventGroup: EventGroup) -> BlockedEvent? {
		guard let jsonData = existingEventGroup.jsonData,
			  let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData),
			  let credentialData = object.credential.data(using: .utf8),
			  let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData),
			  let eventMode = euCredentialAttributes.eventMode
		else { return nil }
		
		var eventDate: Date? {
			guard let eventDate = euCredentialAttributes.eventDate else { return nil }
			return DateFormatter.Event.iso8601.date(from: eventDate)
		}
		
		return Current.walletManager.storeBlockedEvent(
			type: eventMode,
			eventDate: eventDate ?? .distantPast,
			reason: blockItem.reason
		)
	}
}
