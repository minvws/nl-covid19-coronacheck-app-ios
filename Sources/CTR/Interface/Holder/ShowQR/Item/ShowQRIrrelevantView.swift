/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import UIKit

class ShowQRIrrelevantView: BaseView {

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
		view.image = I.eye()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

        return Label(title3: nil, montserrat: true).multiline().header()
	}()

	/// The action label
	private let actionLabel: Label = {

		return Label(bodySemiBold: nil)
	}()

	let actionButton: UIButton = {

		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// The display constants
	private struct ViewTraits {

		// Dimension
		static let iconSize: CGFloat = 28.0
		static let actionLineHeight: CGFloat = 22
		static let titleLineHeight: CGFloat = 28

		// Margins
		static let margin: CGFloat = 20.0
		static let actionTitleMargin: CGFloat = 24.0
		
	}

	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()

		addSubview(overlay)
		addSubview(innerView)
		addSubview(iconView)
		addSubview(titleLabel)
		addSubview(actionLabel)
		addSubview(actionButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// QR View
			overlay.topAnchor.constraint(equalTo: topAnchor),
			overlay.bottomAnchor.constraint(equalTo: bottomAnchor),
			overlay.leadingAnchor.constraint(equalTo: leadingAnchor),
			overlay.trailingAnchor.constraint(equalTo: trailingAnchor),

			innerView.topAnchor.constraint(
				equalTo: overlay.topAnchor,
				constant: ViewTraits.margin
			),
			innerView.leadingAnchor.constraint(
				equalTo: overlay.leadingAnchor,
				constant: ViewTraits.margin
			),
			innerView.trailingAnchor.constraint(
				equalTo: overlay.trailingAnchor,
				constant: -ViewTraits.margin
			),
			innerView.bottomAnchor.constraint(
				equalTo: overlay.bottomAnchor,
				constant: -ViewTraits.margin
			),

			iconView.widthAnchor.constraint(equalToConstant: ViewTraits.iconSize),
			iconView.heightAnchor.constraint(equalToConstant: ViewTraits.iconSize),
			iconView.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
			iconView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor),

			titleLabel.centerYAnchor.constraint(equalTo: innerView.centerYAnchor),
			titleLabel.centerXAnchor.constraint(equalTo: innerView.centerXAnchor),
			titleLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),

			actionLabel.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
			actionLabel.trailingAnchor.constraint(equalTo: innerView.trailingAnchor),
			actionLabel.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.actionTitleMargin
			),

			actionButton.topAnchor.constraint(equalTo: innerView.topAnchor),
			actionButton.bottomAnchor.constraint(equalTo: innerView.bottomAnchor),
			actionButton.leadingAnchor.constraint(equalTo: innerView.leadingAnchor),
			actionButton.trailingAnchor.constraint(equalTo: innerView.trailingAnchor)
		])
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {
		super.setupAccessibility()
		
		accessibilityElements = [actionButton]
		
		guard let title = title, let action = action else { return }
		actionButton.accessibilityLabel = title + action
	}

	// MARK: - Callbacks

	@objc func actionButtonTapped() {

		actionButtonCommand?()
	}

	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight,
															 alignment: .center)
			setupAccessibility()
		}
	}

	/// The  title
	var action: String? {
		didSet {
			actionLabel.attributedText = action?.setLineHeight(
				ViewTraits.actionLineHeight,
				alignment: .center,
				textColor: C.primaryBlue()!
			)
			setupAccessibility()
		}
	}

	var actionButtonCommand: (() -> Void)?
}
