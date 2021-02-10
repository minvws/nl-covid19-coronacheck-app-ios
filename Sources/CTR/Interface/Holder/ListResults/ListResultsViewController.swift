/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import EasyTipView

class ListResultView: BaseView {

	/// The display constants
	private struct ViewTraits {

		//		// Dimensions
		//		static let buttonHeight: CGFloat = 52
		//		static let buttonWidth: CGFloat = 212.0
		//		static let titleLineHeight: CGFloat = 26
		//		static let messageLineHeight: CGFloat = 22
		//		static let imageRatio: CGFloat = 0.75
		//
		// Margins
		static let margin: CGFloat = 20.0
		//		static let buttonMargin: CGFloat = 54.0
		//		static let titleTopMargin: CGFloat = 34.0
		//		static let messageTopMargin: CGFloat = 24.0
	}

	/// The header label
	let headerLabel: Label = {

		return Label(caption1: nil)
	}()

	/// The title label
	let titleLabel: Label = {

		return Label(bodyBold: nil)
	}()

	/// The message label
	let messageLabel: Label = {

		return Label(subhead: nil)
	}()

	let disclaimerButton: UIButton = {

		let button = UIButton()
		button.setImage(.questionMark, for: .normal)
		button.titleLabel?.textColor = Theme.colors.dark
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	let selectButton: UIButton = {

		let button = UIButton()
		button.setTitle("?", for: .normal)
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	let topLineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.dark
		return view
	}()

	let bottomLineView: UIView = {

		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = Theme.colors.dark
		return view
	}()

	override func setupViews() {

		super.setupViews()
		view?.backgroundColor = Theme.colors.viewControllerBackground
		disclaimerButton.addTarget(self, action: #selector(disclaimerButtonTapped), for: .touchUpInside)
		selectButton.addTarget(self, action: #selector(selectButtonTapped), for: .touchUpInside)
	}

	/// Setup the hierarchy
	override func setupViewHierarchy() {

		super.setupViewHierarchy()
		addSubview(headerLabel)
		addSubview(disclaimerButton)
		addSubview(topLineView)
		addSubview(titleLabel)
		addSubview(messageLabel)
		addSubview(bottomLineView)
		addSubview(selectButton)
	}

	/// Setup the constraints
	override func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([

			// Header
			headerLabel.centerYAnchor.constraint(equalTo: disclaimerButton.centerYAnchor),
			headerLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			headerLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			headerLabel.bottomAnchor.constraint(
				equalTo: topLineView.topAnchor,
				constant: -ViewTraits.margin
			),

			// Line
			topLineView.heightAnchor.constraint(equalToConstant: 1),
			topLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			topLineView.trailingAnchor.constraint(equalTo: trailingAnchor),

			// Title
			titleLabel.topAnchor.constraint(
				equalTo: topLineView.bottomAnchor,
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
				constant: -4 // -ViewTraits.messageTopMargin
			),

			// Message
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.leadingAnchor.constraint(
				equalTo: leadingAnchor,
				constant: ViewTraits.margin
			),
			messageLabel.trailingAnchor.constraint(
				equalTo: trailingAnchor,
				constant: -ViewTraits.margin
			),
			messageLabel.bottomAnchor.constraint(
				equalTo: bottomLineView.topAnchor,
				constant: -ViewTraits.margin
			),

			// Line
			bottomLineView.heightAnchor.constraint(equalToConstant: 1),
			bottomLineView.leadingAnchor.constraint(equalTo: leadingAnchor),
			bottomLineView.trailingAnchor.constraint(equalTo: trailingAnchor),
			bottomLineView.bottomAnchor.constraint(equalTo: bottomAnchor),

			// Select Button
			selectButton.topAnchor.constraint(
				equalTo: topLineView.topAnchor
			),
			selectButton.leadingAnchor.constraint(
				equalTo: leadingAnchor
			),
			selectButton.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			selectButton.bottomAnchor.constraint(
				equalTo: bottomLineView.bottomAnchor
			),

			// Disclaimer button
			disclaimerButton.topAnchor.constraint(
				equalTo: topAnchor
			),
			disclaimerButton.widthAnchor.constraint(
				equalToConstant: 50
			),
			disclaimerButton.trailingAnchor.constraint(
				equalTo: trailingAnchor
			),
			disclaimerButton.bottomAnchor.constraint(
				equalTo: topLineView.bottomAnchor
			)
		])
	}

	/// User tapped on the primary button
	@objc func selectButtonTapped() {

		selectButtonTappedCommand?()
	}

	/// User tapped on the primary button
	@objc func disclaimerButtonTapped() {

		disclaimerButtonTappedCommand?()
	}

	// MARK: Public Access

	/// The onboarding title
	var header: String? {
		didSet {
			headerLabel.text = header
		}
	}

	/// The onboarding title
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}

	/// The onboarding message
	var message: String? {
		didSet {
			messageLabel.text = message
		}
	}

	/// The user tapped on the primary button
	var disclaimerButtonTappedCommand: (() -> Void)?

	/// The user tapped on the primary button
	var selectButtonTappedCommand: (() -> Void)?
}

class ListResultsView: BaseView {

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

