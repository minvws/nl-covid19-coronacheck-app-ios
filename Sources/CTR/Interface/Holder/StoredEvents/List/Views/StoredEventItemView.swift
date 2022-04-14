/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class StoredEventItemView: BaseView {
	
	/// The display constants
	private struct ViewTraits {
		enum Title {
			static let topMargin: CGFloat = 24.0
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let leadingMargin: CGFloat = 20.0
		}
		enum Message {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Details {
			static let spacing: CGFloat = 8.0
			static let bottomMargin: CGFloat = 24.0
			static let leadingMargin: CGFloat = 20.0
		}
		enum Disclosure {
			static let height: CGFloat = 12
			static let trailingMargin: CGFloat = 20.0
		}
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(bodyBold: nil).multiline()
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
	
	private let disclosureView: UIImageView = {

		let view = UIImageView(image: I.disclosure())
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// The line above the button
	private let lineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let backgroundButton: UIButton = {
		
		let button = UIButton()
		button.backgroundColor = .clear
		button.translatesAutoresizingMaskIntoConstraints = false
		
		return button
	}()
	
	override func setupViews() {
		
		super.setupViews()
		view?.backgroundColor = C.white()
		lineView.backgroundColor = C.grey4()
		disclosureView.tintColor = C.black()
		backgroundButton.addTarget(
			self,
			action: #selector(backgroundButtonTapped),
			for: .touchUpInside
		)
	}
	
	/// Setup the hierarchy
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		backgroundButton.embed(in: self)
		
		addSubview(titleLabel)
		addSubview(detailsStackView)
		addSubview(disclosureView)
		addSubview(lineView)
		bringSubviewToFront(backgroundButton)
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
				equalTo: leadingAnchor,
				constant: ViewTraits.Title.leadingMargin
			),
			titleLabel.trailingAnchor.constraint(equalTo: disclosureView.leadingAnchor),
			titleLabel.bottomAnchor.constraint(
				equalTo: detailsStackView.topAnchor,
				constant: -ViewTraits.Details.spacing
			),
			
			// Details
			detailsStackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.Details.leadingMargin
			),
			detailsStackView.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			detailsStackView.bottomAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.Details.bottomMargin
			),
			
			disclosureView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.Disclosure.trailingMargin
			),
			disclosureView.heightAnchor.constraint(equalToConstant: ViewTraits.Disclosure.height),
			disclosureView.centerYAnchor.constraint(equalTo: centerYAnchor),
			
			// Line
			lineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			lineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			lineView.bottomAnchor.constraint(equalTo: bottomAnchor),
			lineView.heightAnchor.constraint(equalToConstant: 1)
		])
	}
	
	/// Setup all the accessibility traits
	override func setupAccessibility() {
		
		super.setupAccessibility()
		backgroundButton.isAccessibilityElement = true
		accessibilityElements = [titleLabel, detailsStackView, backgroundButton]
	}
	
	/// User tapped on the primary button
	@objc func backgroundButtonTapped() {
		
		viewTappedCommand?()
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
				let label = Label(body: nil).multiline()
				label.attributedText = .makeFromHtml(
					text: detail,
					style: NSAttributedString.HTMLStyle(
						font: Fonts.body,
						textColor: C.secondaryText()!,
						lineHeight: ViewTraits.Message.lineHeight,
						kern: ViewTraits.Message.kerning
					)
				)
				detailsStackView.addArrangedSubview(label)
			}
		}
	}
	
	/// The user tapped on the disclaimer button
	var viewTappedCommand: (() -> Void)?
}
