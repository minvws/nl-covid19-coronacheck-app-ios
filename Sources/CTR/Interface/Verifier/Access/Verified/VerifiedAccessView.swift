/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifiedAccessView: BaseView {
	
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
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
	}
	
	private let imageView: UIImageView = {

		let view = UIImageView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		view.image = I.access()?.withRenderingMode(.alwaysTemplate)
		return view
	}()
	
	private let titleLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.Spacing.imageToLabel
		return view
	}()
	
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
	
	// MARK: - Public Access

	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 alignment: .center,
															 kerning: ViewTraits.Title.kerning)
		}
	}
	
	var verifiedType: VerifiedType? {
		didSet {
			backgroundColor = verifiedType?.backgroundColor
			imageView.tintColor = verifiedType?.tintColor
			titleLabel.textColor = verifiedType?.tintColor
		}
	}
}

extension VerifiedType {
	
	var backgroundColor: UIColor? {
		switch self {
			case .verified(let riskLevel):
				switch riskLevel {
					case .low:
						return C.accessColor()
					case .high:
						return C.primaryColor()
				}
			case .demo:
				return C.grey4()
		}
	}
	
	var tintColor: UIColor? {
		if case .verified(let risk) = self, risk.isHigh {
			return .white
		} else {
			return C.darkColor()
		}
	}
}
