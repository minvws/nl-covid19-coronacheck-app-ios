// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Managers",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Managers",
			targets: ["Managers"]),
	],
	dependencies: [
		.package(name: "CryptoCore", path: "../CryptoCore"),
		.package(name: "Models", path: "../Models"),
		.package(name: "Persistence", path: "../Persistence"), // TODO: only for FileStorageProtocol, consider moving
		.package(name: "Shared", path: "../Shared"),
		.package(name: "Transport", path: "../Transport"),
		
		.package(url: "https://github.com/securing/IOSSecuritySuite", from: "1.9.5"),
		
		// Testing:
		.package(name: "TestingShared", path: "../TestingShared"),
		.package(url: "https://github.com/Quick/Nimble", from: .init(10, 0, 0)),
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Managers",
			dependencies: [
				.product(name: "CryptoCore", package: "CryptoCore"),
				.product(name: "Models", package: "Models"),
				.product(name: "Persistence", package: "Persistence"),
				.product(name: "Shared", package: "Shared"),
				.product(name: "Transport", package: "Transport"),
				
				.product(name: "IOSSecuritySuite", package: "IOSSecuritySuite"),
			]),
		.testTarget(
			name: "ManagersTests",
			dependencies: [
				"Managers",
				.product(name: "TestingShared", package: "TestingShared"),
				.product(name: "Nimble", package: "Nimble"),
			]),
	]
)
