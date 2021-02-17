/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class OnboardingPageView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = UIDevice.current.isSmallScreen ? 17 : 22
		
		// Margins
		static let margin: CGFloat = UIDevice.current.isSmallScreen ? 0 : 20
		static let spacing: CGFloat = UIDevice.current.isSmallScreen ? 10 : 40
	}
	
	/// The container for centering the image
	private let imageContainerView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// The image view
	private let imageView: UIImageView = {
		
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()

	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .leading
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	private let bottomStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .leading
		view.distribution = .fill
		view.spacing = ViewTraits.margin
		return view
	}()

	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil).multiline()
	}()
	
	/// The message label
	let messageLabel: Label = {
		
		return Label(body: nil).multiline()
	}()
	
	/// setup the views
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		imageContainerView.addSubview(imageView)

		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.addArrangedSubview(messageLabel)
		bottomStackView.addArrangedSubview(UIView())

		stackView.addArrangedSubview(imageContainerView)
		stackView.addArrangedSubview(bottomStackView)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()

		stackView.embed(in: self)
		
		NSLayoutConstraint.activate([

			// Image
			imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor),
			imageView.leadingAnchor.constraint(
				equalTo: imageContainerView.leadingAnchor,
				constant: ViewTraits.margin),
			imageView.trailingAnchor.constraint(
				equalTo: imageContainerView.trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
	}
	
	// MARK: Public Access
	
	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}
	
	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}
	
	/// The onboarding mage
	var image: UIImage? {
		didSet {
			imageView.image = image
		}
	}
}
