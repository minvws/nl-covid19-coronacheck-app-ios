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
        case primary
        case secondary
        case tertiary
    }

    var style = ButtonType.primary {
        didSet {
            updateButtonType()
        }
    }

    var rounded = false {
        didSet {
            updateRoundedCorners()
        }
    }

	var title: String? = "" {
        didSet {
            self.setTitle(title, for: .normal)
        }
    }

    override var isEnabled: Bool {
        didSet {
			updatePrimaryStyleColors()
        }
    }

    var useHapticFeedback = true

    // MARK: - Init

    required init(title: String = "", style: ButtonType = .primary) {

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
        updateRoundedCorners()
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
		
		switch style {
			case .primary:
				updatePrimaryStyleColors()
				contentEdgeInsets = .topBottom(13.5) + .leftRight(20)
			case .secondary:
				backgroundColor = Theme.colors.secondary
				setTitleColor(Theme.colors.dark, for: .normal)
				self.titleLabel?.font = Theme.fonts.subheadBold
				contentEdgeInsets = .topBottom(13.5) + .leftRight(20)
			case .tertiary:
				backgroundColor = .clear
				setTitleColor(Theme.colors.iosBlue, for: .normal)
				setTitleColor(Theme.colors.grey2, for: .disabled)
				self.titleLabel?.font = Theme.fonts.bodySemiBold
				
		}
		tintColor = Theme.colors.viewControllerBackground
	}
	
	private func updatePrimaryStyleColors() {
		
		guard style == .primary else { return }
		
		if isEnabled {
			backgroundColor = Theme.colors.primary
			setTitleColor(Theme.colors.viewControllerBackground, for: .normal)
		} else {
			backgroundColor = Theme.colors.tertiary
			setTitleColor(Theme.colors.gray, for: .normal)
		}
	}

    private func updateRoundedCorners() {

        if rounded {
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
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

    private var isFlashingTitle: Bool = false
}
