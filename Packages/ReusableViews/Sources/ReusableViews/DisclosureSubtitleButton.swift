/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import Resources

/*
 A grey full width button with a title, sub title and a disclosure icon
 */
open class DisclosureSubtitleButton: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		
		enum View {
			static let cornerRadius: CGFloat = 9
			static let leadingMargin: CGFloat = 16.0
		}
		enum Disclosure {
			static let height: CGFloat = 12
			static let width: CGFloat = 12
			static let margin: CGFloat = 18.0
			static let trailingMargin: CGFloat = 8.0
		}
		
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let topMargin: CGFloat = 13.0
			static let bottomMargin: CGFloat = 4.0
		}
		enum Message {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let bottomMargin: CGFloat = 16.0
		}
	}
	
	/// The title label
	let titleLabel: Label = {
		
		return Label(calloutSemiBold: nil).multiline()
	}()
	
	/// The sub title label
	let subtitleLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()
	
	/// The disclosure image
	let disclosureView: UIImageView = {
		
		let view = UIImageView(image: I.disclosure())
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let button: UIButton = {
		
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	override open func setupViews() {
		
		super.setupViews()
		backgroundColor = C.primaryBlue5()
		layer.cornerRadius = ViewTraits.View.cornerRadius
		button.addTarget(self, action: #selector(primaryButtonTapped), for: .touchUpInside)
		titleLabel.isSelectable = false
		subtitleLabel.isSelectable = false
	}
	
	/// Setup the hierarchy
	override open func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		addSubview(disclosureView)
		addSubview(titleLabel)
		addSubview(subtitleLabel)
		button.embed(in: self)
		bringSubviewToFront(button)
	}
	
	/// Setup the constraints
	override open func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.Title.topMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.View.leadingMargin
			),
			titleLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: disclosureView.leadingAnchor,
				constant: -ViewTraits.Disclosure.trailingMargin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: subtitleLabel.topAnchor,
				constant: -ViewTraits.Title.bottomMargin
			),
			
			// Message
			subtitleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.View.leadingMargin
			),
			subtitleLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.Message.bottomMargin
			),
			subtitleLabel.trailingAnchor.constraint(
				lessThanOrEqualTo: disclosureView.leadingAnchor,
				constant: -ViewTraits.Disclosure.trailingMargin
			)
		])
		
		setupDisclosureViewConstraints()
	}
	
	func setupDisclosureViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			disclosureView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.Disclosure.margin
			),
			disclosureView.heightAnchor.constraint(equalToConstant: ViewTraits.Disclosure.height),
			disclosureView.widthAnchor.constraint(equalToConstant: ViewTraits.Disclosure.width),
			disclosureView.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	/// Setup all the accessibility traits
	override open func setupAccessibility() {
		
		super.setupAccessibility()
		
		accessibilityElements = [button]
	}
	
	func setAccessibilityLabel() {
		
		button.accessibilityLabel = "\(title ?? ""). \(subtitle ?? "")"
	}
	
	/// User tapped on the primary button
	@objc public func primaryButtonTapped() {
		
		primaryButtonTappedCommand?()
	}
	
	// MARK: Public Access
	
	/// The user tapped on the primary button
	open var primaryButtonTappedCommand: (() -> Void)?
	
	/// The  title
	open var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
			setAccessibilityLabel()
		}
	}
	
	/// The sub title
	open var subtitle: String? {
		didSet {
			subtitleLabel.attributedText = subtitle?.setLineHeight(
				ViewTraits.Message.lineHeight,
				kerning: ViewTraits.Message.kerning
			)
			setAccessibilityLabel()
		}
	}
}
