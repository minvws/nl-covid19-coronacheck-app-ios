/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class RemoteEventItemView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		enum Link {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let bottomMargin: CGFloat = 24.0
		}
		enum Title {
			static let topMargin: CGFloat = 24.0
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Message {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let paragraphSpacing: CGFloat = 6
		}
		
		enum Details {
			static let spacing: CGFloat = 8.0
		}
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(bodyBold: nil).multiline().header()
	}()
	
	/// The stack view for the details
	private let detailsStackView: UIStackView = {
		
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.Details.spacing
		return view
	}()
	
	/// The link label
	private let linkLabel: Label = {
		
		return Label(bodyMedium: nil).multiline()
	}()
	
	private let backgroundButton: UIButton = {
		
		let button = UIButton()
		button.backgroundColor = .clear
		button.translatesAutoresizingMaskIntoConstraints = false
		
		return button
	}()
	
	override func setupViews() {
		
		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		linkLabel.textColor = Theme.colors.primary
		backgroundButton.addTarget(
			self,
			action: #selector(disclaimerButtonTapped),
			for: .touchUpInside
		)
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		backgroundButton.embed(in: self)
		
		addSubview(titleLabel)
		addSubview(detailsStackView)
		addSubview(linkLabel)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.Title.topMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: detailsStackView.topAnchor,
				constant: -ViewTraits.Details.spacing
			),
			
			// Details
			detailsStackView.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			detailsStackView.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			detailsStackView.bottomAnchor.constraint(
				equalTo: linkLabel.topAnchor,
				constant: -ViewTraits.Details.spacing
			),
			
			// Link
			linkLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			linkLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			linkLabel.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.Link.bottomMargin
			)
		])
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {
		
		super.setupAccessibility()
		
		backgroundButton.isAccessibilityElement = true
		linkLabel.isAccessibilityElement = false
		
		accessibilityElements = [titleLabel, detailsStackView, backgroundButton]
	}
	
	/// User tapped on the primary button
	@objc func disclaimerButtonTapped() {
		
		disclaimerButtonTappedCommand?()
	}
	
	// MARK: Public Access
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	/// The message
	var details: [String] = [] {
		didSet {
			detailsStackView.removeArrangedSubviews()
			details.forEach { detail in
				let label = Label(subhead: nil).multiline()
				label.attributedText = .makeFromHtml(
					text: detail,
					style: NSAttributedString.HTMLStyle(
						font: Theme.fonts.subhead,
						textColor: Theme.colors.secondaryText,
						lineHeight: ViewTraits.Message.lineHeight,
						kern: ViewTraits.Message.kerning
					)
				)
				detailsStackView.addArrangedSubview(label)
			}
		}
	}
	
	var link: String? {
		didSet {
			linkLabel.attributedText = link?.setLineHeight(
				ViewTraits.Link.lineHeight,
				kerning: ViewTraits.Link.kerning,
				textColor: Theme.colors.primary
			)
			backgroundButton.accessibilityLabel = link
		}
	}
	
	/// The user tapped on the disclaimer button
	var disclaimerButtonTappedCommand: (() -> Void)?
}
