/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Lottie
import Shared
import ReusableViews
import Resources

class ScanInstructionsItemView: ScrolledStackView {
	
	/// The display constants
	private struct ViewTraits {
		
		// Dimensions
		static let titleLineHeight: CGFloat = 32
		static let titleKerning: CGFloat = -0.26
		static let imageHeightPercentage: CGFloat = 0.5
		static let stepSubheadingLineHeight: CGFloat = 22
		static let stepSubheadingKerning: CGFloat = -0.41
		
		// Margins
		static let spacing: CGFloat = 24
		static let marginBeneathImage: CGFloat = 18
	}
	
	private let animationView: LottieAnimationView = {
		
		let view = LottieAnimationView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.contentMode = .scaleAspectFit
		view.respectAnimationFrameRate = true
		view.backgroundBehavior = .pauseAndRestore
		view.loopMode = .loop
		return view
	}()

	private let bottomStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .leading
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// "Step 2" etc, above the title.
	private let stepSubheadingLabel: Label = {
		let label = Label("", font: Fonts.bodySemiBold, textColor: C.primaryBlue()!)
		label.translatesAutoresizingMaskIntoConstraints = false
		return label
	}()

	private let titleLabel: Label = {
		
		return Label(title1: nil, montserrat: true).multiline().header()
	}()
	
	let messageTextView: TextView = {
		
		return TextView()
	}()
	
	override func setupViews() {
		
		super.setupViews()
		backgroundColor = C.white()
		
		// Align animation view to top
		stackViewInset.top = 0
	}
	
	override func setupViewHierarchy() {
		
		super.setupViewHierarchy()

		bottomStackView.addArrangedSubview(stepSubheadingLabel)
		bottomStackView.setCustomSpacing(8, after: stepSubheadingLabel)
		bottomStackView.addArrangedSubview(titleLabel)
		bottomStackView.addArrangedSubview(messageTextView)

		stackView.addArrangedSubview(animationView)
		stackView.setCustomSpacing(ViewTraits.marginBeneathImage, after: animationView)
		stackView.addArrangedSubview(bottomStackView)
	}

	override func setupViewConstraints() {
		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			animationView.heightAnchor.constraint(
				lessThanOrEqualTo: heightAnchor,
				multiplier: ViewTraits.imageHeightPercentage
			)
		])
	}

	// MARK: Public Access

	var stepSubheading: String? {
		didSet {
			stepSubheadingLabel.attributedText = stepSubheading?.setLineHeight(ViewTraits.stepSubheadingLineHeight,
																			   kerning: ViewTraits.stepSubheadingKerning,
																			   textColor: C.primaryBlue()!)
		}
	}

	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(
				ViewTraits.titleLineHeight,
				kerning: ViewTraits.titleKerning
			)
		}
	}
	
	var message: String? {
		didSet {
			NSAttributedString.makeFromHtml(text: message, style: .bodyDark) {
				self.messageTextView.attributedText = $0
			}
		}
	}
	
	var animationName: String? {
		didSet {
			guard let animationName = animationName else { return }
			animationView.animation = LottieAnimation.named("Animations/" + animationName, bundle: Resources.R.bundle)
		}
	}

	func hideImage() {

		animationView.isHidden = true
	}

	func showImage() {

		animationView.isHidden = false
	}
	
	/// Play the animation
	func play() {
		
		animationView.play()
	}
	
	/// Resets animation to start frame in case it appears again
	func reset() {
		
		animationView.currentProgress = 0
	}
}
