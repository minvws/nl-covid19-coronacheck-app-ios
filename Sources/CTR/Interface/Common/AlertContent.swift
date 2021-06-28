/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

struct AlertContent {
	var title: String
	var subTitle: String
	var cancelAction: ((UIAlertAction) -> Void)?
	var cancelTitle: String?
	var okAction: ((UIAlertAction) -> Void)?
	var okTitle: String
}

extension UIViewController {
	
	func showAlert(_ alertContent: AlertContent?) {

		guard let content = alertContent else {
			return
		}

		let alertController = UIAlertController(
			title: content.title,
			message: content.subTitle,
			preferredStyle: .alert
		)
		alertController.addAction(
			UIAlertAction(
				title: content.okTitle,
				style: .default,
				handler: content.okAction
			)
		)

		// Optional cancel button:
		if let cancelTitle = content.cancelTitle {
			alertController.addAction(
				UIAlertAction(
					title: cancelTitle,
					style: .cancel,
					handler: content.cancelAction
				)
			)
		}
		present(alertController, animated: true, completion: nil)
	}
}
