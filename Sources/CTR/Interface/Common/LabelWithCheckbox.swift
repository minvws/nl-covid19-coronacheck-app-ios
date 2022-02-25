/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class LabelWithCheckbox: UIControl {

	private enum Images {
		enum Icon {
			
			static var normal: UIImage? = I.toggle.normal()
			static var highlighted: UIImage? = I.toggle.selected()
			static var error: UIImage? = I.toggle.error()
		}
	}
	
	/// The display constants
	private enum ViewTraits {
		
		enum Margin {
			static let vertical: CGFloat = 14
			static let horizontal: CGFloat = 16
		}
		enum Animation {
			static let duration: CGFloat = 0.2
		}
		enum Spacing {
			static let iconToLabel: CGFloat = 16
		}
		enum Dimension {
			static let icon: CGFloat = 24
			static let cornerRadius: CGFloat = 8
			static let lineHeight: CGFloat = 20
		}
	}

	override var isSelected: Bool {
		didSet { applyState() }
	}
	
	var hasError: Bool = false {
		didSet { applyState() }
	}

    override var accessibilityTraits: UIAccessibilityTraits {
        get { return UISwitch().accessibilityTraits }
        set { super.accessibilityTraits = newValue }
    }

    override var accessibilityValue: String? {
        get { return isSelected ? "1" : "0" }
        set { super.accessibilityValue = newValue }
    }
	
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

	// MARK: - Private
	
	/// When button height is made smaller, title label will be scrollable
	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private let titleLabel: Label = {
		let label = Label(subhead: nil).multiline()
		label.adjustsFontForContentSizeCategory = true
		if #available(iOS 15.0, *) {
			label.maximumContentSizeCategory = .accessibilityLarge
		}
		return label
	}()
	
	private let iconImageView: UIImageView = {
		let view = UIImageView(image: Images.Icon.normal, highlightedImage: Images.Icon.highlighted)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		return view
	}()
	
	/// Setup all the views
	private func setupViews() {
		
		clipsToBounds = true
		layer.cornerRadius = ViewTraits.Dimension.cornerRadius
		tintColor = Theme.colors.viewControllerBackground

		applyState()

		addTarget(self, action: #selector(touchUpAnimation), for: [.touchDragExit, .touchCancel, .touchUpInside])
		addTarget(self, action: #selector(toggle), for: .touchUpInside)
		addTarget(self, action: #selector(touchDownAnimation), for: .touchDown)
		
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapScrollView))
		scrollView.addGestureRecognizer(tapGesture)
	}

	/// Setup the view hierarchy
	private func setupViewHierarchy() {

		addSubview(iconImageView)
		addSubview(scrollView)
		scrollView.addSubview(titleLabel)
	}

	/// Setup all the constraints
	private func setupViewConstraints() {

		iconImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
		titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
		
		NSLayoutConstraint.activate([
			
			iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.Margin.horizontal),
			iconImageView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: ViewTraits.Margin.vertical),
			iconImageView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -ViewTraits.Margin.vertical),
			iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
			iconImageView.widthAnchor.constraint(equalToConstant: ViewTraits.Dimension.icon),
			iconImageView.heightAnchor.constraint(equalToConstant: ViewTraits.Dimension.icon),
			
			scrollView.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: ViewTraits.Spacing.iconToLabel),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.Margin.horizontal),
			scrollView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Margin.vertical),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.Margin.vertical),
			
			titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
			titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
			titleLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
			
			{
				let constraint = scrollView.heightAnchor.constraint(equalTo: titleLabel.heightAnchor)
				constraint.priority = .defaultLow
				return constraint
			}()
		])
	}
	
	override func accessibilityActivate() -> Bool {
		
		isSelected.toggle()
		accessibilityValue = isSelected ? "1" : "0"
		
		return true // indicates that this control has handled the activation itself
	}
	
	/// Setup all the accessibility traits
	private func setupAccessibility() {
		
		isAccessibilityElement = true
	}

	@discardableResult
	func valueChanged(_ target: Any?, action: Selector) -> Self {
		super.addTarget(target, action: action, for: .valueChanged)
		return self
	}

	private func applyState() {
		iconImageView.isHighlighted = isSelected
		iconImageView.image = hasError ? Images.Icon.error : Images.Icon.normal
		backgroundColor = hasError ? C.consentButtonError() : C.primaryBlue5()
	}

	@objc private func toggle() {
		isSelected.toggle()
		sendActions(for: .valueChanged)
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
	
	@objc private func tapScrollView() {
		
		sendActions(for: .touchDown)
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
			self.sendActions(for: .touchUpInside)
		}
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Dimension.lineHeight,
															 textColor: Theme.colors.dark)
			accessibilityLabel = title
			setupLargeContentViewer(title: title)
		}
	}
}
