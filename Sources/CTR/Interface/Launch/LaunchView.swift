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
			static let size: CGFloat = 64
			static let margin: CGFloat = 32
		}
		enum Ribbon {
			static let height: CGFloat = 101
			static let width: CGFloat = 153
			static let heightOffset: CGFloat = 10.0
			static let centerOffset: CGFloat = 53.0
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Message {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let spinnerMargin: CGFloat = 5
		}
		enum Version {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let bottomMargin: CGFloat = 32
			static let margin: CGFloat = 20.0
		}
	}

	/// The government ribbon
	private let ribbonVWSView: UIImageView = {

		let view = UIImageView(image: I.ribbonvws())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()

	/// The app icon
	private let appIconView: UIImageView = {

		let view = UIImageView(image: I.ribbonvws())
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
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
		backgroundColor = C.white()
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

			appIconView.widthAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			appIconView.heightAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			appIconView.centerXAnchor.constraint(equalTo: centerXAnchor),
			appIconView.bottomAnchor.constraint(
				equalTo: titleLabel.topAnchor,
				constant: -ViewTraits.Icon.margin
			),

			// Title
			titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
			titleLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
			
			// Version
			versionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
			versionLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor),
			versionLabel.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.Version.bottomMargin
			),
			versionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Version.margin)
		])
		
		setupRibbonViewContraints()
		setupStackViewViewConstraints()
	}
	
	private func setupRibbonViewContraints() {
		
		NSLayoutConstraint.activate([
			
			ribbonVWSView.topAnchor.constraint(
				equalTo: topAnchor,
				constant: -ViewTraits.Ribbon.heightOffset
			),
			ribbonVWSView.centerXAnchor.constraint(
				equalTo: centerXAnchor,
				constant: ViewTraits.Ribbon.centerOffset
			),
			ribbonVWSView.widthAnchor.constraint(equalToConstant: ViewTraits.Ribbon.width),
			ribbonVWSView.heightAnchor.constraint(equalToConstant: ViewTraits.Ribbon.height)
		])
	}
	
	private func setupStackViewViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			// stackView
			stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			stackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
			stackView.bottomAnchor.constraint(equalTo: versionLabel.topAnchor),
			
			// Spinner
			spinner.leadingAnchor.constraint(equalTo: messageContainer.leadingAnchor),
			spinner.trailingAnchor.constraint(
				equalTo: messageLabel.leadingAnchor,
				constant: -ViewTraits.Message.spinnerMargin
			),
			spinner.centerYAnchor.constraint(equalTo: messageContainer.centerYAnchor),
			
			// Message
			messageLabel.centerYAnchor.constraint(equalTo: messageContainer.centerYAnchor),
			messageLabel.trailingAnchor.constraint(equalTo: messageContainer.trailingAnchor),
			messageLabel.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor)
		])
	}

	// MARK: Public Access
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Title.kerning)
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(
				ViewTraits.Message.lineHeight,
				kerning: ViewTraits.Message.kerning,
				textColor: C.grey1()!)
		}
	}
	
	/// The version
	var version: String? {
		didSet {
			versionLabel.attributedText = version?.setLineHeight(
				ViewTraits.Version.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Version.kerning,
				textColor: C.grey1()!)
		}
	}
	
	var appIcon: UIImage? {
		didSet {
			appIconView.image = appIcon
		}
	}

	/// Hide the header image
	func hideImage() {

		appIconView.isHidden = true

	}

	/// Show the header image
	func showImage() {

		appIconView.isHidden = false
	}
}
