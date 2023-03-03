/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Resources

/*
 A struct to setup an alert dialog. Use viewController.showAlert(alertContent) to show the dialog. 
 */
public struct AlertContent {
	
	public struct Action {
		
		public var title: String
		public var action: ((UIAlertAction) -> Void)?
		public var isDestructive: Bool = false
		public var isPreferred: Bool = false
		
		public static let okay = AlertContent.Action(title: L.generalOk(), action: nil)
		public static let cancel = AlertContent.Action(title: L.general_cancel(), action: nil)
		
		public init(title: String, action: ((UIAlertAction) -> Void)? = nil, isDestructive: Bool = false, isPreferred: Bool = false) {
			self.title = title
			self.action = action
			self.isDestructive = isDestructive
			self.isPreferred = isPreferred
		}
	}
	
	public private (set) var title: String
	public private (set) var subTitle: String
	public private (set) var okAction: AlertContent.Action
	public private (set) var cancelAction: AlertContent.Action?
	public private (set) var alertWasPresentedCallback: (() -> Void)?
	
	public init(
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
	public func showAlert(_ alertContent: AlertContent) {

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
	
	public func addAlertAction(action: AlertContent.Action, style: UIAlertAction.Style = .default) {
		
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
