// swift-tools-version:5.6

import PackageDescription

let package = Package(
  name: "Tokamak",
  platforms: [
    .macOS(.v11),
    .iOS(.v13),
  ],
  products: [
    // Products define the executables and libraries produced by a package,
    // and make them visible to other packages.
    .library(
      name: "TokamakLVGL",
      targets: ["TokamakLVGL"]
    ),
    .library(
      name: "TokamakShim",
      targets: ["TokamakShim"]
    ),
    .executable(
      name: "TokamakLVGLDemo",
      targets: ["TokamakLVGLDemo"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/swiftwasm/JavaScriptKit.git",
      from: "0.15.0"
    ),
    .package(
      url: "https://github.com/OpenCombine/OpenCombine.git",
      from: "0.12.0"
    ),
    .package(
      url: "https://github.com/swiftwasm/OpenCombineJS.git",
      from: "0.2.0"
    ),
    .package(
      url: "https://github.com/google/swift-benchmark",
      from: "0.1.2"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
      from: "1.9.0"
    ),
    .package(
      url: "https://github.com/PADL/LVGLSwift.git",
      branch: "main"
    ),
  ],
  targets: [
    // Targets are the basic building blocks of a package. A target can define
    // a module or a test suite.
    // Targets can depend on other targets in this package, and on products
    // in packages which this package depends on.
    .target(
      name: "TokamakCore",
      dependencies: [
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
      ]
    ),
    .target(
      name: "TokamakShim",
      dependencies: [
        .target(name: "TokamakLVGL", condition: .when(platforms: [.linux])),
      ]
    ),
    .target(
      name: "TokamakLVGL",
      dependencies: [
        "TokamakCore",
        .product(
          name: "LVGL",
          package: "LVGLSwift"
        ),
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
      ]
    ),
    .executableTarget(
      name: "TokamakCoreBenchmark",
      dependencies: [
        .product(name: "Benchmark", package: "swift-benchmark"),
        "TokamakCore",
        "TokamakTestRenderer",
      ]
    ),
    .target(
      name: "TokamakTestRenderer",
      dependencies: ["TokamakCore"]
    ),
    .testTarget(
      name: "TokamakReconcilerTests",
      dependencies: [
        "TokamakCore",
        "TokamakTestRenderer",
      ]
    ),
    .testTarget(
      name: "TokamakTests",
      dependencies: ["TokamakTestRenderer"]
    ),
    .executableTarget(
      name: "TokamakLVGLDemo",
      dependencies: ["TokamakLVGL"],
      resources: [.copy("logo-header.png")]
    ),
  ]
)
