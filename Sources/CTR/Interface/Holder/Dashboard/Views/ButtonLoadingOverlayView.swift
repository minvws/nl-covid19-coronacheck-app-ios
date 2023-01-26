/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class ButtonLoadingOverlayView: UIView {

	private let activityIndicatorView: UIActivityIndicatorView

	init() {
		activityIndicatorView = UIActivityIndicatorView()
		activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false

		super.init(frame: .zero)

		addSubview(activityIndicatorView)

		NSLayoutConstraint.activate([
			activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
			activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])

		activityIndicatorView.startAnimating()
	}

	var buttonAppearsEnabled: Bool = false {
		didSet {
			backgroundColor = buttonAppearsEnabled
				? C.primaryBlue()
				: C.grey5()

			activityIndicatorView.color = buttonAppearsEnabled
				? C.white()
				: C.grey3()!
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		updateRoundedCorners()
	}

	private func updateRoundedCorners() {
		layer.cornerRadius = min(bounds.width, bounds.height) / 2
	}
}
