/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ListStoredEventsViewModel: Logging {

	weak var coordinator: (Restartable & OpenUrlProtocol)?

//	let remoteConfigManager: RemoteConfigManaging = Current.remoteConfigManager
//	private let greenCardLoader: GreenCardLoading
//	let mappingManager: MappingManaging = Current.mappingManager

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
		coordinator: Restartable & OpenUrlProtocol
//		greenCardLoader: GreenCardLoading
	) {

		self.coordinator = coordinator
//		self.greenCardLoader = greenCardLoader

		viewState = .loading(content: Content(title: L.holder_storedEvents_title()))

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}

//		viewState = getViewState(from: remoteEvents)
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
		let events = Current.walletManager.listEventGroups()
		events.forEach { eventGroup in
			result.append(ListStoredEventsViewController.Group(
				header: ListStoredEventsViewController.Header(title: "Opgehaald bij \(eventGroup.providerIdentifier)"),
				rows: getEventRows(eventGroup),
				action: ListStoredEventsViewController.Action(title: "Gegevens wissen", action: {
					self.logDebug("We should show popup for delete eventGroup \(eventGroup.objectID)")
				})))
		}
		return result
	}
	
	private func getEventRows(_ storedEvent: EventGroup) -> [ListStoredEventsViewController.Row] {
		
		var result = [ListStoredEventsViewController.Row]()
		
		if let jsonData = storedEvent.jsonData {
			if let object = try? JSONDecoder().decode(SignedResponse.self, from: jsonData),
			   let decodedPayloadData = Data(base64Encoded: object.payload),
			   let wrapper = try? JSONDecoder().decode(EventFlow.EventResultWrapper.self, from: decodedPayloadData) {
				
				wrapper.events?.forEach { event in
					
					if let date = event.getSortDate(with: ListRemoteEventsViewModel.iso8601DateFormatter) {
						let dateString = ListRemoteEventsViewModel.printDateFormatter.string(from: date)
						result.append(
							ListStoredEventsViewController.Row(
								title: event.type,
								details: dateString,
								action: { [weak self] in
									self?.showEventDetails(event)
								}
							)
						)
					}
				}

			} else if let object = try? JSONDecoder().decode(EventFlow.DccEvent.self, from: jsonData) {
				if let credentialData = object.credential.data(using: .utf8),
				   let euCredentialAttributes = Current.cryptoManager.readEuCredentials(credentialData) {
					// Todo Rec + Negative Test
					self.logDebug("todo, extract details from: \(euCredentialAttributes)")
					euCredentialAttributes.digitalCovidCertificate.vaccinations?.forEach { vaccination in
						
						let formattedVaccinationDate: String = Formatter.getDateFrom(dateString8601: vaccination.dateOfVaccination)
							.map(ListRemoteEventsViewModel.printDateFormatter.string) ?? vaccination.dateOfVaccination
						result.append(
							ListStoredEventsViewController.Row(
								title: "DCC Vaccination",
								details: formattedVaccinationDate,
								action: { [weak self] in
									self?.showEventDetails(euCredentialAttributes)
								}
							)
						)
					}
				}
			}
		}
		return result
	}
	
	private func showEventDetails(_ event: EventFlow.Event) {
		
		self.logDebug("We should show details for \(event)")
	}
	
	private func showEventDetails(_ event: EuCredentialAttributes) {
		
		self.logDebug("We should show details for \(event)")
	}
}
