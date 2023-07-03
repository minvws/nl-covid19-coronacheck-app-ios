/*
 *  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import UIKit
import Shared
import ReusableViews
import Resources

class IdentityControlView: BaseView {
	
	/// The display constants
	private enum ViewTraits {
		
		enum StackView {
			static let spacing: CGFloat = 8
			static let insets = UIEdgeInsets(top: 24, left: 68, bottom: 24, right: 0)
		}
		enum Size {
			static let separatorHeight: CGFloat = 1
		}
		enum Title {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}
		enum Content {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}
	}
	
	private let selectionButton: UIButton = {
		
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(I.radioButton24.normal(), for: .normal)
		button.setImage(I.radioButton24.selected(), for: .selected)
		button.isSelected = false
		return button
	}()
	
	private let selectionAdditionalButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()
	
	private let stackView: UIStackView = {
		
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.axis = .vertical
		stackView.spacing = ViewTraits.StackView.spacing
		return stackView
	}()
	
	private let titleLabel: Label = {
		
		return Label(bodyMedium: nil).header().multiline()
	}()
	
	private let contentLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()
	
	private let actionButton: Button = {
		
		return Button(style: .textLabelBlue)
	}()
	
	private let warningLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()
	
	private let separatorView: UIView = {
		
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = C.grey4()
		return view
	}()
	
	override func setupViews() {
		
		super.setupViews()
		
		backgroundColor = C.white()
		
		actionButton.touchUpInside(self, action: #selector(actionButtonTapped))
		actionButton.contentHorizontalAlignment = .leading
		
		selectionButton.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
		selectionAdditionalButton.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
		
		stackView.embed(in: self, insets: ViewTraits.StackView.insets)
		
		stackView.addGestureRecognizer(
			UITapGestureRecognizer(
				target: self,
				action: #selector(selectionButtonTapped)
			)
		)
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()
		
		addSubview(selectionButton)
		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(contentLabel)
		stackView.addArrangedSubview(actionButton)
		stackView.addArrangedSubview(warningLabel)
		addSubview(separatorView)
		addSubview(selectionAdditionalButton)
		
		bringSubviewToFront(stackView)
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		setupSelectionButtonViewConstraints()
		setupSeparatorViewConstraints()
	}
	
	private func setupSelectionButtonViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			selectionButton.leadingAnchor.constraint(equalTo: leadingAnchor),
			selectionButton.topAnchor.constraint(equalTo: topAnchor),
			selectionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
			selectionButton.trailingAnchor.constraint(equalTo: stackView.leadingAnchor),
			
			selectionAdditionalButton.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
			selectionAdditionalButton.topAnchor.constraint(equalTo: topAnchor),
			selectionAdditionalButton.bottomAnchor.constraint(equalTo: bottomAnchor),
			selectionAdditionalButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor)
		])
	}
	
	private func setupSeparatorViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			separatorView.leadingAnchor.constraint(equalTo: leadingAnchor),
			separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
			separatorView.topAnchor.constraint(
				equalTo: bottomAnchor,
				constant: -ViewTraits.Size.separatorHeight
			),
			separatorView.heightAnchor.constraint(equalToConstant: ViewTraits.Size.separatorHeight)
		])
	}
	
	override func setupAccessibility() {
		
		super.setupAccessibility()
		self.accessibilityElements = [titleLabel, contentLabel, warningLabel, actionButton, selectionButton]
	}
	
	@objc private func actionButtonTapped() {
		
		actionButtonCommand?()
	}
	
	@objc private func selectionButtonTapped() {
		
		selectionButtonCommand?()
	}
	
	private func resetSelectionButton() {
		
		selectionButton.setImage(I.radioButton24.normal(), for: .normal)
		selectionButton.setImage(I.radioButton24.selected(), for: .selected)
	}
	
	// MARK: Public Access
	
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.Title.lineHeight,
				kerning: ViewTraits.Title.kerning,
				textColor: C.black()!
			)
			if let title {
				actionButton.accessibilityLabel = L.holder_identitySelection_accessibility_details(title)
				selectionButton.accessibilityLabel = L.holder_identitySelection_accessibility_select(title)
			}
		}
	}
	
	var content: String? {
		didSet {
			contentLabel.attributedText = content?.setLineHeight(
				ViewTraits.Content.lineHeight,
				kerning: ViewTraits.Content.kerning,
				textColor: C.secondaryText()!
			)
		}
	}
	
	var warning: String? {
		didSet {
			warningLabel.attributedText = warning?.setLineHeight(
				ViewTraits.Content.lineHeight,
				kerning: ViewTraits.Content.kerning,
				textColor: C.ccError()!
			)
		}
	}
	
	var actionButtonTitle: String? {
		didSet {
			actionButton.title = actionButtonTitle
		}
	}
	
	var actionButtonCommand: (() -> Void)?
	
	var selectionButtonCommand: (() -> Void)?
	
	var state: IdentityControlViewState = .unselected {
		
		didSet {
			
			switch state {
				case .selected:
					
					warning = nil
					resetSelectionButton()
					selectionButton.isSelected = true
					stackView.setCustomSpacing(0, after: actionButton)
					
				case .unselected:
					
					warning = nil
					resetSelectionButton()
					selectionButton.isSelected = false
					stackView.setCustomSpacing(0, after: actionButton)
					
				case .selectionError:
					
					warning = nil
					selectionButton.isSelected = false
					selectionButton.setImage(I.radioButton24.error(), for: .normal)
					stackView.setCustomSpacing(0, after: actionButton)
					
				case let .warning(warningMessage):
					
					warning = warningMessage
					resetSelectionButton()
					selectionButton.isSelected = false
					stackView.setCustomSpacing(ViewTraits.StackView.spacing, after: actionButton)
			}
		}
	}
}
