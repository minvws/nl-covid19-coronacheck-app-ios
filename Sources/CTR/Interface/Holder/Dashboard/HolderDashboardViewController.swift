/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared
import ReusableViews
import Models
import Resources

class HolderDashboardViewController: GenericViewController<HolderDashboardView, HolderDashboardViewModelType> {
	
	enum Card {
		
		struct Error {
			let message: String
			let didTapURL: (URL) -> Void
		}
		
		case headerMessage(message: String, buttonTitle: String?)
		case emptyStateDescription(message: String, buttonTitle: String?)
		case emptyStatePlaceholderImage(image: UIImage, title: String)
		case addCertificate(title: String, didTapAdd: () -> Void)
		
		// Warnings:
		case expiredQR(message: String, didTapClose: () -> Void)
		case deviceHasClockDeviation(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
		case configAlmostOutOfDate(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
		case eventsWereRemoved(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void, didTapClose: () -> Void)
		
		// QR Cards:
		case europeanUnionQR(title: String, stackSize: Int, validityTexts: (Date) -> [ValidityText], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?, error: Card.Error?)
		
		// Recommendations
		case exportReminder(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
		case recommendedUpdate(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
		
		// Disclosure Policy
		case disclosurePolicyInformation(title: String, buttonText: String, accessibilityIdentifier: String, didTapCallToAction: () -> Void, didTapClose: () -> Void)
	}

	struct ValidityText: Equatable {
		enum Kind: Equatable {
			case past

			// An future-valid origin row can indicate that it would like the "automatically becomes valid"
			// footer to be shown. But if the card as-a-whole is already valid, then this will be ignored.
			case future(desiresToShowAutomaticallyBecomesValidFooter: Bool)
			case current
		}

		let lines: [String]
		let kind: Kind
	}

	private var didSetInitialStartingTabOnSceneView = false
	private var currentlyPresentedAlertDisposable: Observable<AlertContent?>.Disposable?
	
	override func viewDidLoad() {

		super.viewDidLoad()
		
		setupBindings()
		
		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.addCertificateFooterTapped()
		}
		
		sceneView.tapMenuButtonHandler = { [weak self] in
			self?.viewModel.userTappedMenuButton()
		}
		
		navigationController?.setNavigationBarHidden(false, animated: false)
		
		// Forces VoiceOver focus on menu button instead of tab bar on start up
		UIAccessibility.post(notification: .screenChanged, argument: navigationItem.leftBarButtonItem)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		navigationController?.navigationBar.isHidden = true
		viewModel.viewWillAppear()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
		
		currentlyPresentedAlertDisposable = viewModel.currentlyPresentedAlert.observeReturningDisposable { [weak self] alertContent in
			guard let alertContent else { return }
			self?.showAlert(alertContent)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		navigationController?.navigationBar.isHidden = false
		
		currentlyPresentedAlertDisposable = nil
		
		// As the screen animates out, fade out the (fake) navigation bar,
		// as an approximation of the animation that occurs with UINavigationBar.
		transitionCoordinator?.animate(alongsideTransition: { _ in
			self.sceneView.fakeNavigationBarAlpha = 0
		}, completion: { _ in
			self.sceneView.fakeNavigationBarAlpha = 1
		})
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		guard !didSetInitialStartingTabOnSceneView else { return }
		didSetInitialStartingTabOnSceneView = true
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate { _ in }
	}
	
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
	
		if #available(iOS 13.0, *),
			traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
			
			setup(cards: viewModel.internationalCards.value, with: sceneView.internationalScrollView.stackView)
		}
	}

	// MARK: - Setup
	
	private func setupBindings() {

		viewModel.title.observe { [weak self] in self?.sceneView.fakeNavigationTitle = $0 }
		
		viewModel.internationalCards.observe { [sceneView, weak self] cards in
			performUIUpdate {
				self?.setup(cards: cards, with: sceneView.internationalScrollView.stackView)
			}
		}
		
		viewModel.primaryButtonTitle.observe { [weak self] in self?.sceneView.footerButtonView.primaryButton.title = $0 }
		viewModel.shouldShowAddCertificateFooter.observe { [weak self] in self?.sceneView.shouldDisplayButtonView = $0 }
	}

	private func setup(cards: [HolderDashboardViewController.Card], with stackView: UIStackView) {
		let cardViews = cards.compactMap { card in
			card.makeView(openURLHandler: { [weak viewModel] url in viewModel?.openUrl(url) })
		}
		
		stackView.removeArrangedSubviews()
		
		cardViews.forEach {
			stackView.addArrangedSubview($0)
		}

		UIAccessibility.post(notification: .layoutChanged, argument: view)
	}
}

private extension HolderDashboardViewController.Card {
	
