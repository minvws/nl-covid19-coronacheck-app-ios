/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQROverlayView: BaseView {

	private var overlay: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.white()!.withAlphaComponent(0.8)
		return view
	}()

	private var innerView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.white()
		return view
	}()

	private let iconView: UIImageView = {
		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let titleLabel: UILabel = {
		
		return Label(bodyBold: nil).header().multiline()
	}()

	let revealButton: Button = {

		let button = Button(title: "", style: .roundedBlackBorder)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .center
		return button
	}()
	
	let infoButton: Button = {

		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .center
		return button
	}()

	/// The display constants
	private struct ViewTraits {
		
		enum Icon {
			static let size: CGFloat = 28.0
			static let topMargin: CGFloat = 48.0
		}
		enum Title {
			static let topMargin: CGFloat = 13.0
			static let lineHeight: CGFloat = 28.0
			static let kerning: CGFloat = -0.41
		}
		enum InnerView {
			static let margin: CGFloat = 22.0
		}
		enum InfoButton {
			static let topMargin: CGFloat = 8.0
			static let bottomMargin: CGFloat = 10.0
		}
		enum RevealButton {
			static let bottomMargin: CGFloat = 58.0
		}
	}

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		revealButton.addTarget(self, action: #selector(revealButtonTapped), for: .touchUpInside)
		infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		overlay.embed(in: self)
		addSubview(innerView)
		addSubview(iconView)
		addSubview(titleLabel)
		addSubview(infoButton)
		addSubview(revealButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()
		
		setupInnerViewConstraints()
		setupIconViewConstraints()
		setupTitleLabelConstraints()
		setupButtonConstraints()
	}
	
	private func setupInnerViewConstraints() {
		
		NSLayoutConstraint.activate([
			innerView.topAnchor.constraint(
				equalTo: overlay.topAnchor,
				constant: ViewTraits.InnerView.margin
			),
			innerView.leadingAnchor.constraint(
				equalTo: overlay.leadingAnchor,
				constant: ViewTraits.InnerView.margin
			),
			innerView.trailingAnchor.constraint(
				equalTo: overlay.trailingAnchor,
				constant: -ViewTraits.InnerView.margin
			),
			innerView.bottomAnchor.constraint(
				equalTo: overlay.bottomAnchor,
				constant: -ViewTraits.InnerView.margin
			)
		])
	}
	
	func setupIconViewConstraints() {
		
		NSLayoutConstraint.activate([
			iconView.widthAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			iconView.heightAnchor.constraint(equalToConstant: ViewTraits.Icon.size),
			iconView.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
			iconView.topAnchor.constraint(
				lessThanOrEqualTo: innerView.topAnchor,
				constant: ViewTraits.Icon.topMargin
			),
			iconView.topAnchor.constraint(greaterThanOrEqualTo: innerView.topAnchor)
		])
	}
	
	func setupTitleLabelConstraints() {
		
		NSLayoutConstraint.activate([
			titleLabel.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
			titleLabel.topAnchor.constraint(
				lessThanOrEqualTo: iconView.bottomAnchor,
				constant: ViewTraits.Title.topMargin
			),
			titleLabel.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
		])
	}
	
	func setupButtonConstraints() {
		
		NSLayoutConstraint.activate([
			
			infoButton.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.InfoButton.topMargin
			),
			infoButton.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
			infoButton.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),
			
			revealButton.bottomAnchor.constraint(
				greaterThanOrEqualTo: innerView.bottomAnchor,
				constant: -ViewTraits.RevealButton.bottomMargin
			),
			revealButton.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
			revealButton.topAnchor.constraint(
				greaterThanOrEqualTo: infoButton.bottomAnchor,
				constant: ViewTraits.InfoButton.bottomMargin
			)
		])
	}

	/// Setup all the accessibility traits
	override func setupAccessibility() {
		super.setupAccessibility()

		accessibilityElements = [titleLabel, infoButton, revealButton]
	}

	// MARK: - Callbacks

	@objc func revealButtonTapped() {

		revealButtonCommand?()
	}
	
	@objc func infoButtonTapped() {

		infoButtonCommand?()
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Title.kerning
			)
			setupAccessibility()
		}
	}

	/// The  title
	var action: String? {
		didSet {
			revealButton.title = action
			setupAccessibility()
		}
	}
	
	var info: String? {
		didSet {
			infoButton.title = info
			setupAccessibility()
		}
	}
	
	var icon: UIImage? {
		didSet {
			iconView.image = icon
		}
	}

	var revealButtonCommand: (() -> Void)?
	
	var infoButtonCommand: (() -> Void)?
}
