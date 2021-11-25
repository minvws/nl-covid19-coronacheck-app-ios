/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct AlertContent {
	var title: String?
	var subTitle: String?
	var cancelAction: ((UIAlertAction) -> Void)?
	var cancelTitle: String?
	var okAction: ((UIAlertAction) -> Void)?
	var okTitle: String?
}

extension UIViewController {

	/// Show an alert
	/// - Parameters:
	///   - alertContent: the content of the alert
	///   - preferredAction: the title of the preferred action
	func showAlert(_ alertContent: AlertContent?, preferredAction: String? = nil, okActionIsDestructive: Bool = false) {

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
				style: okActionIsDestructive ? .destructive : .default,
				handler: content.okAction
		)
		alertController.addAction(okAction)
		if preferredAction == content.okTitle {
			alertController.preferredAction = okAction
		}

		// Optional cancel button:
		if let cancelTitle = content.cancelTitle {
			let cancelAction = UIAlertAction(
					title: cancelTitle,
					style: .cancel,
					handler: content.cancelAction
				)
			alertController.addAction(cancelAction)
			if preferredAction == cancelTitle {
				alertController.preferredAction = cancelAction
			}
		}

		present(alertController, animated: true, completion: nil)
	}
}
