/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class AboutThisAppView: ScrolledStackView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		enum ListHeader {
			static let lineHeight: CGFloat = 16
			static let spacing: CGFloat = 8
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
		return Button(title: "App resetten..", style: .roundedRedBorder)
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
		
		resetButton.addTarget(self, action: #selector(didTapReset), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(messageTextView)
		stackView.setCustomSpacing(ViewTraits.StackView.topMargin, after: messageTextView)
		stackView.addArrangedSubview(menuStackView)
		stackView.setCustomSpacing(ViewTraits.StackView.bottomMargin, after: menuStackView)
		
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
		
		let pinUpwardsToScrollViewContents = resetButtonStackView.topAnchor.constraint(greaterThanOrEqualTo: menuStackView.bottomAnchor, constant: ViewTraits.ResetButton.verticalMargin)
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

	func createMenuStackView(title: String) -> UIStackView {

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

		return menuOptionStackView
	}
	
	var resetButtonTapHandler: (() -> Void)?
}
