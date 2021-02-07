//
/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

class ConsentView: BaseView {

	/// The display constants
	private struct ViewTraits {

		// Dimensions
		static let buttonHeight: CGFloat = 52
		static let titleLineHeight: CGFloat = 26
		static let messageLineHeight: CGFloat = 22
		static let buttonWidth: CGFloat = 182.0

		// Margins
		static let margin: CGFloat = 20.0
	}

	/// The scrollview
	private let scrollView: UIScrollView = {

		let view = UIScrollView(frame: .zero)
		view.translatesAutoresizingMaskIntoConstraints = false
		return view
	}()

	/// The stackview for the content
	private let stackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .equalSpacing
		view.spacing = ViewTraits.margin
		return view
	}()

	/// The stack view for the privacy hightlight items
	private let itemStackView: UIStackView = {

		let view = UIStackView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.axis = .vertical
		view.alignment = .fill
		view.distribution = .equalSpacing
		view.spacing = ViewTraits.margin
		return view
	}()

	/// The title label
	private let titleLabel: Label = {

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

	let consentButton: ConsentButton = {

		let button = ConsentButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	/// setup the views
	override func setupViews() {

		super.setupViews()
		backgroundColor = Theme.colors.viewControllerBackground
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(messageLabel)
		stackView.addArrangedSubview(itemStackView)
		stackView.addArrangedSubview(consentButton)

		scrollView.addSubview(stackView)

		addSubview(scrollView)
		addSubview(primaryButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Scrollview
			scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
			scrollView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
			scrollView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
			scrollView.bottomAnchor.constraint(
				equalTo: primaryButton.topAnchor,
				constant: -ViewTraits.margin
			),

			// StackView
			stackView.widthAnchor.constraint(
				equalTo: scrollView.widthAnchor,
				constant: -2.0 * ViewTraits.margin
			),
			stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
			stackView.topAnchor.constraint(
				equalTo: scrollView.topAnchor,
				constant: ViewTraits.margin
			),
			stackView.bottomAnchor.constraint(
				equalTo: scrollView.bottomAnchor,
				constant: -ViewTraits.margin
			),

			// Primary Button
			primaryButton.heightAnchor.constraint(equalToConstant: ViewTraits.buttonHeight),
			primaryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
			primaryButton.widthAnchor.constraint(equalToConstant: ViewTraits.buttonWidth),
			primaryButton.bottomAnchor.constraint(
				equalTo: safeAreaLayoutGuide.bottomAnchor,
				constant: -ViewTraits.margin
			)
		])
	}

	// MARK: - Public Access

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

	/// Underline part ot the message
	/// - Parameter text: the text to underline
	func underline(_ text: String?) {

		guard let underlinedText = text,
			  let messageText = message else {
			return
		}

		let attributedUnderlined = messageText.underline(underlined: underlinedText, with: Theme.colors.iosBlue)
		messageLabel.attributedText = attributedUnderlined.setLineHeight(ViewTraits.messageLineHeight)
	}

	var consent: String? {
		didSet {
			consentButton.setTitle(consent, for: .normal)
		}
	}

	/// Add a privacy item
	/// - Parameter text: the privacy text
	func addPrivacyItem(_ text: String) {

		let label = Label(body: nil, textColor: Theme.colors.dark).multiline()
		label.attributedText = text.setLineHeight(ViewTraits.messageLineHeight)

		let stack = HStack(
			spacing: 16,
			ImageView(imageName: "PrivacyItem").asIcon(),
			label
		)
		.alignment(.top)
		itemStackView.addArrangedSubview(stack)
	}
}

class ConsentViewModel {

	/// Coordination Delegate
	weak var coordinator: OnboardingCoordinatorDelegate?

	/// Is the button enabled?
	@Bindable private(set) var isContinueButtonEnabled: Bool
	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var underlinedText: String?
	@Bindable private(set) var consentText: String?
	@Bindable private(set) var summary: [String]

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	init(coordinator: OnboardingCoordinatorDelegate) {

		self.coordinator = coordinator
		self.title = .consentTitle
		self.message = .consentMessage
		self.underlinedText = .consentMessageUnderlined
		self.consentText = .consentButtonTitle
		self.summary = [
			.consentItemOne,
			.consentItemTwo,
			.consentItemThree,
			.consentItemFour
		]
		self.isContinueButtonEnabled = false
	}

	/// The user tapped on the consent buton
	/// - Parameter given: True if consent is given
	func consentGiven(_ given: Bool) {

		isContinueButtonEnabled = given
	}

	/// The user tapped on the privacy link
	/// - Parameter viewController: the presenting view controller
	func linkClicked(_ presentingViewController: UIViewController) {

		coordinator?.showPrivacyPage(presentingViewController)
	}

	/// The user tapped on the primary button
	func primaryButtonTapped() {

		coordinator?.consentGiven()
	}
}

class ConsentViewController: BaseViewController {

	/// The model
	private let viewModel: ConsentViewModel

	/// The view
	let sceneView = ConsentView()

	/// The page controller
	private var pageViewController: UIPageViewController?

	/// Initializer
	/// - Parameter viewModel: view model
	init(viewModel: ConsentViewModel) {

		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
	}

	/// Required initialzer
	/// - Parameter coder: the code
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// Show always in portrait
	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		return .portrait
	}

	// MARK: View lifecycle
	override func loadView() {

		view = sceneView
	}

	override func viewDidLoad() {

		super.viewDidLoad()

		viewModel.$title.binding = { self.sceneView.title = $0 }
		viewModel.$message.binding = { self.sceneView.message = $0 }
		viewModel.$underlinedText.binding = {
			self.sceneView.underline($0)
			self.setupLink()
		}

		viewModel.$isContinueButtonEnabled.binding = { self.sceneView.primaryButton.isEnabled = $0 }
		sceneView.primaryButton.setTitle(.next, for: .normal)
		sceneView.primaryButton.touchUpInside(self, action: #selector(primaryButtonTapped))

		viewModel.$consentText.binding = {
			self.sceneView.consent = $0
		}
		self.sceneView.consentButton.valueChanged(self, action: #selector(consentValueChanged))

		viewModel.$summary.binding = {

			for item in $0 {
				self.sceneView.addPrivacyItem(item)
			}
		}
	}

	/// Setup a gesture recognizer for underlined text
	private func setupLink() {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		sceneView.messageLabel.addGestureRecognizer(tapGesture)
		sceneView.messageLabel.isUserInteractionEnabled = true
	}

	/// User tapped on the consent button
	@objc func consentValueChanged(_ sender: ConsentButton) {

		viewModel.consentGiven(sender.isSelected)
	}

	/// User tapped on the link
	@objc func linkTapped() {

		viewModel.linkClicked(self)
	}

	/// The user tapped on the primary button
	@objc func primaryButtonTapped() {

		viewModel.primaryButtonTapped()
	}
}
