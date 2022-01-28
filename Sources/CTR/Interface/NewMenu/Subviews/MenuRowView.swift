/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class MenuRowView: UIControl {
	
	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let margin: CGFloat = 26
		static let iconTitleSpacing: CGFloat = 16
	}
	
	// MARK: - Subviews

	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let titleLabel: Label = {
		let label = Label(bodyBold: nil).multiline()
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()
	
	private let chevronImageView: UIImageView = {
		let imageView = UIImageView(image: I.menuChevron())
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let bottomBorderView: UIView = {
		let view = UIView()
		view.backgroundColor = C.grey5()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	// MARK: - Lifecycle
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func setupViews() {
		backgroundColor = .white
		
		addTarget(self, action: #selector(touchUp), for: .touchUpInside)
	}

	func setupViewHierarchy() {
		
		addSubview(iconImageView)
		addSubview(titleLabel)
		addSubview(chevronImageView)
		addSubview(bottomBorderView)
	}

	func setupViewConstraints() {

		var constraints = [NSLayoutConstraint]()
		constraints += [iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin)]
		
		constraints += [titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: ViewTraits.iconTitleSpacing)]
		constraints += [titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -ViewTraits.margin)]
		constraints += [titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin)]
		constraints += [titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
		
		constraints += [chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin)]
		
		constraints += [bottomBorderView.leadingAnchor.constraint(equalTo: leadingAnchor)]
		constraints += [bottomBorderView.bottomAnchor.constraint(equalTo: bottomAnchor)]
		constraints += [bottomBorderView.trailingAnchor.constraint(equalTo: trailingAnchor)]
		constraints += [bottomBorderView.heightAnchor.constraint(equalToConstant: 1)]
		
		NSLayoutConstraint.activate(constraints)
	}
	
	/// Setup all the accessibility traits
	private func setupAccessibility() {

		isAccessibilityElement = true
	}
	
	// MARK: - Interaction
	
	override var isSelected: Bool {
		didSet { updateDynamicAttributes() }
	}
	override var isHighlighted: Bool {
		didSet { updateDynamicAttributes() }
	}
	
	private func updateDynamicAttributes() {
		
		backgroundColor = isHighlighted || isSelected
			? C.primaryBlue5()
			: .white
	}
	
	// MARK: - Objc Target-Action callbacks:
	
	@objc
	private func touchUp() {
		// imitate UITableViewCell's selected background tap behaviour
		isSelected = true
		
		action?()
		
		UIView.animate(withDuration: 0.75, delay: 0.5) {
			self.isSelected = false
			self.isHighlighted = false
		}
	}
	
	// MARK: - Accessors
	
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
	
	var icon: UIImage? {
		didSet {
			iconImageView.image = icon
		}
	}
	
	var action: (() -> Void)?
	
	var shouldShowBottomBorder: Bool = false {
		didSet {
			bottomBorderView.isHidden = !shouldShowBottomBorder
		}
	}
}
