/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let top: CGFloat = 24
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let headerToControls: CGFloat = 32
			static let controlsToMoreButton: CGFloat = 24
		}
		enum Height {
			static let separator: CGFloat = 1
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
	
	private let riskControlStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		return stackView
	}()
	
	private let lowRiskControl: RiskSettingControl = {
		return RiskSettingControl()
	}()
	
	private let highRiskControl: RiskSettingControl = {
		return RiskSettingControl()
	}()
	
	private let moreButton: Button = {
		return Button(style: .textLabelBlue)
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		lowRiskControl.onTapCommand = { [weak self] in
			self?.selectRiskCommand?(.low)
			self?.highRiskControl.isSelected = false
		}
		
		highRiskControl.onTapCommand = { [weak self] in
			self?.selectRiskCommand?(.high)
			self?.lowRiskControl.isSelected = false
		}
		
		moreButton.addTarget(self, action: #selector(readMore), for: .touchUpInside)
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(scrollView)
		scrollView.addSubview(headerLabel)
		scrollView.addSubview(riskControlStackView)
		scrollView.addSubview(moreButton)
		
		addSeparator()
		riskControlStackView.addArrangedSubview(lowRiskControl)
		addSeparator()
		riskControlStackView.addArrangedSubview(highRiskControl)
		addSeparator()
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
			scrollView.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			headerLabel.topAnchor.constraint(equalTo: scrollView.topAnchor,
											constant: ViewTraits.Margin.top),
			headerLabel.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											 constant: ViewTraits.Margin.edge),
			headerLabel.rightAnchor.constraint(equalTo: scrollView.rightAnchor,
											  constant: -ViewTraits.Margin.edge),
			headerLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor,
														constant: -2 * ViewTraits.Margin.edge),
			
			riskControlStackView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor,
													  constant: ViewTraits.Spacing.headerToControls),
			riskControlStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
			riskControlStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
			riskControlStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			moreButton.topAnchor.constraint(equalTo: riskControlStackView.bottomAnchor,
											constant: ViewTraits.Spacing.controlsToMoreButton),
			moreButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor,
											 constant: ViewTraits.Margin.edge),
			moreButton.rightAnchor.constraint(lessThanOrEqualTo: scrollView.rightAnchor,
											  constant: -ViewTraits.Margin.edge),
			moreButton.bottomAnchor.constraint(lessThanOrEqualTo: scrollView.bottomAnchor,
											   constant: -ViewTraits.Margin.edge)
		])
	}
	
	private func addSeparator() {
		let separatorView = UIView()
		separatorView.backgroundColor = Theme.colors.grey4
		riskControlStackView.addArrangedSubview(separatorView)

		NSLayoutConstraint.activate([
			separatorView.heightAnchor.constraint(equalToConstant: ViewTraits.Height.separator)
		])
	}
	
	@objc private func readMore() {
		
		readMoreCommand?()
	}
	
	// MARK: Public Access
	
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(ViewTraits.Header.lineHeight,
															   kerning: ViewTraits.Header.kerning,
															   textColor: Theme.colors.dark)
		}
	}
	
	var lowRiskTitle: String? {
		didSet {
			lowRiskControl.title = lowRiskTitle
		}
	}
	
	var lowRiskSubtitle: String? {
		didSet {
			lowRiskControl.subtitle = lowRiskSubtitle
		}
	}
	
	var highRiskTitle: String? {
		didSet {
			highRiskControl.title = highRiskTitle
		}
	}
	
	var highRiskSubtitle: String? {
		didSet {
			highRiskControl.subtitle = highRiskSubtitle
		}
	}
	
	var moreButtonTitle: String? {
		didSet {
			moreButton.title = moreButtonTitle
		}
	}
	
	var riskSetting: RiskSetting? {
		didSet {
			guard let riskSetting = riskSetting else { return }
			lowRiskControl.isSelected = riskSetting.isLow
			highRiskControl.isSelected = riskSetting.isHigh
		}
	}
	
	var selectRiskCommand: ((RiskSetting) -> Void)?
	
	var readMoreCommand: (() -> Void)?
}
