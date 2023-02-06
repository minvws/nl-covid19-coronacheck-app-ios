/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

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
	
	private let addCertificateButton: LargeAddCertificateButton = {
		let button = LargeAddCertificateButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	// MARK: - Lifecycle
	
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = C.white()
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()

		addCertificateButton.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		addCertificateButton.embed(
			in: self,
			insets: UIEdgeInsets.all(ViewTraits.margin)
		)
	}

	private func createShadow() {
		guard !ProcessInfo.processInfo.isUnitTesting else { return } // for better snapshot reliability
		
		// Shadow
		layer.shadowColor = C.shadow()?.cgColor
		layer.shadowOpacity = ViewTraits.shadowOpacity
		layer.shadowOffset = .zero
		layer.shadowRadius = ViewTraits.shadowRadius
		// Cache Shadow
		layer.shouldRasterize = true
		layer.rasterizationScale = UIScreen.main.scale
	}
	
	// MARK: - Objc Target-Action callbacks:
	
	@objc
	private func touchUp() {
		tapHandler?()
	}

	// MARK: - Accessors
	
	var title: String? {
		didSet {
			addCertificateButton.title = title
		}
	}
 
	var tapHandler: (() -> Void)?
}

private class LargeAddCertificateButton: UIControl {
	
	/// The display constants
	private enum ViewTraits {
		
		static let margin: CGFloat = 4
		static let spacing: CGFloat = 16
		
		enum Animation {
			static let duration: CGFloat = 0.2
			static let transform: CGFloat = 0.98
		}
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	private let plusImageView: UIImageView = {
		let imageView = UIImageView(image: I.plus())
		imageView.translatesAutoresizingMaskIntoConstraints = false
		imageView.tintColor = C.primaryBlue()
		return imageView
	}()
	
	private let titleLabel: Label = {
		let label = Label(body: nil).multiline()
		label.textAlignment = .center
		label.textColor = C.primaryBlue()
		label.isSelectable = false
		
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

		backgroundColor = C.white()
		
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
			plusImageView.widthAnchor.constraint(equalTo: plusImageView.heightAnchor),
			
			titleLabel.topAnchor.constraint(equalTo: plusImageView.bottomAnchor, constant: ViewTraits.spacing),
			
			titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
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
		accessibilityTraits = .button
	}
	
	// MARK: - Objc Target-Action callbacks:
	
	@objc
	private func touchUp() {
		tapHandler?()
	}

	// MARK: - Accessors
	
	var tapHandler: (() -> Void)?
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				alignment: .center,
				kerning: ViewTraits.Title.kerning,
				textColor: C.primaryBlue()!
			)
			accessibilityLabel = title
		}
	}
}
