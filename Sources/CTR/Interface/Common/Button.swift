/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

/// A styled UIButton subclass
class Button: TappableButton {
	
	enum ButtonType {
		/// Rounded, blue background, white text
		case roundedBlue
		/// Rounded, white background, dark text
		case roundedWhite
		/// Rounded, clear background, dark border
		case roundedClear
		/// Rounded, white background, blue text, blue border
		case roundedBlueBorder
		/// Rounded, white background, black text, black border
		case roundedBlackBorder
		/// Text only, blue text
		case textLabelBlue
		/// Rounded, blue background, white text, right image with label in center
		case roundedBlueImage
		
		func backgroundColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue, .roundedBlueImage:
					return isEnabled ? C.primaryBlue()! : C.grey5()!
				case .roundedWhite, .roundedBlueBorder, .roundedBlackBorder:
					return isEnabled ? C.white()! : C.grey2()!
				case .roundedClear, .textLabelBlue:
					return .clear
			}
		}
		
		func textColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue, .roundedBlueImage:
					return isEnabled ? C.white()! : C.grey2()!
				case .roundedWhite:
					return C.black()!
				case .roundedClear, .roundedBlackBorder:
					return isEnabled ? C.black()! : C.grey2()!
				case .textLabelBlue:
					return isEnabled ? C.primaryBlue()! : C.grey2()!
				case .roundedBlueBorder:
					return isEnabled ? C.primaryBlue()! : C.grey2()!
			}
		}
		
		var font: UIFont {
			switch self {
				case .textLabelBlue: return Fonts.bodyMedium
				default: return Fonts.bodySemiBold
			}
		}
		
		var contentEdgeInsets: UIEdgeInsets {
			switch self {
				case .textLabelBlue: return .zero
				case .roundedBlueImage: return .topBottom(15) + .left(56) + .right(66)
				default: return .topBottom(15) + .leftRight(56)
			}
		}
		
		func borderColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlueBorder:
					return isEnabled ? C.primaryBlue()! : C.grey2()!
				case .roundedBlackBorder:
					return C.black()!
				default:
					return isEnabled ? C.black()! : C.grey2()!
			}
		}
		
		var borderWidth: CGFloat {
			switch self {
				case .roundedClear, .roundedBlueBorder, .roundedBlackBorder: return 1
				default: return 0
			}
		}
		
		var isRounded: Bool {
			switch self {
				case .textLabelBlue: return false
				default: return true
			}
		}
		
		var imageSpacing: CGFloat {
			switch self {
				case .roundedBlueImage: return 12
				default: return 0
			}
		}
	}
	
	var style = ButtonType.roundedBlue {
		didSet {
			setupButtonType()
		}
	}
	
	var title: String? = "" {
		didSet {
			setTitle(title, for: .normal)
		}
	}
	
	override var isEnabled: Bool {
		didSet {
			setupColors()
		}
	}
	
	var useHapticFeedback = true
	
	// MARK: - Init
	
	required init(title: String = "", style: ButtonType = .roundedBlue) {
		
		super.init(frame: .zero)
		
		defer {
			self.title = title
			self.style = style
		}
		
		// multiline
		self.titleLabel?.lineBreakMode = .byWordWrapping
		self.titleLabel?.numberOfLines = 0
		
		self.clipsToBounds = true
		
		self.addTarget(self, action: #selector(self.touchUpAnimation), for: [.touchDragExit, .touchCancel, .touchUpInside])
		self.addTarget(self, action: #selector(self.touchDownAnimation), for: .touchDown)
		
		self.translatesAutoresizingMaskIntoConstraints = false
		
		setupAccessibility()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@discardableResult
	func touchUpInside(_ target: Any?, action: Selector) -> Self {
		
		super.addTarget(target, action: action, for: .touchUpInside)
		return self
	}
	
	// MARK: - Overrides
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
		layer.cornerRadius = style.isRounded ? min(bounds.width, bounds.height) / 2 : 0
		titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
	}
	
	/// Calculates content size including insets for dynamic font size scaling
	override var intrinsicContentSize: CGSize {
		let fittingSize = titleLabel?.sizeThatFits(
			CGSize(width: frame.width, height: .greatestFiniteMagnitude)
		) ?? .zero
		let intrinsicSize = titleLabel?.intrinsicContentSize ?? CGSize.zero
		
		let maxWidth = max(fittingSize.width, intrinsicSize.width)
		let maxHeight = max(fittingSize.height, intrinsicSize.height)
		
		let horizontalContentPadding = contentEdgeInsets.left + contentEdgeInsets.right
		let verticalContentPadding = contentEdgeInsets.top + contentEdgeInsets.bottom
		
		return CGSize(
			width: maxWidth + horizontalContentPadding,
			height: maxHeight + verticalContentPadding
		)
	}
	
	override func setImage(_ image: UIImage?, for state: UIControl.State) {
		guard style == .roundedBlueImage, let titleLabel = titleLabel else {
			super.setImage(image, for: state)
			return
		}
		contentEdgeInsets = image != nil ? ButtonType.roundedBlueImage.contentEdgeInsets : ButtonType.roundedBlue.contentEdgeInsets
		
		if image != nil {
			// Position image to the right of the label
			imageView?.translatesAutoresizingMaskIntoConstraints = false
			imageView?.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: style.imageSpacing).isActive = true
			imageView?.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
			
			// Increase size
			imageView?.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.1)
		}
		
		super.setImage(image, for: state)
	}
	
	// MARK: - Private
	
	private func setupButtonType() {
		
		setupColors()
		titleLabel?.font = style.font
		contentEdgeInsets = style.contentEdgeInsets
		layer.borderWidth = style.borderWidth
		
		setNeedsLayout()
	}
	
	private func setupColors() {
		
		backgroundColor = style.backgroundColor(isEnabled: isEnabled)
		setTitleColor(style.textColor(isEnabled: true), for: .normal)
		setTitleColor(style.textColor(isEnabled: false), for: .disabled)
		layer.borderColor = style.borderColor(isEnabled: isEnabled).cgColor
	}
	
	private func setupAccessibility() {
		
		if #available(iOS 15.0, *) {
			titleLabel?.maximumContentSizeCategory = .extraExtraExtraLarge
		}
		titleLabel?.adjustsFontForContentSizeCategory = true
		setupLargeContentViewer()
		if #available(iOS 13.0, *) {
			largeContentImage = nil
		}
	}
	
	@objc private func touchDownAnimation() {
		
		if useHapticFeedback { Haptic.light() }
		
		UIButton.animate(withDuration: 0.2, animations: {
			self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
		})
	}
	
	@objc private func touchUpAnimation() {
		
		UIButton.animate(withDuration: 0.2, animations: {
			self.transform = CGAffineTransform.identity
		})
	}
}
