/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/

import Foundation
import SnapshotTesting
@testable import CTR
import XCTest

class MessageCardViewTests: XCTestCase {

    func test_onlyTitle() {
        
        // Arrange
        let sut = MessageCardView(config: MessageCardView.Config(
            title: "Title",
            closeButtonCommand: nil,
            ctaButton: nil
        ))

        // Assert
        sut.frame = CGRect(x: 0, y: 0, width: 335, height: 70)
        sut.assertImage(precision: 0.98)
    }
    
    func test_titleWithClose() {
        
        // Arrange
        let sut = MessageCardView(config: MessageCardView.Config(
            title: "Title",
            closeButtonCommand: {},
            ctaButton: nil
        ))

        // Assert
        sut.frame = CGRect(x: 0, y: 0, width: 335, height: 70)
        sut.assertImage(precision: 0.98)
    }
    
    func test_titleWithCTA() {
        
        // Arrange
        let sut = MessageCardView(config: MessageCardView.Config(
            title: "Title",
            closeButtonCommand: nil,
            ctaButton: ("Call To Action", {})
        ))

        // Assert
        sut.frame = CGRect(x: 0, y: 0, width: 335, height: 335)
        sut.assertImage(precision: 0.98)
    }
    
    func test_titleWithCTAWithCloseButton() {
        
        // Arrange
        let sut = MessageCardView(config: MessageCardView.Config(
            title: "Title",
            closeButtonCommand: {},
            ctaButton: ("Call To Action", {})
        ))

        // Assert
        sut.frame = CGRect(x: 0, y: 0, width: 335, height: 250)
        sut.assertImage(precision: 0.98)
    }
    
    func test_longTitleWithLongCTA() {
        
        // Arrange
        let sut = MessageCardView(config: MessageCardView.Config(
            title: "Here is a really really really really long title ",
            closeButtonCommand: nil,
            ctaButton: ("With also a very long call to action button text", {})
        ))

        // Assert
        sut.frame = CGRect(x: 0, y: 0, width: 335, height: 300)
        sut.assertImage(precision: 0.98)
    }
    
    func test_longTitleWithLongCTAWithCloseButton() {
        
        // Arrange
        let sut = MessageCardView(config: MessageCardView.Config(
            title: "Here is a really really really really long title ",
            closeButtonCommand: {},
            ctaButton: ("With also a very long call to action button text", {})
        ))

        // Assert
        sut.frame = CGRect(x: 0, y: 0, width: 335, height: 300)
        sut.assertImage(precision: 0.98)
    }
}
