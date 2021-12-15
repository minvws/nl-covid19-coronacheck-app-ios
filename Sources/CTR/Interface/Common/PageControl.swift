/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

protocol PageControlViewDelegate: AnyObject {
	
	func pageControl(_ pageControl: PageControl, didChangePage page: Int, previousPage: Int)
}

final class PageControl: BaseView {
	
	private enum ViewTraits {
		
		enum Size {
			static let deselected: CGFloat = 3
			static let selected: CGFloat = 7
		}
		enum Spacing {
			static let indicator: CGFloat = 13
		}
		enum Scale {
			static let selected: CGFloat = 2.5
			static let animation: CGFloat = 2.85
		}
		enum Duration {
			static let animation: TimeInterval = 0.15
		}
		enum Color {
			static let selected = Theme.colors.primary
			static let deselected = Theme.colors.grey2
		}
	}
	
	private var currentPageIndex: Int = 0
	
	private var indicators: [UIView] = []
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.alignment = .center
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.spacing = ViewTraits.Spacing.indicator
		return stackView
	}()
	
	/// Set number of pages. Indicators shown when more than one page is set.
	var numberOfPages: Int = 0 {
		didSet {
			guard numberOfPages > 1 else { return }
			if currentPageIndex >= numberOfPages {
				currentPageIndex = 0
			}
			addIndicators(for: numberOfPages)
			setNeedsLayout()
		}
	}
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = .clear
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		stackView.embed(in: self)
	}
	
	func update(for page: Int) {
		guard currentPageIndex != page else { return }
		
		if page > currentPageIndex {
			nextPage()
		} else {
			previousPage()
		}
	}
	
	override var intrinsicContentSize: CGSize {
		let height: CGFloat = ViewTraits.Size.selected
		let count = CGFloat(numberOfPages)
		let width: CGFloat = (count * ViewTraits.Size.deselected) + (count - 1) * ViewTraits.Spacing.indicator
		return CGSize(width: width, height: height)
	}
}

private extension PageControl {
	
	func addRoundIndicator(isSelected: Bool) -> UIView {
		let indicator = UIView()
		indicator.backgroundColor = isSelected ? ViewTraits.Color.selected : ViewTraits.Color.deselected
		indicator.layer.cornerRadius = ViewTraits.Size.deselected / 2
		indicator.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			indicator.widthAnchor.constraint(equalToConstant: ViewTraits.Size.deselected),
			indicator.heightAnchor.constraint(equalToConstant: ViewTraits.Size.deselected)
		])
		
		if isSelected {
			indicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.selected, y: ViewTraits.Scale.selected)
		}
		
		return indicator
	}
	
	func addIndicators(for count: Int) {
		for index in 0..<count {
			let indicator = addRoundIndicator(isSelected: index <= currentPageIndex)
			stackView.addArrangedSubview(indicator)
			indicators.append(indicator)
		}
	}
	
	func nextPage() {
		guard currentPageIndex + 1 < numberOfPages else { return }
		
		currentPageIndex += 1
		let currentIndicator = indicators[currentPageIndex]
		let previousIndicator = indicators[currentPageIndex - 1]
		
		UIView.animate(withDuration: ViewTraits.Duration.animation,
					   delay: 0,
					   options: [.beginFromCurrentState, .curveEaseOut],
					   animations: {
			currentIndicator.backgroundColor = ViewTraits.Color.selected
			previousIndicator.backgroundColor = ViewTraits.Color.deselected
			currentIndicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.animation, y: ViewTraits.Scale.animation)
			previousIndicator.transform = .identity
		}, completion: { finished in
			guard finished else { return }
			
			UIView.animate(withDuration: ViewTraits.Duration.animation, animations: {
				currentIndicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.selected, y: ViewTraits.Scale.selected)
			})
		})
	}
	
	func previousPage() {
		guard currentPageIndex - 1 >= 0, currentPageIndex < indicators.count else { return }
		
		let currentIndicator = indicators[currentPageIndex]
		let previousIndicator = indicators[currentPageIndex - 1]
		
		UIView.animate(withDuration: ViewTraits.Duration.animation,
					   delay: 0,
					   options: [.beginFromCurrentState, .curveEaseOut],
					   animations: {
			currentIndicator.backgroundColor = ViewTraits.Color.deselected
			previousIndicator.backgroundColor = ViewTraits.Color.selected
			previousIndicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.animation, y: ViewTraits.Scale.animation)
			currentIndicator.transform = .identity
		}, completion: { finished in
			guard finished else { return }
			
			UIView.animate(withDuration: ViewTraits.Duration.animation, animations: {
				previousIndicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.selected, y: ViewTraits.Scale.selected)
			})
			self.currentPageIndex -= 1
		})
	}
}