	func makeView(openURLHandler: @escaping (URL) -> Void) -> UIView {
		
		switch self {
			case let .headerMessage(message, buttonTitle):
				return HeaderMessageCardView.make(message: message, buttonTitle: buttonTitle, openURLHandler: openURLHandler)
				
			case let .addCertificate(title, didTapAdd):
				let card = AddCertificateCardView()
				card.title = title
				card.tapHandler = didTapAdd
				return card
			
			// Message Cards with only a message + close button
			case let .expiredQR(message, didTapCloseAction):
				return MessageCardView(config: .init(title: message, closeButtonCommand: didTapCloseAction, ctaButton: nil))

			// Message Cards with a message + CTA button
			case let .deviceHasClockDeviation(message, callToActionButtonText, didTapCallToAction),
				let .configAlmostOutOfDate(message, callToActionButtonText, didTapCallToAction),
				let .recommendedUpdate(message, callToActionButtonText, didTapCallToAction):
				
				return MessageCardView(config: .init(
					title: message,
					closeButtonCommand: nil,
					ctaButton: (title: callToActionButtonText, command: didTapCallToAction)
				))
				
			case let .exportReminder(message, callToActionButtonText, didTapCallToAction):
				return BlueMessageCardView(config: .init(
					title: message,
					closeButtonCommand: nil,
					ctaButton: (title: callToActionButtonText, command: didTapCallToAction)
				))
				
			// Message Cards with a message + CTA button + close button
			case let .eventsWereRemoved(message, callToActionButtonText, didTapCallToAction, didTapCloseAction):
				
				return MessageCardView(config: .init(
					title: message,
					closeButtonCommand: didTapCloseAction,
					ctaButton: (title: callToActionButtonText, command: didTapCallToAction)
				))
				
			case let .disclosurePolicyInformation(message, callToActionButtonText, accessibilityIdentifier, didTapCallToAction, didTapCloseAction):
				return MessageCardView(config: .init(
					title: message,
					accessibilityIdentifier: accessibilityIdentifier,
					closeButtonCommand: didTapCloseAction,
					ctaButton: (title: callToActionButtonText, command: didTapCallToAction)
				))
								
			case let .emptyStateDescription(message, buttonTitle):
				return EmptyDashboardDescriptionCardView.make(message: message, buttonTitle: buttonTitle, openURLHandler: openURLHandler)

			case let .emptyStatePlaceholderImage(image, title):
				let view = EmptyDashboardImagePlaceholderCardView()
				view.title = title
				view.image = image
				return view
			
			case let .europeanUnionQR(title, stackSize, validityTexts, isLoading, didTapViewQR, buttonEnabledEvaluator, expiryCountdownEvaluator, cardError):
			
				let qrCard = QRCardView(stackSize: stackSize)
				qrCard.viewQRButtonTitle = stackSize == 1 ? L.holderDashboardQrButtonViewQR() : L.holderDashboardQrButtonViewQRs()
				qrCard.viewQRButtonCommand = didTapViewQR
				qrCard.title = title
				qrCard.buttonEnabledEvaluator = buttonEnabledEvaluator
				qrCard.validityTexts = validityTexts
				qrCard.expiryEvaluator = expiryCountdownEvaluator
				qrCard.isLoading = isLoading
				qrCard.accessibilityIdentifier = "QRCard"
				qrCard.errorMessage = cardError?.message
				qrCard.errorMessageTapHandler = cardError?.didTapURL
				return qrCard
		}
	}
}

private extension HeaderMessageCardView {
	
	static func make(message: String, buttonTitle: String?, openURLHandler: @escaping (URL) -> Void) -> HeaderMessageCardView {
		let view = HeaderMessageCardView()
		view.message = message
		view.buttonTitle = buttonTitle
		view.linkTouchedHandler = { url in
			openURLHandler(url)
		}
		view.buttonTappedCommand = {
			guard let url = URL(string: L.holderDashboardIntroInternationalUrl()) else { return }
			openURLHandler(url)
		}
		return view
	}
}

private extension EmptyDashboardDescriptionCardView {
	
	static func make(message: String, buttonTitle: String?, openURLHandler: @escaping (URL) -> Void) -> EmptyDashboardDescriptionCardView {
		let view = EmptyDashboardDescriptionCardView()
		view.message = message
		view.buttonTitle = buttonTitle
		view.linkTouchedHandler = openURLHandler
		view.buttonTappedCommand = {
			guard let url = URL(string: L.holderDashboardEmptyInternationalUrl()) else { return }
			openURLHandler(url)
		}
		return view
	}
}
