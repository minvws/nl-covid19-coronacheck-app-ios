/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

enum EventMode: String {

	case recovery
	case paperflow
	case test
	case vaccination

	var localized: String {
		switch self {
			case .recovery: return L.generalRecoverystatement()
			case .paperflow: return L.generalPaperflow()
			case .test: return L.generalTestresult()
			case .vaccination: return L.generalVaccination()
		}
	}

	var title: String {
		switch self {
			case .paperflow:
				return L.holderDccListTitle()
			case .recovery:
				return L.holderRecoveryListTitle()
			case .test:
				return L.holderTestresultsResultsTitle()
			case .vaccination:
				return L.holderVaccinationListTitle()
		}
	}

	var alertBody: String {

		switch self {
			case .paperflow:
				return L.holderDccAlertMessage()
			case .recovery:
				return L.holderRecoveryAlertMessage()
			case .test:
				return L.holderTestAlertMessage()
			case .vaccination:
				return L.holderVaccinationAlertMessage()
		}
	}

	var listMessage: String {
		switch self {
			case .paperflow:
				return L.holderDccListMessage()
			case .recovery:
				return L.holderRecoveryListMessage()
			case .test:
				return L.holderTestresultsResultsText()
			case .vaccination:
				return L.holderVaccinationListMessage()
		}
	}

	var originsMismatchBody: String {
		switch self {
			case .paperflow:
				return L.holderEventOriginmismatchDccBody()
			case .recovery:
				return L.holderEventOriginmismatchRecoveryBody()
			case .test:
				return L.holderEventOriginmismatchTestBody()
			case .vaccination:
				return L.holderEventOriginmismatchVaccinationBody()
		}
	}
}

enum EventScreenResult: Equatable {

	/// The user wants to go back a scene
	case back(eventMode: EventMode)
	
	case backSwipe

	/// Stop with vaccination flow,
	case stop

	/// Skip back to the beginning of the flow
	case errorRequiringRestart(eventMode: EventMode)

	case error(content: Content, backAction: () -> Void)

	/// Continue with the next step in the flow
	case `continue`(value: String?, eventMode: EventMode)

	/// Show the vaccination events
	case showEvents(events: [RemoteEvent], eventMode: EventMode, eventsMightBeMissing: Bool)

	/// Show some more information
	case moreInformation(title: String, body: String, hideBodyForScreenCapture: Bool)
	
	/// Show event details
	case showEventDetails(title: String, details: [EventDetails])

	static func == (lhs: EventScreenResult, rhs: EventScreenResult) -> Bool {
		switch (lhs, rhs) {
			case (.back, .back), (.stop, .stop), (.continue, .continue):
				return true
			case (let .moreInformation(lhsTitle, lhsBody, lhsCapture), let .moreInformation(rhsTitle, rhsBody, rhsCapture)):
				return (lhsTitle, lhsBody, lhsCapture) == (rhsTitle, rhsBody, rhsCapture)
			case (let showEvents(lhsEvents, lhsMode, lhsComplete), let showEvents(rhsEvents, rhsMode, rhsComplete)):

				if lhsEvents.count != rhsEvents.count || lhsMode != rhsMode || lhsComplete != rhsComplete {
					return false
				}

				for index in 0 ..< lhsEvents.count {

					if lhsEvents[index].wrapper != rhsEvents[index].wrapper ||
						lhsEvents[index].signedResponse != rhsEvents[index].signedResponse {
						return false
					}
				}
				return true
			case (let showEventDetails(lhsTitle, lhsDetails), let showEventDetails(rhsTitle, rhsDetails)):
				return (lhsTitle, lhsDetails) == (rhsTitle, rhsDetails)

			case (let errorRequiringRestart(lhsMode), let errorRequiringRestart(rhsMode)):
				return lhsMode == rhsMode

			case (let error(lhsContent, _), let error(rhsContent, _)):
				return lhsContent == rhsContent

			default:
				return false
		}
	}
}

protocol EventCoordinatorDelegate: AnyObject {

	func eventStartScreenDidFinish(_ result: EventScreenResult)

	func loginTVSScreenDidFinish(_ result: EventScreenResult)

