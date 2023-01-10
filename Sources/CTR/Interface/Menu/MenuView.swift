/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MenuView: ScrolledStackView {

	private let navigationBackgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = C.white()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	private let topBorderView: UIView = {
		let view = UIView()
		view.backgroundColor = C.grey5()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	// MARK: - Lifecycle
	
	override func setupViews() {

		super.setupViews()
		backgroundColor = C.primaryBlue5()
		
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
}
