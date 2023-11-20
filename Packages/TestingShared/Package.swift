// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "TestingShared",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "TestingShared",
			targets: ["TestingShared"]),
	],
	dependencies: [
		// Internal:
		.package(name: "Shared", path: "../Shared"),
		
		// External:
		.package(url: "https://github.com/pointfreeco/swift-snapshot-testing", exact: "1.15.0"),
		.package(url: "https://github.com/Quick/Nimble", exact: "10.0.0")
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "TestingShared",
			dependencies: [
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
				.product(name: "Nimble", package: "Nimble")
			])
	]
)
