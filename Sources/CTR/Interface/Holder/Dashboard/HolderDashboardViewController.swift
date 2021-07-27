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
			let typeText: String
			let validityTextEvaluator: (Date) -> ValidityText
		}

		case headerMessage(message: String)

		case expiredQR(message: String, didTapClose: () -> Void)

		case originNotValidInThisRegion(message: String, didTapMoreInfo: () -> Void)

		case emptyState(title: String, message: String)

		case domesticQR(rows: [QRCardRow], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case europeanUnionQR(rows: [QRCardRow], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case errorMessage(message: String, didTapTryAgain: () -> Void)
	}

	struct ValidityText: Equatable {
		enum Kind: Equatable {
			case past
			case future
			case current
		}

		let text: String
		let kind: Kind
	}

	private let viewModel: HolderDashboardViewModel

	let sceneView = HolderDashboardView()

	var screenCaptureInProgress = false

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

		// Only show an arrow as back button
		styleBackButton(buttonText: "")
		setupPlusButton()

//		sceneView.primaryButtonTappedCommand = { [weak self] in
//			self?.viewModel.addProofTapped()
//		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate { _ in
			self.sceneView.updateForRotation()
		}
	}

	private func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		
		viewModel.$domesticCards.binding = { [sceneView, weak viewModel] cards in
			let cardViews = cards
				.compactMap { card -> UIView? in

				switch card {

					case let .headerMessage(message):

						let text = TextView(htmlText: message)
						text.linkTouched { url in
							viewModel?.openUrl(url)
						}
						return text

					case let .expiredQR(message, didTapCloseAction):
						let expiredQRCard = ExpiredQRView()
						expiredQRCard.title = message
						expiredQRCard.closeButtonTappedCommand = didTapCloseAction
						return expiredQRCard

					case let .originNotValidInThisRegion(message, didTapMoreInfo):
						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.infoButtonTappedCommand = didTapMoreInfo
						return messageCard

					case let .emptyState(title, message):
						let emptyDashboardView = EmptyDashboardView()
						emptyDashboardView.image = .emptyDashboard
						emptyDashboardView.title = title
						emptyDashboardView.message = message
						emptyDashboardView.contentTextView.linkTouched { url in
							viewModel?.openUrl(url)
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
							QRCardView.OriginRow(type: qrCardRow.typeText, validityStringEvaluator: qrCardRow.validityTextEvaluator)
						}

						qrCard.expiryEvaluator = expiryCountdownEvaluator
						qrCard.buttonEnabledEvaluator = buttonEnabledEvaluator
						qrCard.isLoading = isLoading

						return qrCard

					case let .errorMessage(message, didTapTryAgain):

						let errorView = ErrorDashboardView()
						errorView.message = message
						errorView.messageView.linkTouched { url in
							if url.absoluteString == AppAction.tryAgain {
								didTapTryAgain()
							} else {
								viewModel?.openUrl(url)
							}
						}
						return errorView
				}
			}

			sceneView.domesticScrollView.stackView.arrangedSubviews.forEach {
				sceneView.domesticScrollView.stackView.removeArrangedSubview($0)
				$0.removeFromSuperview()
			}

			cardViews.forEach {
				sceneView.domesticScrollView.stackView.addArrangedSubview($0)
			}
		}
		
		viewModel.$internationalCards.binding = { [sceneView, weak viewModel] cards in
			let cardViews = cards
				.compactMap { card -> UIView? in

				switch card {

					case let .headerMessage(message):

						let text = TextView(htmlText: message)
						text.linkTouched { url in
							viewModel?.openUrl(url)
						}
						return text

					case let .expiredQR(message, didTapCloseAction):
						let expiredQRCard = ExpiredQRView()
						expiredQRCard.title = message
						expiredQRCard.closeButtonTappedCommand = didTapCloseAction
						return expiredQRCard

					case let .originNotValidInThisRegion(message, didTapMoreInfo):
						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.infoButtonTappedCommand = didTapMoreInfo
						return messageCard

					case let .emptyState(title, message):
						let emptyDashboardView = EmptyDashboardView()
						emptyDashboardView.image = .emptyDashboard
						emptyDashboardView.title = title
						emptyDashboardView.message = message
						emptyDashboardView.contentTextView.linkTouched { url in
							viewModel?.openUrl(url)
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
							QRCardView.OriginRow(type: qrCardRow.typeText, validityStringEvaluator: qrCardRow.validityTextEvaluator)
						}

						qrCard.expiryEvaluator = expiryCountdownEvaluator
						qrCard.buttonEnabledEvaluator = buttonEnabledEvaluator
						qrCard.isLoading = isLoading

						return qrCard

					case let .errorMessage(message, didTapTryAgain):

						let errorView = ErrorDashboardView()
						errorView.message = message
						errorView.messageView.linkTouched { url in
							if url.absoluteString == AppAction.tryAgain {
								didTapTryAgain()
							} else {
								viewModel?.openUrl(url)
							}
						}
						return errorView
				}
			}

			sceneView.internationalScrollView.stackView.arrangedSubviews.forEach {
				sceneView.internationalScrollView.stackView.removeArrangedSubview($0)
				$0.removeFromSuperview()
			}

			cardViews.forEach {
				sceneView.internationalScrollView.stackView.addArrangedSubview($0)
			}
		}
		
