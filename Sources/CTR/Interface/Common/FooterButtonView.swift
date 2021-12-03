/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

/// Footer view with primary button.
/// It has a fade animation method to display a shadow separator when pinned to a scroll view.
final class FooterButtonView: BaseView {
	
	/// The display constants
	private struct ViewTraits {

		enum Button {
			static let height: CGFloat = 52
		}
		enum Gradient {
			static let height: CGFloat = 15.0
		}
		enum Margin {
			static let edge: CGFloat = 20.0
		}
		enum Spacing {
			static let buttonStack: CGFloat = 16
		}
	}

	/// The shadow gradient view
	let gradientView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	let buttonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .center
		stackView.spacing = ViewTraits.Spacing.buttonStack
		return stackView
	}()

	/// The primary button
	let primaryButton: Button = {
		let button = Button()
		button.titleLabel?.textAlignment = .center
		return button
	}()
	
	/// Setup all the views
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(gradientView)
		addSubview(buttonStackView)
		buttonStackView.addArrangedSubview(primaryButton)
	}

	/// Setup all the constraints
	override  func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			gradientView.bottomAnchor.constraint(equalTo: topAnchor),
			gradientView.leftAnchor.constraint(equalTo: leftAnchor),
			gradientView.rightAnchor.constraint(equalTo: rightAnchor),
			gradientView.heightAnchor.constraint(equalToConstant: ViewTraits.Gradient.height),
			
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Button.height),
			
			buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			buttonStackView.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: ViewTraits.Margin.edge),
			buttonStackView.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -ViewTraits.Margin.edge),
			buttonStackView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Margin.edge),
			{
				let constraint = buttonStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -ViewTraits.Margin.edge)
				bottomButtonConstraint = constraint
				return constraint
			}()
		])
	}
	
	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}
	
	/// Setup the gradient in the footer
	private func setupShadowGradient() {

		gradientView.backgroundColor = .clear
		let gradient = CAGradientLayer()
		gradient.frame = gradientView.bounds
		gradient.colors = [
			UIColor.black.withAlphaComponent(0.0).cgColor,
			UIColor.black.withAlphaComponent(0.01).cgColor,
			UIColor.black.withAlphaComponent(0.03).cgColor,
			UIColor.black.withAlphaComponent(0.08).cgColor,
			UIColor.black.withAlphaComponent(0.1).cgColor
		]
		gradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		gradientView.layer.insertSublayer(gradient, at: 0)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		setupShadowGradient()
	}
	
	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
	
	/// The title for the primary button
	var primaryTitle: String? {
		didSet {
			primaryButton.title = primaryTitle
		}
	}
	
	/// The bottom constraint for keyboard changes
	var bottomButtonConstraint: NSLayoutConstraint?
	
	/// Fade shadow separator.
	/// - Parameter scrollOffset: The scroll offset of the scroll view (animation range: -height to 0).
	func updateFadeAnimation(from scrollOffset: CGFloat) {
		let maxRange: CGFloat = ViewTraits.Gradient.height
		let distance = clamp(scrollOffset: scrollOffset, maxRange: maxRange)
		
		gradientView.alpha = fadeOutPercentage(maxRange: maxRange, currentPosition: distance)
	}
}

private extension FooterButtonView {
	
	func fadeOutPercentage(maxRange: CGFloat, currentPosition: CGFloat) -> CGFloat {
		let startPercentage: CGFloat = 0
		let stopPercentage: CGFloat = 1
		let percentage: CGFloat = currentPosition / maxRange
		let fadePercentage: CGFloat = (percentage - startPercentage) / abs(startPercentage - stopPercentage)
		return 1 - max(0, min(1, fadePercentage))
	}
	
	func clamp(scrollOffset: CGFloat, maxRange: CGFloat) -> CGFloat {
		let startingOffset: CGFloat = -ViewTraits.Gradient.height
		return abs(max(-maxRange, min(startingOffset - scrollOffset, 0)))
	}
}
