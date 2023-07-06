/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

final class MenuRowView: UIControl {
	
	/// The display constants
	private struct ViewTraits {

		enum Icon {
			static let margin: CGFloat = 20
			static let spacing: CGFloat = 16
		}
		enum Chevron {
			static let margin: CGFloat = 22
		}
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let margin: CGFloat = 25
		}
		enum SubTitle {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let margin: CGFloat = 16
			static let spacing: CGFloat = 4
		}
		enum Animation {
			static let duration: CGFloat = 0.2
		}
	}
	
	var titleLabelTopConstraint: NSLayoutConstraint?
	
	var titleLabelBottomConstraint: NSLayoutConstraint?
	
	// MARK: - Subviews

	private let iconImageView: UIImageView = {
		let imageView = UIImageView()
		imageView.tintColor = C.black()
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.isAccessibilityElement = false
		imageView.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
		return imageView
	}()
	
	private let titleLabel: Label = {
		let label = Label(bodyBold: nil).multiline()
		label.textColor = C.black()
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
		label.isSelectable = false
		return label
	}()
	
	private let subTitleLabel: Label = {
		let label = Label(subhead: nil).multiline()
		label.textColor = C.black()
		label.adjustsFontForContentSizeCategory = true
		label.translatesAutoresizingMaskIntoConstraints = false
		label.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
		label.isSelectable = false
		return label
	}()
	
	private let chevronImageView: UIImageView = {
		let imageView = UIImageView(image: I.menuChevron())
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.isAccessibilityElement = false
		return imageView
	}()
	
	private let bottomBorderView: UIView = {
		let view = UIView()
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
		setColorsForCurrentTraitCollection()
		
		addTarget(self, action: #selector(touchUp), for: .touchUpInside)
		addTarget(self, action: #selector(self.touchUpAnimation), for: [.touchDragExit, .touchCancel, .touchUpInside])
		addTarget(self, action: #selector(self.touchDownAnimation), for: .touchDown)
	}

	func setupViewHierarchy() {
		
		addSubview(iconImageView)
		addSubview(titleLabel)
		addSubview(subTitleLabel)
		addSubview(chevronImageView)
		addSubview(bottomBorderView)
	}

	func setupViewConstraints() {

		var constraints = [NSLayoutConstraint]()
		
		constraints += [{
			let constraint = titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Title.margin)
			titleLabelTopConstraint = constraint
			return constraint
		}()]
		constraints += [{
			let constraint = titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.Title.margin)
			titleLabelBottomConstraint = constraint
			return constraint
		}()]
		
		constraints += [iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.Icon.margin)]
		
		constraints += [titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: ViewTraits.Icon.spacing)]
		constraints += [titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -ViewTraits.Title.margin)]
		
		constraints += [chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor)]
		constraints += [chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.Chevron.margin)]
		
		constraints += [bottomBorderView.leadingAnchor.constraint(equalTo: leadingAnchor)]
		constraints += [bottomBorderView.bottomAnchor.constraint(equalTo: bottomAnchor)]
		constraints += [bottomBorderView.trailingAnchor.constraint(equalTo: trailingAnchor)]
		constraints += [bottomBorderView.heightAnchor.constraint(equalToConstant: 1)]
		
		NSLayoutConstraint.activate(constraints)
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		setColorsForCurrentTraitCollection()
	}
	
	/// Setup all the accessibility traits
	private func setupAccessibility() {

		isAccessibilityElement = true
		accessibilityTraits = .button
	}
	
	private func setColorsForCurrentTraitCollection() {
 
		backgroundColor = {
			if shouldUseDarkMode {
				return isHighlighted || isSelected
					? C.white()
					: C.grey5()
			} else {
				return isHighlighted || isSelected
					? C.primaryBlue5()
					: C.white()
			}
		}()
		
		bottomBorderView.backgroundColor = shouldUseDarkMode ? C.grey4() : C.grey5()
	}
	
	// MARK: - Interaction
	
	override var isSelected: Bool {
		didSet { setColorsForCurrentTraitCollection() }
	}
	override var isHighlighted: Bool {
		didSet { setColorsForCurrentTraitCollection() }
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
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning
			)
		}
	}
	
	var subTitle: String? {
		didSet {
			subTitleLabel.attributedText = subTitle?.setLineHeight(
				ViewTraits.SubTitle.lineHeight,
				kerning: ViewTraits.SubTitle.kerning
			)
		}
	}
	
	var icon: UIImage? {
		didSet {
			iconImageView.image = icon
		}
	}
	
	var overrideColor: UIColor? {
		didSet {
			guard let overrideColor else { return }
			iconImageView.image = iconImageView.image?.withRenderingMode(.alwaysTemplate)
			iconImageView.tintColor = overrideColor
			titleLabel.textColor = overrideColor
		}
	}
	
	var action: (() -> Void)?
	
	var shouldShowBottomBorder: Bool = false {
		didSet {
			bottomBorderView.isHidden = !shouldShowBottomBorder
		}
	}
	
	func showSubTitle(_ subTitle: String) {
		
		self.subTitle = subTitle
		
		titleLabelTopConstraint?.constant = ViewTraits.SubTitle.margin
		titleLabelBottomConstraint?.isActive = false
		
		var constraints = [NSLayoutConstraint]()
		constraints += [subTitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor)]
		constraints += [subTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -ViewTraits.Title.margin)]
		constraints += [subTitleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.SubTitle.margin)]
		constraints += [subTitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ViewTraits.SubTitle.spacing)]
		NSLayoutConstraint.activate(constraints)
	}
}
