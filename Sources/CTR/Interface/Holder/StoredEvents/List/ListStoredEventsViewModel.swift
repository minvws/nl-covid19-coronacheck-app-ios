/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation

class ListStoredEventsViewModel: Logging {

	weak var coordinator: (HolderCoordinatorDelegate & OpenUrlProtocol)?

//	private let walletManager: WalletManaging = Current.walletManager
//	let remoteConfigManager: RemoteConfigManaging = Current.remoteConfigManager
//	private let greenCardLoader: GreenCardLoading
//	let mappingManager: MappingManaging = Current.mappingManager

	private lazy var progressIndicationCounter: ProgressIndicationCounter = {
		ProgressIndicationCounter { [weak self] in
			// Do not increment/decrement progress within this closure
			self?.shouldShowProgress = $0
		}
	}()

	@Bindable private(set) var shouldShowProgress: Bool = false

	@Bindable internal var viewState: ListStoredEventsViewController.State

	@Bindable internal var alert: AlertContent?

	@Bindable private(set) var hideForCapture: Bool = false

	private let screenCaptureDetector = ScreenCaptureDetector()

	init(
		coordinator: HolderCoordinatorDelegate & OpenUrlProtocol
//		greenCardLoader: GreenCardLoading
	) {

		self.coordinator = coordinator
//		self.greenCardLoader = greenCardLoader

        viewState = .loading(content: Content(title: "Todo"))

		screenCaptureDetector.screenCaptureDidChangeCallback = { [weak self] isBeingCaptured in
			self?.hideForCapture = isBeingCaptured
		}

//		viewState = getViewState(from: remoteEvents)
	}

	func openUrl(_ url: URL) {

		coordinator?.openUrl(url, inApp: true)
	}
}
