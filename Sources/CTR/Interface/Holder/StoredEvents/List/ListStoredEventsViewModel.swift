/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import CryptoKit

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

		viewState = getViewState()
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
	
	private func getViewState() -> ListStoredEventsViewController.State {
	
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
	
	private func getEventGroups() -> [ListStoredEventsViewController.Group] {
		
		var result = [ListStoredEventsViewController.Group]()
		let events = Current.walletManager.listEventGroups().sorted { lhs, rhs in
			lhs.autoId > rhs.autoId // Newest group first
		}
		events.forEach { eventGroup in
			result.append(ListStoredEventsViewController.Group(
				header: ListStoredEventsViewController.Header(title: getListHeader(providerIdentifier: eventGroup.providerIdentifier)),
				rows: getEventRows(eventGroup),
				action: ListStoredEventsViewController.Action(title: L.holder_storedEvents_button_removeEvents(), action: {
					self.logDebug("We should show popup for delete eventGroup \(eventGroup.objectID)")
				})))
		}
		return result
	}
	
	private func getListHeader(providerIdentifier: String?) -> String {
		
		guard let provider = providerIdentifier else {
			return ""
		}
		
		if "dcc" == provider.lowercased() {
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
				
				wrapper.events?.forEach { event in
					
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
	
	private func showEventDetails(_ event: EventFlow.Event) {
		
		self.logDebug("We should show details for \(event)")
	}
}
