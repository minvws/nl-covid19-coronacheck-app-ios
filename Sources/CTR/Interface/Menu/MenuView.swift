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

class MenuView: ScrolledStackView {

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
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		stackView.addArrangedSubview(topStackView)
//		stackView.addArrangedSubview(lineView)
		stackView.addArrangedSubview(bottomStackView)
		stackView.addArrangedSubview(spacer)
		addSubview(bottomLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			// Lineview
			lineView.heightAnchor.constraint(equalToConstant: 1),

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
