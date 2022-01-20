/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

final class VerifierScanView: BaseView {
	
	/// The display constants
	private struct ViewTraits {

		static let margin: CGFloat = 20.0
		static let maskSpacing: CGFloat = 50.0
	}
	
	let scanView = ScanView()
	
	var verificationPolicy: VerificationPolicy? {
		get { riskLevelIndicator.verificationPolicy }
		set { riskLevelIndicator.verificationPolicy = newValue }
	}
	
	private let moreInformationButton = Button(style: Button.ButtonType.textLabelBlue)
	
	// A dummy view to move the scrollview below the mask on the overlay
	private let dummyView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	private let scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		return scrollView
	}()
	
	private let riskLevelIndicator = RiskLevelIndicator()
	
	override func setupViews() {
		super.setupViews()
		
		backgroundColor = Theme.colors.viewControllerBackground
		
		moreInformationButton.touchUpInside(self, action: #selector(moreInformationButtonTapped))
	}
	
	override func setupViewHierarchy() {
		super.setupViewHierarchy()
		
		scanView.embed(in: self)
		addSubview(dummyView)
		addSubview(scrollView)
		scrollView.addSubview(moreInformationButton)
		addSubview(riskLevelIndicator)
	}
	
	override func setupViewConstraints() {
		super.setupViewConstraints()
		
		NSLayoutConstraint.activate([
			
			dummyView.topAnchor.constraint(equalTo: scanView.maskLayoutGuide.topAnchor),
			dummyView.leadingAnchor.constraint(equalTo: leadingAnchor),
			dummyView.trailingAnchor.constraint(equalTo: trailingAnchor),
			dummyView.bottomAnchor.constraint(equalTo: scanView.maskLayoutGuide.bottomAnchor, constant: ViewTraits.maskSpacing),
			
			// Risk level button
			riskLevelIndicator.centerXAnchor.constraint(equalTo: scanView.maskLayoutGuide.centerXAnchor),
			riskLevelIndicator.bottomAnchor.constraint(equalTo: scanView.maskLayoutGuide.bottomAnchor, constant: -ViewTraits.margin),

			// ScrollView
			scrollView.topAnchor.constraint(equalTo: dummyView.bottomAnchor),
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
			
			// More information button
			moreInformationButton.topAnchor.constraint(equalTo: scrollView.topAnchor),
			moreInformationButton.leadingAnchor.constraint(
				equalTo: scrollView.leadingAnchor,
				constant: ViewTraits.margin
			),
			moreInformationButton.trailingAnchor.constraint(
				equalTo: scrollView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			moreInformationButton.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),
			moreInformationButton.widthAnchor.constraint(
				lessThanOrEqualTo: scrollView.widthAnchor,
				constant: -2 * ViewTraits.margin
			),
			moreInformationButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
		])
	}
	
	@objc func moreInformationButtonTapped() {

		moreInformationButtonCommand?()
	}
	
	// MARK: - Public Access
	
	/// The message
	var moreInformationButtonText: String? {
		didSet {
			guard let moreInformationButtonText = moreInformationButtonText else {
				moreInformationButton.title = nil
				return
			}

			let attributedTitle = moreInformationButtonText.underline(
				underlined: moreInformationButtonText,
				with: .white
			)
			moreInformationButton.setAttributedTitle(attributedTitle, for: .normal)
		}
	}
	
	var moreInformationButtonCommand: (() -> Void)?
}

final class RiskLevelIndicator: BaseView {
	
	var verificationPolicy: VerificationPolicy? {
		didSet { updateForVerificationPolicy() }
	}
	
	private let indicatorImageView: UIImageView = {
		
		let imageView = UIImageView(image: I.scanner.riskEllipse())
		imageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
		imageView.contentMode = .scaleAspectFit
		
		return imageView
	}()
	
	private let titleLabel = Label(subhead: nil)
	
	init(verificationPolicy: VerificationPolicy? = nil) {
		
		self.verificationPolicy = verificationPolicy
		
		super.init(frame: .zero)
		
		updateForVerificationPolicy()
	}
	
	required init?(coder: NSCoder) {
		
		super.init(coder: coder)
	}
	
	override func layoutSubviews() {
		
		super.layoutSubviews()
	
		layer.cornerRadius = bounds.height / 2
	}
	
	override func setupViews() {
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .white
		
		isAccessibilityElement = true
	}

	override func setupViewHierarchy() {
		HStack(spacing: 8,
			   indicatorImageView,
			   titleLabel)
			.embed(in: self, insets: .leftRight(16) + .topBottom(8))
	}
	
	private func updateForVerificationPolicy() {
		isHidden = false
		
		// TODO: Update mode
		switch verificationPolicy {
			case .policy3G:
				titleLabel.text = L.verifier_scanner_policy_indication_3g()
				accessibilityLabel = L.verifier_scanner_policy_indication_3g()
				indicatorImageView.tintColor = Theme.colors.access
			case .policy2G:
				titleLabel.text = L.verifier_scanner_policy_indication_2g()
				accessibilityLabel = L.verifier_scanner_policy_indication_2g()
				indicatorImageView.tintColor = Theme.colors.primary
			case .policy2GPlus:
				titleLabel.text = L.verifier_scanner_policy_indication_2g_plus()
				accessibilityLabel = L.verifier_scanner_policy_indication_2g_plus()
				indicatorImageView.tintColor = Theme.colors.dark
			case .policy1G:
				titleLabel.text = L.verifier_scanner_policy_indication_2g_plus()
				accessibilityLabel = L.verifier_scanner_policy_indication_2g_plus()
				indicatorImageView.tintColor = Theme.colors.dark
			case .none:
				isHidden = true
		}
	}
}
