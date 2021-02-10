/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import MBProgressHUD

class CreateProofView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		static let imageRatio: CGFloat = 0.75

		// Margins
		static let margin: CGFloat = 20.0
		static let buttonMargin: CGFloat = 54.0
		static let titleTopMargin: CGFloat = 34.0
		static let messageTopMargin: CGFloat = 24.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// the update button
	let primaryButton: Button = {

		let button = Button(title: "Button 1", style: .primary)
		button.rounded = true
		return button
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),

			// Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			primaryButton.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	/// User tapped on the primary button
	@objc func primaryButtonTapped() {

		primaryButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.attributedText = title?.setLineHeight(ViewTraits.titleLineHeight)
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.attributedText = message?.setLineHeight(ViewTraits.messageLineHeight)
		}
	}

	var primaryTitle: String = "" {
		didSet {
			primaryButton.setTitle(primaryTitle, for: .normal)
		}
	}

	/// The user tapped on the primary button
	var primaryButtonTappedCommand: (() -> Void)?
}

class CreateProofViewiewModel: Logging {

	var loggingCategory: String = "CreateProofViewiewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	weak var proofManager: ProofManaging?

	weak var cryptoManager: CryptoManagerProtocol?

	/// The network manager
	var networkManager: NetworkManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String = .next
	@Bindable private(set) var showProgress: Bool = false

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(coordinator: HolderCoordinatorDelegate, proofManager: ProofManaging, cryptoManager: CryptoManagerProtocol, networkManager: NetworkManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager
		self.cryptoManager = cryptoManager
		self.networkManager = networkManager

		self.title = "QR code maken"
		self.message = " datum en tijd erin"

		createProof()
	}

	func createProof() {

		showProgress = true

		networkManager?.getNonce { [weak self] resultwrapper in

			switch resultwrapper {
				case let .success(envelope):

					self?.cryptoManager?.setNonce(envelope.nonce)
					self?.cryptoManager?.setStoken(envelope.stoken)
					self?.cryptoManager?.debug()
					self?.fetchTestProof()
				case let .failure(networkError):
					self?.showProgress = false

					self?.logError("Can't fetch the nonce: \(networkError.localizedDescription)")
					self?.message = "Can't connect"
			}
		}
	}

	/// Fetch the proof
	func fetchTestProof() {

		if let icm = cryptoManager?.generateCommitmentMessage(),
		   let icmDictionary = icm.convertToDictionary(),
		   let stoken = cryptoManager?.getStoken(),
		   let wrapper = proofManager?.getTestWrapper() {

			let dictionary: [String: AnyObject] = [
				"test": generateString(object: wrapper) as AnyObject,
				"stoken": stoken as AnyObject,
				"icm": icmDictionary as AnyObject
			]

			networkManager?.fetchTestResultsWithISM(dictionary: dictionary) { [weak self] resultwrapper in

				switch resultwrapper {
					case let .success((_, data)):
						self?.handleTestProofsResponse(data)
					case let .failure(networkError):
						self?.showProgress = false
						self?.logError("Can't fetch the IsM: \(networkError.localizedDescription)")
						self?.message = "Can't connect"
				}
			}
		}
	}

	private func handleTestProofsResponse(_ data: Data?) {

		if let unwrapped = data {

			logDebug("ISM Response: \(String(decoding: unwrapped, as: UTF8.self))")
		}
		showProgress = false
		cryptoManager?.setProofs(data)
		if let message = cryptoManager?.generateQRmessage() {
			print("message: \(message)")
		}
	}

	func generateString<T>(object: T) -> String where T: Codable {

		if let data = try? JSONEncoder().encode(object),
		   let convertedToString = String(data: data, encoding: .utf8) {
			print("CTR: Converted to \(convertedToString)")
			return convertedToString
		}
		return ""
	}

	func buttonClick() {

		coordinator?.navigateBackToStart()
	}
}

class CreateProofViewController: BaseViewController {

	private let viewModel: CreateProofViewiewModel

	let sceneView = CreateProofView()

	init(viewModel: CreateProofViewiewModel) {

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

		edgesForExtendedLayout = []

		viewModel.$title.binding = {
			self.sceneView.title = $0
		}

		viewModel.$message.binding = {
			self.sceneView.message = $0
		}

		viewModel.$buttonTitle.binding = {
			self.sceneView.primaryTitle = $0
		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.buttonClick()
		}

		viewModel.$showProgress.binding = {

			if $0 {
				MBProgressHUD.showAdded(to: self.sceneView, animated: true)
				self.sceneView.primaryButton.isEnabled = false
			} else {
				MBProgressHUD.hide(for: self.sceneView, animated: true)
				self.sceneView.primaryButton.isEnabled = true
			}
		}
	}

	/// User tapped on the button
	@objc private func closeButtonTapped() {

//		viewModel.dismiss()
	}
}
