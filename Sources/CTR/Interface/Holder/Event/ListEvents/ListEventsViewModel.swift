/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ListEventsViewModel: PreventableScreenCapture, Logging {

	weak var coordinator: (EventCoordinatorDelegate & OpenUrlProtocol)?

	private var walletManager: WalletManaging
	internal var remoteConfigManager: RemoteConfigManaging
	private let greenCardLoader: GreenCardLoading
	private let identityChecker: IdentityCheckerProtocol

	internal var eventMode: EventMode

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	internal lazy var dateFormatter: ISO8601DateFormatter = {
		let dateFormatter = ISO8601DateFormatter()
		dateFormatter.formatOptions = [.withFullDate]
		return dateFormatter
	}()
	
	internal lazy var printDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "dd MMMM yyyy"
		return dateFormatter
	}()
	internal lazy var printTestDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EE d MMMM HH:mm"
		return dateFormatter
	}()
	internal lazy var printTestLongDateFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "EEEE d MMMM HH:mm"
		return dateFormatter
	}()
	internal lazy var printMonthFormatter: DateFormatter = {

		let dateFormatter = DateFormatter()
		dateFormatter.timeZone = TimeZone(identifier: "Europe/Amsterdam")
		dateFormatter.dateFormat = "MMMM"
		return dateFormatter
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: ListEventsViewController.State

	@Bindable private(set) var alert: ListEventsViewController.AlertContent?

	@Bindable internal var shouldPrimaryButtonBeEnabled: Bool = true

	private let prefetchingGroup = DispatchGroup()
	private let hasEventInformationFetchingGroup = DispatchGroup()
	private let eventFetchingGroup = DispatchGroup()

	init(
		coordinator: EventCoordinatorDelegate & OpenUrlProtocol,
		eventMode: EventMode,
		remoteEvents: [RemoteEvent],
		greenCardLoader: GreenCardLoading,
		walletManager: WalletManaging = Services.walletManager,
		remoteConfigManager: RemoteConfigManaging = Services.remoteConfigManager,
		identityChecker: IdentityCheckerProtocol = IdentityChecker()
	) {

		self.coordinator = coordinator
		self.eventMode = eventMode
		self.walletManager = walletManager
		self.remoteConfigManager = remoteConfigManager
		self.greenCardLoader = greenCardLoader
		self.identityChecker = identityChecker

		viewState = .loading(
			content: ListEventsViewController.Content(
				title: {
					switch eventMode {
						case .recovery:
							return L.holderRecoveryListTitle()
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

		super.init()

		viewState = getViewState(from: remoteEvents)
	}

	func backButtonTapped() {

		switch viewState {
			case .loading, .listEvents:
				warnBeforeGoBack()
			case .emptyEvents:
				goBack()
		}
	}

	func warnBeforeGoBack() {

		alert = ListEventsViewController.AlertContent(
			title: L.holderVaccinationAlertTitle(),
			subTitle: {
				switch eventMode {
					case .recovery:
						return L.holderRecoveryAlertMessage()
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

		storeEvent(remoteEvents: remoteEvents, replaceExistingEventGroups: replaceExistingEventGroups) { saved in

			guard saved else {
				self.progressIndicationCounter.decrement()
				self.shouldPrimaryButtonBeEnabled = true
				completion(false)
				return
			}

			self.greenCardLoader.signTheEventsIntoGreenCardsAndCredentials(responseEvaluator: { [weak self] remoteResponse in
				// Check if we have any origin for the event mode
				// == 0 -> No greenCards from the signer (name mismatch, expired, etc)
				// > 0 -> Success

				let domesticOrigins: Int = remoteResponse.domesticGreenCard?.origins
					.filter { $0.type == self?.eventMode.rawValue }
					.count ?? 0
				let internationalOrigins: Int = remoteResponse.euGreenCards?
					.flatMap { $0.origins }
					.filter { $0.type == self?.eventMode.rawValue }
					.count ?? 0

				self?.logVerbose("We got \(domesticOrigins) domestic Origins of type \(String(describing: self?.eventMode.rawValue))")
				self?.logVerbose("We got \(internationalOrigins) international Origins of type \(String(describing: self?.eventMode.rawValue))")
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

					case .failure(GreenCardLoader.Error.failedToSave), .failure(GreenCardLoader.Error.noEvents):
						self.shouldPrimaryButtonBeEnabled = true
						completion(false)

					case .failure(NetworkError.requestTimedOut), .failure(NetworkError.noInternetConnection):
						self.showNoInternet(remoteEvents: remoteEvents)
						self.shouldPrimaryButtonBeEnabled = true

					case .failure(GreenCardLoader.Error.failedToPrepareIssue):
						self.showTechnicalError("116 decodePrepareIssueMessage")

					case .failure(NetworkError.serverBusy):
						self.showServerTooBusyError()

					case .failure(GreenCardLoader.Error.preparingIssue117):
						self.showTechnicalError("117 prepareIssue")

					case .failure(GreenCardLoader.Error.stoken118):
						self.showTechnicalError("118 stoken")

					case .failure(GreenCardLoader.Error.credentials119):
						self.showTechnicalError("118 credentials")

					case .failure(let error):
						self.showTechnicalError("119 error: \(error)")
				}
			})
		}
	}

	// MARK: Errors

	internal func showIdentityMismatch(onReplace: @escaping () -> Void) {

		alert = ListEventsViewController.AlertContent(
			title: L.holderEventIdentityAlertTitle(),
			subTitle: L.holderEventIdentityAlertMessage(),
			cancelAction: { [weak self] _ in
				self?.coordinator?.listEventsScreenDidFinish(.stop)
			},
			cancelTitle: L.holderEventIdentityAlertCancel(),
			okAction: { _ in
				onReplace()
			},
			okTitle: L.holderEventIdentityAlertOk()
		)
	}

	internal func showEventError(remoteEvents: [RemoteEvent]) {

		alert = ListEventsViewController.AlertContent(
			title: L.generalErrorTitle(),
			subTitle: L.holderFetcheventsErrorNoresultsNetworkerrorMessage(eventMode.localized),
			cancelAction: nil,
			cancelTitle: L.holderVaccinationErrorClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
					if !success {
						self?.showEventError(remoteEvents: remoteEvents)
					}
				}
			},
			okTitle: L.holderVaccinationErrorAgain()
		)
	}

	private func showServerTooBusyError() {

		alert = ListEventsViewController.AlertContent(
			title: L.generalNetworkwasbusyTitle(),
			subTitle: L.generalNetworkwasbusyText(),
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { [weak self] _ in
				self?.coordinator?.listEventsScreenDidFinish(.stop)
			},
			okTitle: L.generalNetworkwasbusyButton()
		)
	}

	private func showNoInternet(remoteEvents: [RemoteEvent]) {

		// this is a retry-able situation
		alert = ListEventsViewController.AlertContent(
			title: L.generalErrorNointernetTitle(),
			subTitle: L.generalErrorNointernetText(),
			cancelAction: nil,
			cancelTitle: L.generalClose(),
			okAction: { [weak self] _ in
				self?.userWantsToMakeQR(remoteEvents: remoteEvents) { [weak self] success in
					if !success {
						self?.showEventError(remoteEvents: remoteEvents)
					}
				}
			},
			okTitle: L.holderVaccinationErrorAgain()
		)
	}

	private func showTechnicalError(_ customCode: String?) {

		var subTitle = L.generalErrorTechnicalText()
		if let code = customCode {
			subTitle = L.generalErrorTechnicalCustom(code)
		}
		alert = ListEventsViewController.AlertContent(
			title: L.generalErrorTitle(),
			subTitle: subTitle,
			cancelAction: nil,
			cancelTitle: nil,
			okAction: { _ in
				self.coordinator?.listEventsScreenDidFinish(.back(eventMode: self.eventMode))
			},
			okTitle: L.generalClose()
		)
	}

	// MARK: Store events

	private func storeEvent(
		remoteEvents: [RemoteEvent],
		replaceExistingEventGroups: Bool,
		onCompletion: @escaping (Bool) -> Void) {

		var success = true

		if replaceExistingEventGroups {
			walletManager.removeExistingEventGroups()
		}

		for response in remoteEvents where response.wrapper.status == .complete {

			// Remove any existing events for the provider
			walletManager.removeExistingEventGroups(
				type: eventMode,
				providerIdentifier: response.wrapper.providerIdentifier
			)

			// Store the new events
			if let maxIssuedAt = response.wrapper.getMaxIssuedAt(),
			   let signedResponse = response.signedResponse {
				success = success && walletManager.storeEventGroup(
					eventMode,
					providerIdentifier: response.wrapper.providerIdentifier,
					signedResponse: signedResponse,
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
