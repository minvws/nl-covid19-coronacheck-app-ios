/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AboutTestResultView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let spacing: CGFloat = 24
		static let horizontalMargin: CGFloat = 2
		static let bottomMargin: CGFloat = 20
	}

	/// The stackview for the content
	let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.spacing
		return view
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(stackView)
	}

	override func setupViewConstraints() {
		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor, constant: ViewTraits.horizontalMargin),
			stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor, constant: -ViewTraits.horizontalMargin),
			stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor, constant: -ViewTraits.bottomMargin)
		])
	}

	func addToStackView(subview: UIView, followedByCustomSpacing spacing: CGFloat) {
		stackView.addArrangedSubview(subview)
		stackView.setCustomSpacing(spacing, after: subview)
	}
}
