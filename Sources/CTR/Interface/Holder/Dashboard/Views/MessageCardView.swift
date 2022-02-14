/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class MessageCardView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let cornerRadius: CGFloat = 15
		static let shadowRadius: CGFloat = 10
		static let shadowOpacity: Float = 0.15
		static let closeButtonSize: CGFloat = 16
        
		// Margins
		static let margin: CGFloat = 24
        static let verticalPadding: CGFloat = 8
        static let closeButtonTopMargin: CGFloat = 28

		// Label
		static let lineHeight: CGFloat = 22
		static let kerning: CGFloat = -0.41
	}
    
	struct Config {
		
		var title: String
		var accessibilityIdentifier: String?
		var closeButtonCommand: (() -> Void)?
		var ctaButton: ((title: String, command: () -> Void))?
	}
    
    private let config: Config
    private let closeButtonTappedCommand: (() -> Void)?
    private let callToActionButtonTappedCommand: (() -> Void)?
    
	required init(config: Config) {
		self.config = config
		titleLabel.attributedText = config.title.setLineHeight(ViewTraits.lineHeight, kerning: ViewTraits.kerning)
		titleLabel.accessibilityIdentifier = config.accessibilityIdentifier
		
		closeButtonTappedCommand = config.closeButtonCommand
		
		callToActionButton.title = config.ctaButton?.title
		callToActionButtonTappedCommand = config.ctaButton?.command
		
		super.init(frame: .zero)
	}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The title label (- within `messageWithCloseButtonStackView`)
	private let titleLabel: Label = {
        let titleLabel = Label(body: nil).multiline().header()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
	}()

	/// The close button (- within `messageWithCloseButtonStackView`)
	private let closeButton: TappableButton = {

		let button = TappableButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.bannerCross(), for: .normal)
		button.contentHorizontalAlignment = .center
		button.accessibilityLabel = L.generalClose()
		return button
	}()

	/// The callToAction button (-within `callToActionButtonStackView`)
	private let callToActionButton: Button = {

		let button = Button(title: "CTA", style: Button.ButtonType.textLabelBlue)
		button.translatesAutoresizingMaskIntoConstraints = false
		button.contentHorizontalAlignment = .leading
		return button
	}()
    
	/// Setup all the views
	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .white
		layer.cornerRadius = ViewTraits.cornerRadius
		createShadow()

		closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
		callToActionButton.addTarget(self, action: #selector(callToActionButtonTapped), for: .touchUpInside)
	}

	/// Create the shadow around the view
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

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
        
        addSubview(titleLabel)
        
        if nil != config.closeButtonCommand {
            addSubview(closeButton)
        }
        if nil != config.ctaButton {
            addSubview(callToActionButton)
        }
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

        var constraints = [NSLayoutConstraint]()
        
        constraints += [titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.margin)]
        constraints += [titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin)]
        
        if nil != config.closeButtonCommand {
            constraints += [closeButton.topAnchor.constraint(equalTo: topAnchor, constant: ViewTraits.closeButtonTopMargin)]
            constraints += [closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin)]
            constraints += [closeButton.heightAnchor.constraint(equalToConstant: ViewTraits.closeButtonSize)]
            constraints += [closeButton.widthAnchor.constraint(equalToConstant: ViewTraits.closeButtonSize)]
            
            constraints += [titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -ViewTraits.verticalPadding)]
        } else {
            constraints += [titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin)]
        }
        
        if nil != config.ctaButton {
            constraints += [callToActionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: ViewTraits.margin)]
            constraints += [callToActionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -ViewTraits.margin)]
            constraints += [callToActionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: ViewTraits.verticalPadding)]
            constraints += [callToActionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
            
        } else {
            constraints += [titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ViewTraits.margin)]
        }
        
        NSLayoutConstraint.activate(constraints)
	}

    // MARK: - Objc Target-Action callbacks:
    
	/// User tapped on the close button
	@objc func closeButtonTapped() {

		closeButtonTappedCommand?()
	}

	/// User tapped on the callToAction button
	@objc func callToActionButtonTapped() {

		callToActionButtonTappedCommand?()
	}
}
