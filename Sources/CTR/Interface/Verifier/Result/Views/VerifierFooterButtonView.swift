/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifierFooterButtonView: BaseView {
	
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
		
		backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
		
		primaryTitle = L.verifierResultNext()
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
			primaryButton.topAnchor.constraint(equalTo: topAnchor),
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
			Theme.colors.viewControllerBackground.withAlphaComponent(0.0).cgColor,
			Theme.colors.viewControllerBackground.withAlphaComponent(0.5).cgColor,
			Theme.colors.viewControllerBackground.withAlphaComponent(1.0).cgColor
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
}
