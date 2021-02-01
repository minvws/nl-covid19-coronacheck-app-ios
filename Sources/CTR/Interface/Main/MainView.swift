/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MainView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 50

		// Margins
		static let margin: CGFloat = 16.0
		static let buttonOffset: CGFloat = 27.0
		static let buttonSpacing: CGFloat = 40.0
	}

	/// The stackview to house all elements
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .center
		view.distribution = .fill
		view.spacing = 40.0
		return view
	}()

	/// the first button
	private let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// the second button
	private let secondaryButton: Button = {

		let button = Button(title: "Button 2", style: .primary)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// the tertiary button
	private let tertiaryButton: Button = {

		let button = Button(title: "Button 3", style: .primary)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	private let messageLabel: Label = {

		let label = Label(body: nil).multiline()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		return label
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = .white

		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
		tertiaryButton.touchUpInside(self, action: #selector(tertiaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		setupStackView()
		addSubview(stackView)
	}

	/// Setup the stack view
	private func setupStackView() {

		stackView.addArrangedSubview(primaryButton)
	}
	/// Setup the constraints
	override func setupViewConstraints() {

		NSLayoutConstraint.activate([

			// Stackview
			stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
			stackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: stackView.leadingAnchor,
				constant: ViewTraits.buttonOffset
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: stackView.trailingAnchor,
				constant: -ViewTraits.buttonOffset
			)
		])
	}

	func setupSecondaryButtonConstraints() {

		NSLayoutConstraint.activate([

			secondaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			secondaryButton.leadingAnchor.constraint(
				equalTo: stackView.leadingAnchor,
				constant: ViewTraits.buttonOffset
			),
			secondaryButton.trailingAnchor.constraint(
				equalTo: stackView.trailingAnchor,
				constant: -ViewTraits.buttonOffset
			)
		])
	}

	func setupTertiaryButtonConstraints() {

		NSLayoutConstraint.activate([

			tertiaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			tertiaryButton.leadingAnchor.constraint(
				equalTo: stackView.leadingAnchor,
				constant: ViewTraits.buttonOffset
			),
			tertiaryButton.trailingAnchor.constraint(
				equalTo: stackView.trailingAnchor,
				constant: -ViewTraits.buttonOffset
			)

		])
	}

	func setutMessageLabelConstraints() {

		NSLayoutConstraint.activate([

			messageLabel.leadingAnchor.constraint(
				equalTo: stackView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: stackView.trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	var secondaryTitle: String = "" {
		didSet {
			secondaryButton.setTitle(secondaryTitle, for: .normal)
			if secondaryTitle.isEmpty {
				stackView.removeArrangedSubview(secondaryButton)
			} else {
				stackView.addArrangedSubview(secondaryButton)
				setupSecondaryButtonConstraints()
			}
		}
	}

	var tertiaryTitle: String = "" {
		didSet {
			tertiaryButton.setTitle(tertiaryTitle, for: .normal)
			if tertiaryTitle.isEmpty {
				stackView.removeArrangedSubview(tertiaryButton)
			} else {
				stackView.addArrangedSubview(tertiaryButton)
				setupTertiaryButtonConstraints()
			}
		}
	}

	var message: String = "" {
		didSet {
			messageLabel.text = message
			if message.isEmpty {
				stackView.removeArrangedSubview(messageLabel)
			} else {
				stackView.addArrangedSubview(messageLabel)
				setutMessageLabelConstraints()
			}
		}
	}

	var primaryButtonColor: UIColor = Theme.colors.primary {
		didSet {
			primaryButton.backgroundColor = primaryButtonColor
		}
	}

	var secondaryButtonColor: UIColor = Theme.colors.primary {
		didSet {
			secondaryButton.backgroundColor = secondaryButtonColor
		}
	}

	var tertiaryButtonColor: UIColor = Theme.colors.primary {
		didSet {
			tertiaryButton.backgroundColor = tertiaryButtonColor
		}
	}

	/// User tapped on the result
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	/// User tapped on the result
	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	/// User tapped on the result
	@objc func tertiaryButtonTapped() {

		tertiaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The user tapped on the secondary button
	var secondaryButtonTappedCommand: (() -> Void)?

	/// The user tapped on the secondary button
	var tertiaryButtonTappedCommand: (() -> Void)?
}
