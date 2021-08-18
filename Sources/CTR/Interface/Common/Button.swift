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
            updateButtonType()
        }
    }

	var title: String? = "" {
        didSet {
            self.setTitle(title, for: .normal)
        }
    }

    override var isEnabled: Bool {
        didSet {
			updateButtonType()
        }
    }

    var useHapticFeedback = true

    // MARK: - Init

    required init(title: String = "", style: ButtonType = .roundedBlue) {

        super.init(frame: .zero)

        self.setTitle(title, for: .normal)
        self.title = title
        self.titleLabel?.font = Theme.fonts.bodySemiBold
		// multiline
		self.titleLabel?.lineBreakMode = .byWordWrapping
		self.titleLabel?.numberOfLines = 0

        self.layer.cornerRadius = 5
        self.clipsToBounds = true

        self.addTarget(self, action: #selector(self.touchUpAnimation), for: .touchDragExit)
        self.addTarget(self, action: #selector(self.touchUpAnimation), for: .touchCancel)
        self.addTarget(self, action: #selector(self.touchUpAnimation), for: .touchUpInside)
        self.addTarget(self, action: #selector(self.touchDownAnimation), for: .touchDown)

		self.translatesAutoresizingMaskIntoConstraints = false

        self.style = style

        updateButtonType()
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
		let size = titleLabel?.intrinsicContentSize ?? CGSize.zero
		let insets = contentEdgeInsets

		return CGSize(
			width: size.width + insets.left + insets.right,
			height: size.height + insets.top + insets.bottom
		)
	}

    // MARK: - Private

	private func updateButtonType() {
		
		backgroundColor = style.backgroundColor(isEnabled: isEnabled)
		setTitleColor(style.textColor(isEnabled: true), for: .normal)
		setTitleColor(style.textColor(isEnabled: false), for: .disabled)
		contentEdgeInsets = style.contentEdgeInsets
		layer.borderWidth = style.borderWidth
		layer.borderColor = style.borderColor(isEnabled: isEnabled).cgColor
		
		setNeedsLayout()
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

    private var isFlashingTitle: Bool = false
}
