/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class StoredEventDetailsView: ScrolledStackView {
	
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
	
//	/// The stack view to add all labels to
//	private let stackView: UIStackView = {
//
//		let view = UIStackView()
//		view.translatesAutoresizingMaskIntoConstraints = false
//		view.axis = .vertical
//		view.spacing = 0
//		return view
//	}()

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
		
		stackView.addArrangedSubview(titleLabel)
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
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
			loadDetails(details)
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

private extension StoredEventDetailsView {
	
	func createLabel(for detail: NSAttributedString) -> AccessibleBodyLabelView {
		let view = AccessibleBodyLabelView()
		view.label.attributedText = detail
		return view
	}

	func createLineView() -> UIView {

		let view = UIView()
		view.backgroundColor = C.grey2()
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
	
	/// Hide voice over labels when VoiceControl or SwitchControl are enabled. Setting it to none allows it to scroll for VoiceControl and SwitchControl
	func updateAccessibilityStatus() {
		stackView.subviews.forEach { view in
			guard let label = view as? AccessibleBodyLabelView else { return }
			label.updateAccessibilityStatus()
		}
	}
}

/// Hides VoiceControl labels for Label
private class AccessibleBodyLabelView: BaseView {
	
	let label: Label = {
		let label = Label(body: nil).multiline()
		label.textColor = C.black()
		return label
	}()
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		label.embed(in: self)
		label.setContentHuggingPriority(.required, for: .vertical)
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		updateAccessibilityStatus()
	}
	
	func updateAccessibilityStatus() {
		label.setupForVoiceAndSwitchControlAccessibility()
		
		isAccessibilityElement = !UIAccessibility.isSwitchControlRunning
		accessibilityLabel = UIAccessibility.isVoiceOverRunning ? label.text : nil
	}
}
