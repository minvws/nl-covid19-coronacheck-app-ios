/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CoreData

class ListStoredEventsViewModel {

	weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

	@Bindable internal var viewState: ListStoredEventsViewController.State

	@Bindable internal var alert: AlertContent?

	@Bindable private(set) var hideForCapture: Bool = false

	private let screenCaptureDetector = ScreenCaptureDetector()

	init(coordinator: HolderCoordinatorDelegate & OpenUrlProtocol) {

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
	
	fileprivate func getEventGroupListViewState() -> ListStoredEventsViewController.State {
	
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
					self?.showRemovalConfirmationAlert(objectID: eventGroup.objectID)
				},
				actionTitle: L.holder_storedEvents_button_removeEvents()))
		}
		return result
	}
	
	private func getListHeader(providerIdentifier: String?) -> String? {
		
		guard let provider = providerIdentifier else {
			return nil
		}
		
		// Provider Identifier can have an appended unique. Let's strip that.
		let shortProvider = String(provider.split(separator: "-").first ?? "")
		
		// DCC (HKVI or foreign)
		if EventFlow.paperproofIdentier.lowercased() == shortProvider.lowercased() {
			return L.holder_storedEvents_listHeader_paperFlow()
		}
		
		let providerName = Current.mappingManager.getProviderIdentifierMapping(shortProvider)
		
		return L.holder_storedEvents_listHeader_fetchedFromProvider(providerName ?? provider)
	}
	
	private func getEventRows(_ storedEvent: EventGroup) -> [ListStoredEventsViewController.Row] {
		
		var result = [ListStoredEventsViewController.Row]()
		
		guard let jsonData = storedEvent.jsonData else {
			return result
		}
		
		if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
		   let decodedPayloadData = Data(base64Encoded: object.payload),
		   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {
			
			let sortedEvents = wrapper.events?.sorted(by: { lhs, rhs in
				lhs.getSortDate(with: DateFormatter.Event.iso8601) ?? .distantFuture > rhs.getSortDate(with: DateFormatter.Event.iso8601) ?? .distantFuture
			})
			
			guard let sortedEvents = sortedEvents else { return result }
			result.append(contentsOf: sortedEvents.compactMap { event in
				guard let date = event.getSortDate(with: DateFormatter.Event.iso8601),
						let identity = wrapper.identity else {
					return nil
				}
				let dateString = DateFormatter.Format.dayMonthYear.string(from: date)
				
				if event.hasNegativeTest {
					return getRowFromNegativeTestEvent(event, date: dateString, identity: identity)
				} else if event.hasPositiveTest {
					return getRowFromPositiveTestEvent(event, date: dateString, identity: identity)
				} else if event.hasRecovery {
					return getRowFromRecoveryEvent(event, date: dateString, identity: identity)
				} else if event.hasVaccination {
					return getRowFromVaccinationEvent(event, date: dateString, identity: identity, providerName: wrapper.providerIdentifier)
				} else if event.hasVaccinationAssessment {
					return getRowFromAssessementEvent(event, date: dateString, identity: identity)
				}
				return nil
			})
			
		} else if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData) {
			// Scanned DCC Event
			
			guard let credentialData = object.credential.data(using: .utf8),
				  let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) else {
				return result
			}
			
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
					L.general_vaccinationAssessment().capitalizingFirstLetter(),
					details: VaccinationAssessementDetailsGenerator.getDetails(identity: identity, event: event)
				)
			}
		)
	}
	
	// MARK: - DCC Row Helper Methods
	
	private func getRowFromVaccinationDCC(_ vaccination: EuCredentialAttributes.Vaccination, identity: EventFlow.Identity) -> ListStoredEventsViewController.Row {
		
		let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
			.map(DateFormatter.Format.dayMonthYear.string) ?? vaccination.dateOfVaccination
		
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
			.map(DateFormatter.Format.dayMonthYear.string) ?? recovery.firstPositiveTestDate
		
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
			.map(DateFormatter.Format.dayMonthYear.string) ?? test.sampleDate
		
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
			okAction: AlertContent.Action(
				title: L.general_delete(),
				action: { [weak self] _ in
					self?.viewState = .loading(content: Content(title: L.holder_storedEvents_eraseEvents_title()))
					self?.removeEventGroup(objectID: objectID)
				},
				isDestructive: true
			),
			cancelAction: AlertContent.Action(
				title: L.general_cancel(),
				isPreferred: true
			)
		)
	}
	
	private func removeEventGroup(objectID: NSManagedObjectID ) {
		
		let removalResult = Current.walletManager.removeEventGroup(objectID)
		switch removalResult {
			case .success:
				sendEventsToTheSigner()
			case .failure(let error):
				Current.logHandler.logError("Failed to remove event groups: \(error)")
				handleCoreDataError()
		}
	}
	
	private func handleCoreDataError() {
		
		let errorCode = ErrorCode(flow: .clearEvents, step: .removeEventGroups, clientCode: .coreDataFetchError)
		displayError(title: L.holderErrorstateTitle(), message: L.holderErrorstateClientMessage("\(errorCode)"))
	}
	
	private func sendEventsToTheSigner() {
		
		Current.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: nil) { [weak self] result in
			// Result<RemoteGreenCards.Response, Error>
			
			guard let self = self else { return }
			switch result {
				case .success:
					self.viewState = self.getEventGroupListViewState()
					
				case let .failure(greenCardError):
					let parser = GreenCardResponseErrorParser(flow: ErrorCode.Flow.clearEvents)
					switch parser.parse(greenCardError) {
						case .noInternet:
							self.displayNoInternet()
							
						case .didNotEvaluate:
							// Can not occur as we are not passing a response evaluator in this flow
							self.viewState = self.getEventGroupListViewState()
							
						case .noSignedEvents:
							
							// No more stored events. Remove existing greencards.
							Current.walletManager.removeExistingGreenCards()
							self.viewState = self.getEventGroupListViewState()
							
						case let .customError(title: title, message: message):
							self.displayError(title: title, message: message)
					}
			}
		}
	}
	
	func displayNoInternet() {
		
		alert = AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			okAction: AlertContent.Action(
				title: L.generalRetry(),
				action: { [weak self] _ in
					self?.sendEventsToTheSigner()
				},
				isPreferred: true
			),
			cancelAction: AlertContent.Action(
				title: L.generalClose(),
				action: { [weak self] _ in
					guard let self = self else { return }
					self.viewState = self.getEventGroupListViewState()
				}
			)
		)
	}
	
	func displayError(title: String, message: String) {
		
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
			self.coordinator?.presentError(content: content, backAction: nil)
		}
	}
}

// MARK: - ErrorCode.Flow

extension ErrorCode.Flow {

	static let clearEvents = ErrorCode.Flow(value: "11")
}

// MARK: - ErrorCode.Step

extension ErrorCode.Step {

	static let removeEventGroups = ErrorCode.Step(value: "10")
}
