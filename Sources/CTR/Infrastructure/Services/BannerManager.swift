/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit

protocol BannerManaging {

	/// Show a banner
	/// - Parameters:
	///   - title: the title of the banner
	///   - message: the message of the banner
	///   - link: the linked part of the message
	///   - icon: the icon of the banner
	///   - callback: the callback when the linked part is tapped
	func showBanner(title: String, message: String?, link: String?, icon: UIImage?, callback: (() -> Void)?)

	/// Hide the banner
	func hideBanner()
}

/// The banner manager
class BannerManager: BannerManaging {

	/// Singleton instance
	static let shared = BannerManager()

	var bannerView: BannerView?

	var callback: (() -> Void)?

	/// Show a banner
	/// - Parameters:
	///   - title: the title of the banner
	///   - message: the message of the banner
	///   - link: the linked part of the message
	///   - icon: the icon of the banner
	///   - callback: the callback when the linked part is tapped
	func showBanner(title: String, message: String?, link: String?, icon: UIImage?, callback: (() -> Void)?) {

		guard let window: UIWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow }) else {
			return
		}
		self.callback = callback

		if title != bannerView?.title && message != bannerView?.message {
			bannerView?.removeFromSuperview()

			let view = createBannerView(title: title, message: message, icon: icon)
			window.addSubview(view)
			window.bringSubviewToFront(view)
			bannerView = view
			setupViewConstraints(forView: view, window: window)

			if message != nil && callback != nil {
				setupLink(view)
				bannerView?.underline(link)
			}

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
	private func createBannerView(title: String, message: String?, icon: UIImage?) -> BannerView {

		let view = BannerView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.title = title
		view.message = message
		view.icon = icon
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
