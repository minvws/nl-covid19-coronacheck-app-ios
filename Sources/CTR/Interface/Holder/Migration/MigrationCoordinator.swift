/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import DataMigration
import Models
import Resources
import ReusableViews
import Managers
import Shared
import Transport
import UIKit

protocol MigrationFlowDelegate: AnyObject {
	
	func dataMigrationCancelled()
	
	func dataMigrationExportCompleted()
	
	func dataMigrationImportCompleted()
}

protocol MigrationCoordinatorDelegate: AnyObject {
	
	func userCompletedStart()
	
	func userWishesToSeeToThisDeviceInstructions()
	
	func userWishesToSeeToOtherDeviceInstructions()
	
	func userWishesToStartMigrationToThisDevice()
	
	func userWishesToStartMigrationToOtherDevice()
	
	func userCompletedMigrationToOtherDevice()
	
	func userWishesToGoBackToPreviousScreen(animated: Bool)
	
	func presentError(_ errorCode: ErrorCode)
	
	func userWishesToSeeScannedEvents(_ parcels: [EventGroupParcel])
}

class MigrationCoordinator: NSObject, Coordinator, OpenUrlProtocol {
	
	private let version: String = "CC1"
	
	enum MigrationFlow {
		case toThisDevice
		case toOtherDevice
	}
	
	var childCoordinators: [Coordinator] = []
	
	var navigationController: UINavigationController
	
	weak var delegate: MigrationFlowDelegate?
	
	var onboardingFactory: MigrationOnboardingFactory = MigrationOnboardingFactory()
	
	var flow: MigrationFlow?
	
	/// Initializer
	/// - Parameters:
	///   - navigationController: the navigation controller
	///   - delegate: the migration flow delegate
	init(navigationController: UINavigationController, delegate: MigrationFlowDelegate) {
		
		self.navigationController = navigationController
		self.delegate = delegate
		super.init()
		self.navigationController.delegate = self
	}
	
	func start() {
		
		let viewController = ContentWithImageViewController(
			viewModel: MigrationStartViewModel(
				coordinator: self
			)
		)
		navigationController.pushViewController(viewController, animated: true)
	}
	// MARK: - Universal Link handling
	
	func consume(universalLink: Models.UniversalLink) -> Bool {
		
		return false
	}
}

extension MigrationCoordinator: MigrationCoordinatorDelegate {
	
	func userCompletedStart() {
		
		if Current.walletManager.listEventGroups().isNotEmpty {
			
			// We have events -> make the user choose
			let viewController = ListOptionsViewController(viewModel: MigrationTransferOptionsViewModel(self))
			navigationController.pushViewController(viewController, animated: true)
		} else {
			
			// We have no events -> import only
			userWishesToSeeToThisDeviceInstructions()
		}
	}
	
	func userWishesToSeeToThisDeviceInstructions() {
		
		flow = .toThisDevice
		userWishesToSeeOnboarding(pages: onboardingFactory.getImportInstructions())
	}
	
	func userWishesToSeeToOtherDeviceInstructions() {
		
		flow = .toOtherDevice
		userWishesToSeeOnboarding(pages: onboardingFactory.getExportInstructions())
	}
	
	func userWishesToStartMigrationToThisDevice() {
		
		let destination = ImportViewController(
			viewModel: ImportViewModel(
				coordinator: self,
				dataImporter: DataImporter(version: version)
			)
		)
		navigationController.pushViewController(destination, animated: true)
	}
	
	func userWishesToStartMigrationToOtherDevice() {
		
		let destination = ExportLoopViewController(
			viewModel: ExportLoopViewModel(
				delegate: self,
				dataExporter: DataExporter(maxPackageSize: 800, version: version),
				screenBrightness: ScreenBrightnessManager(notificationCenter: NotificationCenter.default)
			)
		)
		navigationController.pushViewController(destination, animated: false)
	}
	
	private func userWishesToSeeOnboarding(pages: [PagedAnnoucementItem]) {
		
		let viewController = PagedAnnouncementViewController(
			title: L.holder_startMigration_onboarding_toolbar(),
			viewModel: PagedAnnouncementViewModel(
				delegate: self,
				pages: pages,
				itemsShouldShowWithFullWidthHeaderImage: true,
				shouldShowWithVWSRibbon: false,
				enableSwipeBack: true,
				hasPhantomTrailingPage: true
			),
			allowsPreviousPageButton: true,
			allowsCloseButton: false,
			allowsNextPageButton: true) { [weak self] in
				// Remove from the navigation stack
				self?.navigationController.popViewController(animated: true)
			}
		navigationController.pushViewController(viewController, animated: true)
	}
	
	func userCompletedMigrationToOtherDevice() {
		
		delegate?.dataMigrationExportCompleted()
	}
	
