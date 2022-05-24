/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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

	/// Scroll view bottom constraint
	var bottomScrollViewConstraint: NSLayoutConstraint?

	var stackViewInset = UIEdgeInsets(
		top: ViewTraits.topMargin,
		left: ViewTraits.margin,
		bottom: ViewTraits.margin,
		right: ViewTraits.margin
	)

	/// The scrollview
	let scrollView: UIScrollView = {

		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.showsHorizontalScrollIndicator = false
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
	
	/// Content view to get proper size in scroll view
	let contentScrollView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.embed(in: contentScrollView)
		scrollView.addSubview(contentScrollView)
		addSubview(scrollView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		stackView.preservesSuperviewLayoutMargins = true

		NSLayoutConstraint.activate([
			
			// Scrollview
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			{
				let constraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
				bottomScrollViewConstraint = constraint
				return constraint
			}(),
			
			// Content view
			contentScrollView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: stackViewInset.left),
			contentScrollView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -stackViewInset.right),
			contentScrollView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stackViewInset.top),
			contentScrollView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -stackViewInset.bottom),
			contentScrollView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -stackViewInset.left - stackViewInset.right),
			
			// StackView
			stackView.widthAnchor.constraint(equalTo: contentScrollView.widthAnchor),
			stackView.centerXAnchor.constraint(equalTo: contentScrollView.centerXAnchor)
		])
	}
}
