/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit

final class DCCQRDetailsView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		static let margin: CGFloat = 20.0
		static let spacing: CGFloat = 24
		
		enum Title {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
		}
		enum Description {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Footer {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
	}
	
	/// The title label
	private let titleLabel: Label = {
		let label = Label(title1: nil, montserrat: true).multiline().header()
		label.textColor = C.black()
		return label
	}()
	
	/// The description label
	private let descriptionLabel: Label = {
		let label = Label(subhead: nil).multiline()
		label.textColor = C.black()
		return label
	}()
	
	/// The footer date information label
	private let dateInformationLabel: Label = {
		let label = Label(footnote: nil).multiline()
		label.textColor = C.black()
		return label
	}()
	
	/// The stack view to add all labels to
	private let stackView: UIStackView = {
		
		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.spacing = ViewTraits.spacing
		return view
	}()
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		addSubview(stackView)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		stackView.embed(
			in: safeAreaLayoutGuide,
			insets: .bottom(ViewTraits.margin) + .leftRight(ViewTraits.margin)
		)
	}
	
	override func setupAccessibility() {
		super.setupAccessibility()
		
		NotificationCenter.default.addObserver(forName: UIAccessibility.voiceOverStatusDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
			self?.updateAccessibilityStatus()
		}
		
		NotificationCenter.default.addObserver(forName: UIAccessibility.switchControlStatusDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
			self?.updateAccessibilityStatus()
		}
	}
	
	// MARK: Public Access
	
	/// The title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.Title.lineHeight,
															 kerning: ViewTraits.Title.kerning)
		}
	}
	
	/// The description
	var detailsDescription: String? {
		didSet {
			descriptionLabel.attributedText = detailsDescription?.setLineHeight(ViewTraits.Description.lineHeight,
																				kerning: ViewTraits.Description.kerning)
		}
	}
	
	/// The dcc details
	var details: [(field: String, value: String)]? {
		didSet {
			guard let details = details else { return }
			loadDetails(details)
			updateAccessibilityStatus()
		}
	}
	
	/// The footer date information
	var dateInformation: String? {
		didSet {
			dateInformationLabel.attributedText = dateInformation?.setLineHeight(ViewTraits.Footer.lineHeight,
																				 kerning: ViewTraits.Footer.kerning)
		}
	}
	
	func handleScreenCapture(shouldHide: Bool) {
		stackView.isHidden = shouldHide
	}
}

private extension DCCQRDetailsView {
	
	func loadDetails(_ details: [(field: String, value: String)]) {
		
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(descriptionLabel)
		
		details.forEach { detail in
			
			let labelView = DCCQRLabelView()
			labelView.field = detail.field
			labelView.value = detail.value
			stackView.addArrangedSubview(labelView)
		}
		
		stackView.addArrangedSubview(dateInformationLabel)
	}
	
	func updateAccessibilityStatus() {
		
		titleLabel.setupForVoiceAndSwitchControlAccessibility()
		descriptionLabel.setupForVoiceAndSwitchControlAccessibility()
		dateInformationLabel.setupForVoiceAndSwitchControlAccessibility()
		
		stackView.subviews.forEach { view in
			guard let labelView = view as? DCCQRLabelView,
				  let field = labelView.field,
				  let value = labelView.value else { return }
			
			if UIAccessibility.isVoiceOverRunning || CommandLine.arguments.contains("-showAccessibilityLabels") {
				// Show labels for VoiceOver
				labelView.accessibilityLabel = [field, value].joined(separator: ",")
			} else {
				// Hide labels for VoiceControl
				labelView.accessibilityLabel = nil
			}
			
			// Disabled as interactive element for SwitchControl
			labelView.isAccessibilityElement = !UIAccessibility.isSwitchControlRunning
			
			labelView.updateAccessibilityStatus()
		}
	}
}
