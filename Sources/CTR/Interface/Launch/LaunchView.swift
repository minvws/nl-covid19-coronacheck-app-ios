/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class LaunchView: BaseView {

	/// The display constants
	private struct ViewTraits {

		enum Icon {
			static let size: CGFloat = 80
		}
		enum Message {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let spinnerMargin: CGFloat = 5
			static let messageToIconSpacingMultiplier: CGFloat = 1.2
			static let margin: CGFloat = 32
		}
	}

	/// The app icon
	private let appIconView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()

	/// The message label
	let messageLabel: Label = {

		let label = Label(body: nil).multiline()
		if #available(iOS 15.0, *) {
			label.maximumContentSizeCategory = .accessibilityMedium
		}
		return label
	}()

	/// The spinner
	let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// A stackview to center the message label between the title and the version
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .horizontal
		view.alignment = .center
		view.distribution = .fill
		view.spacing = ViewTraits.Message.spinnerMargin
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

		addSubview(appIconView)
		addSubview(stackView)

		stackView.addArrangedSubview(spinner)
		stackView.addArrangedSubview(messageLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			appIconView.widthAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			appIconView.heightAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			appIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
			appIconView.centerYAnchor.constraint(equalTo: centerYAnchor),
			
			// Spacing is dynamic and based on screen size
			NSLayoutConstraint(
				item: stackView,
				attribute: .top,
				relatedBy: .equal,
				toItem: appIconView,
				attribute: .bottom,
				multiplier: ViewTraits.Message.messageToIconSpacingMultiplier,
				constant: 0
			),
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: ViewTraits.Message.margin),
			stackView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -ViewTraits.Message.margin)
		])

		messageLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
		spinner.setContentHuggingPriority(.required, for: .horizontal)
	}

	// MARK: Public Access
	
	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(
				ViewTraits.Message.lineHeight,
				kerning: ViewTraits.Message.kerning,
				textColor: C.grey1()!)
		}
	}
	
	var appIcon: UIImage? {
		didSet {
			appIconView.image = appIcon
		}
	}
}
