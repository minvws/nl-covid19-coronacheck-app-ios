/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

extension UIStackView {
    
    convenience init(vertical arrangedSubviews: [UIView], spacing: CGFloat = 0) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = .vertical
        self.spacing = spacing
    }
    
    convenience init(horizontal arrangedSubviews: [UIView], spacing: CGFloat = 0) {
        self.init(arrangedSubviews: arrangedSubviews)
        self.axis = .horizontal
        self.spacing = spacing
    }
    
    func distribution(_ value: UIStackView.Distribution) -> Self {
        distribution = value
        return self
    }
    
    func alignment(_ value: UIStackView.Alignment) -> Self {
        alignment = value
        return self
    }
 
}

func VStack(spacing: CGFloat = 0, _ views: UIView ...) -> UIStackView {
    return UIStackView(vertical: views, spacing: spacing)
}

func VStack(spacing: CGFloat = 0, _ views: [UIView]) -> UIStackView {
    return UIStackView(vertical: views, spacing: spacing)
}

func HStack(spacing: CGFloat = 0, _ views: UIView ...) -> UIStackView {
    return UIStackView(horizontal: views, spacing: spacing)
}

func HStack(spacing: CGFloat = 0, _ views: [UIView]) -> UIStackView {
    return UIStackView(horizontal: views, spacing: spacing)
}
