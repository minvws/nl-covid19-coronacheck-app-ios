/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

open class ActivityIndicatorView: BaseView {
	
	override open func setupViewHierarchy() {

		super.setupViewHierarchy()

		addSubview(spinner)
	}
	
	override open func setupViewConstraints() {

		super.setupViewConstraints()

		NSLayoutConstraint.activate([
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor)
		])
	}
	
	/// The spinner
	private let spinner: UIActivityIndicatorView = {

		let view = UIActivityIndicatorView()
		view.hidesWhenStopped = true
		view.translatesAutoresizingMaskIntoConstraints = false
		if #available(iOS 13.0, *) {
			view.style = .large
		} else {
			view.style = .whiteLarge
		}
		view.color = C.primaryBlue()
		return view
	}()
	
	public var shouldShowLoadingSpinner: Bool = false {
		didSet {
			if shouldShowLoadingSpinner {
				spinner.startAnimating()
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					// After a short delay (otherwise it's never announced)
					UIAccessibility.post(notification: .layoutChanged, argument: self.spinner)
				}
			} else {
				spinner.stopAnimating()
			}
		}
	}
	
	public var shouldShowLoadingSpinnerWithoutVoiceOver: Bool = false {
		didSet {
			if shouldShowLoadingSpinnerWithoutVoiceOver {
				spinner.startAnimating()
			} else {
				spinner.stopAnimating()
			}
		}
	}
}
