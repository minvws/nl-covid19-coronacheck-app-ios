/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppStatusView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let topSpacerHeightMultiplier: CGFloat = 0.07

		// Margins
		static let labelSpacing: CGFloat = 24
		static let imageToLabelSpacing: CGFloat = 43
		static let bottomStackViewMargin: CGFloat = 20
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}

	/// The image view
	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()

	private let bottomStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .center
		view.distribution = .fill
		view.spacing = ViewTraits.labelSpacing
		return view
	}()

	/// The title label
	let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	let contentTextView: TextView = {

		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let topSpacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.addArrangedSubview(contentTextView)

		stackView.addArrangedSubview(topSpacer)
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(bottomStackView)
		
		stackView.setCustomSpacing(ViewTraits.imageToLabelSpacing, after: imageView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			topSpacer.heightAnchor.constraint(
				equalTo: safeAreaLayoutGuide.heightAnchor,
				multiplier: ViewTraits.topSpacerHeightMultiplier
			),
			
			bottomStackView.leadingAnchor.constraint(
				equalTo: stackView.leadingAnchor,
				constant: ViewTraits.bottomStackViewMargin
			),
			bottomStackView.trailingAnchor.constraint(
				equalTo: stackView.trailingAnchor,
				constant: -ViewTraits.bottomStackViewMargin
			)
		])
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	/// The onboarding message
	var message: String? {
		didSet {
			contentTextView.attributedText = .makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(font: Fonts.body, textColor: C.black()!, alignment: .center)
			)
		}
	}
	
	/// The onboarding mage
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}

	/// Hide the image
	func hideImage() {

		imageView.isHidden = true
	}

	/// Show the image
	func showImage() {

		imageView.isHidden = false
	}
	
	var urlTapHander: ((URL) -> Void)? {
		didSet {
			contentTextView.linkTouchedHandler = { [weak self] url in
				self?.urlTapHander?(url)
			}
		}
	}
}
