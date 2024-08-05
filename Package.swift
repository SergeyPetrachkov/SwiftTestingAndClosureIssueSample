// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftTestingAndClosureIssueSample",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(
            name: "SwiftTestingAndClosureIssueSample",
            targets: ["SwiftTestingAndClosureIssueSample"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftTestingAndClosureIssueSample",
            swiftSettings: [.swiftLanguageVersion(.v6)]
        ),
        .testTarget(
            name: "SwiftTestingAndClosureIssueSampleTests",
            dependencies: ["SwiftTestingAndClosureIssueSample"]
        ),
    ]
)
