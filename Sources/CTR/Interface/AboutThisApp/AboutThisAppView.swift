/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

final class AboutThisAppView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		enum ListHeader {
			static let lineHeight: CGFloat = 16
			static let spacing: CGFloat = 8
		}

		enum Footer {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let spacing: CGFloat = 24
		}

		enum StackView {
			static let topMargin: CGFloat = 40
			static let bottomMargin: CGFloat = 40
		}
		
		enum ResetButton {
			static let heightOfButton: CGFloat = 50
			static let verticalMargin: CGFloat = 48
		}
	}

	private let messageTextView: TextView = {

		return TextView()
	}()

	/// The stack view for the menu items
	let menuStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
	}()

	private let resetButton: Button = {
		return Button(title: L.holder_menu_resetApp(), style: .roundedRedBorder)
	}()

	private let appVersionLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	private let configVersionLabel: Label = {

		return Label(subhead: nil).multiline()
	}()

	private let resetButtonStackView: UIStackView = {
		let testStackView = UIStackView()
		testStackView.alignment = .center
		testStackView.axis = .vertical
		return testStackView
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.white()
		stackView.distribution = .fill
		appVersionLabel.textColor = C.grey1()
		configVersionLabel.textColor = C.grey1()
		
		resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(messageTextView)
		stackView.setCustomSpacing(ViewTraits.StackView.topMargin, after: messageTextView)
		stackView.addArrangedSubview(menuStackView)
		stackView.setCustomSpacing(ViewTraits.StackView.bottomMargin, after: menuStackView)
		stackView.addArrangedSubview(appVersionLabel)
		stackView.setCustomSpacing(ViewTraits.Footer.spacing, after: appVersionLabel)
		stackView.addArrangedSubview(configVersionLabel)
		
		resetButtonStackView.addArrangedSubview(resetButton)
		addSubview(resetButtonStackView)
	}

	override func setupViewConstraints() {
		
		super.setupViewConstraints()

		/// Setup resetButtonStackView:
		resetButtonStackView.translatesAutoresizingMaskIntoConstraints = false
		resetButtonStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10).isActive = true
		resetButtonStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10).isActive = true
		resetButtonStackView.heightAnchor.constraint(equalToConstant: ViewTraits.ResetButton.heightOfButton).isActive = true
		
		// Pin to the bottom of the screen, unless scrollview goes off bottom of screen, in which case pin
		//  to the bottom of the scrollview contents (with a nice rubber-band effect)
		
		let pinUpwardsToScrollViewContents = resetButtonStackView.topAnchor.constraint(greaterThanOrEqualTo: configVersionLabel.bottomAnchor, constant: ViewTraits.ResetButton.verticalMargin)
		pinUpwardsToScrollViewContents.priority = .defaultLow
		pinUpwardsToScrollViewContents.isActive = true
		
		let pinDownwardsToScreenBottom = resetButtonStackView.topAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: -(ViewTraits.ResetButton.verticalMargin + ViewTraits.ResetButton.heightOfButton))
		pinDownwardsToScreenBottom.priority = .required
		pinDownwardsToScreenBottom.isActive = true
		
		scrollView.contentInset = .bottom(ViewTraits.ResetButton.verticalMargin + ViewTraits.ResetButton.heightOfButton)
	}
	
	@objc private func didTapReset() {
		resetButtonTapHandler?()
	}
	
	// MARK: Public Access

	/// The message
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(text: message, style: .bodyDark) {
				self.messageTextView.attributedText = $0
			}
		}
	}

	/// The app version
	var appVersion: String? {
		didSet {
			appVersionLabel.attributedText = appVersion?.setLineHeight(
				ViewTraits.Footer.lineHeight,
				kerning: ViewTraits.Footer.kerning,
				textColor: C.grey1()!
			)
		}
	}

	/// The config version
	var configVersion: String? {
		didSet {
			configVersionLabel.attributedText = configVersion?.setLineHeight(
				ViewTraits.Footer.lineHeight,
				kerning: ViewTraits.Footer.kerning,
				textColor: C.grey1()!
			)
		}
	}

	func createMenuStackView(title: String?) -> UIStackView {

		// The stack view for the menu items
		let menuOptionStackView: UIStackView = {

			let view = UIStackView()
			view.translatesAutoresizingMaskIntoConstraints = false
			view.axis = .vertical
			view.alignment = .fill
			view.distribution = .fill
			view.spacing = 0
			return view
		}()
		
		if let title {
			let label = Label(caption1SemiBold: nil).multiline().header()
			label.attributedText = title.setLineHeight(ViewTraits.ListHeader.lineHeight)
			menuOptionStackView.addArrangedSubview(label)
			menuOptionStackView.setCustomSpacing(ViewTraits.ListHeader.spacing, after: label)
		}
		
		return menuOptionStackView
	}

	var resetButtonTapHandler: (() -> Void)?
}
