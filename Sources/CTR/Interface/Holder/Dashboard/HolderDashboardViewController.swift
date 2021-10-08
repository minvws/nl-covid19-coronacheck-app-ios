/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardViewController: BaseViewController {

	enum Card {
		case headerMessage(message: String, buttonTitle: String?)

		case expiredQR(message: String, didTapClose: () -> Void)

		case originNotValidInThisRegion(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)

		case deviceHasClockDeviation(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)

		case upgradeYourInternationalVaccinationCertificate(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)

		case upgradingYourInternationalVaccinationCertificateDidComplete(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void, didTapClose: () -> Void)

		case emptyState(image: UIImage?, title: String, message: String, buttonTitle: String?)

		case domesticQR(title: String, validityTexts: (Date) -> [ValidityText], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case europeanUnionQR(title: String, stackSize: Int, validityTexts: (Date) -> [ValidityText], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case errorMessage(message: String, didTapTryAgain: () -> Void)
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

	let viewModel: HolderDashboardViewModel

	let sceneView = HolderDashboardView()

	var screenCaptureInProgress = false
	
	private var didSetInitialStartingTabOnSceneView = false

	// MARK: Initializers

	init(viewModel: HolderDashboardViewModel) {

		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {

		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle

	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		setupBindings()

		setupPlusButton()
		
		sceneView.delegate = self

		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.addProofTapped()
		}
		
		// Forces VoiceOver focus on menu button instead of tab bar on start up
		UIAccessibility.post(notification: .screenChanged, argument: navigationItem.leftBarButtonItem)
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate { _ in
			self.sceneView.updateScrollPosition()
		}
	}

	private func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		
		viewModel.$domesticCards.binding = { [sceneView, weak self] cards in
			DispatchQueue.main.async {
				self?.setup(cards: cards, with: sceneView.domesticScrollView.stackView)
			}
		}
		
		viewModel.$internationalCards.binding = { [sceneView, weak self] cards in
			DispatchQueue.main.async {
				self?.setup(cards: cards, with: sceneView.internationalScrollView.stackView)
			}
		}
		
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.footerButtonView.primaryButton.title = $0 }
		viewModel.$hasAddCertificateMode.binding = { [weak self] in self?.sceneView.shouldDisplayButtonView = $0 }

		viewModel.$currentlyPresentedAlert.binding = { [weak self] alertContent in
			DispatchQueue.main.async {
				self?.showAlert(alertContent)
			}
		}

		viewModel.$selectedTab.binding = { [weak self, sceneView] region in
			guard let self = self, self.didSetInitialStartingTabOnSceneView else { return }
			sceneView.selectTab(tab: region)
		}
	}
	
	private func setup(cards: [HolderDashboardViewController.Card], with stackView: UIStackView) {
		let cardViews = cards
			.compactMap { [weak self] card -> UIView? in
				
				switch card {
					case let .headerMessage(message, buttonTitle):
						
						let headerMessageView = HeaderMessageView()
						headerMessageView.message = message
						headerMessageView.buttonTitle = buttonTitle
						headerMessageView.contentTextView.linkTouched { url in
							self?.viewModel.openUrl(url)
						}
						headerMessageView.buttonTappedCommand = {

							guard let url = URL(string: L.holderDashboardIntroInternationalUrl()) else { return }
							self?.viewModel.openUrl(url)
						}
						return headerMessageView
						
					// Message Cards with only a message + close button
					case let .expiredQR(message, didTapCloseAction):
						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.closeButtonTappedCommand = didTapCloseAction
						return messageCard

					// Message Cards with a message + CTA button
					case let .originNotValidInThisRegion(message, callToActionButtonText, didTapCallToAction),
						 let .deviceHasClockDeviation(message, callToActionButtonText, didTapCallToAction),
						 let .upgradeYourInternationalVaccinationCertificate(message, callToActionButtonText, didTapCallToAction):

						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.callToActionButtonText = callToActionButtonText
						messageCard.callToActionButtonTappedCommand = didTapCallToAction
						return messageCard

					case let .upgradingYourInternationalVaccinationCertificateDidComplete(message, callToActionButtonText, didTapCallToAction, didTapCloseAction):
						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.callToActionButtonText = callToActionButtonText
						messageCard.callToActionButtonTappedCommand = didTapCallToAction
						messageCard.closeButtonTappedCommand = didTapCloseAction
						return messageCard

					case let .emptyState(image, title, message, buttonTitle):
						let emptyDashboardView = EmptyDashboardView()
						emptyDashboardView.image = image
						emptyDashboardView.title = title
						emptyDashboardView.message = message
						emptyDashboardView.buttonTitle = buttonTitle
						emptyDashboardView.contentTextView.linkTouched { url in
							self?.viewModel.openUrl(url)
						}
						emptyDashboardView.buttonTappedCommand = {
							guard let url = URL(string: L.holderDashboardEmptyInternationalUrl()) else { return }
							self?.viewModel.openUrl(url)
						}
						return emptyDashboardView
						
					case let .domesticQR(title, validityTexts, isLoading, didTapViewQR, buttonEnabledEvaluator, expiryCountdownEvaluator),
						 let .europeanUnionQR(title, _, validityTexts, isLoading, didTapViewQR, buttonEnabledEvaluator, expiryCountdownEvaluator):

						let qrCard: QRCardView

						if case let .europeanUnionQR(_, stackSize, _, _, _, _, _) = card {
							qrCard = QRCardView(stackSize: stackSize)
							qrCard.shouldStyleForEU = true
							qrCard.viewQRButtonTitle = stackSize == 1
								? L.holderDashboardQrButtonViewQR()
								: L.holderDashboardQrButtonViewQRs()
						} else {
							qrCard = QRCardView(stackSize: 1)
							qrCard.shouldStyleForEU = false
							qrCard.viewQRButtonTitle = L.holderDashboardQrButtonViewQR()
						}

						qrCard.viewQRButtonCommand = didTapViewQR
						qrCard.title = title

						qrCard.validityTexts = validityTexts
						qrCard.expiryEvaluator = expiryCountdownEvaluator
						qrCard.buttonEnabledEvaluator = buttonEnabledEvaluator
						qrCard.isLoading = isLoading
						
						return qrCard
						
					case let .errorMessage(message, didTapTryAgain):
						
						let errorView = ErrorDashboardView()
						errorView.message = message
						errorView.messageTextView.linkTouched { url in
							if url.absoluteString == AppAction.tryAgain {
								didTapTryAgain()
							} else {
								self?.viewModel.openUrl(url)
							}
						}
						return errorView
				}
			}
		
		stackView.arrangedSubviews.forEach {
			stackView.removeArrangedSubview($0)
			$0.removeFromSuperview()
		}
		
		cardViews.forEach {
			stackView.addArrangedSubview($0)
		}
		
		// Custom spacing for error message
		for (index, view) in cardViews.enumerated() {
			guard view is ErrorDashboardView else { continue }
			
			// Try to get previous view, which would be an QR card:
			let previousIndex = index - 1
			
			guard previousIndex >= 0 else { continue }
			
			// Check that previous view is a QRCardView:
			guard let previousCardView = cardViews[previousIndex] as? QRCardView else { continue }
			
			stackView.setCustomSpacing(22, after: previousCardView)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		viewModel.viewWillAppear()
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		guard !didSetInitialStartingTabOnSceneView else { return }
		didSetInitialStartingTabOnSceneView = true

		// Select start tab after layouting is done to be able to update scroll position
		let selectedTab: DashboardTab = viewModel.dashboardRegionToggleValue == .domestic ? .domestic : .international
		sceneView.selectTab(tab: selectedTab)
	}

	// MARK: Helper methods

	func setupPlusButton() {
		let config = UIBarButtonItem.Configuration(target: viewModel,
												   action: #selector(HolderDashboardViewModel.addProofTapped),
												   content: .image( I.plus()),
												   accessibilityIdentifier: "PlusButton",
												   accessibilityLabel: L.holderMenuProof())
		navigationItem.rightBarButtonItem = .create(config)
	}
}

extension HolderDashboardViewController: HolderDashboardViewDelegate {
	
	func holderDashboardView(_ view: HolderDashboardView, didDisplay tab: DashboardTab) {
		let changedRegion: QRCodeValidityRegion = tab.isDomestic ? .domestic : .europeanUnion
		viewModel.dashboardRegionToggleValue = changedRegion
	}
}