	func fetchEventsScreenDidFinish(_ result: EventScreenResult)

	func listEventsScreenDidFinish(_ result: EventScreenResult)
}

protocol EventFlowDelegate: AnyObject {

	/// The event flow is finished
	func eventFlowDidComplete()

	func eventFlowDidCancel()
	
	func eventFlowDidCancelFromBackSwipe()
}

class EventCoordinator: Coordinator, Logging, OpenUrlProtocol {

	var childCoordinators: [Coordinator] = []

	var navigationController: UINavigationController

	weak var delegate: EventFlowDelegate?

	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the vaccination flow delegate
	init(
		navigationController: UINavigationController,
		delegate: EventFlowDelegate) {

		self.navigationController = navigationController
		self.delegate = delegate
	}

	func start() {

		startWithVaccination()
	}

	func startWithVaccination() {

		startWith(.vaccination)
	}

	func startWithRecovery() {

		startWith(.recovery)
	}

	func startWithListTestEvents(_ events: [RemoteEvent]) {

		navigateToListEvents(events, eventMode: .test, eventsMightBeMissing: false)
	}

	func startWithScannedEvent(_ event: RemoteEvent) {

		navigateToListEvents([event], eventMode: .paperflow, eventsMightBeMissing: false)
	}

	func startWithTVS(eventMode: EventMode) {
		
		navigateToLogin(eventMode: eventMode)
	}

