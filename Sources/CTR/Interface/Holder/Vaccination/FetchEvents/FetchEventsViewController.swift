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

	private var unomiResults = [UnomiResponse]()

	private var eventResults = [(TestResultWrapper, SignedResponse)]()

	private var networkManager: NetworkManaging
	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	let prefetchingGroup = DispatchGroup()
	let unomiFetchingGroup = DispatchGroup()
	let eventFetchingGroup = DispatchGroup()

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
					self?.logError("Error getting access tokens: \(error)")
					self?.prefetchingGroup.leave()
				case let .success(tokens):
					self?.accessTokens = tokens
					self?.logInfo("We fetched \(tokens.count) access tokens")
					self?.prefetchingGroup.leave()
			}
		}
	}

	private func fetchEventProviders() {

		networkManager.getEventProviders { [weak self] result in
			switch result {
				case let .failure(error):
					self?.logError("Error getting event providers: \(error)")
					self?.prefetchingGroup.leave()
				case let .success(providers):
					self?.eventProviders = providers
					self?.logInfo("We fetched \(providers.count) eventProviders")
					self?.prefetchingGroup.leave()
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
		fetchUnomiRepsonses()
	}

	private func updateEventProvidersWithAccessTokens() {

		for index in 0 ..< eventProviders.count {
			for accessToken in accessTokens where eventProviders[index].identifier == accessToken.providerIdentifier {
				eventProviders[index].eventAccessToken = accessToken.eventAccessToken
				eventProviders[index].unomiAccessToken = accessToken.unomiAccessToken
			}
		}
	}

	private func fetchUnomiRepsonses() {

		logInfo("fetchUnomiRepsonses")
		progressIndicationCounter.increment()
		for provider in eventProviders {
			if let url = provider.unomiURL?.absoluteString, provider.unomiAccessToken != nil, url.starts(with: "https") {

				self.logInfo("evenprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

				unomiFetchingGroup.enter()
				networkManager.getUnomiResult(provider: provider) { [weak self] result in
					// Result<UnomiResponse, NetworkError>
					//					self?.logInfo("evenprovider: \(self?.eventProviders[index].identifier) - \(self?.eventProviders[index].name)")
					switch result {
						case let .failure(error):
							self?.unomiFetchingGroup.leave()
							self?.logError("Error getting unomi: \(error)")
						case let .success(response):
							self?.logInfo("response: \(response)")
							self?.unomiResults.append(response)
							self?.unomiFetchingGroup.leave()
					}
				}
			}
		}
		unomiFetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedUnomiFetching()
		}
	}

	private func finishedUnomiFetching() {

		logInfo("finishedUnomiFetching")
		progressIndicationCounter.decrement()
		updateEventProvidersWithUnomiResponse()
		fetchEvents()
	}

	private func updateEventProvidersWithUnomiResponse() {

		for index in 0 ..< eventProviders.count {
			for response in unomiResults where eventProviders[index].identifier == response.providerIdentifier {
				eventProviders[index].unomi = response.informationAvailable
			}
		}
	}

	private func fetchEvents() {

		logInfo("fetchEvents")
		progressIndicationCounter.increment()

		for provider in eventProviders {
			if let url = provider.eventURL?.absoluteString, provider.eventAccessToken != nil, url.starts(with: "https"), provider.unomi {

				eventFetchingGroup.enter()
				networkManager.getEvents(provider: provider) { [weak self] result in
					// (Result<(TestResultWrapper, SignedResponse), NetworkError>

					switch result {
						case let .failure(error):
							self?.eventFetchingGroup.leave()
							self?.logError("Error getting event: \(error)")
						case let .success(response):
							self?.logInfo("response: \(response)")
							self?.eventResults.append(response)
							self?.eventFetchingGroup.leave()
					}

				}
			}
		}
		eventFetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedEventFetching()
		}
	}

	private func finishedEventFetching() {

		logInfo("finishedEventFetching")
		progressIndicationCounter.decrement()
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
