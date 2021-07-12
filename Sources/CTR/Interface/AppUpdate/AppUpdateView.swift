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
		static let topSpacerHeightMultiplier: CGFloat = 0.07

		// Margins
		static let labelSpacing: CGFloat = 24
		static let imageToLabelSpacing: CGFloat = 43
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

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	private let topSpacer: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .clear
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
		
		stackView.setCustomSpacing(ViewTraits.imageToLabelSpacing, after: imageView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Spacer
			spacer.heightAnchor.constraint(equalTo: primaryButton.heightAnchor),

			topSpacer.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: ViewTraits.topSpacerHeightMultiplier)
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
	}

	/// Show the image
	func showImage() {

		imageView.isHidden = false
	}
}
