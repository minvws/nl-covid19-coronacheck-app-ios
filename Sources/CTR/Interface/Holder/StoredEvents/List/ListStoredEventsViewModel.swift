/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class ListStoredEventsViewModel: Logging {

	weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: ListStoredEventsViewController.State

	@Bindable internal var alert: AlertContent?

	@Bindable private(set) var hideForCapture: Bool = false

	private let screenCaptureDetector = ScreenCaptureDetector()

	init(
		coordinator: HolderCoordinatorDelegate & OpenUrlProtocol
	) {

		self.coordinator = coordinator

		viewState = .loading(content: Content(title: L.holder_storedEvents_title()))

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}

		viewState = getEventGroupListViewState()
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
	
	private func getEventGroupListViewState() -> ListStoredEventsViewController.State {
	
		return ListStoredEventsViewController.State.listEvents(
			content: Content(
				title: L.holder_storedEvents_title(),
				body: L.holder_storedEvents_message(),
				primaryActionTitle: nil,
				primaryAction: nil,
				secondaryActionTitle: L.holder_storedEvents_button_handleData(),
				secondaryAction: { [weak self] in
					guard let url = URL(string: L.holder_storedEvents_url()) else { return }
					self?.coordinator?.openUrl(url, inApp: true)
				}),
			groups: getEventGroups()
		)
	}
	
	// MARK: - Event Group Overview
	
	private func getEventGroups() -> [ListStoredEventsViewController.Group] {
		
		var result = [ListStoredEventsViewController.Group]()
		let events = Current.walletManager.listEventGroups().sorted { lhs, rhs in
			lhs.autoId > rhs.autoId // Newest group first
		}
		events.forEach { eventGroup in
			result.append(ListStoredEventsViewController.Group(
				header: getListHeader(providerIdentifier: eventGroup.providerIdentifier),
				rows: getEventRows(eventGroup),
				action: { [weak self] in
					self?.logDebug("We should show popup for delete eventGroup \(eventGroup.objectID)")
					self?.showRemovalConfirmationAlert(objectID: eventGroup.objectID)
				},
				actionTitle: L.holder_storedEvents_button_removeEvents()))
		}
		return result
	}
	
	private func getListHeader(providerIdentifier: String?) -> String {
		
		guard let provider = providerIdentifier else {
			return ""
		}
		
		if EventFlow.paperproofIdentier.lowercased() == provider.lowercased() {
			return L.holder_storedEvents_listHeader_paperFlow()
		}

		if let providerName = Current.mappingManager.getProviderIdentifierMapping(provider) {
			return L.holder_storedEvents_listHeader_fetchedFromProvider(providerName)
		} else {
			return L.holder_storedEvents_listHeader_fetchedFromProvider(provider)
		}
	}
	
	private func getEventRows(_ storedEvent: EventGroup) -> [ListStoredEventsViewController.Row] {
		
		var result = [ListStoredEventsViewController.Row]()
		
		if let jsonData = storedEvent.jsonData {
			if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
			   let decodedPayloadData = Data(base64Encoded: object.payload),
			   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData),
			   let identity = wrapper.identity {
				
				let sortedEvents = wrapper.events?.sorted(by: { lhs, rhs in
					lhs.getSortDate(with: ListRemoteEventsViewModel.iso8601DateFormatter) ?? .distantFuture > rhs.getSortDate(with: ListRemoteEventsViewModel.iso8601DateFormatter) ?? .distantFuture
				})
				
				sortedEvents?.forEach { event in
					
					if let date = event.getSortDate(with: ListRemoteEventsViewModel.iso8601DateFormatter) {
						let dateString = ListRemoteEventsViewModel.printDateFormatter.string(from: date)
						
						if event.hasNegativeTest {
							result.append(getRowFromNegativeTestEvent(event, date: dateString, identity: identity))
						} else if event.hasPositiveTest {
							result.append(getRowFromPositiveTestEvent(event, date: dateString, identity: identity))
						} else if event.hasRecovery {
							result.append(getRowFromRecoveryEvent(event, date: dateString, identity: identity))
						} else if event.hasVaccination {
							result.append(getRowFromVaccinationEvent(event, date: dateString, identity: identity, providerName: wrapper.providerIdentifier))
						} else if event.hasVaccinationAssessment {
							result.append( getRowFromAssessementEvent(event, date: dateString, identity: identity))
						}
					}
				}

			} else if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData) {
				// Scanned DCC Event

				if let credentialData = object.credential.data(using: .utf8),
				   let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) {
					
					euCredentialAttributes.digitalCovidCertificate.vaccinations?.forEach { vaccination in
						result.append(getRowFromVaccinationDCC(vaccination, identity: euCredentialAttributes.identity))
					}
					euCredentialAttributes.digitalCovidCertificate.recoveries?.forEach { recovery in
						result.append(getRowFromRecoveryDCC(recovery, identity: euCredentialAttributes.identity))
					}
					euCredentialAttributes.digitalCovidCertificate.tests?.forEach { test in
						result.append(getRowFromNegativeTestDCC(test, identity: euCredentialAttributes.identity))
					}
				}
			}
		}
		return result
	}

	// MARK: - Event Row Helper Methods

	private func getRowFromNegativeTestEvent(_ event: EventFlow.Event, date: String, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {

		return ListStoredEventsViewController.Row(
			title: L.general_negativeTest().capitalizingFirstLetter(),
			details: date,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_negativeTest().capitalizingFirstLetter(),
					details: NegativeTestDetailsGenerator.getDetails(identity: identity, event: event)
				)
			}
		)
	}
	
	private func getRowFromPositiveTestEvent(_ event: EventFlow.Event, date: String, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {

		return ListStoredEventsViewController.Row(
			title: L.general_positiveTest().capitalizingFirstLetter(),
			details: date,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_positiveTest().capitalizingFirstLetter(),
					details: PositiveTestDetailsGenerator.getDetails(identity: identity, event: event)
				)
			}
		)
	}
	
	private func getRowFromRecoveryEvent(_ event: EventFlow.Event, date: String, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {

		return ListStoredEventsViewController.Row(
			title: L.general_recoverycertificate().capitalizingFirstLetter(),
			details: date,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_recoverycertificate().capitalizingFirstLetter(),
					details: RecoveryDetailsGenerator.getDetails(identity: identity, event: event)
				)
			}
		)
	}
	
	private func getRowFromVaccinationEvent(_ event: EventFlow.Event, date: String, identity: EventFlow.Identity, providerName: String) -> ListStoredEventsViewController.Row {

		return ListStoredEventsViewController.Row(
			title: L.general_vaccination().capitalizingFirstLetter(),
			details: date,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_vaccination().capitalizingFirstLetter(),
					details: VaccinationDetailsGenerator.getDetails(identity: identity, event: event, providerIdentifier: providerName)
				)
			}
		)
	}
	
	private func getRowFromAssessementEvent(_ event: EventFlow.Event, date: String, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {

		return ListStoredEventsViewController.Row(
			title: L.general_vaccinationAssessment().capitalizingFirstLetter(),
			details: date,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_vaccination().capitalizingFirstLetter(),
					details: VaccinationAssessementDetailsGenerator.getDetails(identity: identity, event: event)
				)
			}
		)
	}
	
	// MARK: - DCC Row Helper Methods
	
	private func getRowFromVaccinationDCC(_ vaccination: EuCredentialAttributes.Vaccination, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {
		
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? vaccination.dateOfVaccination
		
		return ListStoredEventsViewController.Row(
			title: L.general_vaccination().capitalizingFirstLetter(),
			details: formattedVaccinationDate,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_vaccination().capitalizingFirstLetter(),
					details: DCCVaccinationDetailsGenerator.getDetails(identity: identity, vaccination: vaccination)
				)
			}
		)
	}
	
	private func getRowFromRecoveryDCC(_ recovery: EuCredentialAttributes.RecoveryEntry, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {
		
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: recovery.firstPositiveTestDate)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? recovery.firstPositiveTestDate
		
		return ListStoredEventsViewController.Row(
			title: L.general_recoverycertificate().capitalizingFirstLetter(),
			details: formattedVaccinationDate,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_recoverycertificate().capitalizingFirstLetter(),
					details: DCCRecoveryDetailsGenerator.getDetails(identity: identity, recovery: recovery)
				)
			}
		)
	}
	
	private func getRowFromNegativeTestDCC(_ test: EuCredentialAttributes.TestEntry, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {
		
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: test.sampleDate)
			.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? test.sampleDate
		
		return ListStoredEventsViewController.Row(
			title: L.general_negativeTest().capitalizingFirstLetter(),
			details: formattedVaccinationDate,
			action: { [weak self] in
				self?.coordinator?.userWishesToSeeEventDetails(
					L.general_negativeTest().capitalizingFirstLetter(),
					details: DCCTestDetailsGenerator.getDetails(identity: identity, test: test)
				)
			}
		)
	}
	
	// MARK: - Remove Event Groups
	
	private func showRemovalConfirmationAlert(objectID: NSManagedObjectID) {
		
		alert = AlertContent(
			title: L.holder_storedEvent_alert_removeEvents_title(),
			subTitle: L.holder_storedEvent_alert_removeEvents_message(),
			cancelAction: nil,
			cancelTitle: L.generalCancel(),
			cancelActionIsPreferred: true,
			okAction: { [weak self] _ in
				
				self?.viewState = .loading(content: Content(title: L.holder_storedEvents_eraseEvents_title()))
				self?.removeEventGroup(objectID: objectID)
			},
			okTitle: L.general_delete(),
			okActionIsDestructive: true
		)
	}
	
	private func removeEventGroup(objectID: NSManagedObjectID ) {
		
		let removalResult = EventGroupModel.delete(objectID)
		switch removalResult {
			case .success(let success):
				if success {
					sendEventsToTheSigner()
				} else {
					handleClientSideError(clientCode: .coreDataFetchError, for: .removeEventGroups)
				}
			case .failure(let error):
				logError("Failed to remove event groups: \(error)")
				handleClientSideError(clientCode: .coreDataFetchError, for: .removeEventGroups)
		}
	}
	
	private func sendEventsToTheSigner() {
		
		Current.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: nil) { result in
			// Result<RemoteGreenCards.Response, Error>
			
			self.logDebug("Sign result: \(result)")

			switch result {
				case .success:
					self.viewState = self.getEventGroupListViewState()

				case .failure(GreenCardLoader.Error.didNotEvaluate):
					// Can not occur as we are not passing a response evaluator in this flow
					self.viewState = self.getEventGroupListViewState()

				case .failure(GreenCardLoader.Error.noEvents):
					// No more stored events. Remove existing greencards.
					Current.walletManager.removeExistingGreenCards()
					self.viewState = self.getEventGroupListViewState()

				case .failure(GreenCardLoader.Error.failedToParsePrepareIssue):
					self.handleClientSideError(clientCode: .failedToParsePrepareIssue, for: .nonce)

				case .failure(GreenCardLoader.Error.preparingIssue(let serverError)):
					self.handleServerError(serverError, for: .nonce)

				case .failure(GreenCardLoader.Error.failedToGenerateCommitmentMessage):
					self.handleClientSideError(clientCode: .failedToGenerateCommitmentMessage, for: .nonce)

				case .failure(GreenCardLoader.Error.credentials(let serverError)):
					self.handleServerError(serverError, for: .signer)

				case .failure(GreenCardLoader.Error.failedToSaveGreenCards):
					self.handleClientSideError(clientCode: .failedToSaveGreenCards, for: .storingCredentials)

				case .failure(let error):
					self.logError("storeAndSign - unhandled: \(error)")
					self.handleClientSideError(clientCode: .unhandled, for: .signer)
			}
		}
	}
	
	private func handleClientSideError(clientCode: ErrorCode.ClientCode, for step: ErrorCode.Step) {

		let errorCode = ErrorCode(flow: .walletDebug, step: step, clientCode: clientCode)
		
		logDebug("errorCode: \(errorCode)")
		displayClientErrorCode(errorCode)
	}
	
	private func handleServerError(_ serverError: ServerError, for step: ErrorCode.Step) {

		if case let ServerError.error(statusCode, serverResponse, error) = serverError {
			self.logDebug("handleServerError \(serverError)")

			switch error {
				case .serverBusy:
					showServerBusy(ErrorCode(flow: .walletDebug, step: step, errorCode: "429"))

				case .serverUnreachableTimedOut, .serverUnreachableInvalidHost, .serverUnreachableConnectionLost:
					showServerUnreachable(ErrorCode(flow: .walletDebug, step: step, clientCode: error.getClientErrorCode() ?? .unhandled))

				case .noInternetConnection:
					showNoInternet()

				case .responseCached, .redirection, .resourceNotFound, .serverError:
					// 304, 3xx, 4xx, 5xx
					let errorCode = ErrorCode(
						flow: .walletDebug,
						step: step,
						provider: nil,
						errorCode: "\(statusCode ?? 000)",
						detailedCode: serverResponse?.code
					)
					logDebug("errorCode: \(errorCode)")
					displayServerErrorCode(errorCode)

				case .invalidResponse, .invalidRequest, .invalidSignature, .cannotDeserialize, .cannotSerialize, .authenticationCancelled:
					// Client side
					let errorCode = ErrorCode(
						flow: .walletDebug,
						step: step,
						provider: nil,
						clientCode: error.getClientErrorCode() ?? .unhandled,
						detailedCode: serverResponse?.code
					)
					logDebug("errorCode: \(errorCode)")
					displayClientErrorCode(errorCode)
			}
		}
	}

	private func showServerUnreachable(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.generalErrorServerUnreachableErrorCode("\(errorCode)"))
	}
	
	private func showServerBusy(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.generalNetworkwasbusyTitle(), message: L.generalNetworkwasbusyErrorcode("\(errorCode)"))
	}

	private func displayClientErrorCode(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateClientMessage("\(errorCode)"))
	}

	private func displayServerErrorCode(_ errorCode: ErrorCode) {

		displayErrorCode(title: L.holderErrorstateTitle(), message: L.holderErrorstateServerMessage("\(errorCode)"))
	}
	
	private func displayErrorCode(title: String, message: String) {

		let content = Content(
			title: title,
			body: message,
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: {[weak self] in
				self?.coordinator?.navigateBackToStart()
			},
			secondaryActionTitle: L.holderErrorstateMalfunctionsTitle(),
			secondaryAction: { [weak self] in
				guard let url = URL(string: L.holderErrorstateMalfunctionsUrl()) else { return }
				self?.coordinator?.openUrl(url, inApp: true)
			}
		)
		DispatchQueue.main.asyncAfter(deadline: .now() + (ProcessInfo().isUnitTesting ? 0 : 0.5)) {
			self.coordinator?.displayError(content: content, backAction: nil)
		}
	}
	
	private func showNoInternet() {

		// this is a retry-able situation
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: { [weak self] _ in
				guard let self = self else { return }
				self.viewState = self.getEventGroupListViewState()
			},
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				self?.sendEventsToTheSigner()
			},
			okTitle: L.generalRetry(),
			okActionIsPreferred: true
		)
	}
}

extension ErrorCode.Flow {

	static let walletDebug = ErrorCode.Flow(value: "11")
}

// MARK: ErrorCode.Step (Scan log flow)
extension ErrorCode.Step {

	static let removeEventGroups = ErrorCode.Step(value: "10")
}
