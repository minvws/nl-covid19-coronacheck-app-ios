/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingStartView: ScrolledStackWithButtonView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let headerToReadMoreButton: CGFloat = 16
		}
		enum Header {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	private let headerLabel: Label = {
		return Label(body: nil).header().multiline()
	}()
	
	private let readMoreButton: Button = {
		return Button(style: .textLabelBlue)
	}()
	
	override func setupViews() {
		super.setupViews()
		
		stackView.alignment = .leading
		
		readMoreButton.touchUpInside(self, action: #selector(readMore))
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(headerLabel)
		stackView.setCustomSpacing(ViewTraits.Spacing.headerToReadMoreButton, after: headerLabel)
		stackView.addArrangedSubview(readMoreButton)
	}
	
	@objc private func readMore() {
		
		readMoreCommand?()
	}
	
	// MARK: Public Access
	
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(ViewTraits.Header.lineHeight,
															   kerning: ViewTraits.Header.kerning)
		}
	}
	
	var readMoreButtonTitle: String? {
		didSet {
			readMoreButton.title = readMoreButtonTitle
		}
	}
	
	var readMoreCommand: (() -> Void)?
}
