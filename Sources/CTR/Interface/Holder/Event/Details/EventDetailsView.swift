/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class EventDetailsView: BaseView {
	
	private enum ViewTraits {
		
		// Margins
		static let margin: CGFloat = 20.0
		static let spacing: CGFloat = 24
	}
	
	private let titleLabel: Label = {
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = 0
		return view
	}()
	
	override func setupViews() {
		super.setupViews()
		
		addSubview(stackView)
		stackView.addArrangedSubview(titleLabel)
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
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
	
	var details: [(detail: String, hasExtraLineBreak: Bool)]? {
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
	
	func loadDetails(_ details: [(detail: String, hasExtraLineBreak: Bool)]) {
		details.forEach {
			let label = Label(body: nil)
			label.attributedText = .makeFromHtml(text: $0.detail,
												 font: Theme.fonts.body,
												 textColor: Theme.colors.dark)
			label.numberOfLines = 0
			stackView.addArrangedSubview(label)
			
			if $0.hasExtraLineBreak {
				stackView.setCustomSpacing(ViewTraits.spacing, after: label)
			}
		}
	}
}
