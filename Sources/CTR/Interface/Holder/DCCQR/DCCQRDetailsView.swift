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
		let label = Label(title1: nil, montserrat: true).multiline().header()
		label.textColor = Theme.colors.dark
		return label
	}()
	
	/// The description label
	private let descriptionLabel: Label = {
		let label = Label(subhead: nil).multiline()
		label.textColor = Theme.colors.dark
		return label
	}()
	
	/// The footer date information label
	private let dateInformationLabel: Label = {
		let label = Label(footnote: nil).multiline()
		label.textColor = Theme.colors.dark
		return label
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
	
	/// The description
	var detailsDescription: String? {
		didSet {
			descriptionLabel.text = detailsDescription
		}
	}
	
	/// The dcc details
	var details: [(field: String, value: String)]? {
		didSet {
			guard let details = details else { return }
			loadDetails(details)
		}
	}
	
	/// The footer date information
	var dateInformation: String? {
		didSet {
			dateInformationLabel.text = dateInformation
		}
	}
	
	func handleScreenCapture(shouldHide: Bool) {
		stackView.isHidden = shouldHide
	}
}

private extension DCCQRDetailsView {
	
	func loadDetails(_ details: [(field: String, value: String)]) {
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(descriptionLabel)
		
		details.forEach { detail in
			
			let labelView = DCCQRLabelView()
			labelView.field = detail.field
			labelView.value = detail.value
			stackView.addArrangedSubview(labelView)
		}
		
		stackView.addArrangedSubview(dateInformationLabel)
	}
}
