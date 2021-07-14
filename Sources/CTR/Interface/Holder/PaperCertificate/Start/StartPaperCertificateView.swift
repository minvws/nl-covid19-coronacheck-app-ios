/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class StartPaperCertificateView: ScrolledStackWithButtonView {
	
	/// The display constants
	private enum ViewTraits {
		
		static let titleLineHeight: CGFloat = 26
		static let titleKerning: CGFloat = -0.26
	}
	
	/// The title label
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The message label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		setupPrimaryButton()
	}
	
	// MARK: Public Access

	/// The  title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}
	
	/// The message
	var message: String? {
		didSet {
			messageLabel.attributedText = .makeFromHtml(text: message,
														font: Theme.fonts.body,
														textColor: Theme.colors.dark)
		}
	}
}
