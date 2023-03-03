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

final class MenuSectionBreakView: BaseView {
	
	override func setupViews() {
		super.setupViews()
	
		setColorsForCurrentTraitCollection()
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		var constraints = [NSLayoutConstraint]()
		constraints += [heightAnchor.constraint(equalToConstant: 24)]
		NSLayoutConstraint.activate(constraints)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setColorsForCurrentTraitCollection()
	}
	
	private func setColorsForCurrentTraitCollection() {
		backgroundColor = shouldUseDarkMode ? C.white() : C.primaryBlue5()
	}
}
