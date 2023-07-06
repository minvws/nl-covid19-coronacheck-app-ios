/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import CoronaCheckUI

final class ImportView: BaseView, HasScanView {
	
	/// The display constants
	private struct ViewTraits {

		// Margins
		static let margin: CGFloat = 20.0

		enum Step {
			static let lineHeight: CGFloat = 22
			static let kerning: CGFloat = -0.41
			static let bottomMargin: CGFloat = 8.0
		}
		enum Header {
			static let lineHeight: CGFloat = 32
			static let kerning: CGFloat = -0.26
			static let bottomMargin: CGFloat = 24.0
		}
		enum Progress {
			static let cornerRadius: CGFloat = 6
			static let height: CGFloat = 12
		}
	}
	
	private let stepLabel: Label = {

		return Label(bodySemiBold: nil)
	}()
	
	/// The title label
	private let headerLabel: Label = {

		return Label(title1: nil, montserrat: true).multiline()
	}()
	
	/// The title label
	private let messageLabel: TextView = {
		
		return TextView()
	}()
	
	private let progressView: UIProgressView = {

		let view = UIProgressView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.progressViewStyle = .default
		view.trackTintColor = C.grey2()
		view.progressTintColor = .white
		view.layer.cornerRadius = ViewTraits.Progress.cornerRadius
		view.clipsToBounds = true
		return view
	}()
	
	let scanView = ScanView()

	let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.accessibilityIdentifier = "scrollViewA"
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	override func setupViews() {
		super.setupViews()
		scanView.accessibilityIdentifier = "scanView"
		backgroundColor = C.black()
		progressView.backgroundColor = .red
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		scanView.embed(in: self)
		addSubview(scrollView)
		scrollView.addSubview(stepLabel)
		scrollView.addSubview(headerLabel)
		scrollView.addSubview(messageLabel)
		scrollView.addSubview(progressView)
	}
	
	override func setupViewConstraints() {
		
		super.setupViewConstraints()
		setupScrollViewConstraints()
		setupStepLabelViewConstraints()
		setupHeaderLabelViewConstraints()
		setupMessageLabelViewConstraints()
		setupProgressViewViewConstraints()
	}
	
	func setupScrollViewConstraints() {
		
		NSLayoutConstraint.activate([
			// ScrollView
			scrollView.topAnchor.constraint(lessThanOrEqualTo: scanView.maskLayoutGuide.bottomAnchor, constant: 40),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
		])
	}
	
	func setupStepLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			// Step
			stepLabel.topAnchor.constraint(equalTo: scrollView.topAnchor),
			stepLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.margin
			),
			stepLabel.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			// Extra constraints to make the message scrollable
			stepLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.margin
			),
			stepLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])
	}
	
	func setupHeaderLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			// Header
			headerLabel.topAnchor.constraint(
				equalTo: stepLabel.bottomAnchor,
				constant: ViewTraits.Step.bottomMargin
			),
			headerLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.margin
			),
			headerLabel.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			// Extra constraints to make the message scrollable
			headerLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.margin
			),
			headerLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])
	}

	func setupMessageLabelViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			// Message
			messageLabel.topAnchor.constraint(
				equalTo: headerLabel.bottomAnchor,
				constant: ViewTraits.Header.bottomMargin
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			// Extra constraints to make the message scrollable
			messageLabel.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.margin
			),
			messageLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])
	}
	
	func setupProgressViewViewConstraints() {
		
		NSLayoutConstraint.activate([
			
			// Message
			progressView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.Header.bottomMargin
			),
			progressView.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.margin
			),
			progressView.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			// Extra constraints to make the message scrollable
			progressView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.margin
			),
			progressView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),
			progressView.heightAnchor.constraint(equalToConstant: ViewTraits.Progress.height),
			progressView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])
	}
	
	// MARK: - Public Access
	
	var step: String? {
		didSet {
			stepLabel.attributedText = step?.setLineHeight(
				ViewTraits.Step.lineHeight,
				kerning: ViewTraits.Step.kerning,
				textColor: .white
			)
		}
	}
	
	var header: String? {
		didSet {
			headerLabel.attributedText = header?.setLineHeight(
				ViewTraits.Header.lineHeight,
				kerning: ViewTraits.Header.kerning,
				textColor: .white
			)
		}
	}
	
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(
				text: message,
				style: NSAttributedString.HTMLStyle(font: Fonts.body, textColor: .white)
			) {
				self.messageLabel.attributedText = $0
			}
		}
	}
	
	var progress: Float? {
		didSet {
			guard let progress, progress > 0 else {
				progressView.isHidden = true
				return
			}
			progressView.isHidden = false
			progressView.progress = progress
		}
	}
}
