/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Resources

final class RiskSettingStartView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let headerToReadMoreButton: CGFloat = 16
			static let readMoreButtonToChangeRiskView: CGFloat = 40
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
		let button = Button(style: .textLabelBlue)
		button.contentHorizontalAlignment = .leading
		return button
	}()
	
	let footerButtonView: FooterButtonView = {
		let view = FooterButtonView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let changeRiskSettingView: ChangeRiskSettingView = {
		let view = ChangeRiskSettingView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	/// Scroll view bottom constraint
	var bottomScrollViewConstraint: NSLayoutConstraint?
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		readMoreButton.touchUpInside(self, action: #selector(readMore))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(headerLabel)
		scrollView.addSubview(readMoreButton)
		scrollView.addSubview(changeRiskSettingView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			{
				let constraint = scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
				bottomScrollViewConstraint = constraint
				return constraint
			}(),
			
			{
				let constraint = footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor)
				constraint.priority = .defaultLow
				return constraint
			}(),
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			headerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor,
											 constant: ViewTraits.Margin.top),
			headerLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
											  constant: ViewTraits.Margin.edge),
			headerLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
											   constant: -ViewTraits.Margin.edge),
			headerLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
											   constant: -2 * ViewTraits.Margin.edge),
			
			readMoreButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor,
												constant: ViewTraits.Spacing.headerToReadMoreButton),
			readMoreButton.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
												 constant: ViewTraits.Margin.edge),
			readMoreButton.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
												  constant: -ViewTraits.Margin.edge),
			
			changeRiskSettingView.topAnchor.constraint(equalTo: readMoreButton.bottomAnchor,
													   constant: ViewTraits.Spacing.readMoreButtonToChangeRiskView),
			changeRiskSettingView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			changeRiskSettingView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			changeRiskSettingView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
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
	
	var hasUnselectedRiskState: Bool? {
		didSet {
			guard let hasUnselectedRiskState = hasUnselectedRiskState else { return }
			footerButtonView.isHidden = !hasUnselectedRiskState
			changeRiskSettingView.isHidden = hasUnselectedRiskState
			bottomScrollViewConstraint?.isActive = !hasUnselectedRiskState
		}
	}
}
