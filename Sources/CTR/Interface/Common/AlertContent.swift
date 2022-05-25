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
	}
	
	private (set) var title: String
	private (set) var subTitle: String
	private (set) var okAction: AlertContent.Action
	private (set) var cancelAction: AlertContent.Action?
	
	init(
		title: String,
		subTitle: String,
		okAction: AlertContent.Action,
		cancelAction: AlertContent.Action? = nil) {
		self.title = title
		self.subTitle = subTitle
		self.okAction = okAction
		self.cancelAction = cancelAction
	}
}

extension UIViewController {

	/// Show an alert
	/// - Parameters:
	///   - alertContent: the content of the alert
	func showAlert(_ alertContent: AlertContent?) {
	
		guard let content = alertContent else {
			return
		}

		let alertController = UIAlertController(
			title: content.title,
			message: content.subTitle,
			preferredStyle: .alert
		)
		alertController.addAlertAction(action: content.okAction)
		if let cancelAction = content.cancelAction {
			alertController.addAlertAction(action: cancelAction, style: .cancel)
		}

		present(alertController, animated: true, completion: nil)
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
