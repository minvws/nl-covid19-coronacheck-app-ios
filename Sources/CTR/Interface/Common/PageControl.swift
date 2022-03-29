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
			static let extraHorizontalTapArea: CGFloat = 40
		}
		enum Scale {
			static let selected: CGFloat = 2.5
			static let animation: CGFloat = 2.85
		}
		enum Duration {
			static let animation: TimeInterval = 0.15
		}
		enum Color {
			static let selected = C.primaryBlue()!
			static let deselected = C.grey2()
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
			selectPageIndicator(for: currentPageIndex, isInitialSelection: true)
		}
	}
	
	private var indicators: [UIView] = []
	private let indicatorStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.alignment = .center
		stackView.axis = .horizontal
		stackView.distribution = .equalSpacing
		stackView.spacing = ViewTraits.Spacing.indicator
		return stackView
	}()
	private let buttonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.isAccessibilityElement = false
		return stackView
	}()
	
	// MARK: Setup & Overrides
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		let previousButton = TappableButton()
		previousButton.addTarget(self, action: #selector(navigateToPreviousPage), for: .touchUpInside)
		previousButton.isAccessibilityElement = false
		buttonStackView.addArrangedSubview(previousButton)
		let nextButton = TappableButton()
		nextButton.addTarget(self, action: #selector(navigateToNextPage), for: .touchUpInside)
		nextButton.isAccessibilityElement = false
		buttonStackView.addArrangedSubview(nextButton)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		indicatorStackView.embed(
			in: self,
			insets: .leftRight(ViewTraits.Margin.extraHorizontalTapArea)
		)
		buttonStackView.embed(in: self)
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		isAccessibilityElement = true
		accessibilityTraits = .adjustable
	}
	
	override var intrinsicContentSize: CGSize {
		let height: CGFloat = ViewTraits.Size.selected
		let count = CGFloat(numberOfPages)
		let margins = 2 * ViewTraits.Margin.extraHorizontalTapArea
		let width: CGFloat = (count * ViewTraits.Size.deselected) + (count - 1) * ViewTraits.Spacing.indicator + margins
		return CGSize(width: width, height: height)
	}
	
	override func accessibilityIncrement() {
		navigateToNextPage()
	}
	
	override func accessibilityDecrement() {
		navigateToPreviousPage()
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
		
		if pageIndex > currentPageIndex, canGoToNexPage {
			selectPageIndicator(for: pageIndex, isInitialSelection: false)
		} else if canGoToPreviousPage {
			selectPageIndicator(for: pageIndex, isInitialSelection: false)
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
	
	@objc func navigateToNextPage() {
		guard canGoToNexPage else { return }
		
		let nextIndex = currentPageIndex + 1
		delegate?.pageControl(self, didChangeToPageIndex: nextIndex, previousPageIndex: currentPageIndex)
	}
	
	@objc func navigateToPreviousPage() {
		guard canGoToPreviousPage else { return }
		
		let previousIndex = currentPageIndex - 1
		delegate?.pageControl(self, didChangeToPageIndex: previousIndex, previousPageIndex: currentPageIndex)
	}
	
	func addRoundIndicator() -> UIView {
		let indicator = UIView()
		indicator.backgroundColor = ViewTraits.Color.deselected
		indicator.layer.cornerRadius = ViewTraits.Size.deselected / 2
		indicator.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			indicator.widthAnchor.constraint(equalToConstant: ViewTraits.Size.deselected),
			indicator.heightAnchor.constraint(equalToConstant: ViewTraits.Size.deselected)
		])
		
		return indicator
	}
	
	func addIndicators(for count: Int) {
		indicatorStackView.removeArrangedSubviews()
		
		(0..<count).forEach { _ in
			let indicator = addRoundIndicator()
			indicatorStackView.addArrangedSubview(indicator)
			indicators.append(indicator)
		}
	}
	
	func selectPageIndicator(for pageIndex: Int, isInitialSelection: Bool) {
		currentPageIndex = pageIndex
		
		UIView.animate(withDuration: ViewTraits.Duration.animation,
					   delay: 0,
					   options: [.beginFromCurrentState, .curveEaseOut],
					   animations: {
			for (index, indicator) in self.indicators.enumerated() {
				if index == pageIndex {
					indicator.backgroundColor = ViewTraits.Color.selected
					indicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.animation, y: ViewTraits.Scale.animation)
				} else {
					indicator.backgroundColor = ViewTraits.Color.deselected
					indicator.transform = .identity
				}
			}
		}, completion: { finished in
			guard finished, !isInitialSelection else { return }
			
			UIView.animate(withDuration: ViewTraits.Duration.animation, animations: {
				self.indicators[pageIndex].transform = CGAffineTransform(scaleX: ViewTraits.Scale.selected, y: ViewTraits.Scale.selected)
			})
		})
	}
}
