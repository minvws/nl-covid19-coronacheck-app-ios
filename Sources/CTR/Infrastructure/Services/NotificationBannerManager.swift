/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol NotificationBannerManaging {

	/// Show a banner
	/// - Parameters:
	///   - content: the banner content
	///   - callback: the optional callback when the banner is tapped
	func showBanner(content: NotificationBannerContent, callback: (() -> Void)?)

	/// Hide the banner
	func hideBanner()
}

struct NotificationBannerContent: Equatable {

	/// The title of the banner
	let title: String

	/// The message of the banner
	let message: String?

	/// The linked part of the banner
	let link: String?

	/// The icon to display on the banner
	let icon: UIImage?
}

/// The banner manager
class NotificationBannerManager: NotificationBannerManaging {

	/// Singleton instance
	static let shared = NotificationBannerManager()

	var bannerView: BannerView?

	var callback: (() -> Void)?

	var currentContent: NotificationBannerContent?

	/// Show a banner
	/// - Parameters:
	///   - content: the banner content
	///   - callback: the optional callback when the banner is tapped
	func showBanner(content: NotificationBannerContent, callback: (() -> Void)?) {

		guard let window: UIWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
			return
		}
		if content != currentContent {

			self.callback = callback
			self.currentContent = content
			self.bannerView?.removeFromSuperview()

			let view = createBannerView(content)
			window.addSubview(view)
			window.bringSubviewToFront(view)
			self.bannerView = view
			setupViewConstraints(forView: view, window: window)

			UIAccessibility.post(
				notification: .screenChanged,
				argument: bannerView
			)
		}
	}

	/// Create the banner
	/// - Parameters:
	///   - title: the title of the banner
	///   - message: the message of the banner
	///   - icon: the icon of the banner
	/// - Returns: the banner view
	private func createBannerView(_ content: NotificationBannerContent) -> BannerView {

		let view = BannerView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.title = content.title
		view.message = content.message
		view.icon = content.icon

		if content.message != nil && self.callback != nil {
			setupLink(view)
			bannerView?.underline(content.link)
		}
		view.primaryButtonTappedCommand = { [weak self] in
			self?.hideBanner()
		}
		return view
	}

	/// Setup a gesture recognizer for underlined text
	private func setupLink(_ view: BannerView) {

		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
		view.messageTextView.addGestureRecognizer(tapGesture)
		view.messageTextView.isUserInteractionEnabled = true
	}

	// MARK: User interaction

	/// User tapped on the link
	@objc func linkTapped() {

		callback?()
	}

	/// Hide the banner
	func hideBanner() {

		bannerView?.removeFromSuperview()
		bannerView = nil
	}

	private func setupViewConstraints(forView view: BannerView, window: UIWindow) {

		NSLayoutConstraint.activate([
			view.widthAnchor.constraint(
				equalTo: window.widthAnchor
			),
			view.centerXAnchor.constraint(equalTo: window.centerXAnchor),
			view.topAnchor.constraint(equalTo: window.topAnchor)
		])
	}
}
