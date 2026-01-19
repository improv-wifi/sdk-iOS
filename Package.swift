// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Improv-iOS",
    platforms: [.iOS(.v14)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ImproviOS",
            targets: ["Improv-iOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Improv-iOS",
            path: "Improv-iOS"
        ),
        .testTarget(
            name: "Improv-iOSTests",
            dependencies: ["Improv-iOS"],
            path: "Improv-iOSTests"
        ),
    ]
)
