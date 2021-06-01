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

		case makeQR(title: String, message: String, actionTitle: String, didTapMakeQR: () -> Void)

		case changeRegion(buttonTitle: String, currentLocationTitle: String)

		case domesticQR(rows: [QRCardRow], didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)

		case europeanUnionQR(rows: [QRCardRow], didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)
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

	var bannerView: BannerView?

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
		setupChangeRegionButton()
	}

	private func setupBindings() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }

		// Receive an array of cards,
		viewModel.$cards.binding = { [sceneView] cards in
			let cardViews = cards
				.compactMap { card -> UIView? in

				switch card {

					case .headerMessage(let message):
						let headerMessageLabel = sceneView.headerMessageLabel
						headerMessageLabel.text = message
						return headerMessageLabel

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

					case .makeQR(let title, let message, let actionTitle, let didTapAction):
						let makeQRCard = sceneView.makeQRCard
						makeQRCard.title = title
						makeQRCard.message = message
						makeQRCard.primaryTitle = actionTitle
						makeQRCard.backgroundImage = .createTile
						makeQRCard.color = Theme.colors.create
						makeQRCard.primaryButtonTappedCommand = didTapAction
						return makeQRCard

					case .changeRegion(let buttonTitle, let currentLocationTitle):
						let changeRegionCard = sceneView.changeRegionView
						changeRegionCard.changeRegionButtonTitle = buttonTitle
						changeRegionCard.currentLocationTitle = currentLocationTitle
						return changeRegionCard

					case .domesticQR(let rows, let didTapViewQR, let buttonEnabledEvaluator, let expiryCountdownEvaluator),
						 .europeanUnionQR(let rows, let didTapViewQR, let buttonEnabledEvaluator, let expiryCountdownEvaluator):

						let qrCard = QRCardView()
						qrCard.viewQRButtonCommand = didTapViewQR
						qrCard.title = .qrTitle
						qrCard.viewQRButtonTitle = .qrButtonViewQR

						switch card {
							case .domesticQR:
								qrCard.region = .netherlands
							case .europeanUnionQR:
								qrCard.region = .europeanUnion
								qrCard.shouldStyleForEU = true
							default: break
						}

						qrCard.originRows = rows.map { (qrCardRow: Card.QRCardRow) in
							QRCardView.OriginRow(type: qrCardRow.typeText, validityStringEvaluator: qrCardRow.validityTextEvaluator)
						}

						qrCard.expiryEvaluator = expiryCountdownEvaluator
						qrCard.buttonEnabledEvaluator = buttonEnabledEvaluator

						return qrCard
				}
			}

			sceneView.stackView.arrangedSubviews.forEach {
				sceneView.stackView.removeArrangedSubview($0)
				$0.removeFromSuperview()
			}

			cardViews.forEach {
				sceneView.stackView.addArrangedSubview($0)
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
		plusbutton.accessibilityLabel = .add
		navigationItem.rightBarButtonItem = plusbutton
	}

	func setupChangeRegionButton() {
		sceneView.changeRegionView.changeRegionButtonTappedCommand = { [viewModel] in
			viewModel.didTapChangeRegion()
		}
	}
}
