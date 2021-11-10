/*
 * Copyright (c) 2021 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

import Foundation

final class IncompleteDutchVaccinationViewModel: Logging {
	
	@Bindable private(set) var title: String
	@Bindable private(set) var secondVaccineText: String
	@Bindable private(set) var coronaBeforeFirstVaccineText: String
	@Bindable private(set) var learnMoreText: String
	
	@Bindable private(set) var addVaccinesButtonTitle: String
	@Bindable private(set) var addTestResultsButtonTitle: String
	
	private weak var coordinatorDelegate: HolderCoordinatorDelegate?
	
	init(coordinatorDelegate: HolderCoordinatorDelegate?) {
		self.coordinatorDelegate = coordinatorDelegate
 
		title = L.holderIncompletedutchvaccinationTitle()
		secondVaccineText = L.holderIncompletedutchvaccinationParagraphSecondvaccine()
		coronaBeforeFirstVaccineText = L.holderIncompletedutchvaccinationParagraphCoronabeforefirstvaccine()
		learnMoreText = L.holderIncompletedutchvaccinationParagraphLearnmore()
		
		addVaccinesButtonTitle = L.holderIncompletedutchvaccinationButtonAddvaccines()
		addTestResultsButtonTitle = L.holderIncompletedutchvaccinationButtonAddtestresults()
	}
	
	func didTapAddVaccines() {
		coordinatorDelegate?.userWishesToCreateAVaccinationQR()
	}
	
	func didTapAddTestResults() {
		coordinatorDelegate?.userWishesToFetchPositiveTests()
	}
}
