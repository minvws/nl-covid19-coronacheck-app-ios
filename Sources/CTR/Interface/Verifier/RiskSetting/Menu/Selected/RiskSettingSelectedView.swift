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

final class RiskSettingSelectedView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let stackViewToControls: CGFloat = 32
			static let titleToHeader: CGFloat = 24
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
	
	private let headerLabel: TextView = {
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let labelStackView: UIStackView = {
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		return view
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
	
	private var scrollViewContentOffsetObserver: NSKeyValueObservation?
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		
		scrollViewContentOffsetObserver = scrollView.observe(\.contentOffset) { [weak self] scrollView, _ in
			let translatedOffset = scrollView.translatedBottomScrollOffset
			self?.footerButtonView.updateFadeAnimation(from: translatedOffset)
		}
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		addSubview(footerButtonView)
		scrollView.addSubview(labelStackView)
		scrollView.addSubview(riskSettingControlsView)
		labelStackView.addArrangedSubview(titleLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			
			footerButtonView.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
			footerButtonView.leadingAnchor.constraint(equalTo: leadingAnchor),
			footerButtonView.trailingAnchor.constraint(equalTo: trailingAnchor),
			footerButtonView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			labelStackView.topAnchor.constraint(equalTo: scrollView.topAnchor,
											constant: ViewTraits.Margin.top),
			labelStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor,
											 constant: ViewTraits.Margin.edge),
			labelStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor,
											  constant: -ViewTraits.Margin.edge),
			labelStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
											  constant: -2 * ViewTraits.Margin.edge),
			
			riskSettingControlsView.topAnchor.constraint(equalTo: labelStackView.bottomAnchor,
														 constant: ViewTraits.Spacing.stackViewToControls),
			riskSettingControlsView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			riskSettingControlsView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			riskSettingControlsView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			riskSettingControlsView.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
															constant: -ViewTraits.Margin.edge)
		])
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning,
															 textColor: C.black()!)
		}
	}
	
	var header: String? {
		didSet {
			if headerLabel.attributedText == nil, header != nil {
				labelStackView.addArrangedSubview(headerLabel)
				labelStackView.setCustomSpacing(ViewTraits.Spacing.titleToHeader, after: titleLabel)
			}
			
			NSAttributedString.makeFromHtml(text: header, style: .bodyDark) {
				self.headerLabel.attributedText = $0
			}
		}
	}
}
