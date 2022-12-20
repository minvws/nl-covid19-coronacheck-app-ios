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

		enum Footer {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let spacing: CGFloat = 24
		}

		enum StackView {
			static let topMargin: CGFloat = 40
			static let bottomMargin: CGFloat = 40
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
		stackView.addArrangedSubview(resetButtonStackView)
		resetButtonStackView.addArrangedSubview(resetButton)
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

		// Title Label
		let label = Label(caption1SemiBold: nil).multiline().header()
		label.attributedText = title.setLineHeight(ViewTraits.ListHeader.lineHeight)
		menuOptionStackView.addArrangedSubview(label)
		menuOptionStackView.setCustomSpacing(ViewTraits.ListHeader.spacing, after: label)

		return menuOptionStackView
	}
	
	var resetButtonTapHandler: (() -> Void)?
}
