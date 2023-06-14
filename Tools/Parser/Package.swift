// swift-tools-version:5.2
import PackageDescription

let package = Package(
  name: "Simple",
    products: [
        .executable(
            name: "Simple",
            targets: ["Simple"]),
    ],
    dependencies: [
      .package(name: "CSV", url: "https://github.com/yaslab/CSV.swift.git", .upToNextMinor(from: "2.4.3"))
    ],
    targets: [
        .target(
            name: "Simple",
            dependencies: ["CSV"],
            path: ".")
    ]
)
