/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class IncompleteDutchVaccinationView: ScrolledStackWithButtonView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
		
		// Margins & padding
		static let verticalPaddingContentToButton: CGFloat = 8
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let secondVaccineTextView: TextView = {
		
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = C.white()
		stackView.distribution = .fill
		footerButtonView.isHidden = true
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		
		// Paragraph A
		stackView.addArrangedSubview(secondVaccineTextView)
		stackView.addArrangedSubview(secondVaccineTextView)
		stackView.setCustomSpacing(ViewTraits.verticalPaddingContentToButton, after: secondVaccineTextView)
	}

	// MARK: Public Access
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}
	
	var secondVaccineText: String? {
		didSet {
			secondVaccineTextView.applyHTML(secondVaccineText)
		}
	}
	
	var linkTouchedHandler: ((URL) -> Void)? {
		didSet {
			[secondVaccineTextView].forEach { textView in
				textView.linkTouchedHandler = { [weak self] url in
					self?.linkTouchedHandler?(url)
				}
			}
		}
	}
}
