// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "Resources",
	defaultLocalization: "nl",
	products: [
		// Products define the executables and libraries a package produces, and make them visible to other packages.
		.library(
			name: "Resources",
			targets: ["Resources"]),
	],
	dependencies: [
		// Internal:
		.package(name: "Shared", path: "../Shared"),
		
		// External:
		.package(url: "https://github.com/mac-cain13/R.swift.git", from: "7.4.0")
	],
	targets: [
		// Targets are the basic building blocks of a package. A target can define a module or a test suite.
		// Targets can depend on other targets in this package, and on products in packages this package depends on.
		.target(
			name: "Resources",
			dependencies: [
				.product(name: "Shared", package: "Shared"),
				.product(name: "RswiftLibrary", package: "R.swift")
			],
			resources: 	[
				.copy("Resources/Animations"),
				.process("Fonts")
			],
			plugins: [.plugin(name: "RswiftGeneratePublicResources", package: "R.swift")]
		)
	]
)
