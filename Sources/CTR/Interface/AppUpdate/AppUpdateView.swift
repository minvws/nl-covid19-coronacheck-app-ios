/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AppUpdateView: ScrolledStackWithButtonView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let imageHeightPercentage: CGFloat = 0.50
		static let topSpacerHeight: CGFloat = 60

		// Margins
		static let spacing: CGFloat = 24
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
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	private let topSpacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		view.isHidden = true
		return view
	}()

	private let spacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
		return view
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		titleLabel.textAlignment = .center
		messageLabel.textAlignment = .center
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.addArrangedSubview(messageLabel)

		stackView.addArrangedSubview(topSpacer)
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(bottomStackView)
		stackView.addArrangedSubview(spacer)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Image
			imageView.heightAnchor.constraint(
				equalTo: heightAnchor,
				multiplier: ViewTraits.imageHeightPercentage
			),

			// Spacer
			spacer.heightAnchor.constraint(equalTo: primaryButton.heightAnchor),

			topSpacer.heightAnchor.constraint(equalToConstant: ViewTraits.topSpacerHeight)
		])

		setupPrimaryButton(useFullWidth: true)
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.text = message
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
		topSpacer.isHidden = false
	}

	/// Show the image
	func showImage() {

		imageView.isHidden = false
		topSpacer.isHidden = true
	}
}
