/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class AddCertificateCardView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 10
		static let shadowOpacity: Float = 0.15
		
		// Margins
		static let margin: CGFloat = 24
	}
	
	private var addButtonTappedCommand: (() -> Void)?
	
	private let addCertificateButton: LargeAddCertificateButton = {
		let button = LargeAddCertificateButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()

		addCertificateButton.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
	}

	func createShadow() {

		// Shadow
		layer.shadowColor = Theme.colors.shadow.cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		
		addSubview(addCertificateButton)
	}

	override func setupViewConstraints() {

		super.setupViewConstraints()

		var constraints = [NSLayoutConstraint]()
		constraints += [addCertificateButton.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin)]
		constraints += [addCertificateButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin)]
		constraints += [addCertificateButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin)]
		constraints += [addCertificateButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
		NSLayoutConstraint.activate(constraints)
	}

	var title: String? {
		didSet {
			addCertificateButton.title = title
		}
	}

	// MARK: - Objc Target-Action callbacks:
	
	@objc
	private func touchUp() {
		tapHandler?()
	}
	
	var tapHandler: (() -> Void)?
}

private class LargeAddCertificateButton: UIControl {
	
	/// The display constants
	private enum ViewTraits {
		
		static let margin: CGFloat = 4
		static let spacing: CGFloat = 16

		enum Colors {
			static let highlighted = UIColor(white: 0.98, alpha: 1)
		}
		enum Animation {
			static let duration: CGFloat = 0.2
			static let transform: CGFloat = 0.98
		}
	}
	
	private let plusImageView: UIImageView = {
		let imageView = UIImageView(image: I.plus())
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.tintColor = Theme.colors.primary
		return imageView
	}()
	
	private let titleLabel: Label = {
		let label = Label(body: nil).multiline()
		label.textAlignment = .center
		label.textColor = Theme.colors.primary
		
		return label
	}()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		setupViews()
		setupViewHierarchy()
		setupViewConstraints()
		setupAccessibility()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// Setup all the views
	private func setupViews() {

		backgroundColor = Theme.colors.viewControllerBackground
		
		addTarget(self, action: #selector(touchUp), for: .touchUpInside)
		addTarget(self, action: #selector(touchUpAnimation), for: [.touchDragExit, .touchCancel, .touchUpInside])
		addTarget(self, action: #selector(touchDownAnimation), for: .touchDown)
	}

	/// Setup the view hierarchy
	private func setupViewHierarchy() {

		addSubview(plusImageView)
		addSubview(titleLabel)
	}

	/// Setup all the constraints
	private func setupViewConstraints() {

		NSLayoutConstraint.activate([
			
			plusImageView.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin),
			plusImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
			
			titleLabel.topAnchor.constraint(equalTo: plusImageView.bottomAnchor, constant: ViewTraits.spacing),
			
			titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
			titleLabel.rightAnchor.constraint(equalTo: rightAnchor),
			titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)
		])
	}
	
	@objc private func touchDownAnimation() {
		Haptic.light()

		UIButton.animate(withDuration: ViewTraits.Animation.duration, animations: {
			self.transform = CGAffineTransform(scaleX: ViewTraits.Animation.transform, y: ViewTraits.Animation.transform)
		})
	}

	@objc private func touchUpAnimation() {
		UIButton.animate(withDuration: ViewTraits.Animation.duration, animations: {
			self.transform = CGAffineTransform.identity
		})
	}
	
	/// Setup all the accessibility traits
	private func setupAccessibility() {

		isAccessibilityElement = true
	}
	
	@objc
	private func touchUp() {
		tapHandler?()
	}
	
	var tapHandler: (() -> Void)?
	
	var title: String? {
		didSet {
			titleLabel.text = title
			accessibilityLabel = title
		}
	}
}