	let resultView: ListResultView = {

		let view = ListResultView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.isHidden = true
		return view
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
		addSubview(resultView)
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

			// Result
			resultView.topAnchor.constraint(
				equalTo: messageLabel.bottomAnchor,
				constant: ViewTraits.margin
			),
			resultView.leadingAnchor.constraint(equalTo: leadingAnchor),
			resultView.trailingAnchor.constraint(equalTo: trailingAnchor),

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

struct ListResultItem {

	let identifier: String
	let date: String
}

class ListResultsViewModel: Logging {

	var loggingCategory: String = "ListResultsViewModel"

	/// Coordination Delegate
	weak var coordinator: HolderCoordinatorDelegate?

	weak var proofManager: ProofManaging?

	@Bindable private(set) var title: String
	@Bindable private(set) var message: String
	@Bindable private(set) var buttonTitle: String
	@Bindable private(set) var recentHeader: String
	@Bindable private(set) var tooltip: String
	@Bindable private(set) var listItem: ListResultItem?

	/// Initializer
	/// - Parameters:
	///   - coordinator: the coordinator delegate
	///   - proofManager: the proof manager
	init(coordinator: HolderCoordinatorDelegate, proofManager: ProofManaging) {

		self.coordinator = coordinator
		self.proofManager = proofManager

		self.title = .holderTestResultsNoResultsTitle
		self.message = .holderTestResultsNoResultsText
		self.buttonTitle = .holderTestResultsBackToMenuButton
		self.recentHeader = .holderTestResultsRecent
		self.tooltip = .holderTestResultsDisclaimer
		self.listItem = nil
		checkResult()
	}

	/// The te test result
	func checkResult() {

		if let wrapper = proofManager?.getTestWrapper() {
			switch wrapper.status {
				case .complete:
					if let result = wrapper.result, result.negativeResult {
						reportTestResult(result)
					} else {
						reportNoTestResult()
					}
				case .pending:
					reportPendingResult()
				default:
					break
			}
		}
	}

	private func reportPendingResult() {

		title = .holderTestResultsPendingTitle
		message = .holderTestResultsPendingText
		buttonTitle = .holderTestResultsBackToMenuButton
		self.listItem = nil
	}

	private func reportNoTestResult() {

		self.title = .holderTestResultsNoResultsTitle
		self.message = .holderTestResultsNoResultsText
		self.buttonTitle = .holderTestResultsBackToMenuButton
		self.listItem = nil
	}

	private func reportTestResult(_ result: TestResult) {

		self.title = .holderTestResultsResultsTitle
		self.message = .holderTestResultsResultsText
		self.buttonTitle = .holderTestResultsResultsButton
		let date = dateFormatter.date(from: result.sampleDate)
		let dateString = dateFormatter2.string(from: date!)

		self.listItem = ListResultItem(identifier: result.unique, date: dateString)
	}

	private lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = .current
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
		dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
		return dateFormatter
	}()

	private lazy var dateFormatter2: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE d MMM HH:mm"
		return dateFormatter
	}()

	func buttonClick() {

		if let item = listItem {
			coordinator?.navigateToCreateProof()
		} else {
			coordinator?.navigateBackToStart()
		}
	}

	func dismiss() {

		if let item = listItem {
			// Todo: Show Alert
		} else {
			coordinator?.navigateBackToStart()
		}
	}
}

class ListResultsViewController: BaseViewController {
	
	private let viewModel: ListResultsViewModel

	let sceneView = ListResultsView()

	init(viewModel: ListResultsViewModel) {

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

		viewModel.$listItem.binding = {
			if let item = $0 {
				self.sceneView.resultView.isHidden = false
				self.sceneView.resultView.header = .holderTestResultsRecent
				self.sceneView.resultView.title = .holderTestResultsNegative
				self.sceneView.resultView.message = item.date

			} else {
				self.sceneView.resultView.isHidden = true
			}

		}

		sceneView.primaryButtonTappedCommand = { [weak self] in
			self?.viewModel.buttonClick()
		}

		var preferences = EasyTipView.Preferences()
		preferences.drawing.foregroundColor = Theme.colors.viewControllerBackground
		preferences.drawing.backgroundColor = Theme.colors.dark
		preferences.drawing.arrowPosition = .bottom

		tooltip = EasyTipView(text: .holderTestResultsDisclaimer, preferences: preferences) // , delegate: self)

		sceneView.resultView.disclaimerButtonTappedCommand = {

			self.tooltip?.show(forView: self.sceneView.resultView.disclaimerButton)
		}

		addCloseButton(action: #selector(closeButtonTapped), accessibilityLabel: .close)
	}

	var tooltip: EasyTipView?

	/// User tapped on the button
	@objc private func closeButtonTapped() {

		viewModel.dismiss()
	}

	/// Add a close button to the navigation bar.
	/// - Parameters:
	///   - action: the action when the users taps the close button
	///   - accessibilityLabel: the label for Voice Over
	func addCloseButton(
		action: Selector?,
		accessibilityLabel: String) {

		let button = UIBarButtonItem(
			image: .cross,
			style: .plain,
			target: self,
			action: action
		)
		button.accessibilityIdentifier = "CloseButton"
		button.accessibilityLabel = accessibilityLabel
		button.accessibilityTraits = UIAccessibilityTraits.button
		navigationItem.hidesBackButton = true
		navigationItem.leftBarButtonItem = button
		navigationController?.navigationItem.leftBarButtonItem = button
		navigationController?.navigationBar.backgroundColor = Theme.colors.viewControllerBackground
	}
}
