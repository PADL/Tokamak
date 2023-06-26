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
      name: "TokamakGTK",
      targets: ["TokamakGTK"]
    ),
    .executable(
      name: "TokamakGTKDemo",
      targets: ["TokamakGTKDemo"]
    ),
    .library(
      name: "TokamakShim",
      targets: ["TokamakShim"]
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
        .target(name: "TokamakGTK", condition: .when(platforms: [.linux])),
      ]
    ),
    .systemLibrary(
      name: "CGTK",
      pkgConfig: "gtk+-3.0",
      providers: [
        .apt(["libgtk+-3.0", "gtk+-3.0"]),
        // .yum(["gtk3-devel"]),
        .brew(["gtk+3"]),
      ]
    ),
    .systemLibrary(
      name: "CGDK",
      pkgConfig: "gdk-3.0",
      providers: [
        .apt(["libgtk+-3.0", "gtk+-3.0"]),
        // .yum(["gtk3-devel"]),
        .brew(["gtk+3"]),
      ]
    ),
    .target(
      name: "TokamakGTKCHelpers",
      dependencies: ["CGTK"]
    ),
    .target(
      name: "TokamakGTK",
      dependencies: [
        "TokamakCore", "CGTK", "CGDK", "TokamakGTKCHelpers",
        .product(
          name: "OpenCombineShim",
          package: "OpenCombine"
        ),
      ],
      cSettings: [.unsafeFlags(["-I/usr/include/gtk-3.0"])]
    ),
    .executableTarget(
      name: "TokamakGTKDemo",
      dependencies: ["TokamakGTK"],
      resources: [.copy("logo-header.png")]
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
      name: "TokamakLayoutTests",
      dependencies: [
        "TokamakCore",
        .product(
          name: "SnapshotTesting",
          package: "swift-snapshot-testing",
          condition: .when(platforms: [.macOS])
        ),
      ]
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
  ]
)
