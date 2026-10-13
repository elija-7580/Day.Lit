// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Daylit",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "Daylit", targets: ["Daylit"])
    ],
    targets: [
        .executableTarget(
            name: "Daylit",
            path: "Sources/Daylit"
        )
    ]
)
