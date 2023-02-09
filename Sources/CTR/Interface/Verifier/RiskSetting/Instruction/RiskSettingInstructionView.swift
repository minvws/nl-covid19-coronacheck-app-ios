/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

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
	
	let scrollView: UIScrollView = {
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
	
	let errorView: ErrorView = {
		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
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

		setupScrollViewConstraints()
		setupFooterButtonViewConstraints()
		setupTitleLabelViewConstraints()
		setupHeaderLabelViewConstraints()
		setupMoreButtonViewConstraints()
		setupRiskSettingControlsViewConstraints()
		setupErrorViewConstraints()
	}
	
	func setupScrollViewConstraints() {
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
		])
	}
	
	func setupFooterButtonViewConstraints() {
		
		NSLayoutConstraint.activate([
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	func setupTitleLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.Margin.top),
			titleLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.edge),
			titleLabel.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.edge),
			titleLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.Margin.edge)
		])
	}
	
	func setupHeaderLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			headerLabel.topAnchor.constraint(
				equalTo: titleLabel.bottomAnchor,
				constant: ViewTraits.Spacing.titleToHeader),
			headerLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.edge),
			headerLabel.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.edge),
			headerLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.Margin.edge)
		])
	}
	
	func setupMoreButtonViewConstraints() {
		
		NSLayoutConstraint.activate([
			moreButton.topAnchor.constraint(
				equalTo: headerLabel.bottomAnchor,
				constant: ViewTraits.Spacing.headerToMoreButton),
			moreButton.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.edge),
			moreButton.trailingAnchor.constraint(
				lessThanOrEqualTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.edge)
		])
	}
	
	func setupRiskSettingControlsViewConstraints() {
		
		NSLayoutConstraint.activate([
			riskSettingControlsView.topAnchor.constraint(
				equalTo: moreButton.bottomAnchor,
				constant: ViewTraits.Spacing.moreButtonToControls),
			riskSettingControlsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			riskSettingControlsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			riskSettingControlsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
		])
	}
	
	func setupErrorViewConstraints() {
		
		NSLayoutConstraint.activate([
			errorView.topAnchor.constraint(
				equalTo: riskSettingControlsView.bottomAnchor,
				constant: ViewTraits.Spacing.controlsToErrorView),
			errorView.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.Margin.edge),
			errorView.trailingAnchor.constraint(
				lessThanOrEqualTo: scrollView.trailingAnchor,
				constant: -ViewTraits.Margin.edge),
			errorView.bottomAnchor.constraint(
				lessThanOrEqualTo: scrollView.bottomAnchor,
				constant: -ViewTraits.Margin.edge)
		])
	}
	
	@objc private func readMore() {
		
		readMoreCommand?()
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning,
				textColor: C.black()!)
		}
	}
	
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(
				ViewTraits.Header.lineHeight,
				kerning: ViewTraits.Header.kerning,
				textColor: C.black()!)
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
			riskSettingControlsView.hasError = hasError
		}
	}
}
