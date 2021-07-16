/*
* Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
*  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
*
*  SPDX-License-Identifier: EUPL-1.2
*/
  
import XCTest
@testable import CTR
import Nimble

class HolderDashboardViewModelTests: XCTestCase {

	/// Subject under test
	var sut: HolderDashboardViewModel!

	var configSpy: ConfigurationGeneralSpy!
	var cryptoManagerSpy: CryptoManagerSpy!
	var dataStoreManager: DataStoreManager!
	var holderCoordinatorDelegateSpy: HolderCoordinatorDelegateSpy!
	var proofManagerSpy: ProofManagingSpy!

	override func setUp() {
		super.setUp()

		configSpy = ConfigurationGeneralSpy()
		cryptoManagerSpy = CryptoManagerSpy()
		dataStoreManager = DataStoreManager(.inMemory)
		holderCoordinatorDelegateSpy = HolderCoordinatorDelegateSpy()
		proofManagerSpy = ProofManagingSpy()

		sut = HolderDashboardViewModel(
			coordinator: holderCoordinatorDelegateSpy,
			cryptoManager: cryptoManagerSpy,
			proofManager: proofManagerSpy,
			configuration: configSpy,
			dataStoreManager: dataStoreManager
		)
	}

	// MARK: - Tests

}
