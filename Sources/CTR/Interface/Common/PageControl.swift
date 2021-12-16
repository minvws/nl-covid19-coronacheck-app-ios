/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

protocol PageControlDelegate: AnyObject {
	
	func pageControl(_ pageControl: PageControl, didChangeToPageIndex currentPageIndex: Int, previousPageIndex: Int)
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
		enum Margin {
			static let horizontal: CGFloat = 20
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
	
	/// The delegate to get current and previous page index
	weak var delegate: PageControlDelegate?
	
	/// Get current page index
	private(set) var currentPageIndex: Int = 0
	
	/// Set number of pages. Indicators shown when more than one page is set.
	var numberOfPages: Int = 0 {
		didSet {
			let showIndicators = numberOfPages > 1
			isHidden = !showIndicators
			
			guard showIndicators else { return }
			if currentPageIndex >= numberOfPages {
				currentPageIndex = 0
			}
			addIndicators(for: numberOfPages)
			setNeedsLayout()
		}
	}
	
	private var indicators: [UIView] = []
	private let stackView: UIStackView = {
		let stackView = UIStackView()
		stackView.alignment = .center
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.spacing = ViewTraits.Spacing.indicator
		return stackView
	}()
	private var isAnimating = false
	
	// MARK: Setup & Overrides
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		stackView.embed(
			in: self,
			insets: .leftRight(ViewTraits.Margin.horizontal)
		)
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		isAccessibilityElement = true
		accessibilityTraits = .adjustable
	}
	
	override var intrinsicContentSize: CGSize {
		let height: CGFloat = ViewTraits.Size.selected
		let count = CGFloat(numberOfPages)
		let margins = 2 * ViewTraits.Spacing.indicator
		let width: CGFloat = (count * ViewTraits.Size.deselected) + (count - 1) * ViewTraits.Spacing.indicator + margins
		return CGSize(width: width, height: height)
	}
	
	override func accessibilityIncrement() {
		guard canGoToNexPage else { return }
		
		let nextIndex = currentPageIndex + 1
		delegate?.pageControl(self, didChangeToPageIndex: nextIndex, previousPageIndex: currentPageIndex)
	}
	
	override func accessibilityDecrement() {
		guard canGoToPreviousPage else { return }
		
		let previousIndex = currentPageIndex - 1
		delegate?.pageControl(self, didChangeToPageIndex: previousIndex, previousPageIndex: currentPageIndex)
	}
	
	override var accessibilityValue: String? {
		get { L.general_pagecontrol_accessibility_value(currentPageIndex + 1, numberOfPages) }
		set { super.accessibilityValue = newValue }
	}
	
	// MARK: - Public Access
	
	/// Update selected page indicator
	/// - Parameter pageIndex: Page index to have selected state
	func update(for pageIndex: Int) {
		guard currentPageIndex != pageIndex else { return }

		if pageIndex > currentPageIndex {
			selectNextPageIndicator()
		} else {
			selectPreviousPageIndicator()
		}
	}
}

// MARK: - Private

private extension PageControl {
	
	var canGoToNexPage: Bool {
		return currentPageIndex + 1 < numberOfPages
	}
	
	var canGoToPreviousPage: Bool {
		return currentPageIndex - 1 >= 0
	}
	
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
		stackView.removeArrangedSubviews()
		
		for index in 0..<count {
			let indicator = addRoundIndicator(isSelected: index <= currentPageIndex)
			stackView.addArrangedSubview(indicator)
			indicators.append(indicator)
		}
	}
	
	func selectNextPageIndicator() {
		guard canGoToNexPage else { return }
		
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
	
	func selectPreviousPageIndicator() {
		guard canGoToPreviousPage else { return }
		
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
