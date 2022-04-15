/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RemoteEventDetailsView: BaseView, EventDetailsViewable {
	
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
	private(set) var stackView: UIStackView = {

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
	
	override func setupViews() {
		super.setupViews()
		view?.backgroundColor = C.white()
	}
	
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
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		accessibilityLabel = String(describing: RemoteEventDetailsView.self)
		
		NotificationCenter.default.addObserver(forName: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
			self?.updateAccessibilityStatus()
		}
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
			loadDetails(details, spacing: ViewTraits.spacing)
			stackView.addArrangedSubview(footerTextView)
			updateAccessibilityStatus()
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
