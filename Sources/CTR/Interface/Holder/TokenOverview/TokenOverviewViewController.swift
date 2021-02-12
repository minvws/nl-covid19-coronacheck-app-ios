/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class TokenOverviewView: ScrollView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let buttonWidth: CGFloat = 212.0
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22

		// Margins
		static let margin: CGFloat = 20.0
		static let stackMargin: CGFloat = 48.0
		static let titleTopMargin: CGFloat = UIDevice.current.isSmallScreen ? 10.0 : 34.0
		static let messageTopMargin: CGFloat = 24.0
		static let spacing: CGFloat = 28.0
	}

	/// The title label
	let titleLabel: Label = {

		return Label(title1: nil).multiline()
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(body: nil).multiline()
	}()

	/// The stackview for the content
	let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .fill
		view.spacing = ViewTraits.spacing
		return view
	}()

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		contentView.addSubview(titleLabel)
		contentView.addSubview(messageLabel)
		contentView.addSubview(stackView)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: safeAreaLayoutGuide.topAnchor,
				constant: ViewTraits.titleTopMargin
			),
			titleLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			titleLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),
			titleLabel.bottomAnchor.constraint(
				equalTo: messageLabel.topAnchor,
				constant: -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: contentView.leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: contentView.trailingAnchor,
				constant: -ViewTraits.margin
			),

			// StackView
			stackView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.stackMargin
			),
			stackView.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			stackView.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			)
		])
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
}

/// The identty of a provider
enum TokenIdentifier: String {

	// A Commercial Test Provider
	case code

	/// The GGD
	case qr
}

/// Struct for information to display the different test providers
struct TokenProvider {

	/// The identifer
	let identifier: TokenIdentifier

	/// The name
	let name: String

	/// The subtite
	let subTitle: String
}

class TokenOverviewViewModel: Logging {

	var loggingCategory: String = "TokenOverviewViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var providers: [TokenProvider]

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(
		coordinator: HolderCoordinatorDelegate) {

		self.coordinator = coordinator

		title = .holderTokenOverviewTitle
		message = .holderTokenOverviewText
		providers = [
			TokenProvider(
				identifier: .code,
				name: .holderTokenOverviewCodeTitle,
				subTitle: .holderTokenOverviewCodeText
			),
			TokenProvider(
				identifier: .qr,
				name: .holderTokenOverviewQRTitle,
				subTitle: .holderTokenOverviewQRText
			)
		]
	}

	/// The user selected a provider
	/// - Parameters:
	///   - identifier: the identifier of the provider
	///   - presentingViewController: The presenting viewcontroller
	func providerSelected(
		_ identifier: TokenIdentifier,
		presentingViewController: UIViewController?) {

		logInfo("Provider selected: \(identifier)")

		if identifier == TokenIdentifier.code {
			coordinator?.navigateToTokenEntry()
		} else if identifier == TokenIdentifier.qr {
			// Todo, create scanner and parse code.
		}
	}

	/// The user has no code
	func noCode() {

		logInfo("Provider selected: no code")
		coordinator?.presentInformationPage(title: .holderTokenOverviewNoCode, body: .holderTokenOverviewNoCodeDetails)
	}
}

class TokenOverviewViewController: BaseViewController {

	private let viewModel: TokenOverviewViewModel

	let sceneView = TokenOverviewView()

	init(viewModel: TokenOverviewViewModel) {

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

		viewModel.$title.binding = {

			self.sceneView.title = $0
		}

		viewModel.$message.binding = {

			self.sceneView.message = $0
		}

		viewModel.$providers.binding = { providers in

			for provider in providers {
				self.setupProviderButton(provider)
			}
			self.setupNoCodeButton()
		}
	}

	/// Setup a provider button
	/// - Parameter provider: the provider
	func setupProviderButton(_ provider: TokenProvider) {

		let button = ButtonWithSubtitle()
		button.isUserInteractionEnabled = true
		button.title = provider.name
		button.subtitle = provider.subTitle
		button.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.providerSelected(
				provider.identifier,
				presentingViewController: self
			)
		}
		self.sceneView.stackView.addArrangedSubview(button)
	}

	/// Setup no diigid button
	func setupNoCodeButton() {

		let label = Label(bodyBold: .holderTokenOverviewNoCode)
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(noCodeTapped))
		label.isUserInteractionEnabled = true
		label.addGestureRecognizer(tapGesture)
		sceneView.stackView.addArrangedSubview(label)
	}

	@objc func noCodeTapped() {

		viewModel.noCode()
	}
}
