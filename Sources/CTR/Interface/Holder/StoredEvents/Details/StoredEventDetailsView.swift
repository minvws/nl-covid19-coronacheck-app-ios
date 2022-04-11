/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class StoredEventDetailsView: ScrolledStackView, EventDetailsViewable {
	
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
	
	override func setupViews() {
		
		super.setupViews()
		stackView.distribution = .fill
		stackView.spacing = 0
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
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
			stackView.setCustomSpacing(ViewTraits.spacing, after: titleLabel)
		}
	}
	
	/// Tuple with attributed string detail value and if extra linebreak is needed
	var details: [(detail: NSAttributedString, hasExtraLineBreak: Bool, isSeparator: Bool)]? {
		didSet {
			guard let details = details else { return }
			loadDetails(details, spacing: ViewTraits.spacing)
			updateAccessibilityStatus()
		}
	}
	
	func handleScreenCapture(shouldHide: Bool) {
		stackView.isHidden = shouldHide
	}
}
