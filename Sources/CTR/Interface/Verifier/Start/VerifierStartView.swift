/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class VerifierStartView: ScrolledStackWithHeaderView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
		static let titleTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 34.0
		static let messageTopMargin: CGFloat = 24.0
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

	private let showInstructionsButton: Button = {

		let button = Button(title: "Button 2", style: .textLabelBlue)
		button.titleLabel?.font = Theme.fonts.bodyMedium
		button.contentHorizontalAlignment = .leading
		return button
	}()

	private let spacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.viewControllerBackground
		return view
	}()

	/// Footer view with primary button
	let footerButtonView: FooterButtonView = {
		let footerView = FooterButtonView()
		footerView.translatesAutoresizingMaskIntoConstraints = false
		return footerView
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		
		footerButtonView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		showInstructionsButton.touchUpInside(self, action: #selector(showInstructionsButtonTapped))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(contentTextView)
		contentView.addSubview(showInstructionsButton)
		contentView.addSubview(spacer)
		addSubview(footerButtonView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		bottomScrollViewConstraint?.isActive = false

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: headerImageView.bottomAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: contentTextView.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Content
			contentTextView.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			contentTextView.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			showInstructionsButton.centerXAnchor.constraint(
				equalTo: contentView.centerXAnchor
			),
			showInstructionsButton.topAnchor.constraint(
				equalTo: contentTextView.bottomAnchor,
				constant: ViewTraits.margin
			),
			showInstructionsButton.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			showInstructionsButton.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			showInstructionsButton.bottomAnchor.constraint(
				equalTo: contentView.bottomAnchor,
				constant: -ViewTraits.margin
			),

			// Footer view
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	/// User tapped on the showInstructions button
	@objc func showInstructionsButtonTapped() {

		showInstructionsButtonTappedCommand?()
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

	/// The  message
	var message: String? {
		didSet {
			contentTextView.html(message)
		}
	}

	/// The title of the primary button
	var primaryTitle: String = "" {
		didSet {
			footerButtonView.primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The title of the showInstructions Button
	var showInstructionsTitle: String = "" {
		didSet {
			showInstructionsButton.setTitle(showInstructionsTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?

	/// The user tapped on the showInstructions button
	var showInstructionsButtonTappedCommand: (() -> Void)?

	/// The header image
	var headerImage: UIImage? {
		didSet {
			headerImageView.image = headerImage
		}
	}

	/// Hide the header image
	func hideImage() {

		headerImageView.isHidden = true

	}

	/// Show the header image
	func showImage() {

		headerImageView.isHidden = false
	}
}
