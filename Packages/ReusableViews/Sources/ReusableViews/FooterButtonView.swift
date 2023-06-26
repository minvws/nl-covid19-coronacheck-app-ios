/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import Resources

/*
 Footer view with primary button.
 It has a fade animation method to display a shadow separator when pinned to a scroll view.
 */
 public final class FooterButtonView: BaseView {
	
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
			static let top: CGFloat = 24.0
		}
		enum Spacing {
			static let buttonStack: CGFloat = 16
		}
	}

	/// The shadow gradient view
	public let gradientView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()
	
	public let buttonStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.alignment = .fill // Subviews should have equal width
		stackView.spacing = ViewTraits.Spacing.buttonStack
		return stackView
	}()

	/// The primary button
	public let primaryButton: Button = {
		let button = Button()
		button.titleLabel?.textAlignment = .center
		button.titleLabel?.numberOfLines = 2
		return button
	}()
	
	/// Setup all the views
	override public func setupViews() {
		super.setupViews()
		
		backgroundColor = C.white()
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the view hierarchy
	override public func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(gradientView)
		addSubview(buttonStackView)
		buttonStackView.addArrangedSubview(primaryButton)
	}

	/// Setup all the constraints
	override public func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Button.height)
		])
		
		setupGradientViewConstraints()
		setupButtonStackViewConstraints()
	}
	
	private func setupGradientViewConstraints() {
		
		NSLayoutConstraint.activate([
			gradientView.bottomAnchor.constraint(equalTo: topAnchor),
			gradientView.leadingAnchor.constraint(equalTo: leadingAnchor),
			gradientView.trailingAnchor.constraint(equalTo: trailingAnchor),
			gradientView.heightAnchor.constraint(equalToConstant: ViewTraits.Gradient.height)
		])
	}
	
	private func setupButtonStackViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			buttonStackView.centerXAnchor.constraint(equalTo: centerXAnchor),
			buttonStackView.leadingAnchor.constraint(
				greaterThanOrEqualTo: safeAreaLayoutGuide.leadingAnchor,
				constant: ViewTraits.Margin.edge
			),
			buttonStackView.trailingAnchor.constraint(
				lessThanOrEqualTo: safeAreaLayoutGuide.trailingAnchor,
				constant: -ViewTraits.Margin.edge
			),
			{
				let constraint = buttonStackView.topAnchor.constraint(
					equalTo: topAnchor,
					constant: ViewTraits.Margin.top
				)
				topButtonConstraint = constraint
				return constraint
			}(),
			{
				let constraint = buttonStackView.bottomAnchor.constraint(
					equalTo: safeAreaLayoutGuide.bottomAnchor,
					constant: -ViewTraits.Margin.edge
				)
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
			C.shadow()!.withAlphaComponent(0.0).cgColor,
			C.shadow()!.withAlphaComponent(0.01).cgColor,
			C.shadow()!.withAlphaComponent(0.03).cgColor,
			C.shadow()!.withAlphaComponent(0.08).cgColor,
			C.shadow()!.withAlphaComponent(0.1).cgColor
		]
		gradientView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
		gradientView.layer.insertSublayer(gradient, at: 0)
	}
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		setupShadowGradient()
	}
	
	/// The user tapped on the primary button
	public var primaryButtonTappedCommand: (() -> Void)?
	
	/// The title for the primary button
	public var primaryTitle: String? {
		didSet {
			primaryButton.title = primaryTitle
		}
	}
	
	/// The top constraint for margin changes
	public var topButtonConstraint: NSLayoutConstraint?
	
	/// The bottom constraint for keyboard changes
	public var bottomButtonConstraint: NSLayoutConstraint?
	
	/// Fade shadow separator.
	/// - Parameter scrollOffset: The scroll offset of the scroll view (animation range: -height to 0).
	public func updateFadeAnimation(from scrollOffset: CGFloat) {
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
