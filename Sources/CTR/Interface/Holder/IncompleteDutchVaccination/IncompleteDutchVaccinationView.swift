/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
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
		static let verticalPaddingButtonToNextParagaph: CGFloat = 34
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
	
	private let learnMoreTextView: TextView = {
		
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let addVaccinesButton: Button = {
		
		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		stackView.distribution = .fill
		footerButtonView.isHidden = true
		
		// Add touch actions:
		addVaccinesButton.touchUpInside(self, action: #selector(addVaccinesButtonTapped))
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		
		// Paragraph A
		stackView.addArrangedSubview(secondVaccineTextView)
		stackView.addArrangedSubview(secondVaccineTextView)
		stackView.setCustomSpacing(ViewTraits.verticalPaddingContentToButton, after: secondVaccineTextView)
		stackView.addArrangedSubview(addVaccinesButton)
		stackView.setCustomSpacing(ViewTraits.verticalPaddingButtonToNextParagaph, after: addVaccinesButton)
		
		// Paragraph B
		stackView.addArrangedSubview(learnMoreTextView)
	}
	
	@objc func addVaccinesButtonTapped() {
		
		addVaccinesButtonTapCommand?()
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
			secondVaccineTextView.html(secondVaccineText)
		}
	}
	
	var learnMoreText: String? {
		didSet {
			learnMoreTextView.html(learnMoreText)
		}
	}
	
	var addVaccinesButtonTapCommand: (() -> Void)?
	
	var addTestResultsButtonTapCommand: (() -> Void)?
	
	var linkTouchedHandler: ((URL) -> Void)? {
		didSet {
			[learnMoreTextView, secondVaccineTextView].forEach { textView in
				textView.linkTouched { [weak self] url in
					self?.linkTouchedHandler?(url)
				}
			}
		}
	}
	
	/// The title for the secondary white/blue button
	var addVaccinesButtonTitle: String? {
		didSet {
			addVaccinesButton.setTitle(addVaccinesButtonTitle, for: .normal)
			addVaccinesButton.isHidden = addVaccinesButtonTitle?.isEmpty ?? true
		}
	}
}
