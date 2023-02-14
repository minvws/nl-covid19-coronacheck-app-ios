/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import MessageUI
import Shared
import Persistence
import Managers
import Models

// Note: Do NOT use `Current` in this context, as it's not available

class UnrecoverableErrorCoordinator: NSObject, Coordinator {
	
	let window: UIWindow
	
	var childCoordinators = [Coordinator]()
	
	var navigationController = UINavigationController() // unused

	let error: Error

	/// For use with iOS 13 and higher
	@available(iOS 13.0, *)
	init(scene: UIWindowScene, error: Error) {
		self.window = UIWindow(windowScene: scene)
		self.error = error
	}
	
	/// For use with iOS 12.
	init(error: Error) {
		
		self.window = UIWindow(frame: UIScreen.main.bounds)
		self.error = error
	}
	
	// Designated starter method
	func start() {
		
		if case .diskFull = (error as? DataStoreManager.Error) {
			startForDiskFull()
		} else {
			startForSendCrashReport()
		}
	}
	
	private func startForDiskFull() {
		let viewController = AppStatusViewController(viewModel: DiskFullViewModel())
		window.rootViewController = viewController
		window.makeKeyAndVisible()
	}
	
	private func startForSendCrashReport() {
		let backingViewController = UIViewController()
		backingViewController.view.backgroundColor = .white
		
		navigationController.setViewControllers([backingViewController], animated: false)
		
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
		
		guard MFMailComposeViewController.canSendMail() else { // Simulator can't send mail.
			self.presentRestartTheAppDialog()
			return
		}
		
		presentSendCrashReportDialog()
	}
	
	private func presentSendCrashReportDialog() {
		
		let alertController = UIAlertController(
			title: L.general_unrecoverableError_sendCrashReport_title(),
			message: L.general_unrecoverableError_sendCrashReport_message(),
			preferredStyle: .alert
		)
		let openEmailAction = UIAlertAction(
			title: L.general_unrecoverableError_sendCrashReport_action(),
			style: .default) { [weak self] _ in
			self?.openEmailDialog()
		}
		let closeAction = UIAlertAction(
			title: L.generalClose(),
			style: .cancel) { [weak self] _ in
			self?.presentRestartTheAppDialog()
		}
		
		alertController.addAction(openEmailAction)
		alertController.addAction(closeAction)
		alertController.preferredAction = openEmailAction
		
		navigationController.present(alertController, animated: false)
	}
	
	private func presentRestartTheAppDialog() {
		let alertController = UIAlertController(
			title: L.general_unrecoverableError_restartTheApp_title(),
			message: L.general_unrecoverableError_restartTheApp_message(),
			preferredStyle: .alert
		)
		alertController.addAction(UIAlertAction(title: L.generalClose(), style: .default) { _ in
			exit(0)
		})
		navigationController.present(alertController, animated: false)
	}
	
	private func openEmailDialog() {

		let localDesc = (error as NSError).localizedDescription
		let userInfo = (error as NSError).userInfo.filter { $0.key != NSFilePathErrorKey }
		
		let messageBody = L.general_unrecoverableError_email_body(
			"iOS",
			AppFlavor.flavor.rawValue.capitalizingFirstLetter(),
			AppVersionSupplier().getCurrentVersion(),
			AppVersionSupplier().getCurrentBuild(),
			localDesc,
			String(describing: userInfo)
		)
		
		let viewController = MFMailComposeViewController()
		viewController.mailComposeDelegate = self
		viewController.setToRecipients(["crashreport@coronacheck.nl"])
		viewController.setSubject(L.general_unrecoverableError_email_subject("iOS", AppFlavor.flavor.rawValue.capitalizingFirstLetter()))
		viewController.setMessageBody(messageBody, isHTML: false)
		
		navigationController.present(viewController, animated: true, completion: nil)
	}
}

extension UnrecoverableErrorCoordinator {
	func consume(universalLink: UniversalLink) -> Bool {
		return false
	}
}

extension UnrecoverableErrorCoordinator: MFMailComposeViewControllerDelegate {
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true) {
			self.presentRestartTheAppDialog()
		}
	}
}
