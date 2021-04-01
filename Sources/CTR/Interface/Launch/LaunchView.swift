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

		// Dimensions
		static let ribbonHeight: CGFloat = 101
		static let ribbonWidth: CGFloat = 153
		static let iconSize: CGFloat = 64

		// Margins
		static let titleMargin: CGFloat = 32
		static let spinnerMargin: CGFloat = 5
		static let margin: CGFloat = 20.0
		static let ribbonHeightOffset: CGFloat = 10.0
		static let ribbonCenterOffset: CGFloat = 53.0
	}

	/// The government ribbon
	private let ribbonVWSView: UIImageView = {

		let view = UIImageView(image: .ribbonVWS)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()

	/// The app icon
	private let appIconView: UIImageView = {

		let view = UIImageView(image: .ribbonVWS)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
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

	/// The spinner
	let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// A containter for the spinner and message label
	let messageContainer: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// A stackview to center the message label between the title and the version
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .center
		view.distribution = .fill
		return view
	}()

	/// The version label
	let versionLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		titleLabel.textAlignment = .center
		messageLabel.textColor = Theme.colors.grey1
		versionLabel.textColor = Theme.colors.grey1
		backgroundColor = Theme.colors.viewControllerBackground
		versionLabel.textAlignment = .center
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(ribbonVWSView)
		addSubview(appIconView)
		addSubview(titleLabel)

		messageContainer.addSubview(spinner)
		messageContainer.addSubview(messageLabel)
		stackView.addArrangedSubview(messageContainer)

		addSubview(stackView)
		addSubview(versionLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			ribbonVWSView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: -ViewTraits.ribbonHeightOffset
			),
			ribbonVWSView.centerXAnchor.constraint(
				equalTo: centerXAnchor,
				constant: ViewTraits.ribbonCenterOffset
			),
			ribbonVWSView.widthAnchor.constraint(equalToConstant: ViewTraits.ribbonWidth),
			ribbonVWSView.heightAnchor.constraint(equalToConstant: ViewTraits.ribbonHeight),

			appIconView.widthAnchor.constraint(equalToConstant: ViewTraits.iconSize),
			appIconView.heightAnchor.constraint(equalToConstant: ViewTraits.iconSize),
			appIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
			appIconView.bottomAnchor.constraint(
				equalTo: titleLabel.topAnchor,
				constant: -ViewTraits.titleMargin
			),

			// Title
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.heightAnchor.constraint(equalToConstant: ViewTraits.titleMargin),

			// stackView
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
			stackView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor),

			// Spinner
			spinner.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor),
			spinner.trailingAnchor.constraint(
				equalTo: messageLabel.leadingAnchor,
				constant: -ViewTraits.spinnerMargin
			),
			spinner.centerYAnchor.constraint(equalTo: messageContainer.centerYAnchor),

			// Message
			messageLabel.centerYAnchor.constraint(equalTo: messageContainer.centerYAnchor),
			messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor),
			messageLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),

			// Version
			versionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			versionLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
			versionLabel.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.titleMargin
			),
			versionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.margin)
		])
	}

	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The message
	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}

	/// The version
	var version: String? {
		didSet {
			versionLabel.text = version
		}
	}

	var appIcon: UIImage? {
		didSet {
			appIconView.image = appIcon
		}
	}
}
