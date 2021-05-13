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
	private var accessTokens = [Vaccination.AccessToken]()

	/// List of event providers
	private var eventProviders = [Vaccination.EventProvider]()

	private var eventInformationAvailableResults = [Vaccination.EventInformationAvailable]()

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
	let hasEventInformationFetchingGroup = DispatchGroup()
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

	private func fetchVaccinationAccessTokens() {

		networkManager.fetchVaccinationAccessTokens(tvsToken: tvsToken) { [weak self] result in
			switch result {
				case let .failure(error):
					self?.logError("Error getting access tokens: \(error)")
				case let .success(tokens):
					self?.accessTokens = tokens
			}
			self?.prefetchingGroup.leave()
		}
	}

	private func fetchVaccinationEventProviders() {

		networkManager.getVaccinationEventProviders { [weak self] result in
			switch result {
				case let .failure(error):
					self?.logError("Error getting event providers: \(error)")
				case let .success(providers):
					self?.eventProviders = providers
			}
			self?.prefetchingGroup.leave()
		}
	}

	private func startFetching() {

		progressIndicationCounter.increment()
		prefetchingGroup.enter()
		fetchVaccinationAccessTokens()
		prefetchingGroup.enter()
		fetchVaccinationEventProviders()

		prefetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedFetching()
		}
	}

	private func finishedFetching() {

		progressIndicationCounter.decrement()
		updateEventProvidersWithAccessTokens()
		fetchHasEventInformationResponses()
	}

	private func updateEventProvidersWithAccessTokens() {

		for index in 0 ..< eventProviders.count {
			for accessToken in accessTokens where eventProviders[index].identifier == accessToken.providerIdentifier {
				eventProviders[index].accessToken = accessToken
			}
		}
	}

	private func fetchHasEventInformationResponses() {

		progressIndicationCounter.increment()
		for provider in eventProviders {
			fetchHasEventInformationResponse(provider)
		}
		hasEventInformationFetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedHasEventInformationFetching()
		}
	}

	private func fetchHasEventInformationResponse(_ provider: Vaccination.EventProvider) {

		if let url = provider.unomiURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https") {

			self.logInfo("evenprovider: \(provider.identifier) - \(provider.name) - \(String(describing: provider.unomiURL?.absoluteString))")

			hasEventInformationFetchingGroup.enter()
			networkManager.fetchVaccinationEventInformation(provider: provider) { [weak self] result in
				// Result<UnomiResponse, NetworkError>
				switch result {
					case let .failure(error):
						self?.logError("Error getting unomi: \(error)")
					case let .success(response):
						self?.eventInformationAvailableResults.append(response)
				}
				self?.hasEventInformationFetchingGroup.leave()
			}
		}
	}

	private func finishedHasEventInformationFetching() {

		progressIndicationCounter.decrement()
		updateEventProvidersWithUnomiResponse()
		fetchEvents()
	}

	private func updateEventProvidersWithUnomiResponse() {

		for index in 0 ..< eventProviders.count {
			for response in eventInformationAvailableResults where eventProviders[index].identifier == response.providerIdentifier {
				eventProviders[index].hasEventInformationAvailable = response.informationAvailable
			}
		}
	}

	private func fetchEvents() {

		progressIndicationCounter.increment()

		for provider in eventProviders {
			fetchEvent(provider)
		}
		eventFetchingGroup.notify(queue: DispatchQueue.main) { [weak self] in
			self?.finishedEventFetching()
		}
	}

	private func fetchEvent(_ provider: Vaccination.EventProvider) {

		if let url = provider.eventURL?.absoluteString, provider.accessToken != nil, url.starts(with: "https"), provider.hasEventInformationAvailable {

			eventFetchingGroup.enter()
			networkManager.fetchVaccinationEvents(provider: provider) { [weak self] result in
				// (Result<(TestResultWrapper, SignedResponse), NetworkError>

				switch result {
					case let .failure(error):
						self?.logError("Error getting event: \(error)")
					case let .success(response):
						self?.eventResults.append(response)
				}
				self?.eventFetchingGroup.leave()
			}
		}
	}

	private func finishedEventFetching() {

		logInfo("finishedEventFetching")
		progressIndicationCounter.decrement()
		// To do:
		// - Store vaccination events in Core Data
		// - Enable SSL checking for unomi and event calls.
	}
}

class FetchEventsViewController: BaseViewController {

	private let viewModel: FetchEventsViewModel
	private let sceneView = FetchEventsView()

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
