// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "alarmplayer",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "alarmplayer", targets: ["alarmplayer"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "alarmplayer",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            cSettings: [
                .headerSearchPath("include/alarmplayer")
            ]
        )
    ]
)
