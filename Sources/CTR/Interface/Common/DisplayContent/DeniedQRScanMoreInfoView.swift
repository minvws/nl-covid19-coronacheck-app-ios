/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DeniedQRScanMoreInfoView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let spacing: CGFloat = 24
		static let bottomMargin: CGFloat = 20
		static let horizontalMargin: CGFloat = 2
	}

	/// The title label
	private let titleLabel: Label = {

        return Label(title1: nil, montserrat: true).multiline().header()
	}()

	/// The stackview for the content
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.spacing
		return view
	}()

	func addToStackView(subview: UIView, followedByCustomSpacing spacing: CGFloat) {
		stackView.addArrangedSubview(subview)
		stackView.setCustomSpacing(spacing, after: subview)
	}

	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
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

		stackView.addArrangedSubview(titleLabel)
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}
}
