/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DCCQRDetailsView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		static let margin: CGFloat = 20.0
		static let spacing: CGFloat = 24
	}
	
	/// The title label
	private let titleLabel: Label = {
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	/// The stack view to add all labels to
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.spacing
		return view
	}()
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(titleLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		stackView.embed(
			in: safeAreaLayoutGuide,
			insets: UIEdgeInsets.all(ViewTraits.margin)
		)
	}
	
	// MARK: Public Access
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
	
	var details: [(field: String, value: String)]? {
		didSet {
			guard let details = details else { return }
			loadDetails(details)
		}
	}
	
	func handleScreenCapture(shouldHide: Bool) {
		stackView.isHidden = shouldHide
	}
}

private extension DCCQRDetailsView {
	
	func loadDetails(_ details: [(field: String, value: String)]) {
		details.forEach { detail in
			
			let labelView = DCCQRLabelView()
			labelView.field = detail.field
			labelView.value = detail.value
			stackView.addArrangedSubview(labelView)
		}
	}
}
