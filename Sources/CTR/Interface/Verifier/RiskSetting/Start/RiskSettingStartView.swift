/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingStartView: BaseView {
	
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
	
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private let headerLabel: Label = {
		return Label(body: nil).header().multiline()
	}()
	
	private let readMoreButton: Button = {
		return Button(style: .textLabelBlue)
	}()
	
	let footerButtonView: FooterButtonView = {
		let view = FooterButtonView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override func setupViews() {
		super.setupViews()
		
		readMoreButton.touchUpInside(self, action: #selector(readMore))
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(headerLabel)
		scrollView.addSubview(readMoreButton)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leftAnchor.constraint(equalTo: leftAnchor),
			footerButtonView.rightAnchor.constraint(equalTo: rightAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			headerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor,
											 constant: ViewTraits.Margin.top),
			headerLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											  constant: ViewTraits.Margin.edge),
			headerLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
											   constant: -ViewTraits.Margin.edge),
			headerLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
											   constant: -2 * ViewTraits.Margin.edge),
			
			readMoreButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor,
												constant: ViewTraits.Spacing.headerToReadMoreButton),
			readMoreButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
												 constant: ViewTraits.Margin.edge),
			readMoreButton.rightAnchor.constraint(lessThanOrEqualTo: scrollView.rightAnchor,
												  constant: -ViewTraits.Margin.edge),
			
			headerLabel.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
												constant: -ViewTraits.Margin.edge)
		])
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
	
	var hideFooterButtonView: Bool? {
		didSet {
			guard let hideFooterButtonView = hideFooterButtonView else { return }
			footerButtonView.isHidden = hideFooterButtonView
		}
	}
}
