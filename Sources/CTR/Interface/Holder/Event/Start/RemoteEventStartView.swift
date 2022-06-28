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

		static let margin: CGFloat = 20.0

		enum SecondaryButton {
			static let height: CGFloat = 52
		}
		enum Title {
			static let lineHeight: CGFloat = 26
			static let kerning: CGFloat = -0.26
		}
		enum InfoCard {
			static let radius: CGFloat = 8.0
			static let borderWidth: CGFloat = 1.0
		}
		enum InfoText {
			static let margin: CGFloat = 20.0
			static let bottomMargin: CGFloat = 16.0
		}
		enum LabelWithCheckbox {
			static let margin: CGFloat = 20.0
			static let leadingMargin: CGFloat = 4.0
			static let trailingMargin: CGFloat = 4.0
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
	
	let infoCard: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.layer.cornerRadius = ViewTraits.InfoCard.radius
		view.layer.borderWidth = ViewTraits.InfoCard.borderWidth
		view.layer.borderColor = C.grey4()?.cgColor
		return view
	}()

	let infoTextView: TextView = {

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
		labelWithCheckbox.defaultBackgroundColor = C.white()
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
		
		infoCard.addSubview(infoTextView)
		infoCard.addSubview(labelWithCheckbox)

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
		stackView.addArrangedSubview(infoCard)
		footerButtonView.buttonStackView.addArrangedSubview(secondaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Secondary button
			secondaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.SecondaryButton.height)
		])
		
		setupInfoCardViewConstraints()
	}
	
	func setupInfoCardViewConstraints() {
		NSLayoutConstraint.activate([

			infoTextView.topAnchor.constraint(
				equalTo: infoCard.topAnchor,
				constant: ViewTraits.InfoText.margin
			),
			infoTextView.leadingAnchor.constraint(
				equalTo: infoCard.leadingAnchor,
				constant: ViewTraits.InfoText.margin
			),
			infoTextView.trailingAnchor.constraint(
				equalTo: infoCard.trailingAnchor,
				constant: -ViewTraits.InfoText.margin
			),
			infoTextView.bottomAnchor.constraint(
				equalTo: labelWithCheckbox.topAnchor,
				constant: -ViewTraits.InfoText.bottomMargin
			),
			
			labelWithCheckbox.leadingAnchor.constraint(
				equalTo: infoCard.leadingAnchor,
				constant: ViewTraits.LabelWithCheckbox.leadingMargin
			),

			labelWithCheckbox.trailingAnchor.constraint(
				equalTo: infoCard.trailingAnchor,
				constant: -ViewTraits.LabelWithCheckbox.trailingMargin
			),
			labelWithCheckbox.bottomAnchor.constraint(
				equalTo: infoCard.bottomAnchor,
				constant: -ViewTraits.LabelWithCheckbox.margin
			)
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
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}

	var message: String? {
		didSet {
			contentTextView.applyHTML(message)
		}
	}
	
	var info: String? {
		didSet {
			infoTextView.applyHTML(info)
		}
	}
	
	var primaryButtonIcon: UIImage? {
		didSet {
			primaryButton.setImage(primaryButtonIcon, for: .normal)
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
			infoCard.isHidden = checkboxTitle == nil
		}
	}
	
	var didToggleCheckboxCommand: ((Bool) -> Void)?
}
