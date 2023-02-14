// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Models",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Models",
			targets: ["Models"]),
	],
	dependencies: [
		.package(name: "CryptoCore", path: "../CryptoCore"),
		.package(name: "Shared", path: "../Shared"),
		
		.package(url: "https://github.com/minvws/nl-rdo-app-ios-modules", branch: "main"),
		
		// Testing:
		.package(name: "TestingShared", path: "../TestingShared"),
		.package(url: "https://github.com/Quick/Nimble", from: .init(10, 0, 0)),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Models",
			dependencies: [
				.product(name: "CryptoCore", package: "CryptoCore"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "LuhnCheck", package: "nl-rdo-app-ios-modules"),
			]),
		.testTarget(
			name: "ModelsTests",
			dependencies: [
				"Models",
				.product(name: "TestingShared", package: "TestingShared"),
				.product(name: "Nimble", package: "Nimble"),
			]),
	]
)
