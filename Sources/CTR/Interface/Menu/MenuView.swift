/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class MenuItemView: BaseView {

	/// The message label
	let titleLabel: Label = {

		return Label(body: nil).multiline()
	}()

	let primaryButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// Setup the views
	override func setupViews() {

		super.setupViews()
		primaryButton.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(titleLabel)
		addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		titleLabel.embed(in: self)
		primaryButton.embed(in: self)
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}

class MenuView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let lineheight: CGFloat = 1.0

		// Margins
		static let margin: CGFloat = 20.0
		static let topMenuSpacing: CGFloat = 28.0
		static let bottomMenuSpacing: CGFloat = 24.0
		static let lineMarginTop: CGFloat = 27.0
		static let lineMarginBottom: CGFloat = 18.0
	}

	/// The stackview for the content
	 let topStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.topMenuSpacing
		return view
	}()

	/// The stackview for the content
	 let bottomStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.bottomMenuSpacing
		return view
	}()

	let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.secondary.withAlphaComponent(0.2)
		return view
	}()

	/// The bottom label
	let bottomLabel: Label = {

		return Label(body: nil).multiline()
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.primary
		bottomLabel.textColor = Theme.colors.secondary
		bottomLabel.font = Theme.fonts.subheadMontserrat
		bottomLabel.textAlignment = .right
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(topStackView)
//		addSubview(lineView)
		addSubview(bottomStackView)
		addSubview(bottomLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Top Stack View
			topStackView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
			),

			topStackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			topStackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

//			// Line
//			lineView.heightAnchor.constraint(equalToConstant: 1),
//			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
//			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
//			lineView.topAnchor.constraint(
//				equalTo: topStackView.bottomAnchor,
//				constant: ViewTraits.lineMarginTop
//			),

			// Bottom Stack view
//			bottomStackView.topAnchor.constraint(
//				equalTo: lineView.bottomAnchor,
//				constant: ViewTraits.lineMarginBottom
//			),
			bottomStackView.topAnchor.constraint(
				equalTo: topStackView.bottomAnchor,
				constant: ViewTraits.lineMarginBottom * 2
			),
			bottomStackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			bottomStackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			bottomLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
			bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
			bottomLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor)
		])
	}

	// MARK: Public Access

	/// The bottomText
	var bottomText: String? {
		didSet {
			bottomLabel.text = bottomText
		}
	}
}
