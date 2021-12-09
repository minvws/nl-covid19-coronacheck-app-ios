/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingUnselectedView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let headerToControls: CGFloat = 32
			static let controlsToErrorView: CGFloat = 16
		}
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
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
	
	let riskSettingControlsView: RiskSettingControlsView = {
		let view = RiskSettingControlsView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
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
			
			riskSettingControlsView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor,
														 constant: ViewTraits.Spacing.headerToControls),
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
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning,
															 textColor: Theme.colors.dark)
		}
	}
	
	var errorMessage: String? {
		didSet {
			errorView.error = errorMessage
		}
	}
	
	var hasErrorState: Bool? {
		didSet {
			guard let hasError = hasErrorState else { return }
			errorView.isHidden = !hasError
			riskSettingControlsView.hasError = hasError
		}
	}
}