	func presentError(_ errorCode: ErrorCode) {
		
		let content = Content(
			title: L.holderErrorstateTitle(),
			body: errorCode.step == ErrorCode.Step.import.value ? L.holder_migration_import_errorcode_message("\(errorCode)") : L.holder_migration_export_errorcode_message("\(errorCode)"),
			primaryActionTitle: L.general_toMyOverview(),
			primaryAction: {[weak self] in
				self?.delegate?.dataMigrationCancelled()
			}
		)
		DispatchQueue.main.asyncAfter(deadline: .now() + (ProcessInfo().isUnitTesting ? 0 : 0.5)) {
			self.presentContent(content: content)
		}
	}
	
	func userWishesToSeeScannedEvents(_ parcels: [EventGroupParcel]) {
		
		let remoteEvents = parcels.compactMap { $0.asRemoteEvent() }
		let eventCoordinator = EventCoordinator(
			navigationController: navigationController,
			delegate: self
		)
		addChildCoordinator(eventCoordinator)
		
		eventCoordinator.startWithListTestEvents(remoteEvents, originalMode: .migration)
	}
	
	func userWishesToGoBackToPreviousScreen(animated: Bool = false) {
		
		navigationController.popViewController(animated: animated)
	}
}

// MARK: - PagedAnnouncementDelegate

extension MigrationCoordinator: PagedAnnouncementDelegate {
	
	func didFinishPagedAnnouncement() {
		
		switch flow {
			case .none:
				logError("No flow selected for migration")
			case .toOtherDevice:
				userWishesToStartMigrationToOtherDevice()
			case .toThisDevice:
				userWishesToStartMigrationToThisDevice()
		}
	}
}

// MARK: - UINavigationControllerDelegate

extension MigrationCoordinator: UINavigationControllerDelegate {
	
	func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
		
		if !navigationController.viewControllers.contains(where: { $0.isKind(of: ContentWithImageViewController.self) }) {
			// If there is no more ContentWithIconViewController in the stack, we are done here.
			// Works for both back swipe and back button
			delegate?.dataMigrationCancelled()
		}
	}
}

// MARK: - EventFlowDelegate

extension MigrationCoordinator: EventFlowDelegate {

	func eventFlowDidComplete() {

		removeEventCoordinator()
		delegate?.dataMigrationImportCompleted()
	}

	func eventFlowDidCancel() {

		removeEventCoordinator()
		
		if let instructionsViewController = navigationController.viewControllers
			.first(where: { $0 is PagedAnnouncementViewController }) {

			navigationController.popToViewController(
				instructionsViewController,
				animated: false
			)
		}
		userWishesToStartMigrationToThisDevice()
	}

	private func removeEventCoordinator() {
		
		if let childCoordinator = childCoordinators.first(where: { $0 is EventCoordinator }) {
			removeChildCoordinator(childCoordinator)
		}
	}
}

// MARK: ErrorCode.ClientCode

extension ErrorCode.ClientCode {
	
	static let compressionError = ErrorCode.ClientCode(value: "110")
	static let other = ErrorCode.ClientCode(value: "111")
	static let invalidVersion = ErrorCode.ClientCode(value: "112")
	static let invalidNumberOfPackages = ErrorCode.ClientCode(value: "113")
	static let decodingError = ErrorCode.ClientCode(value: "114")
}

extension EventGroupParcel {
	
	func asRemoteEvent() -> RemoteEvent? {
		
		if let remoteEvent = asRemoteEventFromSignedResponse() {
			return remoteEvent
		} else if let remoteEvent = asRemoteEventFromDCCEvent() {
			return remoteEvent
		}
		return nil
	}
	
	private func asRemoteEventFromSignedResponse() -> RemoteEvent? {
		
		let decoder = JSONDecoder()
		do {
			let signedResponse = try decoder.decode(SignedResponse.self, from: jsonData)
			let wrapper = try decoder.decode(EventFlow.EventResultWrapper.self, from: signedResponse.decodedPayload!)
			return RemoteEvent(wrapper: wrapper, signedResponse: signedResponse)
		} catch {
			logError("EventGroupParcel: SignedResponse parse error: \(error)")
		}
		return nil
	}
	
	private func asRemoteEventFromDCCEvent() -> RemoteEvent? {
		
		let decoder = JSONDecoder()
		do {
			let dccEvent = try decoder.decode(EventFlow.DccEvent.self, from: jsonData)
			if let wrapper = Current.couplingManager.convert(dccEvent.credential, couplingCode: dccEvent.couplingCode) {
				return RemoteEvent(wrapper: wrapper, signedResponse: nil)
			}
		} catch {
			logError("EventGroupParcel: DCC parse error: \(error)")
		}
		return nil
	}
}