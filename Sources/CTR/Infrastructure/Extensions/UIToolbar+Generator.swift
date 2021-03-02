/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

extension UIToolbar {

	/// The month picker toolbar
	/// - Parameters:
	///   - previousSelector: the previous action
	///   - nextSelector: the next action
	///   - doneSelector: the done action
	/// - Returns: the toolbar
	class func generateMonthPickerToolbar(
		previousSelector: Selector,
		nextSelector: Selector,
		doneSelector: Selector) -> UIToolbar {

		let bar = UIToolbar()
		bar.sizeToFit()

		let doneButton = UIBarButtonItem(
			title: .done,
			style: .done,
			target: nil,
			action: doneSelector
		)

		let spaceButton = UIBarButtonItem(
			barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace,
			target: nil,
			action: nil
		)

		let previousButton = UIBarButtonItem(
			title: "<",
			style: .plain,
			target: nil,
			action: previousSelector
		)

		let nextButton = UIBarButtonItem(
			title: ">",
			style: .plain,
			target: nil,
			action: nextSelector
		)

		bar.setItems([previousButton, nextButton, spaceButton, doneButton], animated: false)

		return bar
	}
}
