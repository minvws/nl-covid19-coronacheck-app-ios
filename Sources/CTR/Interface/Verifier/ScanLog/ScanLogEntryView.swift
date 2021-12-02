/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ScanLogEntryView: BaseView {

	/// The display constants
	private struct ViewTraits {

		enum Risk {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let leadingMargin: CGFloat = 12
			static let trailingMargin: CGFloat = 32
		}

		enum Time {
			static let lineHeight: CGFloat = 18
			static let kerning: CGFloat = -0.24
			static let bottomMargin: CGFloat = 8
		}

		enum Message {
			static let lineHeight: CGFloat = 17
			static let kerning: CGFloat = -0.41
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

	private let containerView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = .orange // Theme.colors.viewControllerBackground
		riskLabel.backgroundColor = .lightGray
		timeLabel.backgroundColor = .yellow
		messageLabel.backgroundColor = .cyan
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(riskLabel)
		addSubview(containerView)

		containerView.addSubview(timeLabel)
		containerView.addSubview(messageLabel)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

//		riskLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//		containerView.setContentHuggingPriority(.defaultLow, for: .horizontal)

		super.setupViewConstraints()
		NSLayoutConstraint.activate([

			// Risk
			riskLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.Risk.leadingMargin
			),
			riskLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

			// Container
			containerView.leadingAnchor.constraint(
				equalTo: riskLabel.trailingAnchor,
				constant: ViewTraits.Risk.trailingMargin
			),
			containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			containerView.topAnchor.constraint(equalTo: topAnchor),
			containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

			// Time
			timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
			timeLabel.leadingAnchor.constraint( equalTo: containerView.leadingAnchor),
			timeLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.Time.bottomMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: riskLabel.trailingAnchor,
				constant: ViewTraits.Risk.trailingMargin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: containerView.trailingAnchor
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: containerView.bottomAnchor
			)
		])
	}

	func setAccessibilityLabel() {
		
		accessibilityLabel = "\(riskLabel.text ?? "") \(timeLabel.text ?? "").\n\(messageLabel.text ?? "")"
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
				kerning: ViewTraits.Time.kerning
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
}
