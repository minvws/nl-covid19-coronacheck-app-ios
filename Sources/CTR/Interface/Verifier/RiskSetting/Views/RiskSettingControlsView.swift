/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskSettingControlsView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Height {
			static let separator: CGFloat = 1
		}
	}
	
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .vertical
		return stackView
	}()
	
	let lowRiskControl: RiskSettingControl = {
		return RiskSettingControl()
	}()
	
	let highRiskControl: RiskSettingControl = {
		return RiskSettingControl()
	}()
	
	override func setupViews() {
		super.setupViews()
		
		lowRiskControl.onTapCommand = { [weak self] in
			self?.selectRiskCommand?(.low)
			self?.highRiskControl.isSelected = false
		}
		
		highRiskControl.onTapCommand = { [weak self] in
			self?.selectRiskCommand?(.high)
			self?.lowRiskControl.isSelected = false
		}
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSeparator()
		stackView.addArrangedSubview(lowRiskControl)
		addSeparator()
		stackView.addArrangedSubview(highRiskControl)
		addSeparator()
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		stackView.embed(in: self)
	}
	
	private func addSeparator() {
		let separatorView = UIView()
		separatorView.backgroundColor = Theme.colors.grey4
		stackView.addArrangedSubview(separatorView)

		NSLayoutConstraint.activate([
			separatorView.heightAnchor.constraint(equalToConstant: ViewTraits.Height.separator)
		])
	}
	
	// MARK: Public Access
	
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
	
	var lowRiskAccessibilityLabel: String? {
		didSet {
			lowRiskControl.accessibilityLabel = lowRiskAccessibilityLabel
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
	
	var highRiskAccessibilityLabel: String? {
		didSet {
			highRiskControl.accessibilityLabel = highRiskAccessibilityLabel
		}
	}
	
	var riskLevel: RiskLevel? {
		didSet {
			guard let riskLevel = riskLevel else { return }
			lowRiskControl.isSelected = riskLevel.isLow
			highRiskControl.isSelected = riskLevel.isHigh
		}
	}

	var hasError: Bool = false {
		didSet {
			lowRiskControl.hasError = hasError
			highRiskControl.hasError = hasError
		}
	}
	
	var selectRiskCommand: ((RiskLevel) -> Void)?
}
