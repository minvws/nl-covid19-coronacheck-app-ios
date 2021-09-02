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
		// Rounded, blue background, white text
        case roundedBlue
		// Rounded, white background, dark text
        case roundedWhite
		// Rounded, clear background, dark border
		case roundedClear
		// Text only, blue text
        case textLabelBlue
		
		func backgroundColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue:
					return isEnabled ? Theme.colors.primary : Theme.colors.tertiary
				case .roundedWhite:
					return isEnabled ? Theme.colors.secondary : Theme.colors.grey2
				case .roundedClear, .textLabelBlue:
					return .clear
			}
		}
		
		func textColor(isEnabled: Bool = true) -> UIColor {
			switch self {
				case .roundedBlue:
					return isEnabled ? Theme.colors.viewControllerBackground : Theme.colors.gray
				case .roundedWhite:
					return Theme.colors.dark
				case .roundedClear:
					return isEnabled ? Theme.colors.dark : Theme.colors.grey2
				case .textLabelBlue:
					return isEnabled ? Theme.colors.iosBlue : Theme.colors.grey2
			}
		}
		
		var contentEdgeInsets: UIEdgeInsets {
			switch self {
				case .textLabelBlue: return .zero
				default: return .topBottom(13.5) + .leftRight(20)
			}
		}
		
		func borderColor(isEnabled: Bool = true) -> UIColor {
			return isEnabled ? Theme.colors.dark : Theme.colors.grey2
		}
		
		var borderWidth: CGFloat {
			switch self {
				case .roundedClear: return 1
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
		
        self.titleLabel?.font = Theme.fonts.bodySemiBold
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

	override var intrinsicContentSize: CGSize {
        let fittingSize = titleLabel?.sizeThatFits(
            CGSize(width: frame.width, height: .greatestFiniteMagnitude)
        ) ?? .zero
        let intrinsicSize = titleLabel?.intrinsicContentSize ?? CGSize.zero

        let maxWidth = max(fittingSize.width, intrinsicSize.width)
        let maxHeight = max(fittingSize.height, intrinsicSize.height)

        let horizontalPadding = contentEdgeInsets.left + contentEdgeInsets.right
        let verticalPadding = contentEdgeInsets.top + contentEdgeInsets.bottom

        return CGSize(
            width: maxWidth + horizontalPadding,
            height: maxHeight + verticalPadding
        )
	}

    // MARK: - Private

	private func setupButtonType() {
		
		setupColors()
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
