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
			static let indicator: CGFloat = 10
		}
		enum Spacing {
			static let indicator: CGFloat = 8
		}
		enum Scale {
			static let indicator: CGFloat = 1.25
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
		stackView.alignment = .fill
		stackView.axis = .horizontal
		stackView.distribution = .fillEqually
		stackView.spacing = ViewTraits.Spacing.indicator
		return stackView
	}()
	
	var numberOfPages: Int = 0 {
		didSet {
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
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
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
		let height: CGFloat = ViewTraits.Size.indicator
		let count = CGFloat(numberOfPages)
		let width: CGFloat = (count * ViewTraits.Size.indicator) + (count - 1) * ViewTraits.Spacing.indicator
		return CGSize(width: width, height: height)
	}
}

private extension PageControl {
	
	func addRoundIndicator(isSelected: Bool) -> UIView {
		let indicator = UIView()
		indicator.backgroundColor = isSelected ? ViewTraits.Color.selected : ViewTraits.Color.deselected
		indicator.frame = CGRect(origin: .zero, size: CGSize(width: ViewTraits.Size.indicator, height: ViewTraits.Size.indicator))
		indicator.layer.cornerRadius = indicator.bounds.height / 2
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
		UIView.animate(withDuration: ViewTraits.Duration.animation, animations: {
			currentIndicator.backgroundColor = ViewTraits.Color.selected
			currentIndicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.indicator, y: ViewTraits.Scale.indicator)
		}, completion: { finished in
			if finished {
				UIView.animate(withDuration: ViewTraits.Duration.animation, animations: {
					currentIndicator.transform = .identity
				})
			}
		})
	}
	
	func previousPage() {
		guard currentPageIndex - 1 >= 0, currentPageIndex < indicators.count else { return }
		let currentIndicator = indicators[currentPageIndex]
		let previousIndicator = indicators[currentPageIndex - 1]
		UIView.animate(withDuration: ViewTraits.Duration.animation, animations: {
			currentIndicator.backgroundColor = ViewTraits.Color.deselected
			previousIndicator.transform = CGAffineTransform(scaleX: ViewTraits.Scale.indicator, y: ViewTraits.Scale.indicator)
		}, completion: { finished in
			if finished {
				UIView.animate(withDuration: ViewTraits.Duration.animation, animations: {
					previousIndicator.transform = .identity
				})
				self.currentPageIndex -= 1
			}
		})
	}
}
