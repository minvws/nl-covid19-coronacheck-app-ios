/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/*
 A fullscreen scrollView with a public nested stackView to add views to.
 If you need a scrollable fullscreen view, this is the one you need.
 */
open class ScrolledStackView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 16.0
		static let spacing: CGFloat = 32.0
	}

	/// Scroll view bottom constraint
	public var bottomScrollViewConstraint: NSLayoutConstraint?

	public var stackViewInset = UIEdgeInsets(
		top: ViewTraits.topMargin,
		left: ViewTraits.margin,
		bottom: ViewTraits.margin,
		right: ViewTraits.margin
	)

	/// The scrollview
	public let scrollView: UIScrollView = {

		let view = UIScrollView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.showsHorizontalScrollIndicator = false
		return view
	}()

	/// The stackview for the content
	public let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .equalSpacing
		view.spacing = ViewTraits.spacing
		return view
	}()
	
	/// Content view to get proper size in scroll view
	public let scrollViewContent: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// Setup the hierarchy
	override open func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.embed(in: scrollViewContent)
		scrollView.addSubview(scrollViewContent)
		addSubview(scrollView)
	}

	/// Setup the constraints
	override open func setupViewConstraints() {

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
			scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: stackViewInset.left),
			scrollViewContent.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: stackViewInset.top),
			scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -stackViewInset.bottom),
			scrollViewContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -stackViewInset.left - stackViewInset.right),
			
			// StackView
			stackView.widthAnchor.constraint(equalTo: scrollViewContent.widthAnchor),
			stackView.centerXAnchor.constraint(equalTo: scrollViewContent.centerXAnchor)
		])
	}
}
