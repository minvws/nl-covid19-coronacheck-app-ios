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
        case emptyStateDescription(message: String, buttonTitle: String?)
        case emptyStatePlaceholderImage(image: UIImage, title: String)
		case addCertificate(title: String, didTapAdd: () -> Void)

        // Warnings:
        case expiredQR(message: String, didTapClose: () -> Void)
        case expiredVaccinationQR(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void, didTapClose: () -> Void)
        case originNotValidInThisRegion(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
        case deviceHasClockDeviation(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
        case configAlmostOutOfDate(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
		case testOnlyValidFor3G(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
        
        // Errors:
        case errorMessage(message: String, didTapTryAgain: () -> Void)
        
		// Vaccination & Recovery Validity
		case newValidityInfoForVaccinationAndRecoveries(title: String, buttonText: String, didTapCallToAction: () -> Void, didTapClose: () -> Void)
		
		// Vaccination Assessment
		case completeYourVaccinationAssessment(title: String, buttonText: String, didTapCallToAction: () -> Void)
		case vaccinationAssessmentInvalidOutsideNL(title: String, buttonText: String, didTapCallToAction: () -> Void)
		
        // QR Cards:
        case domesticQR(title: String, validityTexts: (Date) -> [ValidityText], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)
        case europeanUnionQR(title: String, stackSize: Int, validityTexts: (Date) -> [ValidityText], isLoading: Bool, didTapViewQR: () -> Void, buttonEnabledEvaluator: (Date) -> Bool, expiryCountdownEvaluator: ((Date) -> String?)?)
		
		// Recommendations
		case recommendCoronaMelder
		case recommendedUpdate(message: String, callToActionButtonText: String, didTapCallToAction: () -> Void)
		case recommendToAddYourBooster(title: String, buttonText: String, didTapCallToAction: () -> Void, didTapClose: () -> Void)
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
		
		sceneView.delegate = self

		sceneView.footerButtonView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.addProofTapped()
		}
		
		// Forces VoiceOver focus on menu button instead of tab bar on start up
		UIAccessibility.post(notification: .screenChanged, argument: navigationItem.leftBarButtonItem)
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		navigationController?.interactivePopGestureRecognizer?.isEnabled = false
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
		viewModel.$shouldShowAddCertificateFooter.binding = { [weak self] in self?.sceneView.shouldDisplayButtonView = $0 }

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
		let cardViews = cards.compactMap { card in
			card.makeView(openURLHandler: { [weak viewModel] url in viewModel?.openUrl(url) })
		}
		
		stackView.removeArrangedSubviews()
		
		cardViews.forEach {
			stackView.addArrangedSubview($0)
		}
		
		// Custom spacing for error message
		for (index, view) in cardViews.enumerated() {
			guard view is ErrorDashboardCardView else { continue }
			
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
}

extension HolderDashboardViewController: HolderDashboardViewDelegate {
	
	func holderDashboardView(_ view: HolderDashboardView, didDisplay tab: DashboardTab) {
		let changedRegion: QRCodeValidityRegion = tab.isDomestic ? .domestic : .europeanUnion
		viewModel.dashboardRegionToggleValue = changedRegion
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
			case let .originNotValidInThisRegion(message, callToActionButtonText, didTapCallToAction),
				let .deviceHasClockDeviation(message, callToActionButtonText, didTapCallToAction),
				let .configAlmostOutOfDate(message, callToActionButtonText, didTapCallToAction),
				let .testOnlyValidFor3G(message, callToActionButtonText, didTapCallToAction),
				let .recommendedUpdate(message, callToActionButtonText, didTapCallToAction),
				let .completeYourVaccinationAssessment(message, callToActionButtonText, didTapCallToAction),
				let .vaccinationAssessmentInvalidOutsideNL(message, callToActionButtonText, didTapCallToAction):
				
				return MessageCardView(config: .init(
					title: message,
					closeButtonCommand: nil,
					ctaButton: (title: callToActionButtonText, command: didTapCallToAction)
				))
				
			// Message Cards with a message + CTA button + close button
			case let .newValidityInfoForVaccinationAndRecoveries(message, callToActionButtonText, didTapCallToAction, didTapCloseAction),
				let .expiredVaccinationQR(message, callToActionButtonText, didTapCallToAction, didTapCloseAction),
				let .recommendToAddYourBooster(message, callToActionButtonText, didTapCallToAction, didTapCloseAction):
				
				return MessageCardView(config: .init(
					title: message,
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
				
			case let .domesticQR(title, validityTexts, isLoading, didTapViewQR, buttonEnabledEvaluator, expiryCountdownEvaluator):
				return QRCardView.make(stackSize: 1, forEu: false, title: title, isLoading: isLoading, validityTexts: validityTexts, didTapViewQR: didTapViewQR, buttonEnabledEvaluator: buttonEnabledEvaluator, expiryCountdownEvaluator: expiryCountdownEvaluator)
			
			case let .europeanUnionQR(title, stackSize, validityTexts, isLoading, didTapViewQR, buttonEnabledEvaluator, expiryCountdownEvaluator):
				return QRCardView.make(stackSize: stackSize, forEu: true, title: title, isLoading: isLoading, validityTexts: validityTexts, didTapViewQR: didTapViewQR, buttonEnabledEvaluator: buttonEnabledEvaluator, expiryCountdownEvaluator: expiryCountdownEvaluator)
				
			case let .errorMessage(message, didTapTryAgain):
				return ErrorDashboardCardView.make(message: message, didTapTryAgain: didTapTryAgain, openURLHandler: openURLHandler)
			
			case .recommendCoronaMelder:
				let view = RecommendCoronaMelderCardView()
				view.message = L.holderDashboardRecommendcoronamelderTitle()
				view.urlTapHandler = openURLHandler
				return view
		}
		
	}
}

private extension ErrorDashboardCardView {
	
	static func make(message: String, didTapTryAgain: @escaping () -> Void, openURLHandler: @escaping (URL) -> Void) -> ErrorDashboardCardView {
		let view = ErrorDashboardCardView()
		view.message = message
		view.messageTextView.linkTouched { url in
			if url.absoluteString == AppAction.tryAgain {
				didTapTryAgain()
			} else {
				openURLHandler(url)
			}
		}
		return view
	}
}

private extension HeaderMessageCardView {
	
	static func make(message: String, buttonTitle: String?, openURLHandler: @escaping (URL) -> Void) -> HeaderMessageCardView {
		let view = HeaderMessageCardView()
		view.message = message
		view.buttonTitle = buttonTitle
		view.contentTextView.linkTouched { url in
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
		view.contentTextView.linkTouched { url in
			openURLHandler(url)
		}
		view.buttonTappedCommand = {
			guard let url = URL(string: L.holderDashboardEmptyInternationalUrl()) else { return }
			openURLHandler(url)
		}
		return view
	}
}

private extension QRCardView {

	// swiftlint:disable:next function_parameter_count
	static func make(
		stackSize: Int,
		forEu: Bool,
		title: String,
		isLoading: Bool,
		validityTexts: @escaping (Date) -> [HolderDashboardViewController.ValidityText],
		didTapViewQR: @escaping () -> Void,
		buttonEnabledEvaluator: @escaping (Date) -> Bool,
		expiryCountdownEvaluator: ((Date) -> String?)?
	) -> QRCardView {
		let qrCard = QRCardView(stackSize: stackSize)
		qrCard.shouldStyleForEU = forEu
		qrCard.viewQRButtonTitle = stackSize == 1
			? L.holderDashboardQrButtonViewQR()
			: L.holderDashboardQrButtonViewQRs()
		qrCard.viewQRButtonCommand = didTapViewQR
		qrCard.title = title
		qrCard.buttonEnabledEvaluator = buttonEnabledEvaluator
		qrCard.validityTexts = validityTexts
		qrCard.expiryEvaluator = expiryCountdownEvaluator
		qrCard.isLoading = isLoading
		
		return qrCard
	}
}
