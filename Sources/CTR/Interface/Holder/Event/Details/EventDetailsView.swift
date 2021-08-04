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
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
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
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.margin
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
			titleLabel.text = title
			stackView.setCustomSpacing(ViewTraits.spacing, after: titleLabel)
		}
	}
	
	/// Tuple with attributed string detail value and if extra linebreak is needed
	var details: [(detail: NSAttributedString, hasExtraLineBreak: Bool)]? {
		didSet {
			guard let details = details else { return }
			loadDetails(details)
		}
	}
	
	func handleScreenCapture(shouldHide: Bool) {
		stackView.isHidden = shouldHide
	}
}

private extension EventDetailsView {
	
	func loadDetails(_ details: [(detail: NSAttributedString, hasExtraLineBreak: Bool)]) {
		details.forEach {
			let label = Label(body: nil)
			label.attributedText = $0.detail
			label.textColor = Theme.colors.dark
			label.numberOfLines = 0
			stackView.addArrangedSubview(label)
			
			if $0.hasExtraLineBreak {
				stackView.setCustomSpacing(ViewTraits.spacing, after: label)
			}
		}
	}
}
