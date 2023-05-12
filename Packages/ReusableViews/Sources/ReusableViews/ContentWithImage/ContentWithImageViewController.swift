/*
*  Copyright (c) 2023 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import UIKit
import Shared

public class ContentWithImageViewController: TraitWrappedGenericViewController<ContentWithImageView, ContentWithImageProtocol> {
		
	public struct Action: Equatable {

		public let title: String
		public let action: (() -> Void)?

		public static func == (lhs: Action, rhs: Action) -> Bool {
			return lhs.title == rhs.title
		}

		public init(
			title: String,
			action: (() -> Void)? = nil) {
				
			self.title = title
			self.action = action
		}
	}
	
	public struct Content: Equatable {

		public let title: String
		public let body: String
		public let primaryAction: ContentWithImageViewController.Action
		public let secondaryAction: ContentWithImageViewController.Action?
		public let image: UIImage?

		public static func == (lhs: Content, rhs: Content) -> Bool {
			return lhs.title == rhs.title &&
				lhs.body == rhs.body &&
				lhs.primaryAction == rhs.primaryAction &&
				lhs.secondaryAction == rhs.secondaryAction &&
				lhs.image == rhs.image
		}

		public init(
			title: String,
			body: String,
			primaryAction: ContentWithImageViewController.Action,
			secondaryAction: ContentWithImageViewController.Action? = nil,
			image: UIImage?) {
				
			self.title = title
			self.body = body
			self.primaryAction = primaryAction
			self.secondaryAction = secondaryAction
			self.image = image
		}
	}
	
	override public func viewDidLoad() {

		super.viewDidLoad()
		setupContent()
		addBackButton()
	}
	
	func setupContent() {
		
		viewModel.content.observe { [weak self] content in
			self?.sceneView.title = content.title
			self?.sceneView.message = content.body
			self?.sceneView.primaryTitle = content.primaryAction.title
			self?.sceneView.primaryButtonTappedCommand = content.primaryAction.action
			if let secondaryAction = content.secondaryAction {
				self?.sceneView.secondaryTitle = secondaryAction.title
				self?.sceneView.secondaryButtonCommand = secondaryAction.action
			} else {
				self?.sceneView.secondaryTitle = nil
				self?.sceneView.secondaryButtonCommand = nil
			}
			self?.sceneView.image = content.image
		}
	}
}
