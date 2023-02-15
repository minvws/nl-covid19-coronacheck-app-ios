/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Models
import Resources

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
			stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.Margin.edge),
			stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.Margin.edge),
			stackView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor),
			stackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor),
			
			{
				let constraint = imageView.widthAnchor.constraint(equalToConstant: ViewTraits.Size.imageWidth)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
		
		// For landscape mode
		titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
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
	
	var verifiedAccess: VerifiedAccess? {
		didSet {
			backgroundColor = verifiedAccess?.backgroundColor
			imageView.tintColor = verifiedAccess?.tintColor
			titleLabel.textColor = verifiedAccess?.tintColor
		}
	}
}

extension VerifiedAccess {
	
	var backgroundColor: UIColor? {
		switch self {
			case .verified(let verificationPolicy):
				switch verificationPolicy {
					case .policy3G:
						return C.secondaryGreen()!
					case .policy1G:
						return C.primaryBlue()!
				}
			case .demo:
				return C.grey4()
		}
	}
	
	var tintColor: UIColor? {
		if case .verified(let verificationPolicy) = self, verificationPolicy == .policy1G {
			return C.white()
		} else {
			return C.black()
		}
	}
}
