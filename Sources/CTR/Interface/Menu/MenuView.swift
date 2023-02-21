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

class MenuView: ScrolledStackView {

	private let navigationBackgroundView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let topBorderView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	// MARK: - Lifecycle
	
	override func setupViews() {

		super.setupViews()
		setColorsForCurrentTraitCollection()
		
		stackViewInset = .zero
		stackView.spacing = 0
		stackView.shouldGroupAccessibilityChildren = true
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(navigationBackgroundView)
		addSubview(topBorderView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		var constraints = [NSLayoutConstraint]()
		
		constraints += [navigationBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor)]
		constraints += [navigationBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)]
		constraints += [navigationBackgroundView.topAnchor.constraint(equalTo: topAnchor)]
		constraints += [navigationBackgroundView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)]
		
		constraints += [topBorderView.leadingAnchor.constraint(equalTo: leadingAnchor)]
		constraints += [topBorderView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor)]
		constraints += [topBorderView.trailingAnchor.constraint(equalTo: trailingAnchor)]
		constraints += [topBorderView.heightAnchor.constraint(equalToConstant: 1)]
		
		NSLayoutConstraint.activate(constraints)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setColorsForCurrentTraitCollection()
	}
	
	private func setColorsForCurrentTraitCollection() {
		navigationBackgroundView.backgroundColor = shouldUseDarkMode ? C.grey5() : C.white()
		topBorderView.backgroundColor = shouldUseDarkMode ? C.grey4() : C.grey5()
		backgroundColor = shouldUseDarkMode ? C.white() : C.primaryBlue5()
	}
}
