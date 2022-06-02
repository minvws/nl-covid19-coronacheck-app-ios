/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class RiskIndicatorIconView: BaseView {
	
	private let imageView = UIImageView(image: I.scanner.riskEllipse())
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.tintColor = C.white()
	}
	
	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		addSubview(imageView)
	}
	
	/// Setup all the constraints
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			imageView.heightAnchor.constraint(equalToConstant: 16),
			imageView.widthAnchor.constraint(equalToConstant: 16),
			imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			imageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 1)
		])
	}
	
	override var tintColor: UIColor! {
		didSet {
			imageView.tintColor = tintColor
		}
	}
}
