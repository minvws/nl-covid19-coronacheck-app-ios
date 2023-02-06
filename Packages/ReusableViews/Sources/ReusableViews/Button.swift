/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared

/*
 A styled UIButton subclass
 */
open class Button: TappableButton {
	
	public enum ButtonType {
		
		/// Used for the QRCardView ShowQR Button
		case narrowRoundedBlue

		/// Rounded, blue background, white text
		case roundedBlue
				
		/// Rounded, white background, dark text
		case roundedWhite
		
		/// Rounded, clear background, dark border
		case roundedClear
		
		/// Rounded, white background, blue text, blue border
		case roundedBlueBorder

		/// Rounded, white background, blue text, blue border
		case roundedRedBorder
		
		/// Rounded, white background, black text, black border
		case roundedBlackBorder
		
		/// Text only, blue text
		case textLabelBlue
		
		/// Rounded, blue background, white text, right image with label in center
		case roundedBlueImage
		
		public func backgroundColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue, .narrowRoundedBlue, .roundedBlueImage:
					return isEnabled ? C.primaryBlue()! : C.grey5()!
				case .roundedWhite, .roundedBlueBorder, .roundedBlackBorder:
					return isEnabled ? C.white()! : C.grey2()!
				case .roundedRedBorder:
					return C.white()!
				case .roundedClear, .textLabelBlue:
					return .clear
			}
		}
		
		public func textColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue, .narrowRoundedBlue, .roundedBlueImage:
					return isEnabled ? C.white()! : C.grey2()!
				case .roundedWhite:
					return C.black()!
				case .roundedClear, .roundedBlackBorder:
					return isEnabled ? C.black()! : C.grey2()!
				case .textLabelBlue:
					return isEnabled ? C.primaryBlue()! : C.grey2()!
				case .roundedBlueBorder:
					return isEnabled ? C.primaryBlue()! : C.grey2()!
				case .roundedRedBorder:
					return isEnabled ? C.ccError()! : C.ccError()!.withAlphaComponent(0.4)
			}
		}
		
		public var font: UIFont {
			switch self {
				case .textLabelBlue: return Fonts.bodyMedium
				default: return Fonts.bodySemiBold
			}
		}
		
		public var contentEdgeInsets: UIEdgeInsets {
			switch self {
				case .textLabelBlue: return .zero
				case .roundedBlue: return .topBottom(10) + .leftRight(56)
				case .narrowRoundedBlue: return .topBottom(10) + .leftRight(32)
				case .roundedBlueImage: return .topBottom(15) + .left(56) + .right(66)
				case .roundedRedBorder: return .topBottom(15) + .leftRight(56)
				default: return .topBottom(10) + .leftRight(32)
			}
		}
		
		public var imageTitlePadding: CGFloat {
			switch self {
				case .roundedBlueImage: return 11
				default: return 0
			}
		}
		
		public func borderColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlueBorder:
					return isEnabled ? C.primaryBlue()! : C.grey2()!
				case .roundedRedBorder:
					return isEnabled ? C.ccError()! : C.ccError()!.withAlphaComponent(0.4)
				case .roundedBlackBorder:
					return C.black()!
				default:
					return isEnabled ? C.black()! : C.grey2()!
			}
		}
		
		public var borderWidth: CGFloat {
			switch self {
				case .roundedClear,
					.roundedBlueBorder,
					.roundedBlackBorder,
					.roundedRedBorder:
					return 1
				default:
					return 0
			}
		}
		
		public var isRounded: Bool {
			switch self {
				case .textLabelBlue: return false
				default: return true
			}
		}
	}
	
	open var style = ButtonType.roundedBlue {
		didSet {
			setupButtonType()
		}
	}
	
	open var title: String? = "" {
		didSet {
			setTitle(title, for: .normal)
		}
	}
	
	override open var isEnabled: Bool {
		didSet {
			setupColors()
		}
	}
	
	open var useHapticFeedback = true
	
	// MARK: - Init
	
	required public init(title: String = "", style: ButtonType = .roundedBlue) {
		
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
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	@discardableResult
	open func touchUpInside(_ target: Any?, action: Selector) -> Self {
		
		super.addTarget(target, action: action, for: .touchUpInside)
		return self
	}
	
	// MARK: - Overrides
	
	override open func layoutSubviews() {

		super.layoutSubviews()
		layer.cornerRadius = style.isRounded ? min(bounds.width, bounds.height) / 2 : 0
		titleLabel?.preferredMaxLayoutWidth = titleLabel?.frame.size.width ?? 0
		
		applyInsets()
	}
	
	// Calculates content size including insets for dynamic font size scaling
	override open var intrinsicContentSize: CGSize {
		
		guard style != .roundedBlueImage else {
			return super.intrinsicContentSize
		}
		
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

	// MARK: - Private
	
	private func applyInsets() {
		contentEdgeInsets = style.contentEdgeInsets
		
		switch style {
			case .roundedBlueImage:
				guard let imageView = imageView, let titleLabel = titleLabel
				else { return }

				// Position image to the right of the label
			
				titleEdgeInsets = UIEdgeInsets(
					top: 0,
					left: -imageView.frame.size.width,
					bottom: 0,
					right: imageView.frame.size.width)
				
				imageEdgeInsets = UIEdgeInsets(
					top: 0,
					left: titleLabel.frame.size.width + style.imageTitlePadding,
					bottom: 0,
					right: -titleLabel.frame.size.width
				)
				
			default: break
		}
	}
	
	private func setupButtonType() {
		
		setupColors()
		titleLabel?.font = style.font
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
