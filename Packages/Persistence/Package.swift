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
		// Internal:
		.package(name: "Shared", path: "../Shared")
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Persistence",
			dependencies: [
				.product(name: "Shared", package: "Shared")
			]
		)
	]
)
