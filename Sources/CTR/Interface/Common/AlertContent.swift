/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import CloudKit

struct AlertContent {
	
	struct Action {
		
		var title: String
		var action: ((UIAlertAction) -> Void)?
		var actionIsDestructive: Bool = false
		var actionIsPreferred: Bool = false
	}
	
//	init(
//		title: String,
//		subTitle: String,
//		cancelAction: ((UIAlertAction) -> Void)? = nil,
//		cancelTitle: String, cancelActionIsDestructive: Bool = false,
//		cancelActionIsPreferred: Bool = false,
//		okAction: ((UIAlertAction) -> Void)? = nil,
//		okTitle: String,
//		okActionIsDestructive: Bool = false,
//		okActionIsPreferred: Bool = false
//	) {
//		self.title = title
//		self.subTitle = subTitle
//		self.okAction = Action(title: okTitle, action: okAction, actionIsDestructive: okActionIsDestructive, actionIsPreferred: okActionIsPreferred)
//		self.cancelAction = Action(title: cancelTitle, action: cancelAction, actionIsDestructive: cancelActionIsDestructive, actionIsPreferred: cancelActionIsPreferred)
////		self.cancelAction = cancelAction
////		self.cancelTitle = cancelTitle
////		self.cancelActionIsDestructive = cancelActionIsDestructive
////		self.cancelActionIsPreferred = cancelActionIsPreferred
////		self.okAction = okAction
////		self.okTitle = okTitle
////		self.okActionIsDestructive = okActionIsDestructive
////		self.okActionIsPreferred = okActionIsPreferred
//	}
	
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

		func addAlertAction(action: AlertContent.Action?) {
			if let action = action {
				let alertAction = UIAlertAction(
					title: action.title,
					style: action.actionIsDestructive ? .destructive : .cancel,
					handler: action.action
				)
				alertController.addAction(alertAction)
				if action.actionIsPreferred {
					alertController.preferredAction = alertAction
				}
			}
		}
		
		guard let content = alertContent else {
			return
		}

		let alertController = UIAlertController(
			title: content.title,
			message: content.subTitle,
			preferredStyle: .alert
		)
		addAlertAction(action: content.okAction)
		addAlertAction(action: content.cancelAction)

		present(alertController, animated: true, completion: nil)
	}
}
