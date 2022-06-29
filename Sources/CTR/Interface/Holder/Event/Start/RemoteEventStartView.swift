/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class RemoteEventStartView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22
		static let buttonHeight: CGFloat = 52

		// Margins
		static let margin: CGFloat = 20.0
		
		enum Icon {
			static let size: CGSize = CGSize(width: 22.0, height: 22.0)
		}
	}

	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()

	let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let secondaryButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .center
		button.contentEdgeInsets = .topBottom(Button.ButtonType.roundedBlue.contentEdgeInsets.top) + .leftRight(ViewTraits.margin)
		return button
	}()
	
	private let labelWithCheckbox: LabelWithCheckbox = {
		let labelWithCheckbox = LabelWithCheckbox()
		labelWithCheckbox.translatesAutoresizingMaskIntoConstraints = false
		labelWithCheckbox.title = "This is a kind of test message"
		return labelWithCheckbox
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		stackView.distribution = .equalSpacing
		secondaryButton.touchUpInside(self, action: #selector(secondaryButtonTapped))
		primaryButton.style = .roundedBlueImage
		footerButtonView.buttonStackView.spacing = ViewTraits.margin
		labelWithCheckbox.addTarget(self, action: #selector(didToggleCheckbox), for: .valueChanged)
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
		stackView.addArrangedSubview(labelWithCheckbox)
		footerButtonView.buttonStackView.addArrangedSubview(secondaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Secondary button
			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.buttonHeight)
		])
	}

	@objc func secondaryButtonTapped() {

		secondaryButtonTappedCommand?()
	}

	@objc func didToggleCheckbox(_ labelWithCheckbox: LabelWithCheckbox) {

		didToggleCheckboxCommand?(labelWithCheckbox.isSelected)
	}

	// MARK: Public Access

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}

	var message: String? {
		didSet {
			contentTextView.applyHTML(message)
		}
	}
	
	var primaryButtonIcon: UIImage? {
		didSet {
			let resizedIcon = primaryButtonIcon?.resizedImage(toSize: ViewTraits.Icon.size)
			primaryButton.setImage(resizedIcon, for: .normal)
		}
	}

	var secondaryButtonTappedCommand: (() -> Void)?

	var secondaryButtonTitle: String? {
		didSet {
			secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
		}
	}
	
	var checkboxTitle: String? {
		didSet {
			labelWithCheckbox.title = checkboxTitle
			labelWithCheckbox.isHidden = checkboxTitle == nil
		}
	}
	
	var didToggleCheckboxCommand: ((Bool) -> Void)?
}
