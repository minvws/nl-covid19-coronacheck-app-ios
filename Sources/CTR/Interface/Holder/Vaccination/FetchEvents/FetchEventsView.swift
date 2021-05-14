/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class FetchEventsView: ScrolledStackView {

	/// The spinner
	let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			view.style = .large
		} else {
			view.style = .whiteLarge
		}
		view.color = Theme.colors.primary
		return view
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(spinner)
	}
}
