/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation
import UIKit

class ShowQRViewModel: Logging {

	private var greenCards = [GreenCard]()

	weak private var coordinator: HolderCoordinatorDelegate?

	@Bindable private(set) var title: String?

	@Bindable private(set) var infoButtonAccessibility: String?

	@Bindable private(set) var showInternationalAnimation: Bool = false

	@Bindable private(set) var thirdPartyTicketAppButtonTitle: String?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(
		coordinator: HolderCoordinatorDelegate,
		greenCards: [GreenCard],
		thirdPartyTicketAppName: String?
//		screenCaptureDetector: ScreenCaptureDetectorProtocol = ScreenCaptureDetector(),
//		userSettings: UserSettingsProtocol,
//		now: @escaping () -> Date = Date.init
	) {

		self.coordinator = coordinator
		self.greenCards = greenCards

//		if greenCard.type == GreenCardType.domestic.rawValue {
//			title = L.holderShowqrDomesticTitle()
//			qrAccessibility = L.holderShowqrDomesticQrTitle()
//			infoButtonAccessibility = L.holderShowqrDomesticAboutTitle()
//			showInternationalAnimation = false
//			thirdPartyTicketAppButtonTitle = thirdPartyTicketAppName.map { L.holderDashboardQrBackToThirdPartyApp($0) }
//		} else if greenCard.type == GreenCardType.eu.rawValue {
			title = L.holderShowqrEuTitle()
			infoButtonAccessibility = L.holderShowqrEuAboutTitle()
			showInternationalAnimation = true
//		}
	}

	func didTapThirdPartyAppButton() {
		coordinator?.userWishesToLaunchThirdPartyTicketApp()
	}

	func showMoreInformation() {

	}
}

class ShowQRViewController: BaseViewController {

	let sceneView = ShowQRView()

	private let viewModel: ShowQRViewModel
	private let pageViewController = PageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
	var previousOrientation: UIInterfaceOrientation?

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ShowQRViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		sceneView.backgroundColor = .white

		setupBinding()

		addBackButton()
	}

	private func setupBinding() {

		viewModel.$title.binding = { [weak self] in self?.title = $0 }

		viewModel.$infoButtonAccessibility.binding = { [weak self] in

			self?.addInfoButton(action: #selector(self?.informationButtonTapped), accessibilityLabel: $0 ?? "")
		}

		viewModel.$showInternationalAnimation.binding = { [weak self] in
			if $0 {
				self?.sceneView.setupForInternational()
			}
		}

		viewModel.$thirdPartyTicketAppButtonTitle.binding = { [weak self] in self?.sceneView.returnToThirdPartyAppButtonTitle = $0 }

		sceneView.didTapThirdPartyAppButtonCommand = { [viewModel] in
			viewModel.didTapThirdPartyAppButton()
		}
	}

	override func viewWillAppear(_ animated: Bool) {

		super.viewWillAppear(animated)
		sceneView.play()
		previousOrientation = OrientationUtility.currentOrientation()
		OrientationUtility.lockOrientation(.portrait, andRotateTo: .portrait)
	}

	override func viewWillDisappear(_ animated: Bool) {

		super.viewWillDisappear(animated)
		OrientationUtility.lockOrientation(.all, andRotateTo: previousOrientation ?? .portrait)
	}
}

// MARK: Details

extension ShowQRViewController {

	/// Add an information button to the navigation bar.
	/// - Parameters:
	///   - action: The action when the users taps the information button
	///   - accessibilityLabel: The label for Voice Over
	func addInfoButton(
		action: Selector,
		accessibilityLabel: String) {

			let config = UIBarButtonItem.Configuration(
				target: self,
				action: action,
				text: L.holderShowqrDetails(),
				tintColor: Theme.colors.iosBlue,
				accessibilityIdentifier: "InformationButton",
				accessibilityLabel: accessibilityLabel
			)
			navigationItem.rightBarButtonItem = .create(config)
		}

	@objc func informationButtonTapped() {

		viewModel.showMoreInformation()
	}

	//
	//		setupTranslucentNavigationBar()
	//
	//		setupPageController()
	//
	//		viewModel.$pages.binding = { [weak self] in
	//
	//			guard let self = self else {
	//				return
	//			}
	//
	//			self.pageViewController.pages = $0.enumerated().compactMap { index, page in
	//				let viewController = self.viewModel.scanInstructionsViewController(forPage: page)
	//				viewController.delegate = self
	//				viewController.sceneView.stepSubheading = L.verifierScaninstructionsStepTitle(String(index + 1))
	//
	//				return viewController
	//			}
	//			self.sceneView.pageControl.numberOfPages = $0.count
	//			self.sceneView.pageControl.currentPage = 0
	//		}
	//
	//		viewModel.$shouldShowSkipButton.binding = { [weak self] shouldShowSkipButton in
	//			self?.skipButton.isHidden = !shouldShowSkipButton
	//		}
	//
	//		viewModel.$nextButtonTitle.binding = { [weak self] nextButtonTitle in
	//			self?.sceneView.primaryButton.setTitle(nextButtonTitle, for: .normal)
	//		}
	//
	//		title = L.verifierScaninstructionsNavigationTitle()
	//		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	//
	//		setupBackButton()
	//		setupSkipButton()
//}
//
//	/// Create a custom back button so we can catch the tap on the back button.
//	private func setupBackButton() {
//
//		let config = UIBarButtonItem.Configuration(target: self,
//												   action: #selector(backButtonTapped),
//												   image: I.backArrow(),
//												   accessibilityIdentifier: "BackButton",
//												   accessibilityLabel: L.generalBack())
//		navigationItem.leftBarButtonItem = .create(config)
//	}
//
//	/// Create a custom skip button
//	private func setupSkipButton() {
//
//		skipButton.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
//
//		navigationItem.rightBarButtonItem = UIBarButtonItem(customView: skipButton)
//	}
//
//	@objc func backButtonTapped() {
//
//		// Move to the previous page
//		guard pageViewController.currentIndex > 0 else {
//			viewModel.userTappedBackOnFirstPage()
//			return
//		}
//		pageViewController.previousPage()
//	}
//
//	@objc func skipButtonTapped() {
//
//		viewModel.finishScanInstructions()
//	}
//
//	/// Setup the page controller
//	private func setupPageController() {
//
//		pageViewController.pageViewControllerDelegate = self
//		pageViewController.view.backgroundColor = .clear
//
//		pageViewController.view.frame = sceneView.containerView.frame
//		sceneView.containerView.addSubview(pageViewController.view)
//		addChild(pageViewController)
//		pageViewController.didMove(toParent: self)
//		sceneView.pageControl.addTarget(self, action: #selector(pageControlValueChanged), for: .valueChanged)
//	}
//
//	/// User tapped on the button
//	@objc func primaryButtonTapped() {
//
//		if pageViewController.isLastPage {
//			// We tapped on the last page
//			viewModel.finishScanInstructions()
//		} else {
//			// Move to the next page
//			pageViewController.nextPage()
//		}
//	}
//
//	/// User tapped on the page control
//	@objc func pageControlValueChanged(_ pageControl: UIPageControl) {
//
//		if pageControl.currentPage > pageViewController.currentIndex {
//			pageViewController.nextPage()
//		} else {
//			pageViewController.previousPage()
//		}
//	}
}
