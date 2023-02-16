/*
* Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import UIKit

public struct PagedAnnoucementItem: Equatable {

	/// The title of a new feature page
	public let title: String

	/// The content of a new feature page
	public let content: String

	/// The image of a new feature page
	public let image: UIImage?

	public let imageBackgroundColor: UIColor?

	/// The tagline of a new feature page
	public let tagline: String?
 
	/// The step of the onboarding page
	public let step: Int

	/// The title of the primary "next" button (or `nil` for default)
	public var nextButtonTitle: String?
	
	public init(
		title: String,
		content: String,
		image: UIImage? = nil,
		imageBackgroundColor: UIColor? = nil,
		tagline: String? = nil,
		step: Int,
		nextButtonTitle: String? = nil) {
		self.title = title
		self.content = content
		self.image = image
		self.imageBackgroundColor = imageBackgroundColor
		self.tagline = tagline
		self.step = step
		self.nextButtonTitle = nextButtonTitle
	}
}
