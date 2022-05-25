/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct AlertContent {
	init(title: String, subTitle: String, cancelAction: ((UIAlertAction) -> Void)? = nil, cancelTitle: String, cancelActionIsDestructive: Bool = false, cancelActionIsPreferred: Bool = false, okAction: ((UIAlertAction) -> Void)? = nil, okTitle: String, okActionIsDestructive: Bool = false, okActionIsPreferred: Bool = false) {
		self.title = title
		self.subTitle = subTitle
		self.cancelAction = cancelAction
		self.cancelTitle = cancelTitle
		self.cancelActionIsDestructive = cancelActionIsDestructive
		self.cancelActionIsPreferred = cancelActionIsPreferred
		self.okAction = okAction
		self.okTitle = okTitle
		self.okActionIsDestructive = okActionIsDestructive
		self.okActionIsPreferred = okActionIsPreferred
	}
	
	private (set) var title: String
	private (set) var subTitle: String
	private (set) var cancelAction: ((UIAlertAction) -> Void)?
	private (set) var cancelTitle: String?
	private (set) var cancelActionIsDestructive: Bool = false
	private (set) var cancelActionIsPreferred: Bool = false
	private (set) var okAction: ((UIAlertAction) -> Void)?
	private (set) var okTitle: String
	private (set) var okActionIsDestructive: Bool = false
	private (set) var okActionIsPreferred: Bool = false
	
	init(title: String, subTitle: String, okTitle: String, okAction: ((UIAlertAction) -> Void)? = nil, okActionIsPreferred: Bool = false) {
		self.title = title
		self.subTitle = subTitle
		self.okAction = okAction
		self.okTitle = okTitle
		self.okActionIsPreferred = okActionIsPreferred
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

		let okAction = UIAlertAction(
			title: content.okTitle,
			style: content.okActionIsDestructive ? .destructive : .default,
			handler: content.okAction
		)
		alertController.addAction(okAction)
		if content.okActionIsPreferred {
			alertController.preferredAction = okAction
		}

		// Optional cancel button:
		if let cancelTitle = content.cancelTitle {
			let cancelAction = UIAlertAction(
					title: cancelTitle,
					style: content.cancelActionIsDestructive ? .destructive : .cancel,
					handler: content.cancelAction
				)
			alertController.addAction(cancelAction)
			if content.cancelActionIsPreferred {
				alertController.preferredAction = cancelAction
			}
		}

		present(alertController, animated: true, completion: nil)
	}
}
