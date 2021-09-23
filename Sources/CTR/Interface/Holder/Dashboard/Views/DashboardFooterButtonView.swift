/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class DashboardFooterButtonView: BaseView {
	
	/// The display constants
	private struct ViewTraits {

		enum Button {
			static let height: CGFloat = 52
			static let width: CGFloat = 253.0
		}
		enum Gradient {
			static let height: CGFloat = 15.0
		}
		enum Margin {
			static let edge: CGFloat = 20.0
		}
	}

	/// The footer gradient
	private let gradientView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
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
		
		backgroundColor = .clear
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the view hierarchy
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(gradientView)
		addSubview(primaryButton)
	}

	/// Setup all the constraints
	override  func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			gradientView.bottomAnchor.constraint(equalTo: topAnchor),
			gradientView.leftAnchor.constraint(equalTo: leftAnchor),
			gradientView.rightAnchor.constraint(equalTo: rightAnchor),
			gradientView.heightAnchor.constraint(equalToConstant: ViewTraits.Gradient.height),
			
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.Button.width),
			primaryButton.heightAnchor.constraint(greaterThanOrEqualToConstant: ViewTraits.Button.height),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: ViewTraits.Margin.edge),
			primaryButton.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -ViewTraits.Margin.edge),
			primaryButton.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.Margin.edge),
			primaryButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -ViewTraits.Margin.edge)
		])
	}
	
	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}
	
	/// Setup the gradient in the footer
	private func setFooterGradient() {

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
		setFooterGradient()
	}
	
	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
	
	/// The title for the primary button
	var primaryTitle: String? {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}
	
	func updateFadeAnimation(from scrollOffset: CGFloat) {
		let maxRange: CGFloat = ViewTraits.Gradient.height
		let distance = abs(clampScrollOffset(from: scrollOffset, maxRange: maxRange))
		
		gradientView.alpha = calculateReverseFade(maxRange: maxRange, currentPosition: distance, startPercentage: 0, stopPercentage: 1)
	}
	
	func calculateReverseFade(maxRange: CGFloat, currentPosition: CGFloat, startPercentage: CGFloat, stopPercentage: CGFloat) -> CGFloat {
		let percentage: CGFloat = currentPosition / maxRange
		let fadePercentage: CGFloat = (percentage - startPercentage) / abs(startPercentage - stopPercentage)
		return 1 - max(0, min(1, fadePercentage))
	}
	
	func clampScrollOffset(from scrollOffset: CGFloat, maxRange: CGFloat) -> CGFloat {
		let startingOffset: CGFloat = -ViewTraits.Gradient.height
		return max(-maxRange, min(startingOffset - scrollOffset, 0))
	}
}
