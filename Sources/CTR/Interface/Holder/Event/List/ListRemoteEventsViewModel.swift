/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import Transport
import Shared
import ReusableViews
import Persistence
import Models

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
		
		if let originalEventMode {
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
			
				// We've just processed some events with the backend and received `.success`,
				// therefore none of the `eventsBeingAdded` should no longer be marked as draft:
				eventsBeingAdded
					.filter { $0.isDraft }
					.forEach { Current.walletManager.updateEventGroup($0, isDraft: false) }
				
				let shouldShowBlockingEndState = Self.processBlockedEvents(fromResponse: response, eventsBeingAdded: eventsBeingAdded)
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
						Current.walletManager.removeExistingGreenCards()
						Current.walletManager.removeDraftEventGroups() // FYI: for the case of `.mismatchedIdentity` below, this is performed in that flow instead. It's also performed on app startup.
					
						showEventError()
						shouldPrimaryButtonBeEnabled = true
						
					case let .customError(title: title, message: message):
						Current.walletManager.removeDraftEventGroups() // FYI: for the case of `.mismatchedIdentity` below, this is performed in that flow instead. It's also performed on app startup.
						displayError(title: title, message: message)
						
					case let .mismatchedIdentity(matchingBlobIds: matchingBlobIds):
						coordinator?.listEventsScreenDidFinish(.mismatchedIdentity(matchingBlobIds: matchingBlobIds))
						self.shouldPrimaryButtonBeEnabled = true // it's possible to navigate back here for a retry.
				}
		}
	}
	
	/// Returns Bool: `true` if what was processed should result in a UI blocking screen, or `false` if not.
	private static func processBlockedEvents(fromResponse response: RemoteGreenCards.Response, eventsBeingAdded: [EventGroup]) -> Bool {
		
		// Events stored in the past, including whatever we're adding right now as well:
		let allEventGroups = Current.walletManager.listEventGroups()

		let eventsNotBeingAdded = allEventGroups.filter { eventGroup in
			!eventsBeingAdded.contains(where: { eventGroup.uniqueIdentifier == $0.uniqueIdentifier })
		}
	
		// The items which the backend has indicated are blocked:
		let blockItems = response.blobExpireDates?.filter { $0.reason == RemovalReason.blockedEvent.rawValue } ?? []
		
		// If any blockItem does not match an ID of an EventGroup that was sent to backend to
		// be signed (i.e. does not match an event in `eventsBeingAdded`), then persist the blockItem:
		// Note: This is not relevant to the end state.
		let blockItemsForEventsNotBeingAdded = blockItems.combinedWith(matchingEventGroups: eventsNotBeingAdded)
		if blockItemsForEventsNotBeingAdded.isNotEmpty {
			// We need to show the alert to the user again:
			Current.userSettings.hasShownBlockedEventsAlert = false
		}
		blockItemsForEventsNotBeingAdded.forEach { blockItem, eventGroup in
			Current.walletManager.createAndPersistRemovedEvent(
				blockItem: blockItem,
				existingEventGroup: eventGroup,
				cryptoManager: Current.cryptoManager
			)
		}
		
		// We may need to show an error screen here, if there's a block on any `eventsBeingAdded`:
		let shouldShowBlockingEndState = blockItems.combinedWith(matchingEventGroups: eventsBeingAdded).isNotEmpty
		return shouldShowBlockingEndState
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
			let removedEventGroupCount = walletManager.removeExistingEventGroups(type: storageMode, providerIdentifier: uniqueIdentifier)
			
			// Store the event group
			guard let eventGroup = walletManager.storeEventGroup(
				storageMode,
				providerIdentifier: uniqueIdentifier,
				jsonData: jsonData,
				expiryDate: nil,
				isDraft: removedEventGroupCount == 0
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

extension EventFlow.Event {
	
	var storageMode: EventMode? {
		
		if hasVaccination {
			return .vaccination
		}
		if hasRecovery {
			return .recovery
		}
		if hasPositiveTest {
			return .vaccinationAndPositiveTest
		}
		if hasNegativeTest {
			return .test(.ggd)
		}
		if hasVaccinationAssessment {
			return .vaccinationassessment
		}
		if hasPaperCertificate {
			return .paperflow
		}
		return nil
	}
}
