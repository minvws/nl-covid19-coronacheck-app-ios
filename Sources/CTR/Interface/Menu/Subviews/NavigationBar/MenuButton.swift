/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class MenuButton: UIControl {
	
	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let margin: CGFloat = 4
		static let iconTitleSpacing: CGFloat = 8
		
		enum Animation {
			static let duration: CGFloat = 0.2
		}
	}
	
	enum IconPosition {
		case left, right
	}
	
	// MARK: - Subviews

	private let iconImageView: UIImageView = {
		let imageView = UIImageView(image: I.icon_menu_hamburger())
		imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		imageView.setContentHuggingPriority(.required, for: .horizontal)
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()
	
	private let titleLabel: Label = {
		let label = Label(bodyBold: L.general_menu()).multiline()
		label.textColor = C.black()
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		label.setContentCompressionResistancePriority(.required, for: .vertical)
		label.isSelectable = false
		
		if #available(iOS 15.0, *) {
			label.maximumContentSizeCategory = .accessibilityMedium
		}
		return label
	}()
	
	private lazy var leftIconPositionConstraints: [NSLayoutConstraint] = {
		var constraints = [NSLayoutConstraint]()
		constraints += [iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor)]
		constraints += [iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)]

		constraints += [titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: ViewTraits.iconTitleSpacing)]
		constraints += [titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin)]
		constraints += [titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
		constraints += [titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)]
		
		return constraints
	}()
	
	private lazy var rightIconPositionConstraints: [NSLayoutConstraint] = {
		var constraints = [NSLayoutConstraint]()
		constraints += [titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor)]
		constraints += [titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin)]
		constraints += [titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
		
		constraints += [iconImageView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: ViewTraits.iconTitleSpacing)]
		constraints += [iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [iconImageView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)]
		return constraints
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
		backgroundColor = C.white()
		
		addTarget(self, action: #selector(touchUp), for: .touchUpInside)
		addTarget(self, action: #selector(touchUpAnimation), for: [.touchDragExit, .touchCancel, .touchUpInside])
		addTarget(self, action: #selector(touchDownAnimation), for: .touchDown)
	}

	func setupViewHierarchy() {
		
		addSubview(iconImageView)
		addSubview(titleLabel)
	}

	func setupViewConstraints() {

		switch iconPosition {
			case .left:
				NSLayoutConstraint.deactivate(rightIconPositionConstraints)
				NSLayoutConstraint.activate(leftIconPositionConstraints)
			case .right:
				NSLayoutConstraint.deactivate(leftIconPositionConstraints)
				NSLayoutConstraint.activate(rightIconPositionConstraints)
		}
		
	}
	
	/// Setup all the accessibility traits
	private func setupAccessibility() {
		
		isAccessibilityElement = true
		
		accessibilityIdentifier = "MenuButton"
		accessibilityLabel = L.generalMenuOpen()
		
		setupLargeContentViewer(title: L.general_menu())
	}
	
	// MARK: - Objc Target-Action callbacks:
	
	@objc
	private func touchUp() {
		action?()
	}

	@objc private func touchDownAnimation() {
		Haptic.light()

		UIButton.animate(withDuration: ViewTraits.Animation.duration, animations: {
			self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
		})
	}

	@objc private func touchUpAnimation() {
		UIButton.animate(withDuration: ViewTraits.Animation.duration, animations: {
			self.transform = CGAffineTransform.identity
		})
	}
	
	// MARK: - Accessors

	var action: (() -> Void)?
	
	var iconPosition: IconPosition = .right {
		didSet {
			setupViewConstraints()
		}
	}
}
