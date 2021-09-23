/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class HolderDashboardViewController: BaseViewController {

	enum Card {
		struct QRCardRow {
			let typeText: String?
			let validityText: (Date) -> ValidityText
		}

		case headerMessage(message: String)

		case expiredQR(message: String, didTapClose: () -> Void)

		case originNotValidInThisRegion(message: String, didTapMoreInfo: () -> Void)

		case deviceHasClockDeviation(message: String, didTapMoreInfo: () -> Void)

		case emptyState(image: UIImage?, title: String, message: String)

		case domesticQR(rows: [QRCardRow], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case europeanUnionQR(rows: [QRCardRow], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

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

		let texts: [String]
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
					
					case let .headerMessage(message):
						
						let text = TextView(htmlText: message)
						text.linkTouched { url in
							self?.viewModel.openUrl(url)
						}
						return text
						
					case let .expiredQR(message, didTapCloseAction):
						let expiredQRCard = ExpiredQRView()
						expiredQRCard.title = message
						expiredQRCard.closeButtonTappedCommand = didTapCloseAction
						return expiredQRCard
						
					case let .originNotValidInThisRegion(message, didTapMoreInfo),
						 let .deviceHasClockDeviation(message, didTapMoreInfo):

						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.infoButtonTappedCommand = didTapMoreInfo
						return messageCard

					case let .emptyState(image, title, message):
						let emptyDashboardView = EmptyDashboardView()
						emptyDashboardView.image = image
						emptyDashboardView.title = title
						emptyDashboardView.message = message
						emptyDashboardView.contentTextView.linkTouched { url in
							self?.viewModel.openUrl(url)
						}
						return emptyDashboardView
						
					case let .domesticQR(rows, isLoading, didTapViewQR, buttonEnabledEvaluator, expiryCountdownEvaluator),
						 let .europeanUnionQR(rows, isLoading, didTapViewQR, buttonEnabledEvaluator, expiryCountdownEvaluator):
						
						let qrCard = QRCardView()
						qrCard.viewQRButtonCommand = didTapViewQR
						qrCard.title = L.holderDashboardQrTitle()
						qrCard.viewQRButtonTitle = L.holderDashboardQrButtonViewQR()
						
						switch card {
							case .domesticQR:
								qrCard.region = L.generalNetherlands()
							case .europeanUnionQR:
								qrCard.region = L.generalEuropeanUnion()
								qrCard.shouldStyleForEU = true
							default: break
						}
						
						qrCard.originRows = rows.map { (qrCardRow: Card.QRCardRow) in
							QRCardView.OriginRow(type: qrCardRow.typeText, validityString: qrCardRow.validityText)
						}
						
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
												   image: I.plus(),
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
