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

		case changeRegion(buttonTitle: String, currentLocationTitle: String)

		case domesticQR(rows: [QRCardRow], didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case europeanUnionQR(rows: [QRCardRow], didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case cardFooter(message: String)
	}

	struct ValidityText {
		enum Kind {
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
		
		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.addProofTapped()
		}
	}

	private func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }
		viewModel.$primaryButtonTitle.binding = { [weak self] in self?.sceneView.primaryButton.title = $0 }
		viewModel.$hasAddCertificateMode.binding = { [weak self] in self?.sceneView.configurePrimaryButton(display: $0) }

		// Receive an array of cards,
		viewModel.$cards.binding = { [sceneView, weak viewModel] cards in
			let cardViews = cards
				.compactMap { card -> UIView? in

				switch card {

					case .headerMessage(let message):

						let text = TextView(htmlText: message)
						text.linkTouched { url in
							viewModel?.openUrl(url)
						}
						return text

					case .expiredQR(let message, let didTapCloseAction):
						let expiredQRCard = ExpiredQRView()
						expiredQRCard.title = message
						expiredQRCard.closeButtonTappedCommand = didTapCloseAction
						return expiredQRCard

					case .originNotValidInThisRegion(let message, let didTapMoreInfo):
						let messageCard = MessageCardView()
						messageCard.title = message
						messageCard.infoButtonTappedCommand = didTapMoreInfo
						return messageCard

					case .emptyState(let title, let message):
						let emptyDashboardView = EmptyDashboardView()
						emptyDashboardView.image = .emptyDashboard
						emptyDashboardView.title = title
						emptyDashboardView.message = message
						emptyDashboardView.contentTextView.linkTouched { url in
							viewModel?.openUrl(url)
						}
						return emptyDashboardView

					case .changeRegion(let buttonTitle, let currentLocationTitle):
						let changeRegionCard = ChangeRegionView()
						changeRegionCard.changeRegionButtonTitle = buttonTitle
						changeRegionCard.currentLocationTitle = currentLocationTitle
						changeRegionCard.changeRegionButtonTappedCommand = {
							viewModel?.didTapChangeRegion()
						}
						return changeRegionCard

					case .domesticQR(let rows, let didTapViewQR, let buttonEnabledEvaluator, let expiryCountdownEvaluator),
						 .europeanUnionQR(let rows, let didTapViewQR, let buttonEnabledEvaluator, let expiryCountdownEvaluator):

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

						return qrCard

					case .cardFooter(let message):

						let cardFooterView = CardFooterView()
						cardFooterView.title = message
						return cardFooterView
				}
			}

			sceneView.stackView.arrangedSubviews.forEach {
				sceneView.stackView.removeArrangedSubview($0)
				$0.removeFromSuperview()
			}

			cardViews.forEach {
				sceneView.stackView.addArrangedSubview($0)
			}

			// Hack to fix the spacing between EU Launch message and a EU Card.
			// 📝 Can be removed once EU Launch date is passed:
			for (index, view) in cardViews.enumerated() {
				guard view is CardFooterView else { continue }

				// Try to get previous view, which would be an EU card:
				let previousIndex = index - 1

				guard previousIndex >= 0 else { continue }

				// Check that previous view is a QRCardView:
				guard let previousCardView = cardViews[previousIndex] as? QRCardView else { continue }

				sceneView.stackView.setCustomSpacing(16, after: previousCardView)
			}
		}
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		
		// Scroll to top
		sceneView.scrollView.setContentOffset(.zero, animated: false)

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
		plusbutton.accessibilityLabel = L.generalAdd()
		navigationItem.rightBarButtonItem = plusbutton
	}
}
