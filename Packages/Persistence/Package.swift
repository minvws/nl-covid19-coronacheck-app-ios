// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Persistence",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Persistence",
			targets: ["Persistence"]),
	],
	dependencies: [
		// Dependencies declare other packages that this package depends on.
		// .package(url: /* package url */, from: "1.0.0"),
		.package(name: "Shared", path: "../Shared"),
		
		// testing:
		.package(name: "TestingShared", path: "../TestingShared"),
		.package(url: "https://github.com/Quick/Nimble", from: .init(10, 0, 0))
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Persistence",
			dependencies: [
				.product(name: "Shared", package: "Shared"),
			],
			resources: [
				.copy("Schemas/CoronaCheck.xcdatamodeld"),
				.copy("Schemas/Verifier.xcdatamodeld"),
			]
		),
		.testTarget(
			name: "PersistenceTests",
			dependencies: [
				"Persistence",
				.product(name: "TestingShared", package: "TestingShared"),
				.product(name: "Nimble", package: "Nimble"),
			]),
	]
)
