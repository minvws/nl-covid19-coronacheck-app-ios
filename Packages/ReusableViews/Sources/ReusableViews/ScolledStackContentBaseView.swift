/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

open class ScolledStackContentBaseView: ScrolledStackWithButtonView {
	
	/// The title label
	public let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	public let contentTextView: TextView = {
		
		let view = TextView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	override open func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentTextView)
	}
}
