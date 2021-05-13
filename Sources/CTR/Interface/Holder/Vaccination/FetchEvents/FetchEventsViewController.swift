/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class FetchEventsViewModel: Logging {

	weak var coordinator: VaccinationCoordinatorDelegate?

	// Resulting token from DigiD VWS
	private var tvsToken: String

	// List of tokens for the vaccination event providers
	private var accessTokens = [AccessToken]()

	/// List of event providers
	private var eventProviders = [EventProvider]()

	private var networkManager: NetworkManaging
	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	let prefetchingGroup = DispatchGroup()

	init(
		coordinator: VaccinationCoordinatorDelegate,
		tvsToken: String,
		networkManager: NetworkManaging = Services.networkManager) {
		self.coordinator = coordinator
		self.tvsToken = tvsToken
		self.networkManager = networkManager

		startFetching()
	}

	func backButtonTapped() {

		coordinator?.didFinishLoad(.stop)
	}

	private func fetchAccessTokens() {

		networkManager.getAccessTokens(tvsToken: tvsToken) { [weak self] result in
			switch result {
				case let .failure(error):
					self?.prefetchingGroup.leave()
					self?.logError("Error getting access tokens: \(error)")
				case let .success(tokens):
					self?.prefetchingGroup.leave()
					self?.accessTokens = tokens
					self?.logInfo("We fetched \(tokens.count) access tokens")
			}
		}
	}

	private func fetchEventProviders() {

		networkManager.getEventProviders { [weak self] result in
			switch result {
				case let .failure(error):
					self?.prefetchingGroup.leave()
					self?.logError("Error getting event providers: \(error)")
				case let .success(providers):
					self?.prefetchingGroup.leave()
					self?.eventProviders = providers
					self?.logInfo("We fetched \(providers.count) eventProviders")
			}
		}
	}

	private func startFetching() {

		logInfo("startFetching")
		progressIndicationCounter.increment()
		prefetchingGroup.enter()
		fetchAccessTokens()
		prefetchingGroup.enter()
		fetchEventProviders()

		prefetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedFetching()
		}
	}

	private func finishedFetching() {

		logInfo("finishedFetching")
		progressIndicationCounter.decrement()
		updateEventProvidersWithAccessTokens()
	}

	private func updateEventProvidersWithAccessTokens() {

		for index in 0 ..< eventProviders.count {
			for accessToken in accessTokens {
				if eventProviders[index].identifier == accessToken.providerIdentifier {
					eventProviders[index].eventAccessToken = accessToken.eventAccessToken
					eventProviders[index].unomiAccessToken = accessToken.unomiAccessToken
				}
			}
		}
	}
}

class FetchEventsViewController: BaseViewController {

	let viewModel: FetchEventsViewModel
	let sceneView = FetchEventsView()

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: FetchEventsViewModel) {

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

		title = "** Vaccinatie loader **"
		navigationItem.hidesBackButton = true
		addCustomBackButton(action: #selector(backButtonTapped), accessibilityLabel: .back)

		viewModel.$shouldShowProgress.binding = {[weak self] in

			if $0 {
				self?.sceneView.spinner.startAnimating()
			} else {
				self?.sceneView.spinner.stopAnimating()
			}
		}
	}

	@objc func backButtonTapped() {

		viewModel.backButtonTapped()
	}
}

class FetchEventsView: ScrolledStackView {

	/// The spinner
	let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			view.style = .large
		} else {
			view.style = .whiteLarge
		}
		view.color = Theme.colors.primary
		return view
	}()

	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		stackView.addArrangedSubview(spinner)
	}
}