	// MARK: - Universal Link handling

	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}

	// MARK: Private functions

	private func startWith(_ eventMode: EventMode) {

		let viewController = EventStartViewController(
			viewModel: EventStartViewModel(
				coordinator: self,
				eventMode: eventMode,
				validAfterDays: Services.remoteConfigManager.getConfiguration().recoveryWaitingPeriodDays
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	private func navigateToLogin(eventMode: EventMode) {

		let viewController = LoginTVSViewController(
			viewModel: LoginTVSViewModel(
				coordinator: self,
				eventMode: eventMode
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}

	private func navigateToFetchEvents(token: String, eventMode: EventMode) {
		let viewController = FetchEventsViewController(
			viewModel: FetchEventsViewModel(
				coordinator: self,
				tvsToken: token,
				eventMode: eventMode
			)
		)

		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToListEvents(
		_ remoteEvents: [RemoteEvent],
		eventMode: EventMode,
		eventsMightBeMissing: Bool) {

		let viewController = ListEventsViewController(
			viewModel: ListEventsViewModel(
				coordinator: self,
				eventMode: eventMode,
				remoteEvents: remoteEvents,
				eventsMightBeMissing: eventsMightBeMissing
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}

	private func navigateToMoreInformation(_ title: String, body: String, hideBodyForScreenCapture: Bool) {

		let viewController = InformationViewController(
			viewModel: InformationViewModel(
				coordinator: self,
				title: title,
				message: body,
				linkTapHander: { [weak self] url in

					self?.openUrl(url, inApp: true)
				},
				hideBodyForScreenCapture: hideBodyForScreenCapture
			)
		)
		presentAsBottomSheet(viewController)
	}
	
	private func navigateToEventDetails(_ title: String, details: [EventDetails]) {
		
		let viewController = EventDetailsViewController(
			viewModel: EventDetailsViewModel(
				coordinator: self,
				title: title,
				details: details,
				hideBodyForScreenCapture: true
			)
		)
		presentAsBottomSheet(viewController)
	}

	private func presentAsBottomSheet(_ viewController: UIViewController) {

		navigationController.visibleViewController?.presentBottomSheet(viewController)
	}

	private func navigateBackToEventStart() {

		if let eventStartViewController = navigationController.viewControllers
			.first(where: { $0 is EventStartViewController }) {

			navigationController.popToViewController(
				eventStartViewController,
				animated: true
			)
		}
	}

	private func navigateBackToTestStart() {
		
		let popBackToViewController = navigationController.viewControllers.first {
			
			switch $0 {
				case is ChooseTestLocationViewController:
					return true
				// Fallback when GGD is not available
				case is ChooseQRCodeTypeViewController:
					return true
				default:
					return false
			}
		}
		if let popBackToViewController = popBackToViewController {
			
			navigationController.popToViewController(
				popBackToViewController,
				animated: true
			)
		}
	}

	private func displayError(content: Content, backAction: @escaping () -> Void) {

		let viewController = ErrorStateViewController(
			viewModel: ErrorStateViewModel(
				content: content,
				backAction: backAction
			)
		)
		navigationController.pushViewController(viewController, animated: false)
	}
}

extension EventCoordinator: EventCoordinatorDelegate {

	func eventStartScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .back, .stop:
				delegate?.eventFlowDidCancel()
			case .backSwipe:
				delegate?.eventFlowDidCancelFromBackSwipe()
			case let .continue(_, eventMode):
				navigateToLogin(eventMode: eventMode)
			default:
				break
		}
	}

	func loginTVSScreenDidFinish(_ result: EventScreenResult) {

		switch result {

			case let .continue(value: token, eventMode: eventMode):
				if let token = token {
					navigateToFetchEvents(token: token, eventMode: eventMode)
				} else {
					start()
				}

			case .errorRequiringRestart(let eventMode):
				handleErrorRequiringRestart(eventMode: eventMode)

			case let .error(content: content, backAction: backAction):
				displayError(content: content, backAction: backAction)

			case .back(let eventMode):
				goBack(eventMode)
	
			case .stop:
				delegate?.eventFlowDidComplete()

			default:
				break
		}
	}

	func fetchEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop:
				delegate?.eventFlowDidComplete()
				
			case .back(let eventMode):
				goBack(eventMode)

			case let .error(content: content, backAction: backAction):
				displayError(content: content, backAction: backAction)

			case let .showEvents(remoteEvents, eventMode, eventsMightBeMissing):
				navigateToListEvents(remoteEvents, eventMode: eventMode, eventsMightBeMissing: eventsMightBeMissing)

			default:
				break
		}
	}

	private func goBack(_ eventMode: EventMode) {

		switch eventMode {
			case .test:
				navigateBackToTestStart()
			case .recovery, .vaccination:
				navigateBackToEventStart()
			case .paperflow:
				delegate?.eventFlowDidCancel()
		}
	}

	func listEventsScreenDidFinish(_ result: EventScreenResult) {

		switch result {
			case .stop, .continue:
				delegate?.eventFlowDidComplete()
			case .back(let eventMode):
				goBack(eventMode)
			case let .error(content: content, backAction: backAction):
				displayError(content: content, backAction: backAction)
			case let .moreInformation(title, body, hideBodyForScreenCapture):
				navigateToMoreInformation(title, body: body, hideBodyForScreenCapture: hideBodyForScreenCapture)
			case let .showEventDetails(title, details):
				navigateToEventDetails(title, details: details)
			default:
				break
		}
	}

	private func handleErrorRequiringRestart(eventMode: EventMode) {
		let popback = navigationController.viewControllers.first {
			// arrange `case`s in the order of matching priority
			switch $0 {
				case is EventStartViewController:
					return true
				case is ChooseTestLocationViewController:
					return true
				default:
					return false
			}
		}

		let presentError = {
			let alertController = UIAlertController(
				title: L.holderErrorstateLoginTitle(),
				message: {
					switch eventMode {
						case .recovery:
							return L.holderErrorstateLoginMessageRecovery()
						case .paperflow:
							return "" // HKVI is not a part of this flow
						case .test:
							return L.holderErrorstateLoginMessageTest()
						case .vaccination:
							return L.holderErrorstateLoginMessageVaccination()
					}
				}(),
				preferredStyle: .alert
			)

			alertController.addAction(.init(title: L.generalClose(), style: .default, handler: nil))
			self.navigationController.present(alertController, animated: true, completion: nil)
		}

		if let popback = popback {
			navigationController.popToViewController(popback, animated: true, completion: presentError)
		} else {
			navigationController.popToRootViewController(animated: true, completion: presentError)
		}
	}
}

extension EventCoordinator: Dismissable {

	func dismiss() {

		navigationController.presentedViewController?.dismiss(animated: true, completion: nil)
	}
}
