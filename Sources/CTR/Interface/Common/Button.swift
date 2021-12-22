/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

/// A styled UIButton subclass
class Button: UIButton {
	
    enum ButtonType {
		/// Rounded, blue background, white text
        case roundedBlue
		/// Rounded, white background, dark text
        case roundedWhite
		/// Rounded, clear background, dark border
		case roundedClear
		/// Rounded, white background, blue text, blue border
		case roundedBlueBorder
		/// Text only, blue text
        case textLabelBlue
		/// Rounded, blue background, white text, right image with label in center
		case roundedBlueImage
		
		func backgroundColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue, .roundedBlueImage:
					return isEnabled ? Theme.colors.primary : Theme.colors.tertiary
				case .roundedWhite, .roundedBlueBorder:
					return isEnabled ? Theme.colors.secondary : Theme.colors.grey2
				case .roundedClear, .textLabelBlue:
					return .clear
			}
		}
		
		func textColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue, .roundedBlueImage:
					return isEnabled ? Theme.colors.viewControllerBackground : Theme.colors.gray
				case .roundedWhite:
					return Theme.colors.dark
				case .roundedClear:
					return isEnabled ? Theme.colors.dark : Theme.colors.grey2
				case .textLabelBlue:
					return isEnabled ? Theme.colors.primary : Theme.colors.grey2
				case .roundedBlueBorder:
					return isEnabled ? Theme.colors.primary : Theme.colors.grey2
			}
		}
		
		var font: UIFont {
			switch self {
				case .textLabelBlue: return Theme.fonts.bodyMedium
				default: return Theme.fonts.bodySemiBold
			}
		}
		
		var contentEdgeInsets: UIEdgeInsets {
			switch self {
				case .textLabelBlue: return .zero
				case .roundedBlueImage: return .topBottom(15) + .left(44) + .right(56)
				default: return .topBottom(15) + .leftRight(56)
			}
		}
		
		var imageEdgeInsets: UIEdgeInsets {
			switch self {
				case .roundedBlueImage: return .left(-12) + .right(12)
				default: return .zero
			}
		}
		
		func borderColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlueBorder:
					return isEnabled ? Theme.colors.primary : Theme.colors.grey2
				default:
					return isEnabled ? Theme.colors.dark : Theme.colors.grey2
			}
		}
		
		var borderWidth: CGFloat {
			switch self {
				case .roundedClear, .roundedBlueBorder: return 1
				default: return 0
			}
		}
		
		var isRounded: Bool {
			switch self {
				case .textLabelBlue: return false
				default: return true
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
		
		let horizontalImagePadding = abs(imageEdgeInsets.left) + abs(imageEdgeInsets.right)
		let verticalImagePadding = imageEdgeInsets.top + imageEdgeInsets.bottom
		
		let verticalPadding = max(verticalContentPadding, verticalImagePadding)

        return CGSize(
            width: maxWidth + horizontalContentPadding + horizontalImagePadding,
            height: maxHeight + verticalPadding
        )
	}
	
	override func setImage(_ image: UIImage?, for state: UIControl.State) {
		super.setImage(image, for: state)
		
		guard style == .roundedBlueImage else { return }
		contentEdgeInsets = image != nil ? ButtonType.roundedBlueImage.contentEdgeInsets : ButtonType.roundedBlue.contentEdgeInsets
	}

    // MARK: - Private

	private func setupButtonType() {
		
		setupColors()
		titleLabel?.font = style.font
		contentEdgeInsets = style.contentEdgeInsets
		layer.borderWidth = style.borderWidth
		imageEdgeInsets = style.imageEdgeInsets
		
		if style == .roundedBlueImage {
			// Increase size
			imageView?.layer.transform = CATransform3DMakeScale(1.1, 1.1, 1.1)
			// Position image to the right of the label
			let flipTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
			transform = flipTransform
			titleLabel?.transform = flipTransform
			imageView?.transform = flipTransform
		}
		
		setNeedsLayout()
	}
	
	private func setupColors() {
		
		backgroundColor = style.backgroundColor(isEnabled: isEnabled)
		setTitleColor(style.textColor(isEnabled: true), for: .normal)
		setTitleColor(style.textColor(isEnabled: false), for: .disabled)
		layer.borderColor = style.borderColor(isEnabled: isEnabled).cgColor
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
