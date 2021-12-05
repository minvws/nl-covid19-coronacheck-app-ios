/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingInstructionView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let titleToHeader: CGFloat = 24
			static let headerToMoreButton: CGFloat = 16
			static let moreButtonToControls: CGFloat = 32
			static let controlsToErrorView: CGFloat = 16
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
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
	
	private let titleLabel: Label = {
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let headerLabel: Label = {
		return Label(body: nil).header().multiline()
	}()
	
	let riskSettingControlsView: RiskSettingControlsView = {
		let view = RiskSettingControlsView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let moreButton: Button = {
		return Button(style: .textLabelBlue)
	}()
	
	let footerButtonView: FooterButtonView = {
		let view = FooterButtonView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let errorView: ErrorView = {
		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		moreButton.touchUpInside(self, action: #selector(readMore))
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(titleLabel)
		scrollView.addSubview(headerLabel)
		scrollView.addSubview(moreButton)
		scrollView.addSubview(riskSettingControlsView)
		scrollView.addSubview(errorView)
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
			
			titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor,
											constant: ViewTraits.Margin.top),
			titleLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											 constant: ViewTraits.Margin.edge),
			titleLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
											  constant: -ViewTraits.Margin.edge),
			titleLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
														constant: -2 * ViewTraits.Margin.edge),
			
			headerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
											 constant: ViewTraits.Spacing.titleToHeader),
			headerLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											 constant: ViewTraits.Margin.edge),
			headerLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
											  constant: -ViewTraits.Margin.edge),
			headerLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
														constant: -2 * ViewTraits.Margin.edge),
			
			moreButton.topAnchor.constraint(equalTo: headerLabel.bottomAnchor,
											constant: ViewTraits.Spacing.headerToMoreButton),
			moreButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											 constant: ViewTraits.Margin.edge),
			moreButton.rightAnchor.constraint(lessThanOrEqualTo: scrollView.rightAnchor,
											  constant: -ViewTraits.Margin.edge),
			
			riskSettingControlsView.topAnchor.constraint(equalTo: moreButton.bottomAnchor,
													  constant: ViewTraits.Spacing.moreButtonToControls),
			riskSettingControlsView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			riskSettingControlsView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			riskSettingControlsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			errorView.topAnchor.constraint(equalTo: riskSettingControlsView.bottomAnchor,
											constant: ViewTraits.Spacing.controlsToErrorView),
			errorView.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											 constant: ViewTraits.Margin.edge),
			errorView.rightAnchor.constraint(lessThanOrEqualTo: scrollView.rightAnchor,
											  constant: -ViewTraits.Margin.edge),
			errorView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
											   constant: -ViewTraits.Margin.edge)
		])
	}
	
	@objc private func readMore() {
		
		readMoreCommand?()
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning,
															 textColor: Theme.colors.dark)
		}
	}
	
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(ViewTraits.Header.lineHeight,
															   kerning: ViewTraits.Header.kerning,
															   textColor: Theme.colors.dark)
		}
	}
	
	var errorMessage: String? {
		didSet {
			errorView.error = errorMessage
		}
	}
	
	var moreButtonTitle: String? {
		didSet {
			moreButton.title = moreButtonTitle
		}
	}
	
	var readMoreCommand: (() -> Void)?
	
	var hasErrorState: Bool? {
		didSet {
			guard let hasError = hasErrorState else { return }
			errorView.isHidden = !hasError
		}
	}
}
