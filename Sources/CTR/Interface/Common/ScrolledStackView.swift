/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScrolledStackView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 16.0
		static let spacing: CGFloat = 32.0
	}

	/// bottom constraint for scroll view
	var bottomScrollViewConstraint: NSLayoutConstraint?

	var stackViewInset = UIEdgeInsets(
		top: ViewTraits.topMargin,
		left: ViewTraits.margin,
		bottom: ViewTraits.margin,
		right: ViewTraits.margin
	)

	/// The scrollview
	let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stackview for the content
	let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .equalSpacing
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		scrollView.addSubview(stackView)
		addSubview(scrollView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		stackView.embed(in: scrollView, insets: stackViewInset)

		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

			// StackView
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -stackViewInset.left - stackViewInset.right
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])

		bottomScrollViewConstraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
		bottomScrollViewConstraint?.isActive = true
	}
}
