/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

final class VerifiedInfoView: BaseView {
	
	/// The display constants
	private struct ViewTraits {

		enum Margin {
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let title: CGFloat = 24
			static let button: CGFloat = 48
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}
	
	private let scrollView: ScrolledContentHeightView = {
		
		let scrollView = ScrolledContentHeightView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.showsHorizontalScrollIndicator = false
		return scrollView
	}()
	
	/// The stackview
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		return view
	}()
	
	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The message text
	private let messageTextView: TextView = {

		return TextView()
	}()
	
	/// The primary button
	let primaryButton: Button = {

		return Button(title: "Button", style: .roundedBlueImage)
	}()
	
	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
	}

	/// Setup the view hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.setCustomSpacing(ViewTraits.Spacing.title, after: titleLabel)
		stackView.addArrangedSubview(messageTextView)

		addSubview(scrollView)
		scrollView.contentView.addSubview(stackView)
		scrollView.contentView.addSubview(primaryButton)
	}
	
	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			stackView.topAnchor.constraint(
				equalTo: scrollView.contentView.topAnchor,
				constant: ViewTraits.Margin.edge
			),
			stackView.leadingAnchor.constraint(
				equalTo: scrollView.contentView.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			stackView.trailingAnchor.constraint(
				equalTo: scrollView.contentView.trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			
			primaryButton.centerXAnchor.constraint(
				equalTo: centerXAnchor
			),
			primaryButton.topAnchor.constraint(
				greaterThanOrEqualTo: stackView.bottomAnchor,
				constant: ViewTraits.Spacing.button
			),
			primaryButton.leadingAnchor.constraint(
				greaterThanOrEqualTo: scrollView.contentView.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			primaryButton.trailingAnchor.constraint(
				lessThanOrEqualTo: scrollView.contentView.trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: scrollView.contentView.bottomAnchor,
				constant: -ViewTraits.Margin.edge
			)
		])
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
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(text: message, style: .bodyDark) {
				self.messageTextView.attributedText = $0
			}
		}
	}
	
	/// The button title
	var primaryTitle: String? {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}
	
	/// The primary button icon
	var primaryButtonIcon: UIImage? {
		didSet {
			primaryButton.setImage(primaryButtonIcon, for: .normal)
		}
	}
}
