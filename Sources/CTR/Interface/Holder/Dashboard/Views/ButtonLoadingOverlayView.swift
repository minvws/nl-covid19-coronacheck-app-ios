/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

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
				? Theme.colors.primary
				: Theme.colors.tertiary

			activityIndicatorView.color = buttonAppearsEnabled
				? Theme.colors.viewControllerBackground
				: Theme.colors.gray
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
