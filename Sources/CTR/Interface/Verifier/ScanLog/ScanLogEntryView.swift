/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews

class ScanLogEntryView: BaseView {

	/// The display constants
	private struct ViewTraits {

		enum Risk {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
		}

		enum Time {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
		}

		enum Message {
			static let lineHeight: CGFloat = 17
			static let kerning: CGFloat = -0.41
		}

		enum StackView {
			static let spacing: CGFloat = 8
			static let horizontalSpacing: CGFloat = 32
			static let leadingMargin: CGFloat = 12
		}
	}

	/// The title label
	private let riskLabel: Label = {
		
		return Label(bodyBold: nil).multiline()
	}()
	
	/// The time text
	private let timeLabel: Label = {
		
		return Label(subhead: nil).multiline()
	}()

	/// The message  label
	private let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	private let errorView: ErrorView = {

		let view = ErrorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
	}()

	let horizontalStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .horizontal
		view.alignment = .center
		view.distribution = .fill
		view.spacing = ViewTraits.StackView.horizontalSpacing
		return view
	}()

	let verticalStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.StackView.spacing
		return view
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = C.white()

		// Make the riskLabel hug the "3G" text
		riskLabel.setContentHuggingPriority(.required, for: .horizontal)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		horizontalStackView.embed(
			in: self,
			insets: UIEdgeInsets(top: 0, left: ViewTraits.StackView.leadingMargin, bottom: 0, right: 0)
		)

		horizontalStackView.addArrangedSubview(riskLabel)
		horizontalStackView.setCustomSpacing(ViewTraits.StackView.horizontalSpacing, after: riskLabel)
		horizontalStackView.addArrangedSubview(verticalStackView)

		verticalStackView.addArrangedSubview(timeLabel)
		verticalStackView.addArrangedSubview(errorView)
		verticalStackView.addArrangedSubview(messageLabel)
	}

	func setAccessibilityLabel() {
		
		accessibilityLabel = "\(riskLabel.text ?? "").\n \(timeLabel.text ?? "").\n \(error ?? "") \n\(messageLabel.text ?? "")"
	}

	override func setupAccessibility() {

		super.setupAccessibility()

		riskLabel.isAccessibilityElement = false
		timeLabel.isAccessibilityElement = false
		errorView.isAccessibilityElement = false
		messageLabel.isAccessibilityElement = false
		isAccessibilityElement = true
	}

	// MARK: Public Access

	/// The risk
	var risk: String? {
		didSet {
			riskLabel.attributedText = risk?.setLineHeight(
				ViewTraits.Risk.lineHeight,
				kerning: ViewTraits.Risk.kerning
			)
			setAccessibilityLabel()
		}
	}

	/// The message
	var time: String? {
		didSet {
			timeLabel.attributedText = time?.setLineHeight(
				ViewTraits.Time.lineHeight,
				kerning: ViewTraits.Time.kerning,
				textColor: C.secondaryText()!
			)
			setAccessibilityLabel()
		}
	}

	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(
				ViewTraits.Message.lineHeight,
				kerning: ViewTraits.Message.kerning
			)
			setAccessibilityLabel()
		}
	}

	var error: String? {
		didSet {
			errorView.error = error
			errorView.isHidden = error == nil
			setAccessibilityLabel()
		}
	}
}
