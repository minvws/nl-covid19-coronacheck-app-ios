/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews
import Resources

class MessageCardView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum Shadow {
			static let radius: CGFloat = 10
			static let opacity: Float = 0.15
		}
		
		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let closeButtonSize: CGFloat = 16
		
		// Margins
		static let margin: CGFloat = 24
		static let verticalPadding: CGFloat = 8
		static let closeButtonTopMargin: CGFloat = 28
		
		enum Message {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	struct Config {
		
		var title: String
		var accessibilityIdentifier: String?
		var closeButtonCommand: (() -> Void)?
		var ctaButton: ((title: String, command: () -> Void))?
	}
	
	private let config: Config
	private let closeButtonTappedCommand: (() -> Void)?
	private let callToActionButtonTappedCommand: (() -> Void)?
	
	required init(config: Config) {
		self.config = config
		messageLabel.attributedText = config.title.setLineHeight(
			ViewTraits.Message.lineHeight,
			kerning: ViewTraits.Message.kerning
		)
		messageLabel.accessibilityIdentifier = config.accessibilityIdentifier
		
		closeButtonTappedCommand = config.closeButtonCommand
		
		callToActionButton.title = config.ctaButton?.title
		callToActionButtonTappedCommand = config.ctaButton?.command
		
		super.init(frame: .zero)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// A label for accessibility to announce the role of this message card ("Notification")
	private let accessibilityRoleView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.accessibilityLabel = L.holder_dashboard_accessibility_notification()
		view.accessibilityTraits = .staticText
		view.backgroundColor = .clear
		view.isAccessibilityElement = true
		return view
	}()
	
	/// The message label
	private let messageLabel: Label = {
		
		let titleLabel = Label(body: nil).multiline()
		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		return titleLabel
	}()
	
	/// The close button
	private let closeButton: TappableButton = {
		
		let button = TappableButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.bannerCross(), for: .normal)
		button.contentHorizontalAlignment = .center
		button.accessibilityLabel = "\(L.generalClose()) \(L.holder_dashboard_accessibility_notification())"
		button.setupLargeContentViewer(title: L.generalClose())
		return button
	}()
	
	/// The callToAction button (-within `callToActionButtonStackView`)
	private let callToActionButton: Button = {
		
		let button = Button(title: "CTA", style: Button.ButtonType.textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	/// Setup all the views
	override func setupViews() {
		
		super.setupViews()
		view?.backgroundColor = shouldUseDarkMode ? C.grey5() : C.white()
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()
		
		closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		callToActionButton.addTarget(self, action: #selector(callToActionButtonTapped), for: .touchUpInside)
	}
	
	/// Create the shadow around the view
	func createShadow() {
		guard !ProcessInfo.processInfo.isUnitTesting else { return } // for better snapshot reliability
		// Shadow
		layer.shadowColor = C.shadow()?.cgColor
		layer.shadowOpacity = ViewTraits.Shadow.opacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.Shadow.radius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		accessibilityRoleView.embed(in: self)
		addSubview(messageLabel)
		
		if nil != config.closeButtonCommand {
			addSubview(closeButton)
		}
		if nil != config.ctaButton {
			addSubview(callToActionButton)
		}
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin)]
		constraints += [messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin)]
		
		if nil != config.closeButtonCommand {
			constraints += [closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.closeButtonTopMargin)]
			constraints += [closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin)]
			constraints += [closeButton.heightAnchor.constraint(equalToConstant: ViewTraits.closeButtonSize)]
			constraints += [closeButton.widthAnchor.constraint(equalToConstant: ViewTraits.closeButtonSize)]
			
			constraints += [messageLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -ViewTraits.verticalPadding)]
		} else {
			constraints += [messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin)]
		}
		
		if nil != config.ctaButton {
			constraints += [callToActionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin)]
			constraints += [callToActionButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -ViewTraits.margin)]
			constraints += [callToActionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: ViewTraits.verticalPadding)]
			constraints += [callToActionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
			
		} else {
			constraints += [messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
		}
		
		NSLayoutConstraint.activate(constraints)
	}
	
	// MARK: - Objc Target-Action callbacks:
	
	/// User tapped on the close button
	@objc func closeButtonTapped() {
		
		closeButtonTappedCommand?()
	}
	
	/// User tapped on the callToAction button
	@objc func callToActionButtonTapped() {
		
		callToActionButtonTappedCommand?()
	}
}