//		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryButton.title = $0 }
//		viewModel.$hasAddCertificateMode.binding = { [weak self] in self?.sceneView.setupPrimaryButton(display: $0) }
//		viewModel.$regionMode.binding = { [weak self] in self?.sceneView.setupRegionButton(
//			buttonTitle: $0?.buttonTitle,
//			currentLocationTitle: $0?.currentLocationTitle
//		) {
//			self?.viewModel.didTapChangeRegion()
//		}}

		// Receive an array of cards,
		/*
		viewModel.$cards.binding = { [sceneView, weak viewModel] cards in
			let cardViews = cards
				.compactMap { card -> UIView? in

				switch card {

					case let .headerMessage(message):

						let text = TextView(htmlText: message)
						text.linkTouched { url in
							viewModel?.openUrl(url)
						}
						return text

					case let .expiredQR(message, didTapCloseAction):
						let expiredQRCard = ExpiredQRView()
						expiredQRCard.title = message
						expiredQRCard.closeButtonTappedCommand = didTapCloseAction
						return expiredQRCard

					case let .originNotValidInThisRegion(message, didTapMoreInfo):
						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.infoButtonTappedCommand = didTapMoreInfo
						return messageCard

					case let .emptyState(title, message):
						let emptyDashboardView = EmptyDashboardView()
						emptyDashboardView.image = .emptyDashboard
						emptyDashboardView.title = title
						emptyDashboardView.message = message
						emptyDashboardView.contentTextView.linkTouched { url in
							viewModel?.openUrl(url)
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
							QRCardView.OriginRow(type: qrCardRow.typeText, validityStringEvaluator: qrCardRow.validityTextEvaluator)
						}

						qrCard.expiryEvaluator = expiryCountdownEvaluator
						qrCard.buttonEnabledEvaluator = buttonEnabledEvaluator
						qrCard.isLoading = isLoading

						return qrCard

					case let .errorMessage(message, didTapTryAgain):

						let errorView = ErrorDashboardView()
						errorView.message = message
						errorView.messageView.linkTouched { url in
							if url.absoluteString == AppAction.tryAgain {
								didTapTryAgain()
							} else {
								viewModel?.openUrl(url)
							}
						}
						return errorView
				}
			}

			sceneView.stackView.arrangedSubviews.forEach {
				sceneView.stackView.removeArrangedSubview($0)
				$0.removeFromSuperview()
			}

			cardViews.forEach {
				sceneView.stackView.addArrangedSubview($0)
			}

			// Custom spacing for error message
			for (index, view) in cardViews.enumerated() {
				guard view is ErrorDashboardView else { continue }

				// Try to get previous view, which would be an QR card:
				let previousIndex = index - 1

				guard previousIndex >= 0 else { continue }

				// Check that previous view is a QRCardView:
				guard let previousCardView = cardViews[previousIndex] as? QRCardView else { continue }

				sceneView.stackView.setCustomSpacing(22, after: previousCardView)
			}
		}
		*/

		viewModel.$currentlyPresentedAlert.binding = { [weak self] alertContent in
			DispatchQueue.main.async {
				self?.showAlert(alertContent)
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)

		// Scroll to top
//		sceneView.scrollView.setContentOffset(.zero, animated: false)

		viewModel.viewWillAppear()
	}

	// MARK: Helper methods

	func setupPlusButton() {
		let plusbutton = UIBarButtonItem(
			image: .plus,
			style: .plain,
			target: viewModel,
			action: #selector(HolderDashboardViewModel.addProofTapped)
		)
		plusbutton.title = L.generalAdd()
		navigationItem.rightBarButtonItem = plusbutton
	}
}
