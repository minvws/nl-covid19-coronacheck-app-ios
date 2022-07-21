/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class FetchRemoteEventsView: ContentView {

	private let activityIndicatorView: ActivityIndicatorView = {
		
		let view = ActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(activityIndicatorView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor),
			activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
	
	var shouldShowLoadingSpinner: Bool = false {
		didSet {
			activityIndicatorView.shouldShowLoadingSpinner = shouldShowLoadingSpinner
		}
	}
	
	func applyContent(_ content: Content) {

		// Texts
		title = content.title
		message = content.body

		// Button
		if let actionTitle = content.primaryActionTitle {
			primaryTitle = actionTitle
			footerButtonView.isHidden = false
		} else {
			primaryTitle = nil
			footerButtonView.isHidden = true
		}
		primaryButtonTappedCommand = content.primaryAction
		secondaryButtonTappedCommand = content.secondaryAction
		secondaryButtonTitle = content.secondaryActionTitle
	}
}
