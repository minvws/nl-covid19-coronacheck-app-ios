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

	/// Setup all the accessibility traits
	override func setupAccessibility() {

		super.setupAccessibility()
		
		titleLabel.isAccessibilityElement = false

	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
			primaryButton.accessibilityLabel = title
		}
	}
}

class MenuView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0
		static let topMargin: CGFloat = 32.0
		static let topMenuSpacing: CGFloat = 32.0
		static let bottomMenuSpacing: CGFloat = 24.0
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

	private let spacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	/// The bottom label
	let bottomLabel: Label = {

		return Label(footnote: nil, textColor: Theme.colors.secondary).multiline()
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.primary
		
		stackViewInset = UIEdgeInsets(
			top: ViewTraits.topMargin,
			left: ViewTraits.margin,
			bottom: ViewTraits.margin,
			right: ViewTraits.margin
		)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		stackView.addArrangedSubview(topStackView)
		stackView.addArrangedSubview(bottomStackView)
		stackView.addArrangedSubview(spacer)
		addSubview(bottomLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			// Spacer
			spacer.heightAnchor.constraint(equalTo: bottomLabel.heightAnchor),

			// Bottom label
			bottomLabel.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			),
			bottomLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
			bottomLabel.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			)
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
