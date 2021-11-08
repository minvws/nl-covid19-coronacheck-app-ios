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
		static let buttonSize: CGFloat = 20
		static let imageWidth: CGFloat = 30
		static let imageHeight: CGFloat = 32

		// Margins
		static let margin: CGFloat = 24.0
		
		// Label
		static let lineHeight: CGFloat = 22
		static let kerning: CGFloat = -0.41
	}
    
    struct Config {
        
        var title: String
        var closeButtonCommand: (() -> Void)?
        var ctaButton: ((title: String, command: () -> Void))?
    }
    
    private let config: Config
    private let closeButtonTappedCommand: (() -> Void)?
    private let callToActionButtonTappedCommand: (() -> Void)?
    
    required init(config: Config) {
        self.config = config
        titleLabel.attributedText = config.title.setLineHeight(ViewTraits.lineHeight, kerning: ViewTraits.kerning)
        
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
        
        constraints += [titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 24)]
        constraints += [titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)]
        
        if nil != config.closeButtonCommand {
            constraints += [closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 27)]
            constraints += [closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)]
            constraints += [closeButton.heightAnchor.constraint(equalToConstant: 16)]
            constraints += [closeButton.widthAnchor.constraint(equalToConstant: 16)]
            
            constraints += [titleLabel.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -8)]
        } else {
            constraints += [titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -24)]
        }
        
        if nil != config.ctaButton {
            constraints += [callToActionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 24)]
            constraints += [callToActionButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24)]
            constraints += [callToActionButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8)]
            constraints += [callToActionButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)]
            
        } else {
            constraints += [titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)]
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
