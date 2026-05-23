// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "KokoroSwift",
  platforms: [
    .iOS(.v18), .macOS(.v15)
  ],
  products: [
    // Switched from upstream's `type: .dynamic` to a default
    // (static) library. Dynamic frameworks need an explicit
    // "Embed & Sign" build phase in the consumer's Xcode project;
    // wiring that through `project.pbxproj` from the Aria side
    // is fragile, and the static path means symbols link straight
    // into the Avyra binary — no runtime dyld resolution, no
    // missing-framework errors. Trade: a few MB larger app
    // binary, which is irrelevant next to the 327MB model file.
    // Local-only diff.
    .library(
      name: "KokoroSwift",
      targets: ["KokoroSwift"]
    ),
  ],
  dependencies: [
    // Pin relaxed from upstream's `.exact("0.30.2")` so KokoroSwift
    // resolves alongside Aria's `mlx-swift-lm`, which transitively
    // requires mlx-swift 0.31.x. KokoroSwift only touches the
    // MLX / MLXNN / MLXRandom / MLXFFT surfaces; those haven't
    // shifted across 0.30 → 0.31. Revisit if MLX 0.32 lands with a
    // breaking change. Local-only diff vs upstream.
    .package(url: "https://github.com/ml-explore/mlx-swift", "0.30.0"..<"1.0.0"),
    // .package(url: "https://github.com/mlalma/eSpeakNGSwift", from: "1.0.1"),
    // 3theories fork of MisakiSwift carries the same `Package.swift`
    // patches as this one (relaxed mlx-swift pin + flattened
    // resources). Reference by URL with `branch: main` rather than
    // a tag so both forks evolve together; a future Aria can pin
    // to a SHA if reproducibility matters. The earlier
    // `.package(path: "../MisakiSwift")` form only resolved inside
    // Aria's repo layout — when KokoroSwift is consumed via its
    // git URL there's no sibling MisakiSwift checkout.
    .package(url: "https://github.com/3theories/MisakiSwift.git", from: "0.0.1"),
    .package(url: "https://github.com/mlalma/MLXUtilsLibrary.git", "0.0.6"..<"1.0.0")
  ],
  targets: [
    .target(
      name: "KokoroSwift",
      dependencies: [
        .product(name: "MLX", package: "mlx-swift"),
        .product(name: "MLXNN", package: "mlx-swift"),
        .product(name: "MLXRandom", package: "mlx-swift"),
        .product(name: "MLXFFT", package: "mlx-swift"),
        // .product(name: "eSpeakNGLib", package: "eSpeakNGSwift"),
        .product(name: "MisakiSwift", package: "MisakiSwift"),
        .product(name: "MLXUtilsLibrary", package: "MLXUtilsLibrary")
      ],
      // `.process` instead of upstream's `.copy("../../Resources/")`.
      // `.copy` preserves the `Resources/` subdirectory inside the
      // produced bundle (`KokoroSwift_KokoroSwift.bundle/Resources/
      // config.json`) — a macOS-style layout that the iOS codesign
      // tool rejects with "bundle format unrecognized, invalid, or
      // unsuitable." `.process` flattens the file to the bundle
      // root (`KokoroSwift_KokoroSwift.bundle/config.json`), which
      // matches the iOS-flat bundle layout codesign expects.
      // `Bundle.module.url(forResource:withExtension:)` finds the
      // file in either layout, so runtime loading is unaffected.
      // Local-only diff vs upstream.
      resources: [
       .process("../../Resources/config.json")
      ]
    ),
    .testTarget(
      name: "KokoroSwiftTests",
      dependencies: ["KokoroSwift"]
    ),
  ]
)
