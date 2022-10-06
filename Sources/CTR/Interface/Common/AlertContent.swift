/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct AlertContent {
	
	struct Action {
		
		var title: String
		var action: ((UIAlertAction) -> Void)?
		var isDestructive: Bool = false
		var isPreferred: Bool = false
		
		static let okay = AlertContent.Action(title: L.generalOk())
		static let cancel = AlertContent.Action(title: L.general_cancel())
	}
	
	private (set) var title: String
	private (set) var subTitle: String
	private (set) var okAction: AlertContent.Action
	private (set) var cancelAction: AlertContent.Action?
	private (set) var alertWasPresentedCallback: (() -> Void)?
	
	init(
		title: String,
		subTitle: String,
		okAction: AlertContent.Action,
		cancelAction: AlertContent.Action? = nil,
		alertWasPresentedCallback: (() -> Void)? = nil) {
		self.title = title
		self.subTitle = subTitle
		self.okAction = okAction
		self.cancelAction = cancelAction
		self.alertWasPresentedCallback = alertWasPresentedCallback
	}
}

extension UIViewController {

	/// Show an alert
	/// - Parameters:
	///   - alertContent: the content of the alert
	func showAlert(_ alertContent: AlertContent) {

		performUIUpdate {
			let alertController = UIAlertController(
				title: alertContent.title,
				message: alertContent.subTitle,
				preferredStyle: .alert
			)
			alertController.addAlertAction(action: alertContent.okAction)
			if let cancelAction = alertContent.cancelAction {
				alertController.addAlertAction(action: cancelAction, style: .cancel)
			}
			
			self.present(alertController, animated: true, completion: alertContent.alertWasPresentedCallback)
		}
	}
}

extension UIAlertController {
	
	func addAlertAction(action: AlertContent.Action, style: UIAlertAction.Style = .default) {
		
		let alertAction = UIAlertAction(
			title: action.title,
			style: action.isDestructive ? .destructive : style,
			handler: action.action
		)
		addAction(alertAction)
		if action.isPreferred {
			preferredAction = alertAction
		}
	}
}
