/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

class IncompleteDutchCertificateView: ScrolledStackWithButtonView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
	}
	
	/// The title label
	private let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	let contentTextViewA: TextView = {
		
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let contentTextViewB: TextView = {
		
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let contentTextViewC: TextView = {
		
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let secondaryButtonA: Button = {
		
		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	let secondaryButtonB: Button = {
		
		let button = Button(title: "", style: .textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.isHidden = true
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
		secondaryButtonA.touchUpInside(self, action: #selector(secondaryButtonTappedA))
		secondaryButtonB.touchUpInside(self, action: #selector(secondaryButtonTappedB))
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextViewA)
		stackView.addArrangedSubview(secondaryButtonA)
		stackView.addArrangedSubview(contentTextViewB)
		stackView.addArrangedSubview(secondaryButtonB)
		stackView.addArrangedSubview(contentTextViewC)
	}
	
	@objc func secondaryButtonTappedA() {
		
		secondaryButtonATappedCommand?()
	}
	
	@objc func secondaryButtonTappedB() {
		
		secondaryButtonBTappedCommand?()
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
	
	var messageA: String? {
		didSet {
			contentTextViewA.html(messageA)
		}
	}
	
	var messageB: String? {
		didSet {
			contentTextViewA.html(messageB)
		}
	}
	
	var messageC: String? {
		didSet {
			contentTextViewA.html(messageC)
		}
	}
	
	var secondaryButtonATappedCommand: (() -> Void)?
	
	var secondaryButtonBTappedCommand: (() -> Void)?
	
	/// The title for the secondary white/blue button
	var secondaryButtonATitle: String? {
		didSet {
			secondaryButtonA.setTitle(secondaryButtonATitle, for: .normal)
			secondaryButtonA.isHidden = secondaryButtonATitle?.isEmpty ?? true
		}
	}
	
	/// The title for the secondary white/blue button
	var secondaryButtonBTitle: String? {
		didSet {
			secondaryButtonB.setTitle(secondaryButtonBTitle, for: .normal)
			secondaryButtonB.isHidden = secondaryButtonBTitle?.isEmpty ?? true
		}
	}
}
