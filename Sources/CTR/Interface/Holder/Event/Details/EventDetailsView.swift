/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class EventDetailsView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		static let margin: CGFloat = 20.0
		static let spacing: CGFloat = 24
		static let titleLineHeight: CGFloat = 32
		static let titleKerning: CGFloat = -0.26
	}
	
	/// The title label
	private let titleLabel: Label = {
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The stack view to add all labels to
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = 0
		return view
	}()

	/// The footer text
	private let footerTextView: TextView = {

		return TextView()
	}()
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(titleLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([

			stackView.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor
			),
			stackView.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			),
			stackView.leadingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
	}
	
	// MARK: Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight,
															 kerning: ViewTraits.titleKerning)
			stackView.setCustomSpacing(ViewTraits.spacing, after: titleLabel)
		}
	}
	
	/// Tuple with attributed string detail value and if extra linebreak is needed
	var details: [(detail: NSAttributedString, hasExtraLineBreak: Bool, isSeparator: Bool)]? {
		didSet {
			guard let details = details else { return }
			loadDetails(details)
			stackView.addArrangedSubview(footerTextView)
		}
	}
	
	func handleScreenCapture(shouldHide: Bool) {
		stackView.isHidden = shouldHide
	}

	/// The message
	var footer: String? {
		didSet {
			footerTextView.attributedText = .makeFromHtml(text: footer, style: .bodyDark)
		}
	}
}

private extension EventDetailsView {
	
	func createLabel(for detail: NSAttributedString) -> Label {
		let label = Label(body: nil)
		label.attributedText = detail
		label.textColor = Theme.colors.dark
		label.numberOfLines = 0
		return label
	}

	func createLineView() -> UIView {

		let view = UIView()
		view.backgroundColor = Theme.colors.line
		return view
	}
	
	func loadDetails(_ details: [(detail: NSAttributedString, hasExtraLineBreak: Bool, isSeparator: Bool)]) {
		details.forEach {
			if $0.isSeparator {
				let spaceView = UIView()
				let lineView = createLineView()
				stackView.addArrangedSubview(spaceView)
				stackView.setCustomSpacing(ViewTraits.spacing, after: spaceView)
				stackView.addArrangedSubview(lineView)
				NSLayoutConstraint.activate([
					// Set height to 1, else it will default to 0.
					lineView.heightAnchor.constraint(equalToConstant: 1.0)
				])
				stackView.setCustomSpacing(ViewTraits.spacing, after: lineView)
			} else {
				let label = createLabel(for: $0.detail)
				stackView.addArrangedSubview(label)

				if $0.hasExtraLineBreak {
					stackView.setCustomSpacing(ViewTraits.spacing, after: label)
				}
			}
		}
	}
}
