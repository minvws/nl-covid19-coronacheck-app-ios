/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ConsentButton: UIButton {

	override var isSelected: Bool {
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
    
	var useHapticFeedback = true

	required init(title: String = "", selected: Bool = false) {

		icon = ImageView(imageName: "Toggle/Normal", highlightedImageName: "Toggle/Selected")

		super.init(frame: .zero)

		setTitle(title, for: .normal)

		addTarget(self, action: #selector(touchUpAnimation), for: .touchDragExit)
		addTarget(self, action: #selector(touchUpAnimation), for: .touchCancel)
		addTarget(self, action: #selector(touchUpAnimation), for: .touchUpInside)
		addTarget(self, action: #selector(toggle), for: .touchUpInside)
		addTarget(self, action: #selector(touchDownAnimation), for: .touchDown)

		icon.contentMode = .scaleAspectFit
		icon.snap(to: .left, of: self, insets: .left(16))

		isSelected = selected

		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Private

	fileprivate func setup() {
		clipsToBounds = true
		contentEdgeInsets = .topBottom(14) + .left(56) + .right(16)

		layer.cornerRadius = 8

		titleLabel?.font = Theme.fonts.subhead
		titleLabel?.lineBreakMode = .byWordWrapping
		titleLabel?.numberOfLines = 0

		tintColor = Theme.colors.viewControllerBackground
		backgroundColor = Theme.colors.tertiary
		setTitleColor(Theme.colors.dark, for: .normal)
		contentHorizontalAlignment = .left

		applyState()
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		titleLabel?.preferredMaxLayoutWidth = bounds.width - contentEdgeInsets.left - contentEdgeInsets.right
	}

	override var intrinsicContentSize: CGSize {
		var base = super.intrinsicContentSize
		base.height += contentEdgeInsets.top + contentEdgeInsets.bottom
		base.width += contentEdgeInsets.right
		return base
	}

	@discardableResult
	func valueChanged(_ target: Any?, action: Selector) -> Self {
		super.addTarget(target, action: action, for: .valueChanged)
		return self
	}

	private func applyState() {
		icon.isHighlighted = isSelected
	}

	@objc private func toggle() {
		isSelected.toggle()
		sendActions(for: .valueChanged)
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

	fileprivate let icon: UIImageView
}
