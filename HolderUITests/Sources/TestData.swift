/*
 * Copyright (c) 2022 De Staat der Nederlanden, Ministerie van Volksgezondheid, Welzijn en Sport.
 *  Licensed under the EUROPEAN UNION PUBLIC LICENCE v. 1.2
 *
 *  SPDX-License-Identifier: EUPL-1.2
 */

final class TestData {
	
	// Vaccinations
	static let vacP1 = TestPerson(bsn: "999990019", doseIntl: ["1/2"]) // 1 pfizer
	static let vacP2 = TestPerson(bsn: "999990020", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 240) // 2 pfizer
	static let vacP3 = TestPerson(bsn: "999990032", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -30) // 3 pfizer
	static let vacP4 = TestPerson(bsn: "999990044", dose: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], vacFrom: -30) // 4 pfizer
	static let vacJ1 = TestPerson(bsn: "999990081", dose: 1, doseIntl: ["1/1"], vacFrom: -2, vacUntil: 240) // 1 janssen
	static let vacJ2 = TestPerson(bsn: "999990093", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30) // 2 janssen
	static let vacM1 = TestPerson(bsn: "999990147", doseIntl: ["1/2"]) // 1 moderna
	static let vacM2 = TestPerson(bsn: "999990159", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 240) // 2 moderna
	static let vacM3 = TestPerson(bsn: "999990160", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -30) // 3 moderna
	static let vacM4 = TestPerson(bsn: "999990172", dose: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], vacFrom: -30) // 4 moderna
	static let vacM5 = TestPerson(bsn: "999990184", dose: 5, doseIntl: ["1/2", "2/2", "3/3", "4/4", "5/5"], vacFrom: -30) // 5 moderna
	
	// Vaccinations - combinations
	static let vacP1J1 = TestPerson(bsn: "999990196", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30) // 1 pfizer + 1 janssen
	static let vacP1M1 = TestPerson(bsn: "999990287", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 240) // 1 pfizer + 1 moderna
	static let vacP1M2 = TestPerson(bsn: "999990299", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -30) // 1 pfizer + 2 moderna
	static let vacP1M3 = TestPerson(bsn: "999990305", dose: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], vacFrom: -30) // 1 pfizer + 3 moderna
	static let vacP2M1 = TestPerson(bsn: "999990317", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -30) // 2 pfizer + 1 moderna
	static let vacP2M2 = TestPerson(bsn: "999990329", dose: 4, doseIntl: ["1/2", "2/2", "3/3", "4/4"], vacFrom: -30) // 2 pfizer + 2 moderna
	static let vacJ1M1 = TestPerson(bsn: "999990366", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30) // 1 janssen + 1 moderna
	static let vacJ1M2 = TestPerson(bsn: "999990378", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -30) // 1 janssen + 2 moderna
	static let vacJ2M1 = TestPerson(bsn: "999990408", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -30) // 2 janssen + 1 moderna
	
	// Vaccinations - vaccination elsewhere
	static let vacP1PersonalStatementVacElsewhere = TestPerson(bsn: "999993501", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 pfizer + personal statement + vaccination elsewhere
	static let vacP1PersonalStatementPriorEvent = TestPerson(bsn: "999993525", doseIntl: ["1/2"]) // 1 pfizer + personal statement + prior event
	static let vacP2PersonalStatementVacElsewhereBoth = TestPerson(bsn: "999992934", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30, vacUntil: 240) // 2 pfizer + personal statement + vaccination elsewhere both
	static let vacP2PersonalStatementPriorEventBoth = TestPerson(bsn: "999993136", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240) // 2 pfizer + personal statement + prior event both
	static let vacP2PersonalStatementVacElsewhereFirst = TestPerson(bsn: "999993537", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30) // 2 pfizer + personal statement + vaccination elsewhere first
	static let vacP2PersonalStatementPriorEventFirst = TestPerson(bsn: "999993550", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240) // 2 pfizer + personal statement + prior event first
	
	// Vaccinations - personal statement
	static let vacP1PersonalStatement = TestPerson(bsn: "999990457", dose: 1, doseIntl: ["1/1"], vacFrom: -16, vacUntil: 240) // 1 pfizer + personal statement 'recovery'
	static let vacP2PersonalStatement = TestPerson(bsn: "999990469", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30) // 2 pfizer + personal statement 'recovery'
	static let vacP3PersonalStatement = TestPerson(bsn: "999990470", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -30) // 3 pfizer + personal statement 'recovery'
	static let vacJ1PersonalStatement = TestPerson(bsn: "999990482", dose: 1, doseIntl: ["1/1"], vacFrom: -16, vacUntil: 240) // 1 janssen + personal statement 'recovery'
	static let vacM1PersonalStatement = TestPerson(bsn: "999990524", dose: 1, doseIntl: ["1/1"], vacFrom: -16, vacUntil: 240) // 1 moderna + personal statement 'recovery'
	static let vacM3PersonalStatement = TestPerson(bsn: "999990548", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -30) // 3 moderna + personal statement 'recovery'
	
	// Vaccinations - medical statement
	static let vacP1MedicalStatement = TestPerson(bsn: "999990561", dose: 1, doseIntl: ["1/1"], vacFrom: -16, vacUntil: 240) // 1 pfizer + medical statement 'recovery'
	static let vacP2MedicalStatement = TestPerson(bsn: "999990573", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30) // 2 pfizer + medical statement 'recovery'
	static let vacM1MedicalStatement = TestPerson(bsn: "999990639", dose: 1, doseIntl: ["1/1"], vacFrom: -16, vacUntil: 240) // 1 moderna + medical statement 'recovery'
	static let vacM3MedicalStatement = TestPerson(bsn: "999990652", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -30) // 3 moderna + medical statement 'recovery'
	
	// Vaccinations - dose numbers
	static let vacP1DoseNumbers = TestPerson(bsn: "999990664", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 pfizer + dose numbers 1/2
	static let vacP2DoseNumbers = TestPerson(bsn: "999990676", dose: 3, doseIntl: ["2/2", "3/3"], vacFrom: -30) // 2 pfizer + dose numbers 1/2 en 2/2
	static let vacP3DoseNumbers = TestPerson(bsn: "999990688", dose: 5, doseIntl: ["3/3", "4/4", "5/5"], vacFrom: -30) // 3 pfizer + dose numbers 1/2, 2/2, 3/3
	static let vacJ1DoseNumbers = TestPerson(bsn: "999990706", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen + dose numbers 1/1
	static let vacM1DoseNumbers = TestPerson(bsn: "999990755", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 moderna + dose numbers 1/2
	static let vacM3DoseNumbers = TestPerson(bsn: "999990779", dose: 5, doseIntl: ["3/3", "4/4", "5/5"], vacFrom: -30) // 3 moderna + dose numbers 1/2, 2/2, 3/3
	
	// Vaccinations - last dose older than a year
	static let vacP1Old = TestPerson(bsn: "999990780", doseIntl: ["1/2"], vacOffset: -390) // 1 pfizer old
	static let vacP2Old = TestPerson(bsn: "999990792", doseIntl: ["1/2", "2/2"], vacOffset: -390) // 2 pfizer old
	static let vacP1P1Old = TestPerson(bsn: "999990809", doseIntl: ["1/2", "2/2"], vacOffset: -390) // 1 pfizer + 1 pfizer old
	static let vacJ1Old = TestPerson(bsn: "999990810", doseIntl: ["1/1"], vacOffset: -390) // 1 janssen old
	static let vacJ1J1Old = TestPerson(bsn: "999990834", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -390, vacOffset: -390) // 1 janssen + 1 janssen old
	static let vacM1Old = TestPerson(bsn: "999990858", doseIntl: ["1/2"], vacOffset: -390) // 1 moderna old
	static let vacM2Old = TestPerson(bsn: "999990871", doseIntl: ["1/2", "2/2"], vacOffset: -390) // 2 moderna old
	static let vacM1M1Old = TestPerson(bsn: "999990883", doseIntl: ["1/2", "2/2"], vacOffset: -390) // 1 moderna + 1 moderna old
	static let vacP1J1Old = TestPerson(bsn: "999990895", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -390, vacOffset: -390) // 1 pfizer + 1 janssen old
	static let vacP1OldJ2 = TestPerson(bsn: "999990901", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -390, vacOffset: -390) // 1 pfizer old + 2 janssen
	static let vacP1M1Old = TestPerson(bsn: "999990913", doseIntl: ["1/2", "2/2"], vacOffset: -390) // 1 pfizer + 1 moderna old
	static let vacP1OldM2 = TestPerson(bsn: "999990925", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -390, vacOffset: -390) // 1 pfizer old + 2 moderna
	static let vacJ1OldM2 = TestPerson(bsn: "999990949", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -390, vacOffset: -390) // 1 janssen old + 2 moderna
	
	// Vaccinations - nearly valid
	static let vacP2DatedToday = TestPerson(bsn: "999993586", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: 14, vacOffset: -0) // 2 pfizer dated today
	static let vacJ1DatedToday = TestPerson(bsn: "999992983", dose: 1, doseIntl: ["1/1"], vacFrom: 28, vacOffset: -0) // 1 janssen dated today
	static let vacM2DatedToday = TestPerson(bsn: "999993598", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: 14, vacOffset: -0) // 2 moderna dated today
	static let vacP2ValidTomorrow = TestPerson(bsn: "999993604", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: 1, vacOffset: -13) // 2 pfizer valid tomorrow
	static let vacJ1ValidTomorrow = TestPerson(bsn: "999993616", dose: 1, doseIntl: ["1/1"], vacFrom: 1, vacOffset: -27) // 1 janssen valid tomorrow
	static let vacM2ValidTomorrow = TestPerson(bsn: "999993628", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: 1, vacOffset: -13) // 2 moderna valid tomorrow
	static let vacP2ValidToday = TestPerson(bsn: "999993641", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: 0, vacUntil: 256, vacOffset: -14) // 2 pfizer valid today
	static let vacJ1ValidToday = TestPerson(bsn: "999993653", dose: 1, doseIntl: ["1/1"], vacFrom: 0, vacUntil: 242, vacOffset: -28) // 1 janssen valid today
	static let vacM2ValidToday = TestPerson(bsn: "999993665", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: 0, vacUntil: 256, vacOffset: -14) // 2 moderna valid today
	
	// Vaccinations - future
	static let vacP1Future = TestPerson(bsn: "999990950") // 1 pfizer future
	static let vacP2Future = TestPerson(bsn: "999990962") // 2 pfizer future
	static let vacP1P1Future = TestPerson(bsn: "999990974", doseIntl: ["1/2"]) // 1 pfizer + 1 pfizer future
	static let vacJ1Future = TestPerson(bsn: "999990986") // 1 janssen future
	static let vacM2Future = TestPerson(bsn: "999991036") // 2 moderna future
	static let vacM1M1Future = TestPerson(bsn: "999991048", doseIntl: ["1/2"]) // 1 moderna + 1 moderna future
	static let vacP1M1Future = TestPerson(bsn: "999991085", doseIntl: ["1/2"]) // 1 pfizer + 1 moderna future
	static let vacP1FutureM2 = TestPerson(bsn: "999991097", dose: 2, doseIntl: ["1/2", "2/2"]) // 1 pfizer future + 2 moderna
	static let vacJ1M1Future = TestPerson(bsn: "999991103", dose: 1, doseIntl: ["1/1"]) // 1 janssen + 1 moderna future
	static let vacJ1FutureM2 = TestPerson(bsn: "999991115", dose: 2, doseIntl: ["1/2", "2/2"]) // 1 janssen future + 2 moderna
	
	// Vaccinations - error states
	static let vacNoVaccination = TestPerson(bsn: "999991127") // no vaccination
	static let vacP2SameDate = TestPerson(bsn: "999991139", dose: 1, doseIntl: ["1/2"], vacFrom: -16, vacUntil: 240) // 2 pfizer same date
	static let vacP1J1SameDate = TestPerson(bsn: "999991140", dose: 1, doseIntl: ["1/1"], vacFrom: -2, vacUntil: 240) // 1 pfizer + 1 janssen same date
	static let vacP1M1SameDate = TestPerson(bsn: "999991164", doseIntl: ["1/2"]) // 1 pfizer + 1 moderna same date
	static let vacP2EmptyFirstName = TestPerson(bsn: "999991176", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 240) // 2 pfizer empty first name
	static let vacP2EmptyLastName = TestPerson(bsn: "999991188", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 240) // 2 pfizer empty last name
	static let vacP2BirthdateXXXX = TestPerson(bsn: "999991206", birthDate: "1960-XX-XX") // 2 pfizer birthdate XX-XX
	static let vacP2BirthdateXX01 = TestPerson(bsn: "999993008", birthDate: "1960-XX-01", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 240) // 2 pfizer birthdate XX-01
	static let vacP2BirthdateJAN01 = TestPerson(bsn: "999991231", birthDate: "1960-JAN-01") // 2 pfizer birthdate JAN-01
	static let vacP2Birthdate0101 = TestPerson(bsn: "999991243", birthDate: "19600101") // 2 pfizer birthdate 0101
	
	// Vaccinations - event matching
	static let vacP2DifferentSetupSituation = TestPerson(bsn: "999993562", name: "van Geer, Corrie", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 210, vacOffset: -60) // 2 pfizer setup situation
	static let vacJ1DifferentFirstNameReplaces = TestPerson(bsn: "999991255", name: "van Geer, Pieter", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen different first name, replaces setup
	static let vacJ1DifferentLastNameReplaces = TestPerson(bsn: "999991267", name: "de Heuvel, Corrie", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen different last name, replaces setup
	static let vacJ1DifferentFullNameReplaces = TestPerson(bsn: "999992156", name: "de Heuvel, Pieter", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen different full name, replaces setup
	static let vacJ1DifferentBirthDayCanReplace = TestPerson(bsn: "999991279", birthDate: "1960-01-02", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen different birth day, can replace setup
	static let vacJ1DifferentBirthMonthCanReplace = TestPerson(bsn: "999993021", birthDate: "1960-02-01", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen different birth month, can replace setup
	static let vacJ1DifferentBirthYearReplaces = TestPerson(bsn: "999991292", birthDate: "1970-01-01", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen different birth year, replaces setup
	static let vacJ1DifferentEverythingReplaces = TestPerson(bsn: "999991723", name: "de Heuvel, Pieter", birthDate: "1970-02-02", dose: 1, doseIntl: ["1/1"], vacUntil: 240) // 1 janssen different full name and birthdate, replaces setup
	
	// Vaccinations - around 18
	static let around18Is17y8mWithP2LastDose1M = TestPerson(bsn: "999993422", birthDate: "2004-08-01", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16) // 2 pfizer, 4 months before 18, last dose 1 month ago
	static let around18Is17y10mWithP2LastDose1M = TestPerson(bsn: "999993434", birthDate: "2004-06-01", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 240) // 2 pfizer, 2 months before 18, last dose 1 month ago
	static let around18Is17y10mWithP2LastDose9M = TestPerson(bsn: "999993446", birthDate: "2004-06-01", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -256, vacUntilDate: "2022-06-01", vacOffset: -270) // 2 pfizer, 2 months before 18, last dose 9 months ago
	static let around18Is18y2mWithP2LastDose3M = TestPerson(bsn: "999992417", birthDate: "2004-02-01", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -76, vacUntil: 180, vacOffset: -90) // 2 pfizer, 2 months after 18, last dose 3 months ago
	static let around18Is18y2mWithP2LastDose9M = TestPerson(bsn: "999993173", birthDate: "2004-02-01", dose: 2, doseIntl: ["1/2", "2/2"], vacOffset: -270) // 2 pfizer, 2 months after 18, last dose 9 months ago
	static let around18Is17y8mWithJ1LastDose1M = TestPerson(bsn: "999993458", birthDate: "2004-08-01", dose: 1, doseIntl: ["1/1"], vacFrom: -2) // 1 janssen, 4 months before 18, last dose 1 month ago
	static let around18Is17y10mWithJ1LastDose1M = TestPerson(bsn: "999993471", birthDate: "2004-06-01", dose: 1, doseIntl: ["1/1"], vacFrom: -2, vacUntil: 240) // 1 janssen, 2 months before 18, last dose 1 month ago
	static let around18Is17y10mWithJ1LastDose9M = TestPerson(bsn: "999993483", birthDate: "2004-06-01", dose: 1, doseIntl: ["1/1"], vacFrom: -242, vacUntilDate: "2022-06-01", vacOffset: -270) // 1 janssen, 2 months before 18, last dose 9 months ago
	static let around18Is18y2mWithJ1LastDose3M = TestPerson(bsn: "999993185", birthDate: "2004-02-01", dose: 1, doseIntl: ["1/1"], vacFrom: -62, vacUntil: 180, vacOffset: -90) // 1 janssen, 2 months after 18, last dose 3 months ago
	static let around18Is18y2mWithJ1LastDose9M = TestPerson(bsn: "999993197", birthDate: "2004-02-01", dose: 1, doseIntl: ["1/1"], vacOffset: -270) // 1 janssen, 2 months after 18, last dose 9 months ago
	
	// Vaccination - Null or empty information
	static let vacP1NullPersonalStatement = TestPerson(bsn: "999992818", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + personal statement = null
	static let vacP1NullMedicalStatement = TestPerson(bsn: "999992831", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + medical statement = null
	static let vacP1NullFirstName = TestPerson(bsn: "999992843", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + first name = null
	static let vacP1NullLastName = TestPerson(bsn: "999992855", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + last name = null
	static let vacP1NullBirthdate = TestPerson(bsn: "999992867", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + birthdate = null
	static let vacP1EmptyPersonalStatement = TestPerson(bsn: "999992879", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + personal statement = empty
	static let vacP1EmptyMedicalStatement = TestPerson(bsn: "999992880", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + medical statement = empty
	static let vacP1EmptyFirstName = TestPerson(bsn: "999992892", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + first name = empty
	static let vacP1EmptyLastName = TestPerson(bsn: "999992909", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + last name = empty
	static let vacP1EmptyBirthdate = TestPerson(bsn: "999992910", doseIntl: ["1/2"], vacOffset: 0) // 1 pfizer + birthdate = empty
	
	// Positive tests (and combinations)
	static let posPcr = TestPerson(bsn: "999993033", recFrom: -19, recUntil: 150) // Positive PCR (NAAT)
	static let posPcrP1 = TestPerson(bsn: "999991346", doseIntl: ["1/2"], vacOffset: -60, recFrom: -19, recUntil: 150) // Positive PCR (NAAT) + 1 pfizer
	static let posPcrP2 = TestPerson(bsn: "999991358", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -60, vacUntil: 210, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 2 pfizer
	static let posPcrP3 = TestPerson(bsn: "999991383", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 3 pfizer
	static let posPcrJ1 = TestPerson(bsn: "999991395", dose: 1, doseIntl: ["1/1"], vacFrom: -2, vacUntil: 210, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 1 janssen
	static let posPcrJ2 = TestPerson(bsn: "999991401", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 2 janssen
	static let posPcrJ3 = TestPerson(bsn: "999991413", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 3 janssen
	static let posPcrP1J1 = TestPerson(bsn: "999991425", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 1 pfizer + 1 janssen
	static let posPcrP2J1 = TestPerson(bsn: "999991437", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 2 pfizer + 1 janssen
	static let posPcrP1M1 = TestPerson(bsn: "999991449", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -60, vacUntil: 210, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 1 pfizer + 1 moderna
	static let posPcrP2M1 = TestPerson(bsn: "999991450", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive PCR (NAAT) + 2 pfizer + 1 moderna
	static let posRat = TestPerson(bsn: "999991310", recUntil: 150) // Positive Sneltest (RAT)
	static let posRatP1 = TestPerson(bsn: "999991462", doseIntl: ["1/2"], vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 1 pfizer
	static let posRatP2 = TestPerson(bsn: "999991474", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 150, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 2 pfizer
	static let posRatP3 = TestPerson(bsn: "999991486", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 3 pfizer
	static let posRatJ1 = TestPerson(bsn: "999991498", dose: 1, doseIntl: ["1/1"], vacFrom: -2, vacUntil: 150, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 1 janssen
	static let posRatJ2 = TestPerson(bsn: "999991504", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 2 janssen
	static let posRatJ3 = TestPerson(bsn: "999991516", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 3 janssen
	static let posRatP1J1 = TestPerson(bsn: "999991553", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 1 pfizer + 1 janssen
	static let posRatP2J1 = TestPerson(bsn: "999991565", dose: 3, doseIntl: ["1/1", "2/1", "3/1"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 2 pfizer + 1 janssen
	static let posRatP1M1 = TestPerson(bsn: "999991577", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -60, vacUntil: 210, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 1 pfizer + 1 moderna
	static let posRatP2M1 = TestPerson(bsn: "999991589", dose: 3, doseIntl: ["1/2", "2/2", "3/3"], vacFrom: -60, vacOffset: -60, recUntil: 150) // Positive Sneltest (RAT) + 2 pfizer + 1 moderna
	static let posBreathalyzer = TestPerson(bsn: "999991322") // Positive Breathalyzer
	static let posBreathalyzerP1 = TestPerson(bsn: "999991590", doseIntl: ["1/2"], vacOffset: -60) // Positive Breathalyzer + 1 pfizer
	static let posAgob = TestPerson(bsn: "999991334", recUntil: 150) // Positive AGOB
	static let posAgobP1 = TestPerson(bsn: "999991747", doseIntl: ["1/2"], vacOffset: -60, recUntil: 150) // Positive AGOB + 1 pfizer
	static let posAgobP2 = TestPerson(bsn: "999991759", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -16, vacUntil: 210, vacOffset: -60, recUntil: 150) // Positive AGOB + 2 pfizer
	
	// Positive tests before vaccinations
	static let posPcrBeforeP1 = TestPerson(bsn: "999993495", dose: 1, doseIntl: ["1/1"], vacFrom: -30, vacUntil: 240, recUntil: 120) // Positive PCR (NAAT) before 1 pfizer
	static let posPcrBeforeP2 = TestPerson(bsn: "999993203", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30, recUntil: 90) // Positive PCR (NAAT) before 2 pfizer
	static let posPcrBeforeJ1 = TestPerson(bsn: "999993215", dose: 1, doseIntl: ["1/1"], vacFrom: -30, vacUntil: 240, recUntil: 120) // Positive PCR (NAAT) before 1 janssen
	static let posPcrBeforeM2 = TestPerson(bsn: "999993227", dose: 2, doseIntl: ["1/1", "2/1"], vacFrom: -30, recUntil: 90) // Positive PCR (NAAT) before 2 moderna
	static let posRatBeforeP1 = TestPerson(bsn: "999993045", dose: 1, doseIntl: ["1/1"], vacFrom: -30, vacUntil: 240, recUntil: 120) // Positive Sneltest (RAT) before 1 pfizer
	
	// Positive tests - older than a year
	static let posOldPcr = TestPerson(bsn: "999991851") // Positive PCR (NAAT) old
	static let posOldRat = TestPerson(bsn: "999991863") // Positive Sneltest (RAT) old
	static let posOldAgob = TestPerson(bsn: "999991887") // Positive AGOB old
	
	// Positive tests - premature
	static let posPrematurePcr = TestPerson(bsn: "999991905", recFrom: 41, recUntil: 210) // Positive PCR (NAAT) premature
	static let posPrematureRat = TestPerson(bsn: "999991917", recFrom: 41, recUntil: 210) // Positive Sneltest (RAT) premature
	static let posPrematureAgob = TestPerson(bsn: "999991930", recFrom: 41, recUntil: 210) // Positive AGOB premature
	
	// Positive tests - event matching
	static let posPcrDifferentFirstName = TestPerson(bsn: "999991942", recUntil: 150) // Positive PCR (NAAT) different first name
	static let posPcrDifferentLastName = TestPerson(bsn: "999991954", recUntil: 150) // Positive PCR (NAAT) different last name
	static let posPcrDifferentBirthdate = TestPerson(bsn: "999991966", recUntil: 150) // Positive PCR (NAAT) different birthdate
	static let posPcrDifferentBirthDay = TestPerson(bsn: "999991978", recUntil: 150) // Positive PCR (NAAT) different birth day
	static let posPcrDifferentBirthMonth = TestPerson(bsn: "999991991", recUntil: 150) // Positive PCR (NAAT) different birth month
	
	// Positive tests - multiples
	static let posPcr2Recent = TestPerson(bsn: "999993689", recUntil: 120) // Positive PCR (NAAT) both new
	static let posPcr2Old = TestPerson(bsn: "999993690", recUntil: 150) // Positive PCR (NAAT) new and old
	
	// Negative tests (and combinations)
	static let negPcr = TestPerson(bsn: "999992004") // Negative PCR (NAAT)
	static let negPcrP1 = TestPerson(bsn: "999992065", doseIntl: ["1/2"], vacOffset: -60) // Negative PCR (NAAT) + 1 pfizer
	static let negRat = TestPerson(bsn: "999992016") // Negative Sneltest (RAT)
	static let negRatP1 = TestPerson(bsn: "999992168", doseIntl: ["1/2"], vacOffset: -60) // Negative Sneltest (RAT) + 1 pfizer
	static let negAgob = TestPerson(bsn: "999992041") // Negative AGOB
	static let negAgobP1 = TestPerson(bsn: "999992429", doseIntl: ["1/2"], vacOffset: -60) // Negative AGOB + 1 pfizer
	static let negPcrSupervisedSelftest = TestPerson(bsn: "999993057") // Negative PCR (NAAT) supervised selftest
	static let negRatSupervisedSelftest = TestPerson(bsn: "999993239") // Negative Sneltest (RAT) supervised selftest
	
	// Negative tests - 30 days old
	static let negOldPcr = TestPerson(bsn: "999992545") // Negative PCR (NAAT) old
	static let negOldRat = TestPerson(bsn: "999992557") // Negative Sneltest (RAT) old
	static let negOldAgob = TestPerson(bsn: "999992570") // Negative AGOB old
	
	// Negative tests - premature
	static let negPrematurePcr = TestPerson(bsn: "999992582", testFrom: 30) // Negative PCR (NAAT) premature
	static let negPrematureRat = TestPerson(bsn: "999992594", testFrom: 30) // Negative Sneltest (RAT) premature
	static let negPrematureAgob = TestPerson(bsn: "999992612", testFrom: 30) // Negative AGOB premature
	
	// Negative tests - event matching
	static let negPcrDifferentFirstName = TestPerson(bsn: "999992624") // Negative PCR (NAAT) different first name
	static let negPcrDifferentLastName = TestPerson(bsn: "999992636") // Negative PCR (NAAT) different last name
	static let negPcrDifferentBirthdate = TestPerson(bsn: "999992648") // Negative PCR (NAAT) different birthdate
	static let negPcrDifferentBirthDay = TestPerson(bsn: "999992661") // Negative PCR (NAAT) different birth day
	static let negPcrDifferentBirthMonth = TestPerson(bsn: "999992685") // Negative PCR (NAAT) different birth month
	
	// Encoding
	static let encodingLatin = TestPerson(bsn: "999992697", name: "Geer, Corrie", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Latin
	static let encodingLatinDiacritic = TestPerson(bsn: "999992703", name: "T.Śar ŃĆ ĹāÑ ŤÙmön ĊéŴÀŅŇĩ Ļl'ÁÚŘŠĎÉ Pomme-d' Or ĽÒÓĢÛŨ, Ŗî Ãō Øū Ŋÿ Ği ŢžŰŲ ŜŞőĠĪ Ŷŵ Ĉŷ", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Latin diacritic
	static let encodingArabic = TestPerson(bsn: "999992715", name: "⁨بوير, بوب⁩", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Arabic
	static let encodingHebrew = TestPerson(bsn: "999992727", name: "⁨בורד, בוב⁩", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Hebrew
	static let encodingChinese = TestPerson(bsn: "999992739", name: "吹牛, 鲍勃", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Chinese
	static let encodingGreek = TestPerson(bsn: "999992740", name: "οικοδόμος, Ἄκαστος", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Greek
	static let encodingCyrillic = TestPerson(bsn: "999992752", name: "строитель, бобов", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Cyrillic
	static let encodingEmoji = TestPerson(bsn: "999992764", name: "😀😃, ↗↩↩↫↹🔙⇥⇌", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Emoji
	static let encodingLongStrings = TestPerson(bsn: "999992788", name: "rjnmngevcjgsnicomdzzzguszmfcelknwscoirscjhyfauwsffyhwlaiqfnoctcjbsihyzvxehksjoehzrkadocswofathihsbwuhvrxetuswcybwrkkcofkybgjbdyn rjnmngevcjgsnicomdzzzguszmfcelknwscoirscjhyfauwsffyhwlaiqfnoctcjbsihyzvxehksjoehzrkadocswofathihsbwuhvrxetuswcybwrkkcofkybgjbdyn, rjnmngevcjgsnicomdzzzguszmfcelknwscoirscjhyfauwsffyhwlaiqfnoctcjbsihyzvxehksjoehzrkadocswofathihsbwuhvrxetuswcybwrkkcofkybgjbdyn", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // More than 128 characters in all fields
	static let encodingLongNames = TestPerson(bsn: "999992806", name: "qhxosdaetanrazewwepgqghihpxaruqkpwhkctspdtjeky, qhxosdaetanrazewwepgqghihpxaruqkpwhkctspdtjeky", dose: 2, doseIntl: ["1/2", "2/2"], vacUntil: 240, recUntil: 90) // Long first name and last name (96 chars)
	
	// Miscellaneous
	static let miscP1Positive = TestPerson(bsn: "999992971", dose: 1, doseIntl: ["1/2"], vacFrom: -16, vacUntil: 240, recUntil: 150) // positive test after 1 pfizer
	static let miscP2PosPcrNegPcr = TestPerson(bsn: "999991772", dose: 2, doseIntl: ["1/2", "2/2"], vacFrom: -90, vacUntil: 180, vacOffset: -90, recUntil: 150) // 2 pfizer + positive/negative PCR (NAAT)
}

extension TestData {
	
	static let validVac2of2NL = TestPerson(doseIntl: ["2/2"], vacDate: "2021-12-01", dcc: "SEMxOk5DRkMyMDQ5MFQ5V1RXR1ZMS1M3OSAxVllMVFhaTThBVlgqNEZCQlU0Mio3MEorOUROMDNFNTRGMy9ZMUxPQ1k1MC5GSzhaS08vRVpLRVo5NjdMNkM1NkdWQypKQzFBNkMlNjNXNVk5Njc0NlRQQ0JFQzdaS1cuQ0M5RENFQ1MzNCQgQ1hLRVcuQ0FXRVYrQTMrOUswOUdZOCBKQzIvRFNOODNMRVFFRE1QQ0cvRFktQ0IxQTVJQVZZODc6RURPTDlXRVFERCtRNlRXNkZBN0M0NjZLQ045RSU5NjFBNkRMNkZBN0Q0Ni5KQ1A5RUpZOEwvNU0vNTU0Ni45NlZGNi5KQ0JFQ0IxQS06OCQ5NjY0NjlMNk9GNlZYNkZWQ1BEMEtRRVBEMExWQzZKRDg0Nlk5Nio5NjNXNS5BNlVQQ0JKQ09UOStFREw4RkhaOTUvRCBRRUFMRU40NDorQyU2OUFFQ0FXRTozNDogQ0ouQ1pLRTk0NDAvRCszNFM5RTVMRVdKQzBGRDMlNEFJQSVHN1pNODFHNzJBNkorOVNHNzdOOTFSNkUrOUxDQk1JQlFDQVlNOFVJQjUxQTlZOUFGNldBNkk0ODE3UzZaS0gvQzMqRiokR1I0TjIrNUY4Rk0gQiRXNktVOTFBOVdUTzhTMVFLODdEQkJNSERLRlQqVU1OQ0kzViRMUy5RRldNRjE4VzZUSDUkOVcrNFFaTFU3MS41REI3MzAwMEZHV1UvMENSRg==", couplingCode: "ZKGBKH")
	
	static let expiredVac1of2DE = TestPerson(doseIntl: ["1/2"], vacDate: "2022-02-11", dcc: "SEMxOk5DRkYyMDE5MFQ5V1RXR1ZMSy00OU5KM0IwSiRPQ0MqQVgqNEZCQlhMMio3MEhTOEZOMENLQ1RIVFdZMENLQ1RNU0Q5N1RLMEY5MCRQQzUkQ1VaQyQkNVkkNUpQQ1QzRTVKRExBNzM0Njc0NjNXNS9BNi4uRFglRFpKQzQvREsvRU0tRDcxOTUkQ0xQQ0cvRFA4RE5COC1SNzNZOFVJQUkzRFktQzA0RSpLRVogQ0kzRDhXRS1NOEVJQSRCOUtFQ1RIRzRLQ0QzRFg0N0I0NklMNjY0NkgqNlovRTVKRCU5NklBNzRSNjY0NjMwN1EkRC5VRFJZQSA5Nk5GNkwvNVNXNlk1N0IkRCUgRDNJQTRXNTY0Njk0Njg0Ni45NlhKQyArRDNLQy5TQ1hKQ0NXRU5GNlBGNjNXNUtGNiU5NldKQ1QzRUorOSVKQytRRU5RNFpFRCtFREtXRTNFRlgzRVQzNFggQzpWREc3RDgyQlVWREdFQ0RaQ0NFQ1JUQ1VPQTA0RTRXRU9QQ044RkhaQTErOTJaQVFCOTc0NlZHN1RTOTdaQSpDQjJYNkdHNks3QkcwOVJJQjcxQklHNkVZOC5RNjBMNDI3Qk01Sjg4Q0VaVjVOQVUqM0NSSFRWSTIxVE9OOEtPSy5VSzREMyQ5UTQrTEpCTUxEUkkqQkowUURXRTlKSlpFVi1RMTUrRjhRNDAlQS9POE8wVjBHOVZBQUQvRldTQ0I6VVY1MFU1MFpGV0Q1R0wyCg==")
	
	static let validVac1of2DE = TestPerson(doseIntl: ["1/2"], vacDate: "2022-02-11", dcc: "SEMxOk5DRkMyMDQ5MFQ5V1RXR1ZMSy00OU5KM0IwSiRPQ0MqQVgqNEZCQlU0Mio3MEhTOEROMDNFNTRGM0paRkNXNVk1MC5GSzhaS08vRVpLRVo5NjdMNkM1NkdWQypKQzFBNkMlNjNXNVk5Njc0NlRQQ0JFQzdaS1cuQ0M5RENFQ1MzNCQgQ1hLRVcuQ0FXRVYrQTMrOUswOUdZOCBKQzIvRFNOODNMRVFFRE1QQ0cvRFktQ0IxQTVJQVZZODc6RURPTDlXRVFERCtRNlRXNkZBN0M0NjZLQ045RSU5NjFBNkRMNkZBN0Q0Ni5KQ1A5RUpZOEwvNU0vNTU0Ni45NlZGNi5KQ0JFQ0IxQS06OCQ5NjY0NjlMNk9GNlZYNkZWQyo3MEtRRVBEMExWQzZKRDg0NktGNjg0NjRXNS5BNlVQQ0JKQ09UOStFREw4RkhaOTUvRCBRRUFMRU40NDorQyU2OUFFQ0FXRTozNDogQ0ouQ1pLRTk0NDAvRCszNFM5RTVMRVdKQzBGRDMlNEFJQSVHN1pNODFHNzJBNkorOS9HNzRaQUNDOU4rOTIxQkMrOUcqOExCOTdPQTNPQUVNOEFGNlhCOFI5ODVCRE1ZMExLSipXS0NTQzVWM0hPODJSMEFHMSAlVS80RkhUVS8xN1IzQzYuODgyTy81Vlg4SzhNNFk4VDowNS80SzlPUDNETUZYRio5VlA4QlE4TDA2Qlg0RENQMDVJMjAwMEZHV0kwUENRRgo=")
	
	static let expiredVac2of2DE = TestPerson(doseIntl: ["2/2"], vacDate: "2022-03-13", dcc: "SEMxOk5DRkYyMDE5MFQ5V1RXR1ZMSy00OU5KM0IwSiRPQ0MqQVgqNEZCQlhMMio3MEhTOEZOMENLQ1RIVFdZMENLQ1RNU0Q5N1RLMEY5MCRQQzUkQ1VaQyQkNVkkNUpQQ1QzRTVKRExBNzM0Njc0NjNXNS9BNi4uRFglRFpKQzQvREsvRU0tRDcxOTUkQ0xQQ0cvRFA4RE5COC1SNzNZOFVJQUkzRFktQzA0RSpLRVogQ0kzRDhXRS1NOEVJQSRCOUtFQ1RIRzRLQ0QzRFg0N0I0NklMNjY0NkgqNlovRTVKRCU5NklBNzRSNjY0NjMwN1EkRC5VRFJZQSA5Nk5GNkwvNVNXNlk1N0IkRCUgRDNJQTRXNTY0Njk0Njg0Ni45NlhKQyQrRDNLQy5TQ1hKQ0NXRU5GNlBGNjNXNTZMNis5NldKQ1QzRUorOSVKQytRRU5RNFpFRCtFREtXRTNFRlgzRVQzNFggQzpWREc3RDgyQlVWREdFQ0RaQ0NFQ1JUQ1VPQTA0RTRXRU9QQ044RkhaQTErOTJaQVFCOTc0NlZHN1RTOUhaQUNMNiVDQjNEQlhSNjYwOUI2OUdSNiQrQUEtQS5RNjdLNDI3QjVQSyRDTE4uQzAqVjZBTFE6RTJHRUokQ1c3TzYvQS1PSVY2MFhOR1RCNTYvM01FTE4zQ0YyRDlIU0dHOFJDVy1NRDEgOEg5M0o1NlctNEsxVSRUSzZGQ0oxRDpMOSBDTFY1MFU1MCVFV05RMkgzCg==")
	
	static let validVac2of2DE = TestPerson(doseIntl: ["2/2"], vacDate: "2022-03-13", dcc: "SEMxOk5DRkMyMDQ5MFQ5V1RXR1ZMSy00OU5KM0IwSiRPQ0MqQVgqNEZCQlU0Mio3MEhTOEROMDNFNTRGM0paRkNXNVk1MC5GSzhaS08vRVpLRVo5NjdMNkM1NkdWQypKQzFBNkMlNjNXNVk5Njc0NlRQQ0JFQzdaS1cuQ0M5RENFQ1MzNCQgQ1hLRVcuQ0FXRVYrQTMrOUswOUdZOCBKQzIvRFNOODNMRVFFRE1QQ0cvRFktQ0IxQTVJQVZZODc6RURPTDlXRVFERCtRNlRXNkZBN0M0NjZLQ045RSU5NjFBNkRMNkZBN0Q0Ni5KQ1A5RUpZOEwvNU0vNTU0Ni45NlZGNi5KQ0JFQ0IxQS06OCQ5NjY0NjlMNk9GNlZYNkZWQ1BEMEtRRVBEMExWQzZKRDg0NktGNjk0NjRXNUVNNlVQQ0JKQ09UOStFREw4RkhaOTUvRCBRRUFMRU40NDorQyU2OUFFQ0FXRTozNDogQ0ouQ1pLRTk0NDAvRCszNFM5RTVMRVdKQzBGRDMlNEFJQSVHN1pNODFHNzJBNkorOU5HN0pOOSQwOTpBODlJQlJJQk1DQkhNOFBUQVVZOUclNkFGNldBNjQ4OEUgVVFVVTYySEs2RlogVi8vNksgVDAzMy1TVEtETSUrTU5IS1crOE06NENaUCRVRFIrRjZBSzo2UjUyMFNBUkdMSFAvMk1URzkgOEJGMEFCMDEtVitCMjM2UFI3MjBVMzAwMEZHV1YrNU0kRgo=")
	
	static let expiredVac3of3DE = TestPerson(doseIntl: ["3/3"], vacDate: "2022-04-12", dcc: "SEMxOk5DRkYyMDE5MFQ5V1RXR1ZMSy00OU5KM0IwSiRPQ0MqQVgqNEZCQlhMMio3MEhTOEZOMENLQ1RIVFdZMENLQ1RNU0Q5N1RLMEY5MCRQQzUkQ1VaQyQkNVkkNUpQQ1QzRTVKRExBNzM0Njc0NjNXNS9BNi4uRFglRFpKQzQvREsvRU0tRDcxOTUkQ0xQQ0cvRFA4RE5COC1SNzNZOFVJQUkzRFktQzA0RSpLRVogQ0kzRDhXRS1NOEVJQSRCOUtFQ1RIRzRLQ0QzRFg0N0I0NklMNjY0NkgqNlovRTVKRCU5NklBNzRSNjY0NjMwN1EkRC5VRFJZQSA5Nk5GNkwvNVNXNlk1N0IkRCUgRDNJQTRXNTY0Njk0Njg0Ni45NlhKQyUrRDNLQy9TQ1hKQ0NXRU5GNlBGNjNXNSRRNio5NldKQ1QzRUorOSVKQytRRU5RNFpFRCtFREtXRTNFRlgzRVQzNFggQzpWREc3RDgyQlVWREdFQ0RaQ0NFQ1JUQ1VPQTA0RTRXRU9QQ044RkhaQTErOTJaQVFCOTc0NlZHN1RTOSA2QTNJQVlIOUgrOVE2QTMrODhJQUtaQTdUOUZCOC5RNklLNDI3QjkyUEg5NzVFMzVTT1A4V0cvQVcgT0RGUTE1VUE6R1JEVjhSSVQ4MUMyQy5KRU5EOVI2NzhTVVgtUTA5UDVOOUQ2TFlZSE5UUCBIN1AvNk1TR1k4UjorSUxMOVVESU0lSFY1MFU1ME5FV1JJVkcyCg==")
	
	static let validVac3of3DE = TestPerson(doseIntl: ["3/3"], vacDate: "2022-04-12", dcc: "SEMxOk5DRkMyMDQ5MFQ5V1RXR1ZMSy00OU5KM0IwSiRPQ0MqQVgqNEZCQlU0Mio3MEhTOEROMDNFNTRGM0paRkNXNVk1MC5GSzhaS08vRVpLRVo5NjdMNkM1NkdWQypKQzFBNkMlNjNXNVk5Njc0NlRQQ0JFQzdaS1cuQ0M5RENFQ1MzNCQgQ1hLRVcuQ0FXRVYrQTMrOUswOUdZOCBKQzIvRFNOODNMRVFFRE1QQ0cvRFktQ0IxQTVJQVZZODc6RURPTDlXRVFERCtRNlRXNkZBN0M0NjZLQ045RSU5NjFBNkRMNkZBN0Q0Ni5KQ1A5RUpZOEwvNU0vNTU0Ni45NlZGNi5KQ0JFQ0IxQS06OCQ5NjY0NjlMNk9GNlZYNkZWQ0JKMEtRRUJKMExWQzZKRDg0NktGNkE0NjRXNVNHNlVQQ0JKQ09UOStFREw4RkhaOTUvRCBRRUFMRU40NDorQyU2OUFFQ0FXRTozNDogQ0ouQ1pLRTk0NDAvRCszNFM5RTVMRVdKQzBGRDMlNEFJQSVHN1pNODFHNzJBNkorOTZHNzROOC8lNlhNOC5CQU9IOTlIOCtIOTZUOVpOQVRIQUFGNkNEQjA1OFhGQUpRTEFZSiBIRCUxVjU2UDFUUFA4OTYgUEIqQTdSUE40QlJXQk1QTjFRQTlOQjc6VjItTVNLRjggQ0hUSVFQRkJKRjdPUC03TU42SC9KQ1k4QiQlSlpOUENRM1Q1QjAwMEZHV0lRVkhURgo=")
}
