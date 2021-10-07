/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifiedView: BaseView, AccessViewable {
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let edge: CGFloat = 20
		}
		enum Spacing {
			static let imageToLabel: CGFloat = 32
		}
		enum Size {
			static let imageWidth: CGFloat = 200
		}
		enum Position {
			static let contentMultiplier: CGFloat = 0.75
		}
	}
	
	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		view.image = I.access()
		return view
	}()
	
	private let titleLabel: Label = {

		let label = Label(title1: nil, montserrat: true).multiline().header()
		label.textAlignment = .center
		label.textColor = Theme.colors.dark
		return label
	}()
	
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.Spacing.imageToLabel
		return view
	}()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.access
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
		stackView.addArrangedSubview(imageView)
		stackView.addArrangedSubview(titleLabel)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			NSLayoutConstraint(item: stackView,
							   attribute: .centerY,
							   relatedBy: .equal,
							   toItem: self,
							   attribute: .centerY,
							   multiplier: ViewTraits.Position.contentMultiplier,
							   constant: 0),
			stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: ViewTraits.Margin.edge),
			stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -ViewTraits.Margin.edge),
			stackView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
			
			{
				let constraint = imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.imageWidth)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
	}
	
	// MARK: - AccessViewable

	/// The title
	func title(_ title: String?) {
		titleLabel.text = title
	}
}
